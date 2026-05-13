import SwiftUI
import Combine

class PatternIntroLogic: ObservableObject {
    @Published var currentBrickIndex: Int = 0
    @Published var shouldSkip: Bool = false
    @Published var animatingIndices: Set<Int> = []
    
    let state: DrillState
    let engine: LessonEngine

    // Skeleton DrillStates (Modes resolved JIT)
    var brickDrills: [DrillState]

    /// Full BrickItem array — carries anchor, expansionBefore, expansionAfter,
    /// base_kind, pattern_json. Parallel to brickDrills by index.
    /// Used by ConversationBridgeView to build the graph without losing data
    /// that DrillItem doesn't carry.
    var bridgeBricks: [BrickItem] = []

    /// All bricks from the full sentence in order — includes context words not being drilled.
    var allSentenceBricks: [BrickItem] = []

    /// The single anchor brick — the starting node of the bridge graph.
    /// Falls back to the highest-importance brick when no explicit anchor flag.
    var anchorBrickIndex: Int {
        if let idx = bridgeBricks.firstIndex(where: { $0.isAnchor }) { return idx }
        // Fallback: highest importance score
        guard !bridgeBricks.isEmpty else { return 0 }
        var best = 0
        var bestScore: Double = -1
        for (i, b) in bridgeBricks.enumerated() {
            let score = b.importance ?? 0
            if score > bestScore { bestScore = score; best = i }
        }
        return best
    }

    @Published var isPlayingIntro: Bool = true // Blocks Bricks
    
    /// Label for the header hint button — e.g. "SEE SPANISH TRANSLATION"
    var hintLabel: String {
        let langCode = engine.lessonData?.target_language ?? "es"
        let langName = TargetLanguageMapping.shared.getDisplayNames(for: langCode).english
        return "SEE \(langName.uppercased()) TRANSLATION"
    }
    
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine

        // Single pipeline lives on `LessonEngine.computeIntroBricks(for:)`.
        // The orchestrator already stamped `engine.lastIntroBrickIDs` from the
        // same call before publishing `activeState`, so headline + drill queue
        // are guaranteed to agree.
        let bricks = engine.computeIntroBricks(for: state)

        // Preserve full BrickItem data for the bridge graph before converting to DrillState.
        // bridgeBricks and brickDrills are parallel arrays — same order, same count.
        // (Assigned after drillStates is built below to keep the single-init flow.)

        var drillStates: [DrillState] = bricks.map { brick in
            let brickDrill = DrillItem(
                target: brick.word,
                meaning: brick.meaning,
                phonetic: brick.phonetic,
                voice_url: brick.voice_url,
                voice_data: brick.voice_data
            )
            return DrillState(
                id: brick.id,
                patternId: state.patternId,
                drillIndex: -1,
                drillData: brickDrill,
                contextMeaning: state.drillData.meaning,
                contextSentence: state.drillData.target,
                isBrick: true,
                currentMode: nil
            )
        }

        if drillStates.isEmpty {
            // Fallback: introduce the whole pattern when no bricks pass the filter.
            let introState = DrillState(
                id: state.patternId,
                patternId: state.patternId,
                drillIndex: state.drillIndex,
                drillData: state.drillData,
                isBrick: false,
                currentMode: nil
            )
            drillStates = [introState]
        }

        self.brickDrills = drillStates
        self.bridgeBricks = bricks

        // All bricks from the lesson group in sentence order (constants hold them in order).
        if let group = engine.lessonData?.groups?.first(where: {
            $0.group_id == state.patternId ||
            $0.patterns?.contains(where: { $0.id == state.patternId }) == true
        }) {
            let all = (group.bricks?.constants ?? [])
                + (group.bricks?.variables ?? [])
                + (group.bricks?.structural ?? [])
            self.allSentenceBricks = all.isEmpty ? bricks : all
        } else {
            self.allSentenceBricks = bricks
        }

        self.currentBrickIndex = 0
        let stampedIds = drillStates.map { $0.id }
        DispatchQueue.main.async {
            engine.lastIntroBrickIDs = stampedIds
            engine.isPlayingPatternIntroAnimation = true
            engine.revealedIntroBrickIDs = []
            engine.introAllRevealed = false
        }
        print("🧩 [PatternIntro] Stamped \(engine.lastIntroBrickIDs.count) brick IDs: \(engine.lastIntroBrickIDs)")

        if !brickDrills.isEmpty {
            print("   🧩 [PatternIntro] Found \(brickDrills.count) bricks. Resolving first: \(brickDrills[0].id)")
            resolveCurrentMode(at: 0)
        } else {
            print("   🧩 [PatternIntro] No bricks found!")
        }

        // Auto-skip if the whole pattern is already mastered — no need to re-introduce.
        let patternMastery = engine.getBlendedMastery(for: state.id)
        if patternMastery >= 0.85 {
            print("🏁 [PatternIntro] Pattern already mastered (\(String(format: "%.2f", patternMastery))). SETTING SKIP.")
            self.shouldSkip = true
        }
    }
    
    var currentDrill: DrillState? {
        guard currentBrickIndex < brickDrills.count else { return nil }
        return brickDrills[currentBrickIndex]
    }
    
    private func resolveCurrentMode(at index: Int) {
        guard index < brickDrills.count else { return }
        
        // Resolve mode for THIS specific brick AT THIS MOMENT
        // NO GUARD: Always re-resolve to catch latest mastery changes from other bricks
        let mode = BrickModeSelector.resolveMode(for: brickDrills[index], engine: engine)
        print("   🧩 [PatternIntro] Resolving brick \(index): \(brickDrills[index].id) -> Mode: \(mode)")
        brickDrills[index].currentMode = mode
    }
    
    func onIntroComplete() {
        print("🏁 [PatternIntro] Animation complete. Showing sentence graph.")
        withAnimation {
            self.animatingIndices.removeAll()
            self.isPlayingIntro = false
        }
        engine.isPlayingPatternIntroAnimation = false
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
