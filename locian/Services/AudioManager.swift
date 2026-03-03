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

// MARK: - Models
struct SpeechSegment: Sendable {
    let text: String
    let language: String
}

class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var onSpeechCompletion: (() -> Void)?
    private var currentCategory: AVAudioSession.Category?
    
    // ✅ Serial Queue for Audio Operations
    private let audioQueue = DispatchQueue(label: "com.locian.audio", qos: .userInitiated)
    
    // MARK: - Singleton
    static let shared = AudioManager()
    
    override private init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Session Management
    
    func configureSession(for mode: AudioSessionMode) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
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
            
            if session.category != targetCategory || session.categoryOptions != targetOptions {
                do {
                    try session.setCategory(targetCategory, mode: targetMode, options: targetOptions)
                    try session.setActive(true, options: .notifyOthersOnDeactivation)
                    self.currentCategory = targetCategory
                } catch {
                    print("🔊 [AudioManager] Session Config Warning for \(mode): \(error.localizedDescription)")
                }
            }
            try? session.overrideOutputAudioPort(.speaker)
        }
    }
    
    // MARK: - THE ONE THING (Unified Multilingual Engine)
    
    /// ✅ ZERO-FLICKER: Queues multiple languages in a single cinematic breath.
    func speak(segments: [SpeechSegment], completion: (() -> Void)? = nil) {
        guard !segments.isEmpty else {
            completion?()
            return
        }
        
        print("🔊 [AudioManager] Multilingual Engine: Queuing \(segments.count) segments.")
        self.onSpeechCompletion = completion
        
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 1. Stop existing
            self.internalStop()
            
            // 2. Configure Session (Inlined for high-sync execution)
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                try session.overrideOutputAudioPort(.speaker)
                self.currentCategory = .playback
            } catch {
                print("🔊 [AudioManager] Unified Session Config Failed: \(error)")
            }
            
            // 3. Hume Routing (Universal Full Context)
            if AppStateManager.shared.isHumeVoiceEnabled {
                 print("🎙️ [AudioManager] Routing to Hume (Global Context)")
                 // Join all text for AI intelligence
                 let fullText = segments.map { $0.text }.joined(separator: " ")
                 HumeTTSService.shared.speak(text: fullText, completion: { [weak self] in
                     self?.finishPlayback()
                 }, onFailure: { [weak self] in
                     print("⚠️ [AudioManager] Hume Failed. Falling back to Local Segments.")
                     self?.audioQueue.async {
                         self?.speakLocalSegments(segments)
                     }
                 })
                 return
            }
            
            // 4. Local High-Sync Reveal
            self.speakLocalSegments(segments)
        }
    }
    
    private func speakLocalSegments(_ segments: [SpeechSegment]) {
        for (index, segment) in segments.enumerated() {
            let u = AVSpeechUtterance(string: segment.text)
            u.voice = AVSpeechSynthesisVoice(language: segment.language)
            
            // Speed control: Increased for clarity as requested
            u.rate = 0.4 // 80% of default speed (0.5 × 0.8 = 0.4) — clear pace for language learning
            
            // Natural pacing between segments
            if index > 0 {
                u.preUtteranceDelay = 0.1 
            }
            
            self.synthesizer.speak(u)
        }
    }
    
    // MARK: - Helpers
    
    func stop() {
        audioQueue.async { [weak self] in
            self?.internalStop()
            self?.finishPlayback()
        }
    }
    
    private func internalStop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        HumeTTSService.shared.stop()
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
        // Debounce check on audio queue
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
