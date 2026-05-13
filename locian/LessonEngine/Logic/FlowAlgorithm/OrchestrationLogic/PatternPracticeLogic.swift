import SwiftUI
import Combine

class PatternPracticeLogic: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var isShowingMistakesIntro: Bool = false
    @Published var activeDrill: DrillState?
    
    // Internal State for Footer
    @Published var isAnswered: Bool = false
    @Published var isCorrect: Bool = false
    @Published var isAudioPlaying: Bool = false
    @Published var hasInput: Bool = false
    
    // ✅ Action Bridging (Parent View -> Child Logic)
    var requestCheckAnswer: (() -> Void)?
    var requestClearInput: (() -> Void)?
    
    // Data Sources
    var mistakes: [DrillState]
    var patterns: [DrillState] // ✅ NEW: Explicit list for second sub-loop
    let targetPattern: DrillState
    let engine: LessonEngine
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        self.targetPattern = targetPattern
        self.engine = engine
        self.mistakes = engine.patternIntroMistakes
        
        // --- 🏗️ SUB-LOOP 2 INITIALIZATION ---
        // Only add the target pattern to the practice list if it wasn't already a mistake.
        // This ensures "Each Quest Only Once" in the practice stage.
        if mistakes.contains(where: { $0.id == targetPattern.id }) {
            self.patterns = [] // Already handled in mistakes phase
            print("   🎭 [GHOST COURT] TARGET PATTERN PRE-EMPTED BY MISTAKE. Skipping redundant Finale.")
        } else {
            self.patterns = [targetPattern]
            print("   🎭 [GHOST COURT] TARGET PATTERN ADDED TO FINALE LIST.")
        }
        
        print("\n⚖️⚖️⚖️ [GHOST COURT] PRACTICE START ⚖️⚖️⚖️")
        print("   👨‍⚖️ TARGET PATTERN: [\(targetPattern.id)]")
        print("   👨‍⚖️ MISTAKE COUNT: \(mistakes.count)")
        print("   👨‍⚖️ FINALE COUNT: \(patterns.count)")
        
        // 3. Conditional Animation Logic
        if !mistakes.isEmpty {
            self.isShowingMistakesIntro = true
            print("   🎭 [GHOST COURT] VERDICT: MISTAKES DETECTED. SHOWING INTRO.")
        } else {
            self.isShowingMistakesIntro = false
            print("   🎭 [GHOST COURT] VERDICT: NO MISTAKES. JUMPING TO FIRST ITEM.")
            loadCurrentItem()
        }
        print("⚖️⚖️⚖️ [GHOST COURT] ========================= ⚖️⚖️⚖️\n")
    }
    
    // MARK: - Core Logic
    
    func onMistakesIntroComplete() {
        withAnimation {
            self.isShowingMistakesIntro = false
            loadCurrentItem()
        }
    }
    
    func loadCurrentItem() {
        // Reset Footer State
        self.isAnswered = false
        self.isCorrect = false
        self.hasInput = false
        self.requestCheckAnswer = nil
        self.requestClearInput = nil
        
        // PHASE 1: The Mistakes Sub-Loop
        if currentIndex < mistakes.count {
            let mistake = mistakes[currentIndex]
            print("   🔁 [PracticeLoop] Phase 1 - Mistake \(currentIndex + 1)/\(mistakes.count): \(mistake.drillData.target)")

            var drill = DrillState(
                id: mistake.id,
                patternId: targetPattern.id,
                drillIndex: 0,
                drillData: mistake.drillData,
                isBrick: true,
                currentMode: nil
            )
            drill.currentMode = BrickModeSelector.resolveMode(for: drill, engine: engine)
            self.activeDrill = drill

        }
        // PHASE 2: The Pattern Practice Sub-Loop (full-sentence MCQ — the test).
        else if (currentIndex - mistakes.count) < patterns.count {
            let subIndex = currentIndex - mistakes.count
            let pattern = patterns[subIndex]
            print("   🔁 [PracticeLoop] Phase 3 - Pattern \(subIndex + 1)/\(patterns.count): \(pattern.drillData.target)")

            var drill = DrillState(
                id: pattern.id,
                patternId: targetPattern.id,
                drillIndex: 0,
                drillData: pattern.drillData,
                isBrick: false,
                currentMode: nil
            )
            drill.currentMode = PatternModeSelector.resolveMode(for: drill, engine: engine)
            self.activeDrill = drill

        }
        // FINISH
        else {
            print("✅ [PracticeLoop] Sequence Complete.")
            activeDrill = nil
            engine.orchestrator?.finishPatternPractice()
        }
    }
    
    
    // MARK: - Navigation Control
    
    // ✅ NEW: Orchestrator Sensor (Synced with Intro/Ghost Mode patterns)
    func markDrillAnswered(isCorrect: Bool) {
        print("🔁 [PracticeLoop] markDrillAnswered: \(isCorrect)")
        self.isCorrect = isCorrect
        self.isAnswered = true
    }
    
    func advance() {
        guard isAnswered else { return }
        
        withAnimation {
            currentIndex += 1
            loadCurrentItem()
        }
    }
}

// MARK: - View Component (Self-Contained)

struct PatternPracticeView: View {
    @StateObject var logic: PatternPracticeLogic
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        _logic = StateObject(wrappedValue: PatternPracticeLogic(targetPattern: targetPattern, engine: engine))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 0. ANIMATION LAYER
            if logic.isShowingMistakesIntro {
                PatternPracticeMistakesAnimationView(
                    mistakes: logic.mistakes,
                    onComplete: { logic.onMistakesIntroComplete() },
                    targetLanguage: logic.engine.lessonData?.target_language ?? "es" // Pass targetLanguage
                )
                .transition(.opacity)
                .zIndex(2)
            }
            
            // 1. MAIN CONTENT LAYER
            else if let drill = logic.activeDrill {
                Group {
                    if drill.isBrick {
                        // A. Bricks (Delegated to BrickModeSelector)
                        BrickModeSelector(
                            drill: drill, 
                            engine: logic.engine, 
                            practiceLogic: logic,
                            onComplete: { _ in 
                                logic.markDrillAnswered(isCorrect: true) // ✅ Ensure advance() can proceed
                                logic.advance()
                            }
                        )
                    } else {
                        // B. Patterns (Direct)
                        PatternModeSelector(
                            drill: drill,
                            engine: logic.engine,
                            practiceLogic: logic, // ✅ Sensor passed to PatternSelector
                            onComplete: { _ in
                                logic.markDrillAnswered(isCorrect: true) // ✅ Ensure advance() can proceed
                                logic.advance()
                            }
                        )
                    }
                }
                .id(drill.id) // Force View Refresh on new drill
                .transition(.opacity)
                // NO PADDING HERE: Child footers will be handled by themselves
            } else {
                Color.black
            }
        }
        .background(Color.black)
    }
    
    // MARK: - Footer Component
    private var footer: some View {
        EmptyView()
    }
}
