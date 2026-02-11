import Foundation

/// Defines shared types and mastery-based filtering logic.
struct MasteryFilterService {
    
    // MARK: - LOGGING
    static let LOG_FILTERING = false
    
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
        let dynamic = 0.85 - (mastery * 0.60)
        let final = min(0.85, max(0.25, dynamic))
        
        print("🔍 [MASTERY_FILTER] Threshold for \"\(text)\": Mastery=\(String(format: "%.2f", mastery)) -> Raw=\(String(format: "%.2f", dynamic)) -> Final=\(String(format: "%.2f", final))")
        
        return final
    }
    
    /// Determines if a brick should be included in a lesson based on its type and semantic relevance.
    static func evaluateBrickRelevance(brick: String, isVariable: Bool, isConstant: Bool, score: Double, threshold: Double, mastery: Double) -> (accepted: Bool, reason: String) {
        // Core Word Boost: Adaptive based on Mastery
        let baseBoost = isVariable ? 0.05 : 0.0
        let adaptiveBoost = baseBoost * (1.0 - mastery)
        
        let boostedScore = score + adaptiveBoost
        let accepted = boostedScore >= threshold
        let brickType = isVariable ? "Variable" : (isConstant ? "Constant" : "Structural")
        
        let scoreStr = String(format: "%.3f", boostedScore)
        let threshStr = String(format: "%.2f", threshold)
        
        let comparisonSymbol = accepted ? ">=" : "<"
        let statusText = accepted ? "KEEP (For Intro)" : "SKIP (Mastered)"
        
        print("   -> 🧱 [\(brickType)] \"\(brick)\": Score=\(String(format: "%.3f", score)) + Boost=\(String(format: "%.3f", adaptiveBoost)) = \(scoreStr) \(comparisonSymbol) Thresh \(threshStr) -> \(statusText)")
        
        let reason = "\(brickType) [\(statusText)]: Final \(scoreStr) \(comparisonSymbol) Thresh \(threshStr)"
        
        let result = (accepted, reason)
        return result
    }
    
    /// Sorting score boost for main words (Variables) to ensure they appear first in lists.
    static func getSortingScore(originalScore: Double, isVariable: Bool) -> Double {
        return isVariable ? (originalScore + 2.0) : originalScore
    }
}
