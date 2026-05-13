import Foundation

extension LessonEngine {
    
    /// Returns the simple mastery for a given ID (Pattern or Brick).
    /// Cleaned of all "Shitty" artificial weights and string stripping.
    func getBlendedMastery(for id: String) -> Double {
        // 2. Identify if this is a Pattern
        _ = self.allPatterns.first(where: { $0.id == id })
        // We don't actually need the pattern object, just to verify it exists if we were using it for grouping,
        // but here we just check our map.
        
        let directScore = self.getDecayedMastery(for: id)
        
        // 3. Find the constituent bricks for this pattern
        // ✅ ROOT FIX: Instead of re-running the heavy Semantic Scan every frame,
        // we use the precomputed mapping from the engine initialization.
        guard let relevantBrickIds = self.patternBrickMap[id] else {
            return directScore
        }
        
        // 4. Calculate the average mastery of all component bricks
        guard !relevantBrickIds.isEmpty else {
            return directScore
        }
        
        let brickScores = relevantBrickIds.map { self.getDecayedMastery(for: $0) }
        let averageBrickMastery = brickScores.reduce(0, +) / Double(brickScores.count)
        
        // 5. BLENDED FORMULA: Weighted Average (60% Direct, 40% Components)
        // This ensures the pattern score is truly "blended" and can be pulled down by its bricks.
        let blendedScore = (directScore * 0.6) + (averageBrickMastery * 0.4)
        
        // Log the breakdown for debugging
        if directScore > 0 || averageBrickMastery > 0 {
            print("📊 [BlendedMastery] Pattern '\(id)': Direct=\(String(format: "%.2f", directScore)) | BricksAvg=\(String(format: "%.2f", averageBrickMastery)) -> Final=\(String(format: "%.2f", blendedScore))")
        }
        
        return blendedScore.clamped(to: 0.0...1.0)
    }
}
