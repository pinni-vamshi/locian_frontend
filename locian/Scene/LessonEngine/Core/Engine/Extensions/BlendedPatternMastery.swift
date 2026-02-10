import Foundation

extension LessonEngine {
    
    /// Returns the blended mastery for a given ID (Pattern or Brick).
    /// If it's a pattern, it applies the 60/40 rule.
    /// If it's a brick, it returns the raw mastery.
    func getBlendedMastery(for id: String) -> Double {
        let cleanId = id.replacingOccurrences(of: "INT-", with: "")
        
        // 1. Identify if this is a pattern
        let pattern = self.rawPatterns.first(where: { "\($0.id)-d0" == cleanId })
            ?? self.allDrills.first(where: { $0.id == id && !$0.isBrick })?.drillDataToPatternData()
        
        guard let p = pattern else {
            // It's a brick or unknown: return decayed mastery
            return self.getDecayedMastery(for: cleanId)
        }
        
        // 2. Extract Structural Score (60%)
        let structureScore = self.getDecayedMastery(for: cleanId)
        
        // 3. Extract Semantic/Brick Score (40%)
        let brickIds = ContentAnalyzer.findRelevantBricks(
            in: p.target,
            meaning: p.meaning,
            bricks: self.lessonData?.bricks,
            targetLanguage: self.lessonData?.target_language ?? "es"
        )
        
        let brickMasteries = brickIds.map { self.getDecayedMastery(for: $0) }
        
        // 4. Final Weighted Blend (60/40 Rule)
        if brickMasteries.isEmpty {
            return structureScore
        } else {
            let brickAvg = brickMasteries.reduce(0, +) / Double(brickMasteries.count)
            let finalScore = (structureScore * 0.60) + (brickAvg * 0.40)
            return min(1.0, max(0.0, finalScore))
        }
    }
}

// Helper to convert DrillState back to PatternData for analysis
extension DrillState {
    func drillDataToPatternData() -> PatternData {
        return PatternData(
            id: self.patternId,
            target: self.drillData.target,
            meaning: self.drillData.meaning,
            phonetic: self.drillData.phonetic
        )
    }
}
