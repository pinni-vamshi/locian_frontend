import SwiftUI

struct BrickMCQView: View {
    @ObservedObject var logic: BrickMCQLogic
    @State private var isHintExpanded: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header with Expandable Hint
                LessonPromptHeader(
                    instruction: "SELECT THE CORRECT MEANING",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    hintText: "Hint",
                    meaningText: logic.state.contextMeaning ?? logic.state.drillData.meaning,
                    contextSentence: logic.state.contextSentence,
                    isHintExpanded: $isHintExpanded,
                    backgroundColor: .white,
                    textColor: .black
                )
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 24) {
                        MCQSelectionGrid(
                            options: logic.options,
                            selectedOption: logic.selectedOption,
                            correctOption: (logic.isCorrect != nil) ? logic.correctOption : nil,
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
                    action: { },
                    label: "SELECT_OPTION",
                    title: "CHOOSING...",
                    color: CyberColors.neonCyan.opacity(0.3),
                    systemImage: "ellipsis",
                    isEnabled: false
                )
                .opacity(0.5)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.black)
    }
}

