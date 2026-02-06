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
        return sentenceEmbedding?.vector(for: text)
    }
}
