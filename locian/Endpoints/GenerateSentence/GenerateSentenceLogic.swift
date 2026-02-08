//
//  GenerateSentenceLogic.swift
//  locian
//
//  Logic layer for Generate Sentence Endpoint
//  Parses raw response data
//

import Foundation

@MainActor
class GenerateSentenceLogic {
    static let shared = GenerateSentenceLogic()
    
    private init() {}
    
    // MARK: - Response Parsing
    
    /// Parse raw JSON data into structured response
    func parseResponse(
        data: Data,
        completion: @escaping (Result<GenerateSentenceResponse, Error>) -> Void
    ) {
            var response = try decoder.decode(GenerateSentenceResponse.self, from: data)
            
            // ---------------------------------------------------------
            // ⚡️ PERFORMANCE OPTIMIZATION: PRE-COMPUTE VECTORS
            // ---------------------------------------------------------
            // We generate vectors NOW (during "Loading...") so the Lesson Engine receives rich data instantly.
            
            if let targetLang = response.data?.target_language {
                let code = targetLang 
                print("🧠 [GenerateSentenceLogic] Pre-computing vectors for target: \(code)")
                
                // 1. Process Bricks (Mutate in place)
                if var bricks = response.data?.bricks {
                    
                    // Constants
                    if var constants = bricks.constants {
                        for i in 0..<constants.count {
                            let text = constants[i].meaning
                            // 1. Vector
                            let vector = EmbeddingService.getVector(for: text, languageCode: code)
                            constants[i].vector = vector
                            // 2. Mastery (Load from DB)
                            if let v = vector, let entry = BrickMasteryService.shared.getBrick(text: text, vector: v) {
                                constants[i].mastery = entry.effectiveScore
                            }
                        }
                        bricks.constants = constants
                    }
                    
                    // Variables
                    if var variables = bricks.variables {
                        for i in 0..<variables.count {
                            let text = variables[i].meaning
                            let vector = EmbeddingService.getVector(for: text, languageCode: code)
                            variables[i].vector = vector
                            if let v = vector, let entry = BrickMasteryService.shared.getBrick(text: text, vector: v) {
                                variables[i].mastery = entry.effectiveScore
                            }
                        }
                        bricks.variables = variables
                    }
                    
                    // Structural
                    if var structural = bricks.structural {
                        for i in 0..<structural.count {
                            let text = structural[i].meaning
                            let vector = EmbeddingService.getVector(for: text, languageCode: code)
                            structural[i].vector = vector
                            if let v = vector, let entry = BrickMasteryService.shared.getBrick(text: text, vector: v) {
                                structural[i].mastery = entry.effectiveScore
                            }
                        }
                        bricks.structural = structural
                    }
                    
                    response.data?.bricks = bricks
                }
                
                // 2. Process Patterns
                if var patterns = response.data?.patterns {
                    for i in 0..<patterns.count {
                        let text = patterns[i].meaning
                        // 1. Vector
                        let vector = EmbeddingService.getVector(for: text, languageCode: code)
                        patterns[i].vector = vector
                        // 2. Mastery (Load from DB - treating patterns as concepts too)
                        // Note: Patterns typically have IDs like "P1", but we can track mastery by meaning/vector too
                        if let v = vector, let entry = BrickMasteryService.shared.getBrick(text: text, vector: v) {
                            patterns[i].mastery = entry.effectiveScore
                        }
                    }
                    response.data?.patterns = patterns
                }
                
                print("🧠 [GenerateSentenceLogic] Vector & Mastery injection complete.")
            }
             
            DispatchQueue.main.async { completion(.success(response)) }
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }
    
    // MARK: - Centralized Writero
    
    /// Update mastery for a specific brick/pattern (called by Lesson Engine)
    func updateMastery(text: String, vector: [Double]?, mode: String, isCorrect: Bool) {
        // Dispatch to DB Service
        // We use the vector if provided (Engine has it), or we could re-generate if needed.
        // It's safer to pass the vector from Engine.
        
        guard let vector = vector else {
             print("⚠️ [GenerateSentenceLogic] Cannot update mastery: Missing vector for '\(text)'")
             return
        }
        
        print("💾 [GenerateSentenceLogic] Requesting DB Update for '\(text)' (Correct: \(isCorrect))")
        BrickMasteryService.shared.updateBrick(
            text: text,
            vector: vector,
            mode: mode,
            isCorrect: isCorrect
        )
    }
}
