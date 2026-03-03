import SwiftUI

struct PatternMCQView: View {
    @StateObject var logic: PatternMCQLogic
    var onComplete: ((Bool) -> Void)?
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        _logic = StateObject(wrappedValue: PatternMCQLogic(
            state: state, 
            engine: engine, 
            patternIntroLogic: patternIntroLogic, 
            practiceLogic: practiceLogic, 
            ghostLogic: ghostLogic, 
            onComplete: onComplete
        ))
        self.onComplete = onComplete
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
                            onSelect: { option in 
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                logic.selectOption(option) 
                            }
                        )
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
            }
            
            // 3. Footer (Suppressed when hosted by an orchestrator)
            if logic.patternIntroLogic == nil && logic.practiceLogic == nil && logic.ghostLogic == nil {
                footer
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            if logic.isAnswered {
                let isCorrect = (logic.isCorrect == true)
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
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.black)
    }
}
