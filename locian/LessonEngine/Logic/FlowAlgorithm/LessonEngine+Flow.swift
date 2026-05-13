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
        
        // --- 🎯 ONE-PASS COMPLETION CHECK ---
        // Finish the session once every pattern has been visited at least once.
        // visitedPatternIds is populated by patternCompleted() each time a pattern finishes.
        let visited = orchestrator?.engine?.visitedPatternIds ?? []
        let allVisited = candidates.allSatisfy { visited.contains($0.id) }
        if allVisited && !visited.isEmpty {
            print("🏁 [Flow] ALL \(candidates.count) patterns completed (one full pass). Ending session.")
            DispatchQueue.main.async {
                self.orchestrator?.engine?.finishSession()
            }
            return
        }

        // --- 🎯 GLOBAL MASTERY CHECK (V5) ---
        // Also finish early if everything reaches full mastery before the pass is done.
        let allMastered = candidates.allSatisfy { (orchestrator?.engine?.getBlendedMastery(for: $0.id) ?? 0.0) >= 0.85 }
        if allMastered && !history.isEmpty {
            print("🏁 [Flow] ALL patterns mastered (Threshold: 0.85). Ending session early.")
            DispatchQueue.main.async {
                self.orchestrator?.engine?.finishSession()
            }
            return
        }
        
        // ✅ [ASA] STANDARD BLENDING: 
        // Use the engine's blended formula (60/40 or ASA) instead of raw structural scores.
        func getBlendedScore(for id: String) -> Double {
            return orchestrator?.engine?.getBlendedMastery(for: id) ?? 0.0
        }
        
        // 1. STOPPING LOGIC (The 0.85 Rule)
        // [DEPRECATED in V5: Replaced by Global check above]
        
        // 2. SELECTION LOGIC (Depth-First: Finish What You Started)
        
        // Deterministic start: pick the first candidate in lesson order.
        if history.isEmpty {
            if let firstStart = candidates.first {
                print("   📍 [Flow] Session Start: Picking FIRST pattern in order: \(firstStart.id)")
                orchestrator?.startPattern(firstStart)
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

        // 1. FILTER: Exclude History AND Mastered patterns (>= 0.85)
        let availablePool = candidates.filter { 
            !history.contains($0.id) && getBlendedScore(for: $0.id) < 0.85 
        }
        
        let pool = availablePool.isEmpty ? candidates : availablePool // Fallback if stuck
        
        // 2. FIND MAX SCORE
        // "Just pick the highest highest master... if everything is Zeero just pick a random one."
        let maxScore = pool.map { getBlendedScore(for: $0.id) }.max() ?? 0.0
        
        // 3. GET ALL CANDIDATES WITH MAX SCORE
        let bestCandidates = pool.filter { getBlendedScore(for: $0.id) == maxScore }
        
        print("   📊 [Flow] Max Score Found: \(String(format: "%.2f", maxScore))")
        print("   🎲 [Flow] Candidates with Max Score: \(bestCandidates.count)")
        
        // 4. DETERMINISTIC TIE-BREAKER (lesson order)
        // Pick the first candidate in original lesson order among tied best candidates.
        if let winner = pool.first(where: { candidate in
            bestCandidates.contains(where: { $0.id == candidate.id })
        }) {
            print("   ✅ [Flow] SELECTED (ORDER): \(winner.id) - \"\(winner.target)\"")
            orchestrator?.startPattern(winner)
        } else {
            // Should be impossible given pool logic, but safe fallback
            print("   ⚠️ [Flow] Fallback Safety Triggered")
            orchestrator?.startPattern(pool[0])
        }
    }
}
