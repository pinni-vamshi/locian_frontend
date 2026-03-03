//
//  GenerateSentenceService.swift
//  locian
//
//  Created by locian-ai on 2026-02-17.
//
//  Service for /api/learning/generate-sentence
//  Replaces the old pattern generative AI endpoint with the requested endpoint system.
//  Adapts the flat API response into the structure expected by LessonEngine.
//

import Foundation
import CoreLocation
import Combine

class GenerateSentenceService {
    static let shared = GenerateSentenceService()
    private init() {}
    
    // MARK: - API Call
    
    /// Fetch pattern lesson for a specific moment
    /// - Parameters:
    ///   - momentId: The ID of the moment card clicked
    ///   - completion: Returns the lesson data ready for the Engine
    func generateSentence(
        momentId: String,
        completion: @escaping (Result<GenerateSentenceResponse, Error>) -> Void
    ) {
        
        // 1. Get Current Context (Time & Location)
        let location = LocationManager.shared.currentLocation
        let latitude = location?.coordinate.latitude ?? 0.0
        let longitude = location?.coordinate.longitude ?? 0.0
        
        let formatter = ISO8601DateFormatter()
        let timeString = formatter.string(from: Date())
        
        // Fetch languages from active state, fallback to defaults
        let defaultPair = AppStateManager.shared.userLanguagePairs.first(where: { $0.is_default })
        let userLang = defaultPair?.native_language ?? "en"
        let targetLang = defaultPair?.target_language ?? "es"
        
        // 2. Build Request
        let request = GenerateSentenceRequest(
            moment_id: momentId,
            user_language: userLang,
            target_language: targetLang,
            latitude: latitude,
            longitude: longitude,
            time: timeString
        )
        
        let sessionToken = AppStateManager.shared.authToken ?? ""
        let headers = ["session_token": sessionToken] // As requested per prompt headers
        
        print("🚀 [GenerateSentence] Requesting lesson for moment: \(momentId)")
        
        // DEBUG: Print Raw Request
        if let requestData = try? JSONEncoder().encode(request),
           let requestString = String(data: requestData, encoding: .utf8) {
            print("📤 [GenerateSentence] EXACT JSON REQUEST PAYLOAD:\n\(requestString)")
        }
        
        // 3. API Call
        print("\n[STRICT_DEBUG] 🛰 SENDING REQUEST TO /api/learning/generate-sentence")
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/learning/generate-sentence",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 30.0
        ) { [weak self] (result: Result<Data, Error>) in
            
            guard let self = self else { return }
            
            print("[STRICT_DEBUG] 📥 RECEIVED RESPONSE FROM /api/learning/generate-sentence")
            
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔥 [STRICT_DEBUG] RAW JSON RESPONSE FROM SERVER:\n\(jsonString)")
                }
                
