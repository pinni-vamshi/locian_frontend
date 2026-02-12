import SwiftUI

struct PatternMCQView: View {
    @StateObject var logic: PatternMCQLogic
    var lessonDrillLogic: LessonDrillLogic?
    
    // ✅ Updated Init: View owns the Logic
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        _logic = StateObject(wrappedValue: PatternMCQLogic(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic))
        self.lessonDrillLogic = lessonDrillLogic
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header
                LessonPromptHeader(
                    instruction: "SELECT THE CORRECT MEANING",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    backgroundColor: .white,
                    textColor: .black,
                    phonetic: logic.phonetic
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
            if let wrapper = lessonDrillLogic {
                // ✅ Use Wrapper Footer
                DrillFooterWrapper(logic: wrapper)
            } else {
                // Fallback (for standalone testing)
                footer
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    // Fallback Legacy Footer
    private var footer: some View {
        VStack(spacing: 0) {
            if let isCorrect = logic.isCorrect {
                Divider().background(Color.white.opacity(0.1))
                
                let color: Color = isCorrect ? CyberColors.neonPink : .red
                let title = isCorrect ? "CORRECT!" : "INCORRECT"
                
                CyberProceedButton(
                    action: { lessonDrillLogic?.continueToNext() }, // Use wrapper for flow control
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

