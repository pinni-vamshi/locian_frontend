//
//  EmbeddingEngine.swift
//  locian
//
//  Wraps NaturalLanguage for on-device embedding generation.
//

import Foundation
import NaturalLanguage

class EmbeddingEngine {
    static let shared = EmbeddingEngine()
    
    private let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english)
    
    private init() {}
    
    func generateEmbedding(for text: String) -> [Double]? {
        // print("\n🟢 [EmbeddingEngine] generateEmbedding called for: '\(text.prefix(20))...'") // Truncated for sanity
        guard let embedding = sentenceEmbedding else {
            print("🔴 [EmbeddingEngine] NLEmbedding is NIL. Cannot generate vector.")
            return nil
        }
        
        let vector = embedding.vector(for: text)
        if let v = vector {
            // print("   ✅ [EmbeddingEngine] Vector Generated (Dim: \(v.count))")
        } else {
            print("⚠️ [EmbeddingEngine] Failed to generate vector for: '\(text)'")
        }
        return vector
    }
}
