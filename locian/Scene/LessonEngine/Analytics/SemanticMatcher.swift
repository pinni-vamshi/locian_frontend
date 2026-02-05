
//
//  SemanticMatcher.swift
//  locian
//
//  Centralized logic for semantic similarity comparisons.
//  Encapsulates the strategy for determining if two strings (Word/Sentence) are "matches".
//

import Foundation
import NaturalLanguage

class SemanticMatcher {
    
    // MARK: - Configuration
    struct Config {
        // High threshold for "Part vs Whole" matching (Word inside Sentence)
        static let relevanceThreshold = 0.92
        // Threshold for direct synonym matching (Word vs Word)
        static let synonymThreshold = 0.25
    }
    
    // MARK: - Logging Helper
    // MARK: - Logging Helper
    private static func logMatch(target: String, candidate: String, score: Double, method: String) {
        // Detailed log format per user request (Similarity Only)
        // print("   📏 [Semantic] '\(candidate)' vs '\(target)' -> Sim: \(String(format: "%.3f", score)) (\(method))")
    }

    // MARK: - Core Matching Logic
    
    // MARK: - Core Matching Logic
    
    /// Calculates the semantic SIMILARITY between a Target (Sentence/Context) and a Candidate (Brick/Option).
    /// Uses a unified strategy:
    /// 1. Neural Embedding: Calculate cosine similarity.
    ///
    /// - Parameters:
    ///   - target: The reference text
    ///   - candidate: The item to check
    ///   - validator: Access to the Neural Engine for embeddings
    /// - Returns: Similarity value (1.0 = Perfect Match, 0.0 = No Match)
    static func calculatePairSimilarity(target: String, candidate: String, validator: NeuralValidator?, silent: Bool = false) -> Double {
        // Validation Guard
        guard let validator = validator else {
             return 0.0 // No brain, no match
        }
        
        let targetCode = validator.targetLocale.language.languageCode?.identifier ?? "en"
        return EmbeddingService.compare(textA: target, textB: candidate, languageCode: targetCode)
    }
    
    // MARK: - Compatibility Helper (Forcing EmbeddingService)
    
    static func calculateRawSimilarity(target: String, candidate: String, embedding: NLEmbedding, silent: Bool = false) -> Double {
        // Fallback for calls passing NLEmbedding directly (usually Native Option Gen)
        // We can't easily extract lang from NLEmbedding instance, but usually it's "en" for native or "target"
        // Ideally callers should switch to EmbeddingService.
        // For now, we manually extract vectors using the passed embedding model.
        
        if let vA = embedding.vector(for: target), let vB = embedding.vector(for: candidate) {
             return EmbeddingService.cosineSimilarity(v1: vA, v2: vB)
        }
        return 0.0
    }
}
