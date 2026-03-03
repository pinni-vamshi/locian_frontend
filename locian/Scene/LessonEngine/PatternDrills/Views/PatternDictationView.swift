import SwiftUI

struct PatternDictationView: View {
    @StateObject private var logic: PatternVoiceLogic
    var onComplete: ((Bool) -> Void)?
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        _logic = StateObject(wrappedValue: PatternVoiceLogic(
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
                    instruction: "LISTEN AND TYPE",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    backgroundColor: .white,
                    textColor: .black,
                    modeLabel: (logic.state.id.contains("ghost") == true) ? "GHOST REHEARSAL" : nil,
                    phonetic: logic.phonetic,
                    onReplay: { logic.playAudio() }
                )
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 32) {
                        SharedMicButton(
                            isRecording: logic.isRecording,
                            action: { logic.triggerSpeechRecognition() }
                        )
                        .padding(.top, 60)
                        
                        // User Transcript (Keep below as it grows)
                        if !logic.recognizedText.isEmpty || logic.isRecording {
                            Text("\"" + logic.recognizedText + "\"")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Show Correction if wrong
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            TypingCorrectionView(
                                correctAnswer: logic.state.drillData.target,
                                phonetic: logic.state.drillData.phonetic
                            )
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            
            // 3. Footer (Suppressed when hosted by an orchestrator)
            // 3. Footer (Suppressed when hosted by an orchestrator, UNLESS it's Ghost Mode needing a check button)
            let isStandalone = logic.patternIntroLogic == nil && logic.practiceLogic == nil && logic.ghostLogic == nil
            let isGhostPreAnswer = logic.ghostLogic != nil && logic.isCorrect == nil
            
            if isStandalone || isGhostPreAnswer {
                footer
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            logic.bindToParent()
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
                    systemImage: "arrow.right"
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
