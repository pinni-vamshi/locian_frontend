import Foundation

// MARK: - THE SELECTOR (Logic)
class LessonFlow {
    
    // Dependency
    weak var orchestrator: LessonOrchestrator?
    
    func pickNextPattern(history: [String], mastery: [String: Double], candidates: [PatternData]) {
        
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
                // ALL PATTERNS IN CURRENT GROUP > 0.85 -> Advance or Stop
                DispatchQueue.main.async {
                    self.orchestrator?.engine?.advanceGroup()
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
        var potential = candidates.filter { !history.contains($0.id) }
        
        if potential.isEmpty {
            potential = candidates // Fallback to avoid stall
        }
        
        // Split into "Active" (Started) and "New" (Untouched)
        let active = potential.filter { getBlendedScore(for: $0.id) > 0.0 }
        let new = potential.filter { getBlendedScore(for: $0.id) == 0.0 }
        
        print("\n🌊 [Flow] SELECTION ANALYTICS (Using Blended ASA Mastery)")
        print("   - Total Candidates: \(potential.count)")
        print("   - Active Pool (>0.0): \(active.count)")
        print("   - New Pool (0.0): \(new.count)")
        
        let selected: PatternData
        
        if !active.isEmpty {
            // PRIORITY 1: Finish Active Patterns
            // Pick the HIGHEST mastery (closest to 0.85 finish line)
            print("   🌊 [Flow] Depth-First: Polishing Active (\(active.count) items)")
            
            // Log top active candidates
            let sortedActive = active.sorted { getBlendedScore(for: $0.id) > getBlendedScore(for: $1.id) }
            for (i, p) in sortedActive.prefix(5).enumerated() {
                print("      \(i+1). [\(p.id)] Mastery: \(String(format: "%.2f", getBlendedScore(for: p.id))) - \"\(p.target)\"")
            }
            
            selected = sortedActive.first ?? active[0]
            print("   ✅ SELECTED: \(selected.id) (Mastery: \(String(format: "%.2f", getBlendedScore(for: selected.id))))")
            
        } else {
            // PRIORITY 2: Start New Patterns
            // Pick from New (Order is usually sequential from groups)
            print("   🌊 [Flow] Depth-First: Starting New (\(new.count) items)")
             if let firstNew = new.first {
                print("   ✅ SELECTED NEW: \(firstNew.id) - \"\(firstNew.target)\"")
                selected = firstNew
             } else {
                selected = candidates[0]
             }
        }
        
        // 3. HANDOFF: Flow -> Orchestrator
        orchestrator?.startPattern(selected)
    }
}
