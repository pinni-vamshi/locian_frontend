import Foundation

// MARK: - THE SELECTOR (Logic)
class LessonFlow {
    
    // Dependency
    weak var orchestrator: LessonOrchestrator?
    
func pickNextPattern(history: [String], mastery: [String: Double], candidates: [PatternData]) {
        
        // 1. STOPPING LOGIC (The 0.85 Rule)
        
        // Check A: Are all NON-HISTORY patterns mastered?
        let nonHistoryCandidates = candidates.filter { !history.contains($0.id) }
        let allNonHistoryMastered = nonHistoryCandidates.allSatisfy { (mastery[$0.id] ?? 0.0) >= 0.85 }
        
        if allNonHistoryMastered && !history.isEmpty {
            // Check B: Look at History. Any weak patterns there?
            let historyWeakSpots = candidates.filter { history.contains($0.id) && (mastery[$0.id] ?? 0.0) < 0.85 }
            
            if historyWeakSpots.isEmpty {
                // ALL PATTERNS IN CURRENT GROUP > 0.85 -> Advance or Stop
                print("   🏁 [Flow] ALL patterns in group mastered (>0.85). Advancing Group...")
                DispatchQueue.main.async {
                    self.orchestrator?.engine?.advanceGroup()
                }
                return
            } else {
                // Polish the weakest link in the recent history
                if let weakest = historyWeakSpots.min(by: { (mastery[$0.id] ?? 0.0) < (mastery[$1.id] ?? 0.0) }) {
                    print("   ✨ [Flow] Non-history mastered. Polishing weakest history pattern: \(weakest.id)")
                    orchestrator?.startPattern(weakest)
                    return
                }
            }
        }
        
        // 2. SELECTION LOGIC (Target Weakest Unseen)
        var potential = candidates.filter { !history.contains($0.id) }
        
        if potential.isEmpty {
            // Everything has been seen in the recent history window.
            // Pick from all candidates to ensure we don't stall.
            potential = candidates
        }
        
        // --- Heat-Seeking Selection ---
        // Pick the pattern with the absolute LOWEST mastery that is not in the recent history.
        let selected = potential.min(by: { 
            (mastery[$0.id] ?? 0.0) < (mastery[$1.id] ?? 0.0)
        }) ?? candidates[0]
        
        print("   🎯 [Flow] Selected Weakest Candidate: '\(selected.id)' (Mastery: \(String(format: "%.2f", mastery[selected.id] ?? 0.0)))")
        
        // 3. HANDOFF: Flow -> Orchestrator
        orchestrator?.startPattern(selected)
    }
}
