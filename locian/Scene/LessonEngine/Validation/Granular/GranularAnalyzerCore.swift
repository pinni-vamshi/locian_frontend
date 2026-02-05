//
//  GranularAnalyzerCore.swift
//  locian
//
//  Shared utilities for granular brick analysis within pattern drills.
//

import Foundation

// MARK: - Granular Analysis Result
// Now using the centralized BrickAnalysisResult from DrillState.swift

/// Shared utilities for all granular analyzers
struct GranularAnalyzerCore {
    
    /// Parse text into clean tokens
    static func parseTextTokens(_ text: String) -> [String] {
        let cleaned = text.lowercased()
        return cleaned
            .components(separatedBy: .punctuationCharacters).joined()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
    
    /// Find best semantic match for a brick word within response tokens
    static func findBestSemanticMatch(
        brickWord: String,
        responseTokens: [String],
        validator: NeuralValidator?,
        threshold: Double
    ) -> (similarity: Double, matchedToken: String, isCorrect: Bool) {
        
        var bestMatch: (Double, String) = (0.0, "")
        
        for token in responseTokens {
            let sim = SemanticMatcher.calculatePairSimilarity(
                target: brickWord,
                candidate: token,
                validator: validator,
                silent: true
            )
            
            if sim > bestMatch.0 {
                bestMatch = (sim, token)
            }
            
            // Early exit if perfect
            if sim >= 0.98 { break }
        }
        
        let isCorrect = bestMatch.0 >= threshold
        return (bestMatch.0, bestMatch.1, isCorrect)
    }
    
    /// Check if brick word appears exactly in text
    static func containsExactMatch(text: String, brickWord: String) -> Bool {
        let cleanText = text.lowercased()
        let cleanBrick = brickWord.lowercased()
        return cleanText.contains(cleanBrick)
    }
}
