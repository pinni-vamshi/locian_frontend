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

class AudioManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    // MARK: - Published State
    @Published var isPlaying: Bool = false
    @Published var currentSpeed: Float = 0.75
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var lastUtterance: AVSpeechUtterance?
    
    // MARK: - Singleton
    static let shared = AudioManager()
    
    override private init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Speak text in specified language at given speed
    func speak(text: String, language: String, speed: Float = 0.75) {
        guard !text.isEmpty else { return }
        
        // Stop any current playback
        stop()
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        // User requested "normal" speed. AVSpeechUtteranceDefaultSpeechRate is roughly 0.5
        // We ignore the 'speed' parameter if it's the default 0.75 causing issues
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Store for replay
        lastUtterance = utterance
        currentSpeed = speed
        
        // Configure Audio Session for Playback
        do {
            let session = AVAudioSession.sharedInstance()
            
            // CONCURRENCY FIX: Do not overwrite category if we are recording (playAndRecord)
            // This allows TTS to play *during* a recording session without killing the mic.
            if session.category != .playAndRecord {
                try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            }
            
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("🔊 [AudioManager] Failed to set audio session: \(error)")
        }
        
        // Speak
        isPlaying = true
        synthesizer.speak(utterance)
    }
    
    /// Speak with phonetic guidance (slower, more deliberate)
    func speakWithPhonetics(text: String, phonetic: String?, language: String) {
        // For now, just speak the text at slower speed
        // Future: Could use phonetic string for IPA pronunciation
        speak(text: text, language: language, speed: 0.6)
    }
    
    /// Stop current playback
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isPlaying = false
        }
    }
    
    /// Pause current playback
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
        }
    }
    
    /// Resume paused playback
    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }
    }
    
    /// Replay last spoken text
    func replay() {
        guard let utterance = lastUtterance else { return }
        
        stop()
        isPlaying = true
        synthesizer.speak(utterance)
    }
    
    /// Set playback speed and replay
    func setSpeed(_ speed: Float) {
        currentSpeed = speed
        
        // If we have a last utterance, update its speed and replay
        if let lastText = lastUtterance?.speechString,
           let lastLanguage = lastUtterance?.voice?.language {
            speak(text: lastText, language: lastLanguage, speed: speed)
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
