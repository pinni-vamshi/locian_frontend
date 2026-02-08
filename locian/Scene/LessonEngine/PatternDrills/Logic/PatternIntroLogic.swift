import SwiftUI
import Combine

class PatternIntroLogic: ObservableObject {
    @Published var currentBrickIndex: Int = 0
    @Published var shouldSkip: Bool = false
    
    let state: DrillState
    let session: LessonSessionManager
    
    // Skeleton DrillStates (Modes resolved JIT)
    var brickDrills: [DrillState]
    
    init(state: DrillState, session: LessonSessionManager) {
        self.state = state
        self.session = session
        let rawBricks = state.batchBricks ?? []
        
        // 1. Prepare skeleton states (Deduplicated)
        var seenIds = Set<String>()
        var drills: [DrillState] = []
        
        for brick in rawBricks {
            let brickId = brick.id ?? brick.word
            if seenIds.contains(brickId) { continue }
            seenIds.insert(brickId)
            
            let drillId = "INT-\(brickId)"
            let drillItem = DrillItem(
                target: brick.word,
                meaning: brick.meaning,
                phonetic: brick.phonetic
            )
            
            var brickState = DrillState(
                id: drillId,
                patternId: state.patternId,
                drillIndex: -1,
                drillData: drillItem,
                isBrick: true
            )
            brickState.contextMeaning = state.drillData.meaning
            brickState.contextSentence = state.drillData.target
            drills.append(brickState)
        }
        
        self.brickDrills = drills
        print("\n🧑‍🏫 [PatternIntro] Initializing Sequence for Pattern: \(state.patternId)")
        print("   - Raw Bricks: \(rawBricks.count)")
        print("   - Unique Bricks: \(brickDrills.count)")
        print("   - Dropped Duplicates: \(rawBricks.count - brickDrills.count)")
        
        for (i, drill) in brickDrills.enumerated() {
            print("   brick[\(i)]: '\(drill.drillData.target)' (ID: \(drill.id))")
        }
        
        if brickDrills.isEmpty {
            // Orchestrator should have skipped this, but safety fallback
            print("   ⚠️ [PatternIntroLogic] No bricks found. Should have been skipped.")
        } else {
            // Resolve mode for the first brick immediately
            resolveCurrentMode(at: 0)
        }
    }
    
    var currentDrill: DrillState? {
        guard currentBrickIndex < brickDrills.count else { return nil }
        return brickDrills[currentBrickIndex]
    }
    
    private func resolveCurrentMode(at index: Int) {
        guard index < brickDrills.count else { return }
        
        // Don't re-resolve if already set
        if brickDrills[index].currentMode != nil { return }
        
        // Resolve mode for THIS specific brick AT THIS MOMENT
        let mode = BrickModeSelector.resolveMode(for: brickDrills[index], session: session)
        brickDrills[index].currentMode = mode
        
        print("   🧱 [IntroLoop-JIT] Resolved [\(brickDrills[index].id)] Mode: \(mode.rawValue)")
    }
    
    // Track completed bricks to prevent double-advancement
    private var completedIndices: Set<Int> = []
    
    func advance() {
        // Guard: Only advance if this index isn't already marked done
        guard !completedIndices.contains(currentBrickIndex) else { return }
        completedIndices.insert(currentBrickIndex)
        
        if currentBrickIndex < brickDrills.count - 1 {
            withAnimation(.spring()) {
                currentBrickIndex += 1
                // Resolve mode for the NEW active brick JIT
                resolveCurrentMode(at: currentBrickIndex)
            }
            print("   🧑‍🏫 [PatternIntroLogic] Advancing to brick \(currentBrickIndex + 1)/\(brickDrills.count)")
        } else {
            print("   🧑‍🏫 [PatternIntroLogic] Loop complete. Navigating to next orchestrated stage...")
            session.continueToNext()
        }
    }
}

struct PatternIntroManagerView: View {
    @StateObject var logic: PatternIntroLogic
    
    init(state: DrillState, session: LessonSessionManager) {
        _logic = StateObject(wrappedValue: PatternIntroLogic(state: state, session: session))
    }
    
    var body: some View {
        PatternIntroView(
            drill: logic.state,
            session: logic.session,
            logic: logic
        )
    }
}

// MARK: - Pattern Drill (Stage 3) Manager
// Ensures the final practice drill is single-pass and persistent

class PatternDrillLogic: ObservableObject {
    let state: DrillState
    let session: LessonSessionManager
    let resolvedMode: DrillMode
    
    init(state: DrillState, session: LessonSessionManager) {
        self.state = state
        self.session = session
        
        // Resolve mode JIT, once per visit
        self.resolvedMode = state.currentMode ?? PatternModeSelector.resolveMode(for: state, session: session)
        print("   🎯 [PatternDrillLogic] Final Practice Mode Resolved JIT: \(resolvedMode.rawValue)")
    }
}

struct PatternDrillManagerView: View {
    @StateObject var logic: PatternDrillLogic
    
    init(state: DrillState, session: LessonSessionManager) {
        _logic = StateObject(wrappedValue: PatternDrillLogic(state: state, session: session))
    }
    
    var body: some View {
        PatternModeSelector(
            drill: logic.state,
            session: logic.session,
            forcedMode: logic.resolvedMode
        )
    }
}
