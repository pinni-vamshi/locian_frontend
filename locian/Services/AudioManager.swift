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
    @Published private(set) var isVoiceSpeaking: Bool = false
    private var onSpeechCompletion: (() -> Void)?
    private var currentCategory: AVAudioSession.Category?
    private var pcmPlayer: AVAudioPlayer?
    private var voiceStartedAt: Date?
    
    // ✅ Serial Queue for Audio Operations
    private let audioQueue = DispatchQueue(label: "com.locian.audio", qos: .userInitiated)
    
    // ✅ Mic Ownership Tracking
    private var currentMicOwner: MicOwner = .none
    private var micOwnerCleanup: ((@escaping () -> Void) -> Void)?

    // MARK: - Singleton
    static let shared = AudioManager()
    
    override private init() {
        super.init()
    }
    
    // MARK: - Centralized Mic Management
    
    func requestMic(owner: MicOwner, onDetach: @escaping (@escaping () -> Void) -> Void, completion: @escaping () -> Void) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            print("🎙️ [AudioManager] Mic REQUEST from: \(owner). Current owner: \(self.currentMicOwner)")
            
            let proceed = {
                self.currentMicOwner = owner
                self.micOwnerCleanup = onDetach
                
                // 2. Configure for recording
                self.internalConfigureSession(for: .recording) {
                    completion()
                }
            }
            
            // 1. Force previous owner to detach if any
            if self.currentMicOwner != .none && self.currentMicOwner != owner {
                print("⚠️ [AudioManager] EVICTING current owner: \(self.currentMicOwner)")
                
                if let cleanup = self.micOwnerCleanup {
                    DispatchQueue.main.async { 
                        cleanup {
                            self.audioQueue.async {
                                proceed()
                            }
                        }
                    }
                } else {
                    proceed()
                }
            } else {
                proceed()
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
            
            // ✅ Safety Cooldown: Wait 100ms for Speech Reporter to finalize cloud connection
            // before flipping the session back to playback mode.
            self.audioQueue.asyncAfter(deadline: .now() + 0.1) {
                self.internalConfigureSession(for: .playback)
            }
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
            if mode == .recording {
                // Nudge the session toward a stable, mono input format.
                try? session.setPreferredSampleRate(48_000)
                try? session.setPreferredInputNumberOfChannels(1)
                try? session.setPreferredIOBufferDuration(0.01)
            }
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
    


    func playAudioFile(named name: String, ext: String = "mp3") -> Bool {
        print("🔊 [AudioManager] Playing bundled file: \(name).\(ext)")
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return false }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            DispatchQueue.main.async {
                self.pcmPlayer = player
                self.pcmPlayer?.delegate = self
                self.setVoiceSpeaking(true)
                self.pcmPlayer?.play()
            }
            return true
        } catch {
            print("❌ [AudioManager] File Playback Failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.setVoiceSpeaking(false)
            }
            return false
        }
    }
    
    func playVoiceData(_ voiceData: String, id: String, rate: Float = 1.0, completion: (() -> Void)? = nil) {
        print("🔊 [AudioManager] playVoiceData() TRIGGERED")
        print("   🆔 ID: \(id)")
        print("   📊 Base64 Length: \(voiceData.count) characters")
        print("   ⏩ Playback Rate: \(rate)")
        prepareForNewPlayback(completion: completion)
        DispatchQueue.main.async {
            self.setVoiceSpeaking(true)
        }
        
        Task {
            do {
                let request = GetVoiceRequest(relativeUrlPath: voiceData, fileId: id)
                let localURL = try await GetVoiceService.shared.downloadVoice(request: request)
                
                let player = try AVAudioPlayer(contentsOf: localURL)
                player.enableRate = true
                player.rate = rate
                
                DispatchQueue.main.async { [weak self] in
                    self?.pcmPlayer = player
                    self?.pcmPlayer?.delegate = self
                    self?.pcmPlayer?.play()
                }
            } catch {
                print("❌ [AudioManager] Voice Playback Failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.setVoiceSpeaking(false)
                    completion?()
                }
            }
        }
    }

    /// Backend-only playback at `relativePath` (same contract as ``playVoiceData`` / ``GetVoiceRequest``).
    /// Empty path or download/play failure ends cleanly via `completion` with no TTS fallback.
    func playVoiceFromBackendIfAvailable(
        relativePath: String?,
        id: String,
        rate: Float = 1.0,
        completion: (() -> Void)? = nil
    ) {
        let path = relativePath?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        print("🔊 [AudioManager] playVoiceFromBackendIfAvailable id=\(id) pathLen=\(path.count)")
        prepareForNewPlayback(completion: completion)
        guard !path.isEmpty else {
            finishPlayback()
            return
        }

        DispatchQueue.main.async {
            self.setVoiceSpeaking(true)
        }

        Task {
            do {
                let request = GetVoiceRequest(relativeUrlPath: path, fileId: id)
                let localURL = try await GetVoiceService.shared.downloadVoice(request: request)
                let player = try AVAudioPlayer(contentsOf: localURL)
                player.enableRate = true
                player.rate = rate
                DispatchQueue.main.async { [weak self] in
                    self?.pcmPlayer = player
                    self?.pcmPlayer?.delegate = self
                    self?.pcmPlayer?.play()
                }
            } catch {
                print("❌ [AudioManager] Backend voice playback failed: \(error.localizedDescription)")
                self.finishPlayback()
            }
        }
    }
    
    // MARK: - Private Helpers
    
    func stop() {
        audioQueue.async { [weak self] in
            self?.internalStop()
            self?.onSpeechCompletion = nil
            DispatchQueue.main.async {
                self?.setVoiceSpeaking(false)
            }
        }
    }

    private func internalStop() {
        pcmPlayer?.stop()
    }

    /// Stop current playback synchronously before starting a new one.
    /// This avoids async stop/start race that can briefly flip speaking=false
    /// right after a new playback has already started.
    private func prepareForNewPlayback(completion: (() -> Void)?) {
        audioQueue.sync {
            internalStop()
            onSpeechCompletion = completion
        }
    }
    
    private func finishPlayback() {
        let completion = onSpeechCompletion
        DispatchQueue.main.async {
            completion?()
            self.onSpeechCompletion = nil
            self.setVoiceSpeaking(false)
        }
    }

    private func setVoiceSpeaking(_ speaking: Bool) {
        if isVoiceSpeaking != speaking {
            isVoiceSpeaking = speaking
            if speaking {
                voiceStartedAt = Date()
                print("🔊 [AudioManager] isVoiceSpeaking -> STARTED at \(voiceStartedAt!)")
            } else {
                let duration = voiceStartedAt.map { Date().timeIntervalSince($0) } ?? 0
                voiceStartedAt = nil
                print("🔊 [AudioManager] isVoiceSpeaking -> STOPPED (duration: \(String(format: "%.2f", duration))s)")
            }
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}
