//
//  AudioManager.swift
//  locian
//
//  Text-to-Speech manager for audio drills
//  Supports multiple languages with speed control
//

import Foundation
import AVFoundation
import Combine

// MARK: - Enums
enum AudioSessionMode: Sendable {
    case playback
    case recording
}

enum MicOwner: String {
    case none
    case speech
    case ambient
}

class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var onSpeechCompletion: (() -> Void)?
    private var currentCategory: AVAudioSession.Category?
    private var pcmPlayer: AVAudioPlayer?
    
    // ✅ Serial Queue for Audio Operations
    private let audioQueue = DispatchQueue(label: "com.locian.audio", qos: .userInitiated)
    
    // ✅ Mic Ownership Tracking
    private var currentMicOwner: MicOwner = .none
    private var micOwnerCleanup: (() -> Void)?

    // MARK: - Singleton
    static let shared = AudioManager()
    
    override private init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Centralized Mic Management
    
    func requestMic(owner: MicOwner, onDetach: @escaping () -> Void, completion: @escaping () -> Void) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            print("🎙️ [AudioManager] Mic REQUEST from: \(owner). Current owner: \(self.currentMicOwner)")
            
            // 1. Force previous owner to detach if any
            if self.currentMicOwner != .none && self.currentMicOwner != owner {
                print("⚠️ [AudioManager] EVICTING current owner: \(self.currentMicOwner)")
                let cleanup = self.micOwnerCleanup
                self.micOwnerCleanup = nil
                DispatchQueue.main.async { cleanup?() }
            }
            
            self.currentMicOwner = owner
            self.micOwnerCleanup = onDetach
            
            // 2. Configure for recording
            self.internalConfigureSession(for: .recording) {
                completion()
            }
        }
    }
    
    func releaseMic(owner: MicOwner) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            guard self.currentMicOwner == owner else { return }
            
            print("🎙️ [AudioManager] Mic RELEASE from: \(owner)")
            self.currentMicOwner = .none
            self.micOwnerCleanup = nil
            
            // Revert to playback
            self.internalConfigureSession(for: .playback)
        }
    }
    
    func configureSession(for mode: AudioSessionMode, completion: (() -> Void)? = nil) {
        audioQueue.async { [weak self] in
            self?.internalConfigureSession(for: mode, completion: completion)
        }
    }

    private func internalConfigureSession(for mode: AudioSessionMode, completion: (() -> Void)? = nil) {
        let session = AVAudioSession.sharedInstance()
        let targetCategory: AVAudioSession.Category
        let targetMode: AVAudioSession.Mode
        let targetOptions: AVAudioSession.CategoryOptions
        
        switch mode {
        case .recording:
            targetCategory = .playAndRecord
            targetMode = .spokenAudio
            targetOptions = [.duckOthers, .defaultToSpeaker]
        case .playback:
            targetCategory = .playback
            targetMode = .default
            targetOptions = [.duckOthers]
        }
        
        do {
            try session.setCategory(targetCategory, mode: targetMode, options: targetOptions)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            self.currentCategory = targetCategory
            try? session.overrideOutputAudioPort(.speaker)
            
            DispatchQueue.main.async { completion?() }
        } catch {
            print("🔊 [AudioManager] Session Config Failed: \(error.localizedDescription)")
            DispatchQueue.main.async { completion?() }
        }
    }
    
    // MARK: - Basic Speech & Playback
    
    func speak(text: String, language: String = "en-US", completion: (() -> Void)? = nil) {
        self.stop()
        self.onSpeechCompletion = completion
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.4
        
        synthesizer.speak(utterance)
    }

    func playAudioFile(named name: String, ext: String = "mp3") -> Bool {
        print("🔊 [AudioManager] Playing bundled file: \(name).\(ext)")
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return false }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            DispatchQueue.main.async {
                self.pcmPlayer = player
                self.pcmPlayer?.delegate = self
                self.pcmPlayer?.play()
            }
            return true
        } catch {
            print("❌ [AudioManager] File Playback Failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Private Helpers
    
    func stop() {
        audioQueue.async { [weak self] in
            self?.internalStop()
            self?.onSpeechCompletion = nil
        }
    }

    private func internalStop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        pcmPlayer?.stop()
    }
    
    private func finishPlayback() {
        if let completion = onSpeechCompletion {
            DispatchQueue.main.async {
                completion()
                self.onSpeechCompletion = nil
            }
        }
    }
}

// MARK: - Delegates
extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        audioQueue.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if !self.synthesizer.isSpeaking {
                self.finishPlayback()
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        finishPlayback()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}
