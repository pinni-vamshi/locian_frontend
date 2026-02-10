import SwiftUI
import Combine

class PatternIntroLogic: ObservableObject {
    @Published var currentBrickIndex: Int = 0
    @Published var shouldSkip: Bool = false
    
    let state: DrillState
    let engine: LessonEngine
    
    // Skeleton DrillStates (Modes resolved JIT)
    var brickDrills: [DrillState] // Renamed to drillStates in the instruction, but keeping original name for consistency with other parts of the class.
    
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine
        
        // DIRECT PATTERN INTRO: No more brick discovery here.
        // Stage 1 (Prerequisites) handled the bricks.
        // Stage 2 (This file) only introduces the full sentence.
        
        let introState = DrillState(
            id: "FULL-\(state.patternId)",
            patternId: state.patternId,
            drillIndex: state.drillIndex,
            drillData: state.drillData,
            isBrick: false,
            currentMode: .vocabIntro
        )
        
        self.brickDrills = [introState] // Using brickDrills as per original class property name
        self.currentBrickIndex = 0 // Renamed to currentBrickIndex as per original class property name
        
        // Resolve mode for the first brick immediately
        if !brickDrills.isEmpty {
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
        let mode = BrickModeSelector.resolveMode(for: brickDrills[index], engine: engine)
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
            print("   🧑‍🏫 [PatternIntroLogic] Loop complete. Notifying Orchestrator.")
            engine.orchestrator?.finishVocabIntro()
        }
    }
}

struct PatternIntroManagerView: View {
    @StateObject var logic: PatternIntroLogic
    
    init(state: DrillState, engine: LessonEngine) {
        _logic = StateObject(wrappedValue: PatternIntroLogic(state: state, engine: engine))
    }
    
    var body: some View {
        Group {
            if logic.shouldSkip {
                Color.clear.onAppear {
                    print("   ⏩ [IntroView] Auto-Skipping (0ms)...")
                    logic.engine.orchestrator?.finishVocabIntro()
                }
            } else {
                PatternIntroView(
                    drill: logic.state,
                    engine: logic.engine,
                    logic: logic
                )
            }
        }
    }
}

// MARK: - Pattern Drill (Stage 3) Manager
// Ensures the final practice drill is single-pass and persistent

class PatternDrillLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    let resolvedMode: DrillMode
    
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine
        
        // Resolve mode JIT, once per visit
        self.resolvedMode = state.currentMode ?? PatternModeSelector.resolveMode(for: state, engine: engine)
        print("   🎯 [PatternDrillLogic] Final Practice Mode Resolved JIT: \(resolvedMode.rawValue)")
    }
}

struct PatternDrillManagerView: View {
    @StateObject var logic: PatternDrillLogic
    
    init(state: DrillState, engine: LessonEngine) {
        _logic = StateObject(wrappedValue: PatternDrillLogic(state: state, engine: engine))
    }
    
    var body: some View {
        PatternModeSelector(
            drill: logic.state,
            engine: logic.engine,
            forcedMode: logic.resolvedMode
        )
    }
}
