import SwiftUI
import Combine

class PatternIntroLogic: ObservableObject {
    @Published var currentBrickIndex: Int = 0
    @Published var shouldSkip: Bool = false
    @Published var currentBrickAnswered: Bool = false  // ✅ NEW: Tracks if current brick was answered
    @Published var currentBrickCorrect: Bool = false   // ✅ NEW: Tracks if answer was correct
    @Published var isAudioPlaying: Bool = false        // ✅ NEW: Synced with voice bricks
    @Published var currentBrickHasInput: Bool = false  // ✅ NEW: Hoisted input state for Footer Check button
    
    // ✅ NEW: Action Bridging (Parent View -> Child Logic)
    var requestCheckAnswer: (() -> Void)?
    var requestClearInput: (() -> Void)?
    
    let state: DrillState
    let engine: LessonEngine
    
    // Skeleton DrillStates (Modes resolved JIT)
    var brickDrills: [DrillState]
    
    @Published var isPlayingIntro: Bool = true // Blocks Bricks
    
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
                id: brick.safeID,
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
                id: state.patternId,
                patternId: state.patternId,
                drillIndex: state.drillIndex,
                drillData: state.drillData,
                isBrick: false,
                currentMode: nil  // Will be resolved JIT
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
        
        // UI Text is already static "Here are the core words."
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
    func markBrickAnswered(isCorrect: Bool, input: String? = nil) {
        print("   🧩 [PatternIntro] markBrickAnswered: Correct=\(isCorrect) | Input: \(input ?? "nil")")
        
        currentBrickAnswered = true
        currentBrickCorrect = isCorrect
        
        // --- 🎙️ SUPPORTIVE GUIDANCE SYSTEM ---
        // MOVED TO INDIVIDUAL BRICK LOGIC (Decentralized)
        
        // ✅ NEW: Collect mistake for Ghost Mode recycle
        if !isCorrect {
            // Only capture if we have the brick reference
            if let brick = currentDrill {
                print("\n⚖️⚖️⚖️ [GHOST COURT] EVIDENCE CAPTURED ⚖️⚖️⚖️")
                print("   🕵️‍♂️ MISTAKE: [\(brick.id)] \"\(brick.drillData.target)\"")
                print("   🕵️‍♂️ REASON: User provided incorrect answer.")
                engine.patternIntroMistakes.append(brick)
                print("   🕵️‍♂️ POOL SIZE: \(engine.patternIntroMistakes.count)")
                print("⚖️⚖️⚖️ [GHOST COURT] ========================= ⚖️⚖️⚖️\n")
            }
        }
    }
    
    // Track completed bricks to prevent double-advancement
    private var completedIndices: Set<Int> = []
    
    func advance() {
        print("   🧩 [PatternIntro] Advance called for index \(currentBrickIndex)")
        
        // Guard: Prevent advancing while audio is playing (avoid overlap)
        guard !isAudioPlaying else {
            print("   🧩 [PatternIntro] BLOCKED: Audio still playing!")
            return
        }
        
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
    
    private var hasStartedIntro: Bool = false
    
    // ✅ NEW: Triggered by PatternIntroAnimationView when voice finishes
    func onIntroComplete() {
        print("🏁 [PatternIntro] Animation & Voice Complete. Unblocking UI.")
        withAnimation {
            self.isPlayingIntro = false
        }
    }
    
    // Safety Fallback (called by View's onAppear)
    func playIntroAudio() {
        // We no longer trigger audio here because the View owns it.
        // But we keep this as a trace point.
        print("🧩 [PatternIntro] Start sequence initiated.")
    }
}

struct PatternIntroManagerView: View {
    @StateObject var logic: PatternIntroLogic
    
    init(state: DrillState, engine: LessonEngine) {
        _logic = StateObject(wrappedValue: PatternIntroLogic(state: state, engine: engine))
    }
    
    var body: some View {
        ZStack {
            if logic.shouldSkip {
                Color.clear.onAppear {
                    logic.engine.orchestrator?.finishVocabIntro()
                }
            } else {
                // ✅ Always show View (logic.isPlayingIntro handles sub-view switching)
                PatternIntroView(
                    drill: logic.state,
                    engine: logic.engine,
                    logic: logic
                )
            }
        }
        .onAppear {
            // ✅ Trigger Intro Delay (Injection happened in init)
            logic.playIntroAudio()
        }
    }
}
