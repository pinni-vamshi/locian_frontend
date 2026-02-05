import Foundation

/// Centralized calculator for weighted mastery scores
struct MasteryCalculator {
    
    
    /// Calculates the weighted mastery percentage (0.0 - 1.0) for a pattern
    /// - Parameters:
    ///   - id: Pattern ID
    ///   - patternScore: The stored structural mastery score (0.0 - 1.0)
    ///   - brickIds: List of constituent brick IDs
    ///   - brickMastery: Dictionary of Brick ID -> Current Mastery Score (0.0 - 1.0)
    ///   - brickWeights: Importance weights
    ///   - avgResponseTime: Fluency
    ///   - isNewPattern: If true, semantics counts for LESS (prevents skipping grammar practice)
    static func calculatePatternMastery(id: String, patternScore: Double, brickIds: [String] = [], brickMastery: [String: Double] = [:], brickWeights: [String: Double] = [:], avgResponseTime: TimeInterval? = nil, isNewPattern: Bool = false) -> Double {
        
        // 1. Structural Mastery (The Pattern itself)
        let structureScore = patternScore
        
        // 2. Semantic Mastery (The Bricks inside)
        var brickScore: Double = 0.0
        if !brickIds.isEmpty {
            // Simple Average of all bricks
            let total = brickIds.map { brickMastery[$0] ?? 0.0 }.reduce(0, +)
            brickScore = total / Double(brickIds.count)
        } else {
            // If no bricks, semantic score matches structure (it's purely structural)
            brickScore = structureScore
        }
        
        // 3. Final Score: 50% Structure, 50% Semantics
        // No fancy weights, no time multipliers, no 'new pattern' logic.
        let combinedScore = (structureScore + brickScore) / 2.0
        
        print("   🧮 [Basics Calc] \(id): (Struct \(String(format: "%.2f", structureScore)) + Bricks \(String(format: "%.2f", brickScore))) / 2 = \(String(format: "%.2f", combinedScore))")
        
        return min(combinedScore, 1.0)
    }
    
    /// Checks if a pattern is implicitly mastered (Fluent)
    static func checkImplicitMastery(avgResponseTime: TimeInterval, successRate: Double) -> Bool {
        // Must be very accurate (> 90%) and very fast (< 2.5s)
        return successRate > 0.9 && avgResponseTime > 0 && avgResponseTime <= AdaptiveConfig.Fluency.fastThreshold
    }
    


}
