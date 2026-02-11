//
//  AdaptiveConfig.swift
//  locian
//
//  Created by Antigravity on 07/01/2026.
//

import Foundation

/// Centralized configuration for the adaptive lesson engine
struct AdaptiveConfig {
    
    // MARK: - Priority Weights (Mutable for Thermostat Drift)
    
    /// Weight for urgency component (Leitner-based spacing)
    static var w_urgency: Double = 0.4
    
    /// Weight for difficulty component (inverse success rate)
    static var w_difficulty: Double = 0.3
    
    /// Weight for exploration component (UCB1)
    static var w_exploration: Double = 0.15
    
    // MARK: - Semantic Thresholds (Mutable for Thermostat Drift)
    
    /// Similarity threshold above which interference penalty is applied (0.8 = Very Similar)
    static var interferenceThreshold: Double = 0.8
    
    /// Penalty weight for interference (Sim - Threshold) * weight
    static let w_interference: Double = 5.0 
    
    // Constant for fixed penalty if needed (though we use dynamic calc mostly)
    static var interferencePenalty: Double = 2.0
    
    /// Minimum similarity for clustering bonus
    static let clusteringMinSim: Double = 0.4
    
    /// Maximum similarity for clustering bonus
    static let clusteringMaxSim: Double = 0.75

    struct MasteryWeights {
        // GRANULAR DEMOTION LOGIC:
        // L3 (Typing) Failure -> Drops 25%
        // L2 (Voice) Failure -> Drops 15%
        // L1 (MCQ) Failure -> Drops 10%
        static let brick: [Int: Double] = [0: 0.2, 1: 0.5, 2: 0.6, 3: 0.75, 4: 1.0]
        
        // Pattern Weights follow similar curve
        // L3 (Typing) Error -> Drops 25%
        // L2 (Voice) Error -> Drops 15% (0.75 -> 0.60)
        static let pattern: [Int: Double] = [1: 0.6, 2: 0.75, 3: 1.0]
    }
    
    struct Fluency {
        static let fastThreshold: TimeInterval = 3.0 // < 3s = 100% Fluency
        static let slowThreshold: TimeInterval = 10.0 // > 10s = Penalized
        static let minMultiplier: Double = 0.8 // Floor for penalty (never go below 80% mastery due to speed)
    }
    

    
    /// Weight for clustering bonus
    static let w_clustering: Double = 0.3
    
    /// Weight for Bridge Bonus (Semantic Continuity)
    static let w_bridge: Double = 2.0
    
    // MARK: - Smart Bridging & Safety Guards
    
    /// Max consecutive drills with high overlap before forced break
    static let tunnelLimit: Int = 3
    
    /// Ideal overlap range (Goldilocks Zone)
    static let idealOverlapMin: Double = 0.3
    static let idealOverlapMax: Double = 0.7
    
    /// Max new cards allowed in rolling window
    static let maxIntroVelocity: Int = 3
    static let introWindowSize: Int = 10
    static let velocityPenaltyWeight: Double = 5.0


    // MARK: - Thermostat (Adaptive Drift) Configuration
    
    /// Maximum allowed drift per session
    static let maxDriftPerSession: Double = 0.05
    
    /// Target response time (seconds) - Baseline for "Fast" vs "Slow"
    static let targetResponseTime: TimeInterval = 4.0
    
    /// Boredom accuracy threshold
    static let boredomAccuracyThreshold: Double = 0.90
    
    /// Frustration accuracy threshold
    static let frustrationAccuracyThreshold: Double = 0.70
    
    // MARK: - Leitner System
    
    /// Review intervals for each Leitner box (in steps)
    static let leitnerBoxes: [Int] = [1, 2, 4, 8, 16]
    
    /// Continuous review interval function: 1.5^successCount
    static func reviewInterval(successCount: Int) -> Int {
        return min(Int(pow(1.5, Double(successCount))), 20)
    }
    
    // MARK: - Forgetting Curve
    
    /// Half-life multiplier (days per box level)
    static let halfLifeDays: Double = 3.0
    
    /// Retention threshold below which pattern is considered forgotten
    static let retentionThreshold: Double = 0.7
    
    /// Steps per day (for forgetting calculation)
    static let stepsPerDay: Double = 50.0
    
    // MARK: - Success Rate Tracking
    
    /// Window size for success rate calculation (last N results)
    static let successRateWindow: Int = 10
    
    /// Steps after which success rate is reset (fresh start)
    static let successRateResetSteps: Int = 100
    
    // MARK: - Intervention
    
    /// Maximum consecutive failures before intervention
    static let maxConsecutiveFailures: Int = 3
    
    /// Cooldown duration in steps (~24 hours)
    static let cooldownSteps: Int = 1200
    
