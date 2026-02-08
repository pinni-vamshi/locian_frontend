import Foundation

extension LessonEngine {
    
    // MARK: - MAIN LOOP: Get Next Card
    
    /// Determines the next state to show (The Heartbeat)
    func getNextState() -> DrillState? {
        guard var state = _getNextBaseState() else { return nil }
        
        // Enrich state with JIT mastery score for UI/Dispatch
        state.masteryScore = getBlendedMastery(for: state.id)
        
        print("\n💓 [Engine] --- Heartbeat ---")
        print("   ✅ [Engine] Serving Purified State: \(state.id)")
        print("   📊 [Engine] Current Blended Mastery: \(String(format: "%.2f", state.masteryScore))")
        return state
    }
    
    private func _getNextBaseState() -> DrillState? {
        // 1. Check Buffer (Selection Queue)
        // Orchestrated stages (STAGE- prefix) and standard IDs are both handled by popNextOrchestratedState.
        // We loop because a stage might fail to materialize (e.g. missing pattern), 
        // in which case we want the NEXT item in the queue, not a total fallback.
        while !selectionQueue.isEmpty {
            if let orchestrated = popNextOrchestratedState() {
                return orchestrated
            }
        }
        
        // 2. JIT Pattern Selection (Semantic Chaining)
        if let nextPattern = findSmartNextPattern() {
            let patternState = materializePatternState(nextPattern)
            return getOrchestratedState(for: patternState)
        }
        
        return nil
    }
    
    // MARK: - JIT Pattern Helpers
    
    /// Selects the next pattern using Semantic Chaining ("The Ripple Effect")
    private func findSmartNextPattern() -> PatternData? {
        // 1. Check Session Guardrails
        let elapsed = Date().timeIntervalSince(sessionStartTime ?? Date())
        
        // Calculate mastery for all patterns
        let patternProgress = rawPatterns.map { getBlendedMastery(for: "\($0.pattern_id)-d0") }
        let allMastered = patternProgress.allSatisfy { $0 >= 0.80 }
        
        print("   🕒 [Flow: Guardrails] Elapsed: \(Int(elapsed))s | All Mastered (80%): \(allMastered)")
        
        // DECISION: Should we stop?
        if elapsed >= LessonEngine.MAX_SESSION_DURATION {
            print("   🏁 [Flow: Stop] MAX duration reached (\(Int(elapsed))s). Ending session.")
            return nil
        }
        
        if allMastered && elapsed >= LessonEngine.MIN_SESSION_DURATION {
            print("   🏁 [Flow: Stop] Goal reached (All 80% + Min duration). Ending session.")
            return nil
        }

        // 2. Identify Candidates
        // Candidates are:
        // A. Unvisited Patterns
        // B. Visited Patterns with < 80% mastery (if unvisited are exhausted)
        var candidates = rawPatterns.filter { !visitedPatternIds.contains($0.pattern_id) }
        
        if candidates.isEmpty && (!allMastered || elapsed < LessonEngine.MIN_SESSION_DURATION) {
            print("   🔄 [Flow: Loop] Unvisited exhausted but goals not met. Enabling Re-visit Mode.")
            // Allow re-visiting patterns below 80%
            candidates = rawPatterns.filter { 
                let sim = getBlendedMastery(for: "\($0.pattern_id)-d0")
                return sim < 0.80 
            }
            
            // If even those are empty (e.g. all are 0.8 but time is < min), allow re-visiting everything
            if candidates.isEmpty { 
                candidates = rawPatterns 
            }
        }
        
        print("   🧠 [Flow: Chaining] Candidates Remaining: \(candidates.count)")
        
        guard !candidates.isEmpty else { return nil }
        
        // 3. If it's the first pattern, pick a random one
        guard !lastDrilledBricks.isEmpty else {
            let first = candidates.randomElement() 
            if let first = first {
                visitedPatternIds.insert(first.pattern_id)
            }
            return first
        }
        
        // 4. Score all candidates
        var bestPattern: PatternData? = nil
        var highestScore: Double = -1.0
        
        for pattern in candidates {
            // A. Semantic Similarity (70%)
            var totalSemanticSim: Double = 0.0
            let targetLang = lessonData?.target_language ?? "es"
            
            for brick in lastDrilledBricks {
                let sim = EmbeddingService.compare(textA: brick.word, textB: pattern.target, languageCode: targetLang)
                totalSemanticSim = max(totalSemanticSim, sim)
            }
            
            // B. Word Overlap (30%)
            let currentWords = Set(pattern.target.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted))
            var overlapCount = 0
            for brick in lastDrilledBricks {
                if currentWords.contains(brick.word.lowercased()) {
                    overlapCount += 1
                }
            }
            let overlapScore = Double(min(overlapCount, 3)) / 3.0 
            
            // C. Combined Score
            let finalScore = (totalSemanticSim * 0.7) + (overlapScore * 0.3)
            
            print("      🧪 [Flow: Candidate] '\(pattern.target.prefix(25))...'")
            print("         ↳ Semantic Sim (70%): \(String(format: "%.3f", totalSemanticSim))")
            print("         ↳ Word Overlap (30%): \(String(format: "%.3f", overlapScore))")
            print("         ↳ FINAL SCORE: \(String(format: "%.3f", finalScore))")
            
            if finalScore > highestScore {
                highestScore = finalScore
                bestPattern = pattern
            }
        }
        
        if let winner = bestPattern {
            print("   🎯 [Flow: Winner] '\(winner.target)' (Score: \(String(format: "%.2f", highestScore)))")
            visitedPatternIds.insert(winner.pattern_id)
        }
        
        return bestPattern
    }
    
    // Legacy helper replaced by findSmartNextPattern
    private func getNextUnmasteredPattern() -> PatternData? {
        return findSmartNextPattern()
    }
    
    /// Creates a DrillState from raw PatternData (JIT Materialization)
    private func materializePatternState(_ pattern: PatternData) -> DrillState {
        let drillId = "\(pattern.pattern_id)-d0"
        
        // Check if already materialized
        if let existing = allDrills.first(where: { $0.id == drillId }) {
            return existing
        }
        
        // JIT: Create DrillState on demand
        print("   🏭 [JIT] Materializing Pattern: [\(pattern.pattern_id)] -> '\(pattern.target.prefix(30))...'")
        let drillItem = DrillItem(
            target: pattern.target,
            meaning: pattern.meaning,
            phonetic: pattern.phonetic
        )
        
        let drillState = DrillState(
            id: drillId,
            patternId: pattern.pattern_id,
            drillIndex: rawPatterns.firstIndex(where: { $0.pattern_id == pattern.pattern_id }) ?? 0,
            drillData: drillItem,
            isBrick: false
        )
        
        allDrills.append(drillState)
        return drillState
    }
}
