import SwiftUI

struct PatternTypingView: View {
    @StateObject private var logic: PatternTypingLogic
    @FocusState private var isFocused: Bool
    var lessonDrillLogic: LessonDrillLogic?
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        _logic = StateObject(wrappedValue: PatternTypingLogic(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic))
        self.lessonDrillLogic = lessonDrillLogic
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header
                LessonPromptHeader(
                    instruction: "TYPE THE TRANSLATION",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    backgroundColor: .white,
                    textColor: .black,
                    modeLabel: (lessonDrillLogic?.state.id.contains("ghost") == true) ? "GHOST REHEARSAL" : nil
                )
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("YOUR ANSWER")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 20) // Spacing
                        
                            TypingInputArea(
                                text: $logic.userInput,
                                placeholder: "Type here...",
                                isCorrect: logic.isCorrect,
                                isDisabled: logic.isCorrect != nil
                            )
                            .focused($isFocused)
                        }
                        
                        // Show Correction if wrong
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            TypingCorrectionView(
                                correctAnswer: logic.state.drillData.target,
                                phonetic: logic.state.drillData.phonetic
                            )
                        }
                    }
                    .padding(.top, 0)
                    .padding(.bottom, 120)
                }
            }
            
            // 3. Footer
            // ✅ Only use Wrapper (Continue) if we are in CHECK mode
            if let wrapper = lessonDrillLogic, logic.isCorrect != nil {
                DrillFooterWrapper(logic: wrapper)
            } else {
                // Otherwise show Local Footer (Check Button)
                footer
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear { isFocused = true }
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            if !logic.userInput.isEmpty || logic.isCorrect != nil {
                Divider().background(Color.white.opacity(0.1))
                
                Group {
                    if let isCorrect = logic.isCorrect {
                        let color: Color = isCorrect ? CyberColors.neonPink : .red
                        let title = isCorrect ? "CORRECT!" : "INCORRECT"
                        
                        CyberProceedButton(
                            action: { lessonDrillLogic?.continueToNext() },
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
                            isEnabled: true
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.black)
            }
        }
    }
}
