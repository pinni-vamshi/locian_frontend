import Foundation
import Combine
import NaturalLanguage

class LessonEngine: ObservableObject {
    
    // MARK: - Core State
    @Published var allDrills: [DrillState] = []
    @Published var currentStep: Int = 0
    
    /// The dispatch queue for special sequences (e.g. Intro -> Brick -> Main Pattern)
    @Published var selectionQueue: [String] = [] 
    
    /// Pure Mastery Scores provided by the API or current session
    @Published var componentMastery: [String: Double] = [:] 
    
    // MARK: - Data Source
    var lessonData: GenerateSentenceData?
    @Published var isTransitionReady: Bool = false 
    
    // NEW: Raw patterns for JIT creation (like bricks)
    var rawPatterns: [PatternData] = []
    @Published var visitedPatternIds: Set<String> = []
    @Published var lastDrilledBricks: [BrickItem] = []
    
    /// Tracks the 'Step' (card count) when a component was last successfully recalled.
    @Published var lastRecallStep: [String: Int] = [:]
    
    // Session Guardrails
    var sessionStartTime: Date?
    static let MIN_SESSION_DURATION: TimeInterval = 60 * 2 // 2 minutes
    static let MAX_SESSION_DURATION: TimeInterval = 60 * 10 // 10 minutes
    
    // External Services
    var validator: NeuralValidator?
    
    // MARK: - Properties for UI/Debug (Stateless)
    var isAmbulanceModeActive: Bool = false
    var currentCognitiveLoad: Double = 0.0
    
