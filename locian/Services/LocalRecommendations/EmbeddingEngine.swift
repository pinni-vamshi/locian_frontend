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
        print("\n🟢 [EmbeddingEngine] generateEmbedding called for: '\(text)'")
        print("   ⚠️ [EmbeddingEngine] USING HARDCODED STATIC ENGLISH MODEL (NLEmbedding.sentenceEmbedding(for: .english))")
        
        guard let embedding = sentenceEmbedding else {
            print("🔴 [EmbeddingEngine] NLEmbedding is NIL. Cannot generate vector.")
            return nil
        }
        
        let vector = embedding.vector(for: text)
        if let v = vector {
            print("   ✅ [EmbeddingEngine] Vector Generated (Dim: \(v.count))")
            print("   📊 [EmbeddingEngine] RAW VECTOR (First 5): \(v.prefix(5))")
        } else {
            print("⚠️ [EmbeddingEngine] Failed to generate vector for: '\(text)'")
        }
        return vector
    }
}
