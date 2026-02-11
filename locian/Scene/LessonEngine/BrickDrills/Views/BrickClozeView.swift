import SwiftUI

struct BrickClozeView: View {
    @StateObject var logic: BrickClozeLogic
    var lessonDrillLogic: LessonDrillLogic?
    var onComplete: (() -> Void)?
    @FocusState private var isFocused: Bool
    @State private var isHintExpanded: Bool = false
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil, onComplete: (() -> Void)? = nil) {
        _logic = StateObject(wrappedValue: BrickClozeLogic(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic, onComplete: onComplete))
        self.lessonDrillLogic = lessonDrillLogic
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header with Hint (meaning only)
                LessonPromptHeader(
                    instruction: "FILL IN THE BLANK",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    hintText: "Hint",
                    meaningText: logic.state.contextMeaning ?? logic.state.drillData.meaning,
                    contextSentence: nil,
                    isHintExpanded: $isHintExpanded,
                    backgroundColor: .white,
                    textColor: .black
                )
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 24) {
                        // FALLBACK / TRADITIONAL MODE
                        TypingInputArea(
                            text: $logic.userInput,
                            placeholder: "Fill in the blank...",
                            isCorrect: logic.isCorrect,
                            isDisabled: logic.isCorrect != nil
                        )
                        .focused($isFocused)
                        .padding(.horizontal, 24)
                        
                        // Show Correction if wrong
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            TypingCorrectionView(correctAnswer: logic.state.drillData.target)
                        }
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 120)
                }
            }
            
            // 3. Footer
            if let wrapper = lessonDrillLogic {
                DrillFooterWrapper(logic: wrapper)
            } else {
                footer
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            isFocused = true
        }
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            if let isCorrect = logic.isCorrect {
                let color: Color = isCorrect ? CyberColors.neonPink : .red
                let title = isCorrect ? "CORRECT!" : "INCORRECT"
                
                CyberProceedButton(
                    action: { logic.continueToNext() },
                    label: "NEXT_STORY_STEP",
                    title: title,
                    color: color,
                    systemImage: "arrow.right",
                    isEnabled: true
                )
            } else {
                CyberProceedButton(
                    action: { logic.checkAnswer() },
                    label: "READY?",
                    title: "CHECK",
                    color: CyberColors.neonCyan,
                    systemImage: "checkmark",
                    isEnabled: logic.hasInput
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.black)
    }
}

