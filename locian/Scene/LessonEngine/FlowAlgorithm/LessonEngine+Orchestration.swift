import Foundation

extension LessonEngine {
    
    // MARK: - ORCHESTRATION LAYER
    // "The Sequential Dispatcher"
    
    /// Determines the next macro-sequence for a pattern.
    /// It populates the selectionQueue with high-level task identifiers.
    func getOrchestratedState(for state: DrillState) -> DrillState {
        print("\n👮 [Orchestrator] Orchestrating: \(state.id)")
        
        // 1. Data Prep: Find relevant bricks for this pattern
        let brickMatches = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: lessonData?.bricks,
            targetLanguage: lessonData?.target_language ?? "es"
        )
        _ = MasteryFilterService.resolveBricks(ids: Set(brickMatches.map { $0.id }), from: lessonData?.bricks)
        
        // 2. High-Level Sequence Building
        // Stage 1: Intro (Intro Card + Individual Brick Drills)
        // Stage 2: Ghost (Find past pattern + Practice Pattern)
        // Stage 3: Target Practice (Current Pattern Drill)
        
        selectionQueue.removeAll()
        
        // ALWAYS push the 3-stage sequence
        selectionQueue.append("STAGE-INTRO-\(state.id)")
        selectionQueue.append("STAGE-GHOST-\(state.id)")
        selectionQueue.append("STAGE-DRILL-\(state.id)")
        
        print("   👮 [Orchestrator] Sequence Loaded: INTRO -> GHOST -> DRILL")
        
        // 3. Pop and return the first state
        return popNextOrchestratedState() ?? state
    }
    
    /// Processes the selection queue and materializes the next stage.
    /// This keeps the Flow motor clean.
    func popNextOrchestratedState() -> DrillState? {
        guard !selectionQueue.isEmpty else { return nil }
        let nextId = selectionQueue.removeFirst()
        print("   👮 [Orchestrator] Popping from Queue: \(nextId)")
        
        // Handle STAGE-INTRO-
        if nextId.hasPrefix("STAGE-INTRO-") {
            let patternId = nextId.replacingOccurrences(of: "STAGE-INTRO-", with: "")
            if let drill = allDrills.first(where: { $0.id == patternId }) {
                let brickMatches = ContentAnalyzer.findRelevantBricksWithSimilarity(
                    in: drill.drillData.target,
                    meaning: drill.drillData.meaning,
                    bricks: lessonData?.bricks,
                    targetLanguage: lessonData?.target_language ?? "es"
                )
                let resolvedBricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches.map { $0.id }), from: lessonData?.bricks)
                
                // SKIP: If no bricks to introduce, immediately pop the next stage
                if resolvedBricks.isEmpty {
                    print("   ⏭️ [Orchestrator] Skipping empty INTRO for \(patternId)")
                    return popNextOrchestratedState()
                }
                
                return materializeStageState(id: "STAGE-INTRO-", targetPattern: drill, bricks: resolvedBricks)
            }
        }
        
        // Handle STAGE-GHOST-
        if nextId.hasPrefix("STAGE-GHOST-") {
            let drillId = nextId.replacingOccurrences(of: "STAGE-GHOST-", with: "")
            
            if let drill = allDrills.first(where: { $0.id == drillId }) {
                // SKIP: If no past patterns visited yet, immediately pop the next stage
                // visitedPatternIds contains raw IDs like "p1", "p2"
                let visited = visitedPatternIds.filter { $0 != drill.patternId }
                if visited.isEmpty {
                    print("   👻 [Orchestrator] No past patterns for Ghost Rehearsal. Skipping \(drillId).")
                    return popNextOrchestratedState()
                }
                
                return materializeStageState(id: "STAGE-GHOST-", targetPattern: drill, bricks: [])
            }
        }
        
        // Handle STAGE-DRILL- (Step 3: Pattern Drill)
        if nextId.hasPrefix("STAGE-DRILL-") {
            let patternId = nextId.replacingOccurrences(of: "STAGE-DRILL-", with: "")
            if let drill = allDrills.first(where: { $0.id == patternId }) {
                print("   🎯 [Orchestrator] Step 3: Serving Target Practice for \(drill.id)")
                return drill // The pattern mode selector will handle this
            }
        }
        
        // Fallback for standard IDs
        if let drill = allDrills.first(where: { $0.id == nextId }) {
             return drill
        }
        
        return nil
    }
    
    /// Translates a STAGE-ID into a DrillState that the UI can handle.
    func materializeStageState(id: String, targetPattern: DrillState, bricks: [BrickItem]) -> DrillState {
        var state = targetPattern
        state.batchBricks = bricks
        
        if id.hasPrefix("STAGE-INTRO-") {
            state.currentMode = .vocabIntro
            return state
        } else if id.hasPrefix("STAGE-GHOST-") {
            state.currentMode = .ghostManager 
            return state
        } else {
            return state
        }
    }
}
