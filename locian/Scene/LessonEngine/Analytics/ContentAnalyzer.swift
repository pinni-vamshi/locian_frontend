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
    
    // MARK: - LOGGING FLAGS
    static let LOG_MAIN_HEADER = true           // Main analysis header logs
    static let LOG_STAGE1_WORD_MATCHING = true  // Stage 1: Word matching logs
    static let LOG_STAGE2_SEMANTIC_CALC = true  // Stage 2: Semantic similarity calculation logs
    
    /// Finds which bricks exist in the pattern text via word matching
    /// Returns: List of Brick IDs (no scoring - SemanticFilterService handles that)
    static func findRelevantBricksWithSimilarity(in text: String, meaning: String, bricks: BricksData?, targetLanguage: String) -> [(id: String, score: Double)] {
        if LOG_MAIN_HEADER {
            print("\n🔍 [LessonFlow] [ContentAnalyzer] Finding bricks via word matching: '\(text)'")
        }
        
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
                    if LOG_STAGE1_WORD_MATCHING {
                        print("      🎯 [ContentAnalyzer] Match Found: [\(id)] via Target Match ('\(brickWord)')")
                    }
                }
            }
        }
        
        // Process all brick types
        findMatchingBricks(list: bricks?.constants)
        findMatchingBricks(list: bricks?.variables)
        findMatchingBricks(list: bricks?.structural)
        
        // Return as (id, 1.0) - score unused, SemanticFilterService will score them
        let result = foundBricks.map { (id: $0, score: 1.0) }
        
        if LOG_MAIN_HEADER {
            print("   ✅ [LessonFlow] [ContentAnalyzer] Found \(result.count) candidate bricks: \(result.map{$0.id})")
        }
        
        return result
    }

    /// Helper for ID-only return
    static func findRelevantBricks(in text: String, meaning: String, bricks: BricksData?, targetLanguage: String) -> [String] {
        return findRelevantBricksWithSimilarity(in: text, meaning: meaning, bricks: bricks, targetLanguage: targetLanguage).map { $0.id }
    }
    

}
