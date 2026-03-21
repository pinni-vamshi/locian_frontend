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
    static func findRelevantBricksWithSimilarity(in text: String, meaning: String, bricks: BricksData?, targetLanguage: String, nativeLanguage: String = "en") -> [(id: String, score: Double)] {
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
                let id = brick.id
                
                // Split brick into words to handle phrases (e.g. "me gusta")
                let brickWords = brick.word.lowercased()
                    .components(separatedBy: .whitespacesAndNewlines)
                    .map { $0.trimmingCharacters(in: .punctuationCharacters) }
                    .filter { !$0.isEmpty }
                
                // ✅ V4.2 FIX: Sub-sequence matching
                // Instead of strict .contains(), we check if the brick phrase exists as a contiguous sequence of words
                var targetMatch = false
                if !brickWords.isEmpty && targetWords.count >= brickWords.count {
                    for i in 0...(targetWords.count - brickWords.count) {
                        let chunk = Array(targetWords[i..<(i + brickWords.count)])
                        if chunk == brickWords {
                            targetMatch = true
                            break
                        }
                    }
                }
                
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
            // Resolve the brick and its category
            let all = (bricks?.constants ?? []) + (bricks?.variables ?? []) + (bricks?.structural ?? [])
            guard let brick = all.first(where: { $0.id == id }) else { return nil }
            
            let category: BrickCategory
            if bricks?.constants?.contains(where: { $0.id == id }) == true {
                category = .constant
            } else if bricks?.variables?.contains(where: { $0.id == id }) == true {
                category = .variable
            } else {
                category = .structural
            }
            
            // Dual JNS: L2 (target language) + L1 (native meaning), averaged + category boost
            let score = WordSimilarityService.calculateDualJointScore(
                word: brick.word,
                sentence: text,
                targetLanguage: targetLanguage,
                wordMeaning: brick.meaning,
                meaningContext: meaning,
                nativeLanguage: nativeLanguage,
                category: category
            )
            
            print("🧠 [ContentAnalyzer] Scored Brick \"\(brick.word)\": Similarity=\(String(format: "%.3f", score))")
            return (id: id, score: score)
        }
        
        return result
    }

    /// Helper for ID-only return
    static func findRelevantBricks(in text: String, meaning: String, bricks: BricksData?, targetLanguage: String, nativeLanguage: String = "en") -> [String] {
        return findRelevantBricksWithSimilarity(in: text, meaning: meaning, bricks: bricks, targetLanguage: targetLanguage, nativeLanguage: nativeLanguage).map { $0.id }
    }
    

}
