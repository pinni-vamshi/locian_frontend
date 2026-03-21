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
        return all.first(where: { $0.id == id })
    }
    
    // MARK: - SEMANTIC CLIFF DETECTION (V4.1)
    
    /// The "Brain" of the filtration system.
    /// Uses a mastery-relative threshold to progressively reveal bricks.
    /// Scores arrive pre-normalized to [0, 1] from WordSimilarityService.
    /// At low mastery: only top bricks are shown.
    /// At high mastery: all bricks are revealed.
    ///
    /// Relative threshold formula:
    ///   threshold = T_fraction × (1 - clamp(mastery / M_ceiling, 0, 1))
    ///   At mastery=0    →  threshold = T_fraction (show only top portion)
    ///   At mastery=0.5  →  threshold = 0          (show all bricks)
    static func filterBricksBySemanticCliff(
        bricks: [(id: String, score: Double)],
        patternMastery: Double,
        activeBricks: BricksData?
    ) -> [String] {
        guard !bricks.isEmpty else { return [] }
        
        // 1. Sort by score (highest first) — scores already in [0, 1]
        let ranked = bricks.sorted { $0.score > $1.score }
        
        // 2. Relative Threshold
        let T_fraction = 0.65
        let M_ceiling  = 0.50
        let masteryProgress = min(patternMastery / M_ceiling, 1.0)
        let threshold = T_fraction * (1.0 - masteryProgress)
        
        // 3. Select bricks whose score is above the threshold
        var selectedIDs = ranked.filter { $0.score >= threshold }.map { $0.id }
        
        // 4. Locian Guardrail: Always show at least 2 bricks
        if selectedIDs.count < 2 && ranked.count >= 2 {
            selectedIDs = Array(ranked.prefix(2)).map { $0.id }
        }
        
        return selectedIDs
    }
}
