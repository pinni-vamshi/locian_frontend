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

class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Singleton
    static let shared = AudioManager()
    
    override private init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Speak text in specified language at given speed
    func speak(text: String, language: String, speed: Float = 0.7) {
        guard !text.isEmpty else { return }
        
        // Stop any current playback
        stop()
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        // Adjust rate based on speed multiplier
        utterance.rate = speed * AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
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
        synthesizer.speak(utterance)
    }
    
    /// Stop current playback
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