    /// Minimum success rate before intervention
    static let interventionSuccessThreshold: Double = 0.3
    
    /// Minimum appearances before intervention
    static let interventionMinAppearances: Int = 10
    
    // MARK: - Mastery
    
    /// Intra-session decay per step if not seen
    static let w_sessionDecay: Double = 0.02
    
    /// Minimum appearances required for mastery
    static let masteryMinAppearances: Int = 3
    
    /// Minimum success rate required for mastery
    static let masterySuccessThreshold: Double = 0.75
    
    // MARK: - Cold Start
    
    /// Number of steps to use curated starter sequence
    static let coldStartSteps: Int = 15
    
    /// Curated starter patterns (easy, high-frequency)
    static let starterPatterns: [String] = []  // To be populated from API
    
    // MARK: - Semantic Clustering
    
    /// Number of clusters for k-means
    static let clusterCount: Int = 5
    
    /// Number of k-means iterations
    static let clusterIterations: Int = 10
    
    /// Maximum number of similar patterns to store per pattern
    static let maxSimilarPatterns: Int = 10
    
    // MARK: - Roadmap Improvements (from Spec Volume 8)
    
    /// Accuracy threshold below which word-level drills are triggered
    static let ambulanceAccuracyThreshold: Double = 0.2
    
    /// Maximum time (seconds) allowed per card before force-skipping
    static let abortThreshold: TimeInterval = 120.0
    
    /// Steps between dashboard/remote syncs
    static let dashboardSyncInterval: Int = 5
    
    /// Number of times to relax selection criteria before giving up
    static let selectionToleranceIterations: Int = 3
    
    /// Multiplier for cooldown step count for mastery successes
    static let cooldownMultiplier: Double = 2.5

    // MARK: - Cognitive Load Tracking
    
    /// Maximum cognitive load allowed in a rolling window
    static let maxCognitiveLoad: Double = 15.0
    
    /// Size of the rolling window for effort tracking
    static let cognitiveLoadWindow: Int = 5
    
    /// Effort weights per drill mode
    static let effortWeights: [DrillMode: Double] = [
        .mcq: 1.5,
        .voiceMcq: 2.0,
        .sentenceBuilder: 2.5,
        .cloze: 3.0,
        .typing: 4.0,
        .voiceTyping: 4.5,
        .voiceNativeTyping: 5.0,
        .mastery: 5.0,
        .componentMcq: 1.5,
        .componentTyping: 3.5,
        .speaking: 4.5
    ]
    
    // MARK: - Performance Smoothing
    
    /// Decay factor for the Exponential Moving Average (EMA) of success rates
    /// Increased to 0.4 for faster adaptation to "sick days" or sudden struggle.
    static let emaAlpha: Double = 0.4
    
    
    // MARK: - Persistence
    
    private static let weightsKey = "archon_adaptive_weights"
    
    static func saveWeights() {
        let weights: [String: Double] = [
            "w_urgency": w_urgency,
            "w_difficulty": w_difficulty,
            "w_exploration": w_exploration,
            "interferenceThreshold": interferenceThreshold
        ]
        UserDefaults.standard.set(weights, forKey: weightsKey)
    }
    
    static func loadWeights() {
        guard let weights = UserDefaults.standard.dictionary(forKey: weightsKey) as? [String: Double] else {
            return
        }
        
        if let urgency = weights["w_urgency"] { w_urgency = urgency }
        if let difficulty = weights["w_difficulty"] { w_difficulty = difficulty }
        if let interf = weights["interferenceThreshold"] { interferenceThreshold = interf }
        
        // Validate loaded value
        if interferenceThreshold <= clusteringMaxSim {
            interferenceThreshold = 0.8
        }
    }

    // MARK: - Validation
    
    /// Validate configuration on startup
    static func validate() {
        loadWeights() // Load personalized weights
        
        assert(w_urgency + w_difficulty + w_exploration <= 2.0, "Weights too high - priority inflation")
        
        // SIMILARITY LOGIC: Higher value = better match
        // interferenceThreshold (0.8) should be HIGHER than clusteringMaxSim (0.75)
        // This means interference requires MORE similarity (stricter)
        assert(interferenceThreshold > clusteringMaxSim, "Interference threshold (\(interferenceThreshold)) must be higher than clustering max (\(clusteringMaxSim)) - stricter similarity required")
        
        assert(clusteringMaxSim > clusteringMinSim, "Clustering max (\(clusteringMaxSim)) must be higher than clustering min (\(clusteringMinSim))")
        
        assert(retentionThreshold > 0 && retentionThreshold < 1, "Invalid retention threshold")
        assert(successRateWindow > 0, "Success rate window must be positive")
        assert(maxConsecutiveFailures > 0, "Max consecutive failures must be positive")
    }
}
