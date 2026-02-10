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
        do {
            var response = try JSONDecoder().decode(GenerateSentenceResponse.self, from: data)
            
            // ---------------------------------------------------------
            // ⚡️ ENRICHMENT PIPELINE: GENERATE VECTORS
            // ---------------------------------------------------------
            // We generate vectors NOW so the Lesson Engine receives rich data.
            
            if let targetLang = response.data?.target_language {
                let code = targetLang 
                print("\n🧪 [GenerateSentenceLogic] Starting Enrichment Pipeline for: \(code)")
                
                // Process Groups (New LEGO Structure)
                if var groups = response.data?.groups {
                    for i in 0..<groups.count {
                        print("   📦 Group [\(i+1)/\(groups.count)]: Enriching components...")
                        
                        // 1. Prerequisites
                        if var prereqs = groups[i].prerequisites {
                            for j in 0..<prereqs.count {
                                prereqs[j].vector = EmbeddingService.getVector(for: prereqs[j].meaning, languageCode: code)
                            }
                            groups[i].prerequisites = prereqs
                        }
                        
                        // 2. Patterns
                        if var patterns = groups[i].patterns {
                            for j in 0..<patterns.count {
                                patterns[j].vector = EmbeddingService.getVector(for: patterns[j].meaning, languageCode: code)
                            }
                            groups[i].patterns = patterns
                        }
                        
                        // 3. Bricks (Constants, Variables, Structural)
                        if var bricks = groups[i].bricks {
                            // Constants
                            if var constants = bricks.constants {
                                for j in 0..<constants.count {
                                    constants[j].vector = EmbeddingService.getVector(for: constants[j].meaning, languageCode: code)
                                }
                                bricks.constants = constants
                            }
                            // Variables
                            if var variables = bricks.variables {
                                for j in 0..<variables.count {
                                    variables[j].vector = EmbeddingService.getVector(for: variables[j].meaning, languageCode: code)
                                }
                                bricks.variables = variables
                            }
                            // Structural
                            if var structural = bricks.structural {
                                for j in 0..<structural.count {
                                    structural[j].vector = EmbeddingService.getVector(for: structural[j].meaning, languageCode: code)
                                }
                                bricks.structural = structural
                            }
                            groups[i].bricks = bricks
                        }
                    }
                    response.data?.groups = groups
                }
                
                // Legacy / Legacy Support (Patterns/Bricks at Top Level)
                if var patterns = response.data?.patterns {
                    for i in 0..<patterns.count {
                        patterns[i].vector = EmbeddingService.getVector(for: patterns[i].meaning, languageCode: code)
                    }
                    response.data?.patterns = patterns
                }
                
                if var bricks = response.data?.bricks {
                    if var constants = bricks.constants {
                        for i in 0..<constants.count { constants[i].vector = EmbeddingService.getVector(for: constants[i].meaning, languageCode: code) }
                        bricks.constants = constants
                    }
                    if var variables = bricks.variables {
                        for i in 0..<variables.count { variables[i].vector = EmbeddingService.getVector(for: variables[i].meaning, languageCode: code) }
                        bricks.variables = variables
                    }
                    if var structural = bricks.structural {
                        for i in 0..<structural.count { structural[i].vector = EmbeddingService.getVector(for: structural[i].meaning, languageCode: code) }
                        bricks.structural = structural
                    }
                    response.data?.bricks = bricks
                }
                
                print("🧪 [GenerateSentenceLogic] Enrichment COMPLETE for target \(code).\n")
                
                // ---------------------------------------------------------
                // 🚀 HANDOVER TO MEMORY SERVICE (The Linear Pipeline)
                // ---------------------------------------------------------
                if var finalData = response.data {
                    print("💾 [GenerateSentenceLogic] Passing enriched data to SemanticMemoryService...")
                    SemanticMemoryService.shared.processLessonData(data: &finalData)
                }
            }
             
            DispatchQueue.main.async { completion(.success(response)) }
        } catch {
            print("❌ [GenerateSentenceLogic] Parse Error: \(error.localizedDescription)")
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }
    
    // MARK: - Centralized Writer
    
    /// Update mastery for a specific brick/pattern (called by Lesson Engine)
    func updateMastery(text: String, vector: [Double]?, languageCode: String, mode: String, isCorrect: Bool, currentStep: Int) {
        print("\n📝 [GenerateSentenceLogic] updateMastery bridge: '\(text)' (Correct: \(isCorrect))")
        guard let vector = vector else {
             print("   ⚠️ [GenerateSentenceLogic] Skipping update: Missing vector for '\(text)'")
             return
        }
        
        SemanticMemoryService.shared.updateRecall(
            text: text,
            vector: vector,
            languageCode: languageCode,
            isCorrect: isCorrect,
            currentStep: currentStep
        )
    }
}
