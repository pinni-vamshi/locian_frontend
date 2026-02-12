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
    
    // MARK: - SEMANTIC CLIFF DETECTION (V4.1)
    
    /// The "Brain" of the filtration system. 
    /// Takes raw similarity scores and decides which bricks to include based on 
    /// the "Semantic Cliff" - the point where relevance breaks.
    /// Simplified 3-Stage Reveal Logic (Locian-Appropriate)
    /// 0.00 - 0.25 Mastery: Core (2 bricks)
    /// 0.25 - 0.50 Mastery: Most (3-4 bricks)
    /// > 0.50 Mastery: Full (all bricks)
    static func filterBricksBySemanticCliff(
        bricks: [(id: String, score: Double)],
        patternMastery: Double,
        activeBricks: BricksData?
    ) -> [String] {
        guard !bricks.isEmpty else { return [] }
        
        // 1. Weight = similarity only (keep simple)
        let ranked = bricks.sorted { $0.score > $1.score }
        let scores = ranked.map { $0.score }
        let total = scores.reduce(0, +)
        
        // 2. Fast growth schedule (full reveal reached by 0.50 mastery)
        // Formula: C(M) = 0.50 + 0.50 * min(M/0.50, 1.0)
        let normalized = min(patternMastery / 0.50, 1.0)
        let coverage = 0.50 + (0.50 * normalized)
        let requiredTotal = coverage * total
        
        // 3. Selection loop until coverage reached
        var selectedIDs: [String] = []
        var currentSum: Double = 0
        
        for item in ranked {
            selectedIDs.append(item.id)
            currentSum += item.score
            if currentSum >= requiredTotal { break }
        }
        
        // 4. Locian Guardrails: Minimum 2 bricks
        if selectedIDs.count < 2 && ranked.count >= 2 {
            selectedIDs = Array(ranked.prefix(2)).map { $0.id }
        }
        
        return selectedIDs
    }
}
