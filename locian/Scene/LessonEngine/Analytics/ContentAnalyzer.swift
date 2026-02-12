//
//  ContentAnalyzer.swift
//  locian
//
//  Logic for finding Bricks in target text.
//

import Foundation
import NaturalLanguage

// MARK: - Content Analysis (Neural Engine)
// Centralized Logic for "What Bricks are in this text?"
class ContentAnalyzer {
    
    /// Finds which bricks exist in the pattern text via word matching
    /// Returns: List of Brick IDs (no scoring - SemanticFilterService handles that)
    static func findRelevantBricksWithSimilarity(in text: String, meaning: String, bricks: BricksData?, targetLanguage: String) -> [(id: String, score: Double)] {
        // Extract words from pattern
        let targetWords = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
        
        // Find all bricks that match ANY word in the target text
        var foundBricks: Set<String> = []
        
        func findMatchingBricks(list: [BrickItem]?) {
            guard let list = list else { return }
            for brick in list {
                let id = brick.id ?? brick.word
                let brickWord = brick.word.lowercased().trimmingCharacters(in: .punctuationCharacters)
                
                // Strict Match: Only check if the brick's word is in the target text
                let targetMatch = targetWords.contains(brickWord)
                
                if targetMatch {
                    foundBricks.insert(id)
                }
            }
        }
        
        // Process all brick types
        findMatchingBricks(list: bricks?.constants)
        findMatchingBricks(list: bricks?.variables)
        findMatchingBricks(list: bricks?.structural)
        
        // Return as (id, score) - Using actual semantic similarity instead of hardcoded 1.0
        let result = foundBricks.compactMap { id -> (id: String, score: Double)? in
            // Resolve the brick item to get its word for comparison
            let all = (bricks?.constants ?? []) + (bricks?.variables ?? []) + (bricks?.structural ?? [])
            guard let brick = all.first(where: { ($0.id ?? $0.word) == id }) else { return nil }
            
            // Calculate real neural similarity between the pattern text and this specific brick
            let score = EmbeddingService.compare(
                textA: text,
                textB: brick.word,
                languageCode: targetLanguage
            )
            
            print("🧠 [ContentAnalyzer] Scored Brick \"\(brick.word)\": Similarity=\(String(format: "%.3f", score))")
            return (id: id, score: score)
        }
        
        return result
    }

    /// Helper for ID-only return
    static func findRelevantBricks(in text: String, meaning: String, bricks: BricksData?, targetLanguage: String) -> [String] {
        return findRelevantBricksWithSimilarity(in: text, meaning: meaning, bricks: bricks, targetLanguage: targetLanguage).map { $0.id }
    }
    

}
