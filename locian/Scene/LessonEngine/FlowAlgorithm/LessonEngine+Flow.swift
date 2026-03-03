import Foundation

// MARK: - THE SELECTOR (Logic)
class LessonFlow {
    
    // Dependency
    weak var orchestrator: LessonOrchestrator?
    
    func pickNextPattern(history: [String], mastery: [String: Double], candidates: [PatternData]) {
        guard !candidates.isEmpty else {
            print("⚠️ [Flow] pickNextPattern called with EMPTY candidates. Aborting.")
            return
        }
        
        // ✅ [ASA] STANDARD BLENDING: 
        // Use the engine's blended formula (60/40 or ASA) instead of raw structural scores.
        func getBlendedScore(for id: String) -> Double {
            return orchestrator?.engine?.getBlendedMastery(for: id) ?? 0.0
        }
        
        // 1. STOPPING LOGIC (The 0.85 Rule)
        
        // Check A: Are all NON-HISTORY patterns mastered?
        let nonHistoryCandidates = candidates.filter { !history.contains($0.id) }
        let allNonHistoryMastered = nonHistoryCandidates.allSatisfy { getBlendedScore(for: $0.id) >= 0.85 }
        
        if allNonHistoryMastered && !history.isEmpty {
            // Check B: Look at History. Any weak patterns there?
            let historyWeakSpots = candidates.filter { history.contains($0.id) && getBlendedScore(for: $0.id) < 0.85 }
            
            if historyWeakSpots.isEmpty {
                // ALL PATTERNS > 0.85 -> FINISH SESSION
                DispatchQueue.main.async {
                    self.orchestrator?.engine?.finishSession()
                }
                return
            } else {
                // Polish the weakest link in the recent history
                if let weakest = historyWeakSpots.min(by: { getBlendedScore(for: $0.id) < getBlendedScore(for: $1.id) }) {
                    orchestrator?.startPattern(weakest)
                    return
                }
            }
        }
        
        // 2. SELECTION LOGIC (Depth-First: Finish What You Started)
        
        // ✅ USER REQUEST: "First one be random"
        // If this is the START of a session (no history), pick a random pattern to begin.
        if history.isEmpty {
            if let randomStart = candidates.randomElement() {
                print("   🎲 [Flow] Session Start: Picking RANDOM first pattern: \(randomStart.id)")
                orchestrator?.startPattern(randomStart)
                return
            }
        }
        
        var potential = candidates.filter { !history.contains($0.id) }
        
        if potential.isEmpty {
            potential = candidates // Fallback to avoid stall
        }
        
        print("\n🌊 [Flow] SIMPLIFIED SELECTION LOGIC TRIGGERED")
        print("   - Candidates Total: \(candidates.count)")
        print("   - History Buffer (Last 3): \(history)")

        // 1. FILTER: Exclude History
        let availablePool = candidates.filter { !history.contains($0.id) }
        
        let pool = availablePool.isEmpty ? candidates : availablePool // Fallback if stuck
        
        // 2. FIND MAX SCORE
        // "Just pick the highest highest master... if everything is Zeero just pick a random one."
        let maxScore = pool.map { getBlendedScore(for: $0.id) }.max() ?? 0.0
        
        // 3. GET ALL CANDIDATES WITH MAX SCORE
        // This handles both the "Finish Best" case and the "Randomize Zeros" case automatically.
        let bestCandidates = pool.filter { getBlendedScore(for: $0.id) == maxScore }
        
        print("   📊 [Flow] Max Score Found: \(String(format: "%.2f", maxScore))")
        print("   🎲 [Flow] Candidates with Max Score: \(bestCandidates.count)")
        
        // 4. RANDOM TIE-BREAKER
        // If maxScore is 0.0, this picks a random new pattern.
        // If maxScore is 0.84, this picks a random high-mastery pattern to finish.
        if let winner = bestCandidates.randomElement() {
            print("   ✅ [Flow] SELECTED: \(winner.id) - \"\(winner.target)\"")
            orchestrator?.startPattern(winner)
        } else {
            // Should be impossible given pool logic, but safe fallback
            print("   ⚠️ [Flow] Fallback Safety Triggered")
            orchestrator?.startPattern(pool[0])
        }
    }
}
