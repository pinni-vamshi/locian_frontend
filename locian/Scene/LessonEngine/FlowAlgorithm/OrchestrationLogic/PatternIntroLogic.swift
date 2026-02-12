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
        // BRICK FILTERING PIPELINE (V4.1)
        // ========================================
        
        // STEP 1: Discovery (ContentAnalyzer)
        let brickMatches = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.getBricks(for: state.patternId),
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        
        // STEP 2: Filtration (MasteryFilterService)
        let patternMastery = engine.getBlendedMastery(for: state.id)
        let selectedIDs = MasteryFilterService.filterBricksBySemanticCliff(
            bricks: brickMatches,
            patternMastery: patternMastery,
            activeBricks: engine.getBricks(for: state.patternId)
        )
        
        // STEP 3: Resolve & Preserve Order
        var bricks: [BrickItem] = []
        for id in selectedIDs {
            if let brick = MasteryFilterService.getBrick(id: id, from: engine.getBricks(for: state.patternId)) {
                bricks.append(brick)
            }
        }
        
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
           print("   🧩 [PatternIntro] Found \(brickDrills.count) bricks. Resolving first: \(brickDrills[0].id)")
           resolveCurrentMode(at: 0)
        } else {
           print("   🧩 [PatternIntro] No bricks found!")
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
        print("   🧩 [PatternIntro] Resolving brick \(index): \(brickDrills[index].id) -> Mode: \(mode)")
        brickDrills[index].currentMode = mode
    }
    
    // ✅ NEW: Called by brick logic when answer is validated
    func markBrickAnswered(isCorrect: Bool) {
        print("   🧩 [PatternIntro] markBrickAnswered: Correct=\(isCorrect)")
        
        // DEBUG: Trace where this call came from!
        let symbols = Thread.callStackSymbols
        print("   🧩 [PatternIntro] Trace (Top 5):")
        for i in 0..<min(5, symbols.count) {
            print("      \(symbols[i])")
        }
        
        currentBrickAnswered = true
        currentBrickCorrect = isCorrect
        
        // ✅ NEW: Collect mistake for Ghost Mode recycle
        if !isCorrect, let brick = currentDrill {
            print("   🧩 [PatternIntro] Capturing mistake: \(brick.id)")
            engine.patternIntroMistakes.append(brick)
        }
    }
    
    // Track completed bricks to prevent double-advancement
    private var completedIndices: Set<Int> = []
    
    func advance() {
        print("   🧩 [PatternIntro] Advance called for index \(currentBrickIndex)")
        
        // Guard: Only advance if this index isn't already marked done
        guard !completedIndices.contains(currentBrickIndex) else {
            print("   🧩 [PatternIntro] BLOCKED: Index \(currentBrickIndex) already advanced!")
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
                print("   🧩 [PatternIntro] Advancing to next brick: \(currentBrickIndex)")
                resolveCurrentMode(at: currentBrickIndex)
            }
        } else {
            // ✅ Last brick completed - notify orchestrator WITHOUT resetting state
            // (Keep footer visible until orchestration switches views)
            print("   🧩 [PatternIntro] Finishing Intro!")
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
