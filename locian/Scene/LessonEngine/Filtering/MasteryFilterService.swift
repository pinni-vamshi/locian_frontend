import Foundation

/// Defines shared types and mastery-based filtering logic.
struct MasteryFilterService {
    
    // MARK: - LOGGING
    static let LOG_FILTERING = true
    
    /// Result returned by any brick filtering logic
    struct FilterResult {
        let brickId: String
        let mastery: Double
        let similarityScore: Double
    }
    
    // STATE: Track recently used patterns for cooldown
    var recentPatterns: Set<String> = []
    
    // MARK: - CENTRALIZED LOOKUP
    
    /// Maps a set of brick IDs to their actual BrickItem objects from the lesson data.
    static func resolveBricks(ids: Set<String>, from data: BricksData?) -> [BrickItem] {
        guard let data = data else { return [] }
        return ids.compactMap { id in
            getBrick(id: id, from: data)
        }
    }
    
    /// Finds a single brick by ID.
    static func getBrick(id: String, from data: BricksData?) -> BrickItem? {
        guard let data = data else { return nil }
        let all = (data.constants ?? []) + (data.variables ?? []) + (data.structural ?? [])
        return all.first(where: { ($0.id ?? $0.word) == id })
    }
    
    // MARK: - SHARED THRESHOLD LOGIC
    
    /// Dynamically calculates the threshold for semantic filtering.
    static func calculateThreshold(text: String, mastery: Double, languageCode: String) -> Double {
        let isContextual = EmbeddingService.isContextualAvailable(for: languageCode)
        let wordCount = Double(text.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").count)
        
        let base: Double
        if isContextual {
            let wordPenalty = min(0.1, wordCount * 0.01)
            base = 0.72 - wordPenalty
        } else {
            base = 0.59 - (wordCount * 0.01)
        }
        
        let dynamic = base - (mastery * 0.08)
        let final = min(0.85, max(0.45, dynamic))
        
        if LOG_FILTERING {
            print("   ⚖️ [LessonFlow] [Threshold] Logic:")
            print("      - Model: \(isContextual ? "CONTEXTUAL" : "STATIC")")
            print("      - Text: '\(text.prefix(30))...'")
            print("      - Base: \(String(format: "%.2f", base)) (WordCount: \(Int(wordCount)))")
            print("      - Mastery Adj: -\(String(format: "%.2f", mastery * 0.08)) (\(String(format: "%.0f%%", mastery * 100)) mastery)")
            print("      - Result: \(String(format: "%.2f", final))")
        }
        
        return final
    }
    
    /// Determines if a brick should be included in a lesson based on its type and semantic relevance.
    static func evaluateBrickRelevance(brick: String, isVariable: Bool, isConstant: Bool, score: Double, threshold: Double, mastery: Double) -> (accepted: Bool, reason: String) {
        // Core Word Boost: Adaptive based on Mastery
        let baseBoost = isVariable ? 0.05 : 0.0
        let adaptiveBoost = baseBoost * (1.0 - mastery)
        
        let boostedScore = score + adaptiveBoost
        let accepted = boostedScore < threshold
        let brickType = isVariable ? "Variable" : (isConstant ? "Constant" : "Structural")
        
        let scoreStr = String(format: "%.3f", boostedScore)
        let threshStr = String(format: "%.2f", threshold)
        
        let comparisonSymbol = accepted ? "<" : ">="
        let statusEmoji = accepted ? "❌" : "✅"
        let statusText = accepted ? "KEEP (For Intro)" : "SKIP (Mastered)"
        
        let reason = "\(brickType) [\(statusText)]: Final \(scoreStr) \(comparisonSymbol) Thresh \(threshStr)"
        
        let result = (accepted, reason)
        print("      \(statusEmoji) [LessonFlow] [Filter] '\(brick)' - \(reason)")
        return result
    }
    
    /// Sorting score boost for main words (Variables) to ensure they appear first in lists.
    static func getSortingScore(originalScore: Double, isVariable: Bool) -> Double {
        return isVariable ? (originalScore + 2.0) : originalScore
    }
}
