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
        // ✅ NOW USING ALL BRICKS (Global Influence)
        let brickIds = ContentAnalyzer.findRelevantBricks(
            in: p.target,
            meaning: p.meaning,
            bricks: self.allBricks,
            targetLanguage: self.lessonData?.target_language ?? "es"
        )
        
        let brickMasteries = brickIds.map { self.getDecayedMastery(for: $0) }
        
        // 4. Final Weighted Blend (ASA Rule - Asymptotic Syntax Anchor)
        if brickMasteries.isEmpty {
            return structureScore
        } else {
            let brickAvg = brickMasteries.reduce(0, +) / Double(brickMasteries.count)
            
            // ✅ DYNAMIC WEIGHTING (ASA)
            // Low Mastery: 50/50 balance (Bricks are essential to start)
            // Mid Mastery: 75/25 balance (Architecture starts to dominate)
            // High Mastery: 90/10 balance (Architecture is the anchor; vocab errors shouldn't block progress)
            
            let structuralWeight: Double
            if structureScore < 0.30 {
                structuralWeight = 0.50
            } else if structureScore < 0.70 {
                structuralWeight = 0.75
            } else {
                structuralWeight = 0.90
            }
            
            let semanticWeight = 1.0 - structuralWeight
            let finalScore = (structureScore * structuralWeight) + (brickAvg * semanticWeight)
            
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
