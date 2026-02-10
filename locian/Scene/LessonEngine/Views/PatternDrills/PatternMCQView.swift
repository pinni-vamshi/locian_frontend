import SwiftUI

struct PatternMCQView: View {
    @ObservedObject var logic: PatternMCQLogic
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header
                LessonPromptHeader(
                    instruction: "SELECT THE CORRECT MEANING",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    backgroundColor: .white,
                    textColor: .black
                )
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 24) {
                        MCQSelectionGrid(
                            options: logic.options,
                            selectedOption: logic.selectedOption,
                            correctOption: (logic.isCorrect != nil) ? logic.state.drillData.meaning : nil,
                            isAnswered: logic.isCorrect != nil,
                            onSelect: { option in logic.selectOption(option) }
                        )
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
            }
            
            // 3. Footer
            footer
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            if let isCorrect = logic.isCorrect {
                Divider().background(Color.white.opacity(0.1))
                
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
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.black)
            }
        }
    }
}

