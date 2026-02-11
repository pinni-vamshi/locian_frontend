import SwiftUI
import Combine

// MARK: - Full Drill (Stage 2 & 3) Manager
// Universal manager for full-screen bricks (Ghost Mode) and patterns (Stage 3)

class LessonDrillLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    let resolvedMode: DrillMode
    
    // ✅ State for continue button and feedback
    @Published var isDrillAnswered: Bool = false
    @Published var isCorrect: Bool = false
    @Published var isAudioPlaying: Bool = false 
    
    // ✅ Callback for custom completion (e.g., Ghost Mode)
    var onNext: (() -> Void)? = nil
    
    init(state: DrillState, engine: LessonEngine, onNext: (() -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.onNext = onNext
        
        // Resolve mode JIT
        if state.isBrick {
            self.resolvedMode = state.currentMode ?? BrickModeSelector.resolveMode(for: state, engine: engine)
        } else {
            self.resolvedMode = state.currentMode ?? PatternModeSelector.resolveMode(for: state, engine: engine)
        }
    }
    
    func markDrillAnswered(isCorrect: Bool) {
        self.isCorrect = isCorrect
        self.isDrillAnswered = true
        
        // ✅ NEW: Capture failure in Ghost Mode pool for both Bricks and Patterns
        if !isCorrect {
            engine.patternIntroMistakes.append(state)
            print("   ⚠️ [LessonDrillLogic] Captured failure for \(state.id). Added to recycling pool.")
        }
    }
    
    func continueToNext() {
        if let onNext = onNext {
            onNext()
        } else {
            engine.orchestrator?.finishPattern()
        }
    }
}

struct FullDrillManagerView: View {
    @StateObject var logic: LessonDrillLogic
    
    init(state: DrillState, engine: LessonEngine, onNext: (() -> Void)? = nil) {
        _logic = StateObject(wrappedValue: LessonDrillLogic(state: state, engine: engine, onNext: onNext))
    }
    
    var body: some View {
        Group {
            if logic.state.isBrick {
                BrickModeSelector(
                    drill: logic.state,
                    engine: logic.engine,
                    forcedMode: logic.resolvedMode,
                    lessonDrillLogic: logic // Pass wrapper for footer support
                )
            } else {
                PatternModeSelector(
                    drill: logic.state,
                    engine: logic.engine,
                    forcedMode: logic.resolvedMode,
                    lessonDrillLogic: logic
                )
            }
        }
    }
}