    struct MinimalStats {
        var correctAnswers: Int = 0
        var totalQuestions: Int = 0
        var accuracyRate: Double { totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) : 0.0 }
        var lastSimilarityScore: Double?
    }
    @Published var stats = MinimalStats()
    
    // Cooldown and Orchestration helpers
    var cooldownService = CooldownService() // Assuming it's stateless or managed elsewhere
    var history: [DrillResultEntry] = [] // Minimal history for interleaving logic
    
    // MARK: - Initialization
    func initialize(with data: GenerateSentenceData) {
        self.lessonData = data
        self.allDrills = []
        self.currentStep = 0
        self.selectionQueue = []
        self.visitedPatternIds = []
        self.lastDrilledBricks = []
        self.sessionStartTime = Date()
        
        // JIT: Store raw patterns, don't create DrillStates upfront
        self.rawPatterns = data.patterns ?? []
        
        let brickCount = (data.bricks?.constants?.count ?? 0) + 
                         (data.bricks?.variables?.count ?? 0) + 
                         (data.bricks?.structural?.count ?? 0)
                         
        print("\n🚀 [Engine: Init] Session Start")
        print("   📦 Patterns: \(rawPatterns.count)")
        print("   🧱 Bricks available: \(brickCount)")
        print("   🌐 Target Language: \(data.target_language ?? "unknown")")
        
        // Initialize Decay Tracker: Everyone starts at step 0
        self.lastRecallStep = [:]
        data.patterns?.forEach { self.lastRecallStep["\($0.pattern_id)-d0"] = 0 }
        
        // PERSISTENCE: 2. Load Stored Mastery Scores (Now Pre-filled by Logic Layer)
        print("   💾 [Engine] Loading Persistent Mastery Scores...")
        
        // A. Load Brick Mastery
        let allBricks: [BrickItem] = (data.bricks?.constants ?? []) + 
                                     (data.bricks?.variables ?? []) + 
                                     (data.bricks?.structural ?? [])
                                     
        for brick in allBricks {
            let text = brick.word
            // Direct Read: Logic Layer already populated this from DB
            if let score = brick.mastery {
                componentMastery[brick.safeID] = score
                if score > 0.1 {
                     print("      ✅ [Engine] Restored Mastery for Brick '\(text)': \(String(format: "%.2f", score))")
                }
            } else {
                componentMastery[brick.safeID] = 0.0
            }
            self.lastRecallStep[brick.safeID] = 0
        }
        
        // B. Load Pattern Mastery (NEW: Fixes Pattern Mode Selection)
        if let patterns = data.patterns {
            for pattern in patterns {
                let id = pattern.pattern_id
                // Direct Read: Logic Layer already populated this
                if let score = pattern.mastery {
                    componentMastery[id] = score
                    if score > 0.1 {
                        print("      ✅ [Engine] Restored Mastery for Pattern '\(id)': \(String(format: "%.2f", score))")
                    }
                } else {
                    componentMastery[id] = 0.0
                }
                // Patterns have multiple drill types (-d0, -d1 etc), but base mastery is per Pattern ID
            }
        }
    }
    
    func calculateOverallProgress() -> Double {
        let masteredCount = allDrills.filter { getBlendedMastery(for: $0.id) >= 0.95 }.count
        return allDrills.isEmpty ? 0.0 : Double(masteredCount) / Double(allDrills.count)
    }

    func calculatePatternPriority(pattern: DrillState, lastPattern: DrillResultEntry?) -> Double {
        // Pure stateless priority calculation (mocked for now)
        return 1.0 
    }
    
    /// Returns the mastery score adjusted for intra-session decay.
    /// Uses 'w_sessionDecay' (-0.02) per step since last recall.
    func getDecayedMastery(for id: String) -> Double {
        let rawMastery = componentMastery[id] ?? 0.0
        let lastStep = lastRecallStep[id] ?? 0
        let stepsSince = max(0, currentStep - lastStep)
        
        if stepsSince == 0 { return rawMastery }
        
        let decay = Double(stepsSince) * AdaptiveConfig.w_sessionDecay
        let effectiveMastery = max(0.0, rawMastery - decay)
        
        if decay > 0 {
             print("      📉 [Memory Decay] [\(id)]")
             print("         ↳ Steps Since Recall: \(stepsSince) steps (At Step: \(currentStep))")
             print("         ↳ Formula: \(String(format: "%.2f", rawMastery)) - (\(stepsSince) * \(String(format: "%.3f", AdaptiveConfig.w_sessionDecay)))")
             print("         ↳ Effective Mastery: \(String(format: "%.2f", effectiveMastery))")
        }
        
        return effectiveMastery
    }
    
    // MARK: - Mastery Updates (Consolidated)
    
    // MARK: - Mastery Hub (Simplified)
    
    /// Updates the mastery score for a component by a specific delta.
    func updateMastery(id: String, delta: Double, reason: String = "") {
        let current = componentMastery[id] ?? 0.0
        let newValue = (current + delta).clamped(to: 0.0...1.0)
        componentMastery[id] = newValue
        
        // RECALL REFRESH: If score improved or stayed high, reset the decay timer
        if delta >= 0 {
            lastRecallStep[id] = currentStep
            print("      ✨ [Memory: Recall] [\(id)] Reset timer to step \(currentStep)")
        }
        
        let direction = delta > 0 ? "📈" : (delta < 0 ? "📉" : "⚪️")
        let icon = reason.contains("Brick") || reason.contains("Ripple") ? "🧱" : "🧬"
        
        print("      \(direction) \(icon) [Mastery Update] [\(id)]")
        print("         ↳ Current: \(String(format: "%.2f", current)) -> New: \(String(format: "%.2f", newValue)) (Δ \(String(format: "%.3f", delta)))")
        print("         ↳ Reason: \(reason)")
        
        // PERSISTENCE: 3. Save to Disk (Via Logic Layer)
        // We need to resolve the ID to a Brick OR Pattern to get its text/vector
        if let brick = resolveBrick(id: id) {
            let text = brick.word
            // Optimization: Vector should be available on the model
            let vector = brick.vector ?? validator?.getVector(for: text)
            
            GenerateSentenceLogic.shared.updateMastery(
                text: text,
                vector: vector,
                mode: "practice",
                isCorrect: delta > 0
            )
        } else if let pattern = resolvePattern(id: id) {
            let text = pattern.meaning // Track patterns by Meaning
            let vector = pattern.vector // Should be on model
            
            GenerateSentenceLogic.shared.updateMastery(
                text: text,
                vector: vector,
                mode: "practice",
                isCorrect: delta > 0
            ) 
        }
    }
    
    private func resolveBrick(id: String) -> BrickItem? {
        let all = (lessonData?.bricks?.constants ?? []) + 
                  (lessonData?.bricks?.variables ?? []) + 
                  (lessonData?.bricks?.structural ?? [])
        // ID often matches one of these
        // IDs are "INT-xxx" stripped usually before calling updateMastery?
        // updateMastery(id: "apple") usually.
        return all.first { ($0.id ?? $0.word) == id }
    }
    
    private func resolvePattern(id: String) -> PatternData? {
        return rawPatterns.first { $0.pattern_id == id }
    }
}

// MARK: - Clamping Helper
extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(range.upperBound, self))
    }
}

// Minimal placeholder types for compilation
struct CooldownService {
    var recentPatterns: [String] = []
}

