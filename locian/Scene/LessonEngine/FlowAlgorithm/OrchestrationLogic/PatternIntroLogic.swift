import SwiftUI
import Combine

class PatternIntroLogic: ObservableObject {
    @Published var currentBrickIndex: Int = 0
    @Published var shouldSkip: Bool = false
    @Published var currentBrickAnswered: Bool = false  // ✅ NEW: Tracks if current brick was answered
    @Published var currentBrickCorrect: Bool = false   // ✅ NEW: Tracks if answer was correct
    @Published var isAudioPlaying: Bool = false        // ✅ NEW: Synced with voice bricks
    
    let state: DrillState
    let engine: LessonEngine
    
    // Skeleton DrillStates (Modes resolved JIT)
    var brickDrills: [DrillState] // Renamed to drillStates in the instruction, but keeping original name for consistency with other parts of the class.
    
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine
        
        // ========================================
        // BRICK FILTERING PIPELINE
        // ========================================
        // STEP 1: ContentAnalyzer - Word Matching
        // Finds which bricks exist in the pattern via literal word matching
        // ========================================
        
        let brickIDs = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.getBricks(for: state.patternId),  // ✅ PATTERN-SPECIFIC LOOKUP
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        
        // ========================================
        // STEP 2: MasteryFilterService - Resolve to Objects
        // Converts brick IDs → actual BrickItem objects
        // ========================================
        
        let bricks = MasteryFilterService.resolveBricks(
            ids: Set(brickIDs), 
            from: engine.getBricks(for: state.patternId)  // ✅ PATTERN-SPECIFIC LOOKUP
        )
        
        // ========================================
        // STEP 3: Convert to DrillStates
        // ========================================
        
        var drillStates: [DrillState] = []
        
        for brick in bricks {
            let brickDrill = DrillItem(
                target: brick.word,
                meaning: brick.meaning,
                phonetic: brick.phonetic
            )
            
            let drillState = DrillState(
                id: "INT-\(brick.safeID)",
                patternId: state.patternId,
                drillIndex: -1,
                drillData: brickDrill,
                // ✅ Pass pattern context so Cloze Mode can mask it ("Es mi _______")
                contextMeaning: state.drillData.meaning,
                contextSentence: state.drillData.target,
                isBrick: true,
                currentMode: nil  // Will be resolved JIT
            )
            
            drillStates.append(drillState)
        }
        
        // ========================================
        // FALLBACK: If no bricks, show full pattern
        // ========================================
        
        if drillStates.isEmpty {
            let introState = DrillState(
                id: "FULL-\(state.patternId)",
                patternId: state.patternId,
                drillIndex: state.drillIndex,
                drillData: state.drillData,
                isBrick: false,
                currentMode: .vocabIntro
            )
            drillStates = [introState]
        }
        
        self.brickDrills = drillStates
        self.currentBrickIndex = 0
        
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
    }
    
    // ✅ NEW: Called by brick logic when answer is validated
    func markBrickAnswered(isCorrect: Bool) {
        currentBrickAnswered = true
        currentBrickCorrect = isCorrect
        
        // ✅ NEW: Collect mistake for Ghost Mode recycle
        if !isCorrect, let brick = currentDrill {
            engine.patternIntroMistakes.append(brick)
        }
    }
    
    // Track completed bricks to prevent double-advancement
    private var completedIndices: Set<Int> = []
    
    func advance() {
        // Guard: Only advance if this index isn't already marked done
        guard !completedIndices.contains(currentBrickIndex) else {
            return
        }
        completedIndices.insert(currentBrickIndex)
        
        // Check if there's a next brick
        if currentBrickIndex < brickDrills.count - 1 {
            // ✅ Reset answer state for next brick
            currentBrickAnswered = false
            currentBrickCorrect = false
            
            withAnimation(.spring()) {
                currentBrickIndex += 1
                // Resolve mode for the NEW active brick JIT
                resolveCurrentMode(at: currentBrickIndex)
            }
        } else {
            // ✅ Last brick completed - notify orchestrator WITHOUT resetting state
            // (Keep footer visible until orchestration switches views)
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
