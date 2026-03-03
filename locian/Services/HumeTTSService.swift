//
//  HumeTTSService.swift
//  locian
//
//  Service for Hume AI Text-to-Speech (TTS) API
//  Uses Hume's Octave speech model for expressive, natural-sounding speech
//

import Foundation
import AVFoundation

class HumeTTSService {
    static let shared = HumeTTSService()
    
    private let baseURL = "https://api.hume.ai/v0/tts"
    private var audioPlayer: AVAudioPlayer?
    
    // ✅ USER REQUEST: No hardcoded fancy IDs. Just let Hume use its default.
    // private let FIXED_VOICE_ID = "..." (REMOVED)
    
    private init() {}
    
    /// Converts text to speech using Hume's TTS API
    /// - Parameters:
    ///   - text: The text to convert to speech
    ///   - voiceName: Optional voice name (default: nil uses Hume's system default)
    ///   - completion: Called when speech playback completes
    func speak(text: String, voiceName: String? = nil, completion: (() -> Void)? = nil, onFailure: (() -> Void)? = nil) {
        guard let apiKey = AppStateManager.shared.humeApiKey, !apiKey.isEmpty else {
            print("❌ [HumeTTSService] Missing API Key")
            onFailure?()
            return
        }
        
        print("🎙️ [HumeTTSService] Generating speech for: '\(text)'")
        
        Task {
            do {
                let audioData = try await generateSpeech(text: text, voiceName: voiceName, apiKey: apiKey)
                await playSpeech(audioData: audioData, completion: completion)
            } catch {
                print("❌ [HumeTTSService] Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onFailure?()
                }
            }
        }
    }
    
    /// Generates speech audio data from Hume's TTS API
    private func generateSpeech(text: String, voiceName: String?, apiKey: String) async throws -> Data {
        guard let url = URL(string: "\(baseURL)") else {
            throw NSError(domain: "HumeTTSService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Hume-Api-Key")
        
        // Build request body according to Hume API schema
        // Build request body according to Hume API schema
        var utterance: [String: Any] = ["text": text]
        
        // ✅ USER REQUEST: Use Default Voice (Simplest Path)
        // Only attach 'voice' if a specific overriding name is allowed, otherwise let API pick default.
        if let sensitiveVoice = voiceName {
             utterance["voice"] = ["name": sensitiveVoice]
        }
        // else: Do not send "voice" key at all. Let API use default.
        
        // Correct Top Level is just "utterances" for TTS
        let body: [String: Any] = [
            "utterances": [utterance],
             "format": [
                "type": "mp3",
                "container": "mp3"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [HumeTTSService] Invalid response type")
            throw NSError(domain: "HumeTTSService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        print("📡 [HumeTTSService] HTTP Status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            // Try to parse error response
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [HumeTTSService] API Error Response: \(errorString)")
            }
            throw NSError(domain: "HumeTTSService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status \(httpResponse.statusCode)"])
        }
        
        print("✅ [HumeTTSService] Received response: \(data.count) bytes")
        
        // Parse JSON response to extract audio data from generations array
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let generations = json["generations"] as? [[String: Any]],
              let firstGeneration = generations.first,
              let audioBase64 = firstGeneration["audio"] as? String,
              let audioData = Data(base64Encoded: audioBase64) else {
            // If parsing fails, log the response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [HumeTTSService] Failed to parse response. Raw response: \(responseString.prefix(500))...")
            }
            throw NSError(domain: "HumeTTSService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse audio data from response"])
        }
        
        print("✅ [HumeTTSService] Extracted audio data: \(audioData.count) bytes")
        return audioData
    }
    
    /// Plays the audio data using AVAudioPlayer
    @MainActor
    private func playSpeech(audioData: Data, completion: (() -> Void)?) async {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.enableRate = true
            audioPlayer?.rate = 1.6 // Doubled from 0.8 for clarity, as requested
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // Wait for playback to complete
            if let duration = audioPlayer?.duration {
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            }
            
            completion?()
        } catch {
            print("❌ [HumeTTSService] Playback error: \(error.localizedDescription)")
            completion?()
        }
    }
    
    /// Stops any ongoing speech
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
