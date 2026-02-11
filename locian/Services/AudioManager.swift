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
    private var onSpeechCompletion: (() -> Void)?
    private var currentCategory: AVAudioSession.Category?
    
    // MARK: - Singleton
    static let shared = AudioManager()
    
    override private init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Session Management
    
    enum AudioSessionMode {
        case playback
        case recording
    }
    
    func configureSession(for mode: AudioSessionMode) {
        let session = AVAudioSession.sharedInstance()
        let targetCategory: AVAudioSession.Category = (mode == .recording) ? .playAndRecord : .playback
        let targetMode: AVAudioSession.Mode = (mode == .recording) ? .spokenAudio : .spokenAudio
        let targetOptions: AVAudioSession.CategoryOptions = (mode == .recording) ? [.duckOthers, .defaultToSpeaker] : [.duckOthers]
        
        // LOGIC CORRECT: Only touch the session if actually changing category OR options
        // Adding options check to prevent redundant setActive calls which trigger Code -50
        if session.category != targetCategory || session.categoryOptions != targetOptions {
            do {
                try session.setCategory(targetCategory, mode: targetMode, options: targetOptions)
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                currentCategory = targetCategory
            } catch {
                print("🔊 [AudioManager] Failed to configure session for \(mode): \(error)")
            }
        }
        
        // Force speaker routing for both modes to ensure full volume
        try? session.overrideOutputAudioPort(.speaker)
    }
    
    // MARK: - Public Methods
    
    /// Speak text in specified language at given speed
    func speak(text: String, language: String, speed: Float = 0.7, completion: (() -> Void)? = nil) {
        guard !text.isEmpty else { 
            completion?()
            return 
        }
        
        // LOGIC CORRECT: Complete previous callback BEFORE starting new one
        // If we just overwrite, the previous screen's "Next" button might stay disabled forever
        if let prevCompletion = onSpeechCompletion {
            DispatchQueue.main.async {
                prevCompletion()
            }
            onSpeechCompletion = nil
        }
        
        // Store new completion
        self.onSpeechCompletion = completion
        
        // Stop any current playback
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Configure Session via central logic
        configureSession(for: .playback)
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = speed * AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Speak
        synthesizer.speak(utterance)
    }
    
    /// Stop current playback
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // Trigger completion if it exists and clear it
        if let completion = onSpeechCompletion {
            DispatchQueue.main.async {
                completion()
            }
            onSpeechCompletion = nil
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.onSpeechCompletion?()
            self.onSpeechCompletion = nil
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.onSpeechCompletion?()
            self.onSpeechCompletion = nil
        }
    }
}
