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
    
    // Data Sources
    var mistakes: [DrillState]
    let targetPattern: DrillState
    let engine: LessonEngine
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        self.targetPattern = targetPattern
        self.engine = engine
        self.mistakes = engine.patternIntroMistakes
        
        print("\n⚖️⚖️⚖️ [GHOST COURT] PRACTICE START ⚖️⚖️⚖️")
        print("   👨‍⚖️ TARGET PATTERN: [\(targetPattern.id)]")
        print("   👨‍⚖️ MISTAKE COUNT: \(mistakes.count)")
        
        // 3. Conditional Animation Logic
        if !mistakes.isEmpty {
            self.isShowingMistakesIntro = true
            print("   🎭 [GHOST COURT] VERDICT: MISTAKES DETECTED. SHOWING INTRO.")
            for (i, m) in mistakes.enumerated() {
                print("      \(i+1). [\(m.id)] \"\(m.drillData.target)\"")
            }
        } else {
            self.isShowingMistakesIntro = false
            print("   🎭 [GHOST COURT] VERDICT: NO MISTAKES. JUMPING TO TRUTH.")
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
        
        // 1. Check if we are in the Mistakes Phase
        if currentIndex < mistakes.count {
            let mistake = mistakes[currentIndex]
            print("   🔁 [PracticeLoop] Serving Mistake \(currentIndex + 1)/\(mistakes.count): \(mistake.drillData.target)")
            
            // Create Drill for Brick
            let drill = DrillState(
                id: mistake.id,
                patternId: targetPattern.id,
                drillIndex: 0,
                drillData: DrillItem(target: mistake.drillData.target, meaning: mistake.drillData.meaning, phonetic: mistake.drillData.phonetic),
                isBrick: true,
                currentMode: nil // Use autonomous Mastery-Based Mode selection
            )
            
            self.activeDrill = drill
            
        } else if currentIndex == mistakes.count {
            // 2. The Final Target Pattern
            print("   🔁 [PracticeLoop] Serving Final Target Pattern.")
            
            var drill = DrillState(
                id: targetPattern.id,
                patternId: targetPattern.id,
                drillIndex: 0,
                drillData: DrillItem(target: targetPattern.drillData.target, meaning: targetPattern.drillData.meaning, phonetic: targetPattern.drillData.phonetic),
                isBrick: false,
                currentMode: nil // Let PatternModeSelector decide (likely speaking)
            )
            
            drill.overrideVoiceInstructions = generateMasteryInstruction()
            self.activeDrill = drill
            
        } else {
            // 3. Finished
            print("✅ [PracticeLoop] Sequence Complete.")
            activeDrill = nil
            engine.orchestrator?.finishPatternPractice()
        }
    }
    
    private func generateMasteryInstruction() -> String {
        return ""
    }
    
    // MARK: - Navigation Control
    
    // ✅ NEW: Orchestrator Sensor (Synced with Intro/Ghost Mode patterns)
    func markDrillAnswered(isCorrect: Bool) {
        print("🔁 [PracticeLoop] markDrillAnswered: \(isCorrect)")
        self.isCorrect = isCorrect
        self.isAnswered = true
        
        // ✅ USER REQUEST: Duplicative audio trigger removed to prevent stuttering.
        // The child drill already handles speaking the target word for correct answers.
        if currentIndex == mistakes.count {
             print("🔁 [PracticeLoop] Final Drill Answered. Child drill handles audio.")
        }
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
                            onComplete: { isCorrect in 
                                logic.markDrillAnswered(isCorrect: isCorrect) 
                            }
                        )
                    } else {
                        // B. Patterns (Direct)
                        PatternModeSelector(
                            drill: drill,
                            engine: logic.engine,
                            practiceLogic: logic, // ✅ Sensor passed to PatternSelector
                            onComplete: { isCorrect in
                                logic.markDrillAnswered(isCorrect: isCorrect)
                            }
                        )
                    }
                }
                .id(drill.id) // Force View Refresh on new drill
                .transition(.opacity)
                // NO PADDING HERE: Child footers will be silenced if they sense the orchestrator
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // 2. FOOTER LAYER (Overlay)
            if logic.isAnswered {
                footer
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    // MARK: - Footer Component
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            let color: Color = logic.isCorrect ? CyberColors.neonPink : .red
            let title = logic.isCorrect ? "CORRECT!" : "INCORRECT"
            
            CyberProceedButton(
                action: { logic.advance() },
                label: "CONTINUE",
                title: title,
                color: color,
                systemImage: "arrow.right"
            )
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color.black)
        }
    }
}