                do {
                    // 4. Decode Response (Flat Structure)
                    print("[STRICT_DEBUG] 🔍 Attempting to decode into GenerateSentenceResponse...")
                    let response = try JSONDecoder().decode(GenerateSentenceResponse.self, from: data)
                    print("[STRICT_DEBUG] ✅ Decoding SUCCESS. Success Status: \(response.success), Error: \(response.error ?? "None")")
                    
                    // 5. HYDRATE & ADAPT
                    self.hydrateAndAdaptForEngine(response: response) { adaptedResponse in
                        print("✅ [STRICT_DEBUG] Lesson fully hydrated and adapted for Engine.")
                        completion(.success(adaptedResponse))
                    }
                    
                } catch {
                    print("❌ [STRICT_DEBUG] DECODING ERROR: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ [STRICT_DEBUG] FAILED TO DECODE THIS JSON: \(jsonString)")
                    }
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("❌ [GenerateSentence] Network Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Adaptation Layer (The "Bridge" to Lesson Engine)
    
    /// Takes the flat API response, generates embeddings locally, and wraps it in a Group structure
    // MARK: - Adaptation Layer (The "Bridge" to Lesson Engine)
    
    /// Takes the flat API response, generates embeddings locally, and wraps it in a Group structure
    private func hydrateAndAdaptForEngine(
        response: GenerateSentenceResponse,
        completion: @escaping (GenerateSentenceResponse) -> Void
    ) {
        // Create local immutable copy for capture
        let initialResponse = response
        
        guard let data = initialResponse.data else {
            print("⚠️ [GenerateSentence] Hydration ABORT: Response data field is nil.")
            completion(initialResponse)
            return
        }
        
        print("💧 [GenerateSentence] Starting Hydration Bridge...")
        print("   - Patterns Found: \(data.patterns?.count ?? 0)")
        print("   - Bricks Found: Constants(\(data.bricks?.constants?.count ?? 0)), Variables(\(data.bricks?.variables?.count ?? 0)), Structural(\(data.bricks?.structural?.count ?? 0))")
        
        // Move to background thread for heavy embedding calculation
        DispatchQueue.global(qos: .userInitiated).async {
            print("[STRICT_DEBUG] 💧 Hydration: Starting...")
            
            // Working with local copies
            var updatedData = data
            
            // A. Handle patterns (Top level fallback or from first group)
            var patterns = updatedData.patterns ?? []
            
            // If top-level patterns are missing but groups exist, pull from groups
            if patterns.isEmpty, let firstGroup = updatedData.groups?.first {
                print("[STRICT_DEBUG] 📦 Extracting \(firstGroup.patterns?.count ?? 0) patterns from first group")
                patterns = firstGroup.patterns ?? []
            }
            
            var bricks = updatedData.bricks
            if (bricks?.constants?.count ?? 0) == 0 && (bricks?.variables?.count ?? 0) == 0, 
               let firstGroup = updatedData.groups?.first {
                print("[STRICT_DEBUG] 📦 Extracting bricks from first group")
                bricks = firstGroup.bricks
            }
            
            print("[STRICT_DEBUG] 💧 Hydration: Processing \(patterns.count) patterns...")
            
            // B. Generate Embeddings for Patterns
            for i in 0..<patterns.count {
                let text = patterns[i].target
                print("[STRICT_DEBUG] 🧮 Calculating vectors for pattern: \(text)")
                if let vector = EmbeddingService.getVector(for: text, languageCode: "es") { // TODO: Dynamic Lang?
                    patterns[i].vector = vector
                }
            }
            
            // C. Generate Embeddings for Bricks
            // Constants
            if var constants = bricks?.constants {
                for i in 0..<constants.count {
                    if let vector = EmbeddingService.getVector(for: constants[i].word, languageCode: "es") {
                        constants[i].vector = vector
                    }
                }
                bricks?.constants = constants
            }
            
            // Variables
            if var variables = bricks?.variables {
                for i in 0..<variables.count {
                    if let vector = EmbeddingService.getVector(for: variables[i].word, languageCode: "es") {
                        variables[i].vector = vector
                    }
                }
                bricks?.variables = variables
            }
            
            // Structural
            if var structural = bricks?.structural {
                for i in 0..<structural.count {
                    if let vector = EmbeddingService.getVector(for: structural[i].word, languageCode: "es") {
                        structural[i].vector = vector
                    }
                }
                bricks?.structural = structural
            }
            
            // D. Final Assembly on Main Thread
            DispatchQueue.main.async {
                // 1. Assign hydrated lists back to data
                updatedData.patterns = patterns
                updatedData.bricks = bricks
                
                // 2. Ensure we have at least one group for the Engine
                if (updatedData.groups?.isEmpty ?? true) {
                    print("[STRICT_DEBUG] 🏗 Synthesizing Virtual Group")
                    let virtualGroup = LessonGroup(
                        group_id: "main_group",
                        patterns: patterns,
                        bricks: bricks
                    )
                    updatedData.groups = [virtualGroup]
                } else {
                    print("[STRICT_DEBUG] 🔄 Updating first group with hydrated data")
                    updatedData.groups?[0].patterns = patterns
                    updatedData.groups?[0].bricks = bricks
                }
                
                // 3. Update Response
                var finalResponse = initialResponse
                finalResponse.data = updatedData
                print("✅ [GetPatternLesson] Hydration Complete. Groups: \(updatedData.groups?.count ?? 0). First group patterns: \(updatedData.groups?.first?.patterns?.count ?? 0)")
                completion(finalResponse)
            }
        }
    }
}
