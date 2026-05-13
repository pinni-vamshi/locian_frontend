import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - BrickVoiceView (self-contained — logic feeds data in)
// ─────────────────────────────────────────────────────────────

struct BrickVoiceView: View {
    @StateObject var logic: BrickVoiceLogic
    var onComplete: ((Bool) -> Void)?
    @State private var isHintExpanded: Bool = false
    @Environment(\.compactDrillZone) private var compactDrillZone
    
    init(
        state: DrillState, 
        engine: LessonEngine, 
        practiceLogic: PatternPracticeLogic? = nil, 
        ghostLogic: GhostModeLogic? = nil, 
        onComplete: ((Bool) -> Void)? = nil
    ) {
        let logic = BrickVoiceLogic(
            state: state,
            engine: engine,
            onComplete: onComplete
        )
        logic.practiceLogic = practiceLogic
        logic.ghostLogic = ghostLogic
        _logic = StateObject(wrappedValue: logic)
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header
                if !compactDrillZone {
                    brickVoiceHeader
                }
                
                // 2. Body — mic and transcription
                ScrollView {
                    VStack(spacing: 32) {
                        // Instruction Label (Standardized style)

                        // Inlined Mic Button (Formerly SharedMicButton)
                        // Inlined Mic Button (Formerly SharedMicButton)
                        Button(action: { logic.triggerSpeechRecognition() }) {
                            HStack(spacing: 0) {
                                // 1. Mic Part (Pink Square)
                                ZStack {
                                    CyberColors.neonPink
                                    
                                    if logic.isStarting {
                                        ProgressView()
                                            .tint(.black)
                                    } else {
                                        Image(systemName: logic.isRecording ? "waveform" : "mic.fill")
                                            .font(.system(size: 32, weight: .black))
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(width: 80, height: 80)
                                
                                // 2. Text Part (White Rect)
                                ZStack {
                                    Color.white
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(logic.isStarting ? "PREPARING..." : (logic.isRecording ? "LISTENING..." : "TAP TO SPEAK"))
                                            .font(.system(size: 14, weight: .black, design: .monospaced))
                                            .foregroundColor(.black)
                                        
                                        Text(logic.isRecording ? "SAY IT NOW" : "USE MICROPHONE")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(.black.opacity(0.5))
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .frame(height: 80)
                            }
                            .background(Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .fixedSize(horizontal: true, vertical: true)
                        }
                        .padding(.top, compactDrillZone ? 12 : 60)
                        .diagnosticBorder(.green.opacity(0.2))
                        
                        // Clear Button
                        if logic.isCorrect == nil && !logic.recognizedText.isEmpty {
                            Button(action: { 
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation {
                                    logic.clearInput() 
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.fill")
                                    Text("CLEAR SENTENCE")
                                }
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    Rectangle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .diagnosticBorder(.orange.opacity(0.35))
                        }
                        
                        // User Transcript
                        if !logic.recognizedText.isEmpty || logic.isRecording {
                            Text("\"" + logic.recognizedText + "\"")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .diagnosticBorder(.blue.opacity(0.28))
                        }
                        
                        // Show Correction if wrong
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            brickVoiceCorrectionView
                                .diagnosticBorder(.red.opacity(0.3))
                        }
                    }
                    .padding(.top, compactDrillZone ? 26 : 0)
                    .padding(.bottom, 120)
                    .diagnosticBorder(.white.opacity(0.1))
                }
                .diagnosticBorder(.cyan.opacity(0.28))
            }
            .diagnosticBorder(.yellow.opacity(0.28))
            
            // 3. Footer (Suppressed when hosted by an orchestrator, UNLESS it has an answer or is standalone)
            let isStandalone = logic.practiceLogic == nil && logic.ghostLogic == nil
            let hasAnswer = logic.isCorrect != nil
            
            if isStandalone || hasAnswer {
                brickVoiceFooter
                    .diagnosticBorder(.white.opacity(0.2))
            }
        }
        .diagnosticBorder(.pink.opacity(0.25))
        .background(compactDrillZone ? Color.clear : Color.black)

    }

    // ── Header ─────────────────────────────────────────────────
    private var brickVoiceHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // 1. PROGRESS with circles and Mastery
                HStack(spacing: 8) {
                    Text("PROGRESS")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .tracking(1.0)
                    
                    PatternProgressRow(
                        patterns: logic.engine.rawPatterns.map { $0.id },
                        currentPatternId: logic.state.patternId,
                        engine: logic.engine
                    )
                    
                    Text(String(format: "%.0f%% Mastery", logic.engine.getBlendedMastery(for: logic.state.patternId) * 100))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(CyberColors.neonCyan)
                
                // 2. Main prompt
                Text(logic.prompt)
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                
                // Target Metadata
                let target = logic.targetLanguage
                if !target.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "character.bubble.fill")
                            .font(.system(size: 14))
                            .foregroundColor(CyberColors.textGray)
                        Text("TARGET: \(target.uppercased())")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberColors.textGray)
                            .tracking(1)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.leading, 24)
            .overlay(
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(Color.white).frame(width: 4).offset(x: 1, y: 1)
                    Rectangle().fill(CyberColors.neonPink).frame(width: 4)
                }
                .fixedSize(horizontal: true, vertical: false),
                alignment: .leading
            )
            Spacer()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // ── Correction View ─────────────────────────────────────────
    private var brickVoiceCorrectionView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CORRECT SOLUTION")
                .font(.caption)
                .tracking(1)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(logic.state.drillData.target)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                
                if let ph = logic.state.drillData.phonetic, !ph.isEmpty {
                    Text(ph)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(CyberColors.neonGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    // ── Footer ──────────────────────────────────────────────────
    private var brickVoiceFooter: some View {
        VStack(spacing: 0) {
            if let isCorrect = logic.isCorrect {
                Divider().background(Color.white.opacity(0.1))
                let color: Color = isCorrect ? CyberColors.success : .red
                let title = isCorrect ? "CORRECT!" : "INCORRECT"
                
                CyberProceedButton(
                    action: { logic.continueToNext() },
                    label: "NEXT_STORY_STEP",
                    title: title,
                    color: color,
                    systemImage: "arrow.right",
                    isEnabled: true
                )
            } else if logic.hasInput {
                Divider().background(Color.white.opacity(0.1))
                
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
        .padding(.bottom, 20)
        .background(Color.black)
    }
}
