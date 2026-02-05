//
//  MasteryCore.swift
//  locian
//
//  Shared configuration and utilities for mastery calculations.
//

import Foundation

/// Centralized configuration for mastery thresholds and penalties
struct MasteryConfig {
    struct Weights {
        static let newPatternStructure = 0.50 // WAS 1.0 - Now allows Vocab to help
        static let newPatternSemantic = 0.50  // WAS 0.0 - Now allows Vocab to help
        static let regularStructure = 0.60
        static let regularSemantic = 0.40
        
        // Relevance Filters (SIMILARITY: Higher is Better)
        static let strictSimilarity = 0.40 // For Novices (Strict match only)
        static let looseSimilarity = 0.00  // For Experts (Accept all)
    }
    
    
    struct Penalties {
        static let momentFailure = 0.50
        static let decayStability = 0.75
        static let severe = 0.30
        static let moderate = 0.15
        static let light = 0.10
    }
}

enum ComponentType {
    case brick
    case pattern
    case moment
}


/// Shared utility functions for mastery calculations
struct MasteryUtils {
    
    /// Calculates dynamic semantic relevance threshold based on mastery.
    /// Uses Linear Interpolation (LERP): Strict (0.4) -> Loose (0.0) as Mastery 0 -> 1
    static func getRelevanceThreshold(for mastery: Double) -> Double {
        let startSim = MasteryConfig.Weights.strictSimilarity
        let endSim = MasteryConfig.Weights.looseSimilarity
        let progress = max(0.0, min(mastery, 1.0)) // Clamp 0-1
        
        let threshold = startSim + ((endSim - startSim) * progress)
        
         print("      🎚️ [Relevance Internal] Mastery \(String(format: "%.2f", mastery)) -> LERP(\(startSim) -> \(endSim)) = \(String(format: "%.3f", threshold))")
        
        return threshold
    }
    
    /// Checks if a pattern is implicitly mastered (Fluent)
    static func checkImplicitMastery(avgResponseTime: TimeInterval, successRate: Double) -> Bool {
        // Must be very accurate (> 90%) and very fast (< 2.5s)
        let isFluent = successRate > 0.9 && avgResponseTime > 0 && avgResponseTime <= AdaptiveConfig.Fluency.fastThreshold
        
        if isFluent {
             print("      ⚡️ [Implicit Mastery] VALID: Speed \(String(format: "%.2f", avgResponseTime))s <= \(AdaptiveConfig.Fluency.fastThreshold)s AND Acc \(Int(successRate*100))% > 90%")
        }
        
        return isFluent
    }
}
