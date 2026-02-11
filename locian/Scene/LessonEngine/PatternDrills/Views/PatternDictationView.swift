import SwiftUI

struct PatternDictationView: View {
    @StateObject private var logic: PatternVoiceLogic
    var lessonDrillLogic: LessonDrillLogic?
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        _logic = StateObject(wrappedValue: PatternVoiceLogic(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic))
        self.lessonDrillLogic = lessonDrillLogic
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
                    modeLabel: (lessonDrillLogic?.state.id.contains("ghost") == true) ? "GHOST REHEARSAL" : nil,
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
                            TypingCorrectionView(correctAnswer: logic.state.drillData.target)
                        }
                    }
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
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            if let isCorrect = logic.isCorrect {
                let color: Color = isCorrect ? CyberColors.neonPink : .red
                let title = isCorrect ? "CORRECT!" : "INCORRECT"
                
                CyberProceedButton(
                    action: { lessonDrillLogic?.continueToNext() },
                    label: "NEXT_STORY_STEP",
                    title: title,
                    color: color,
                    systemImage: "arrow.right",
                    isEnabled: !logic.isAudioPlaying
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
