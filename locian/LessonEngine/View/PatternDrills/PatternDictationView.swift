import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - PatternDictationView (self-contained — logic feeds data in)
// ─────────────────────────────────────────────────────────────

struct PatternDictationView: View {
    @StateObject private var logic: PatternVoiceLogic
    var onComplete: ((Bool) -> Void)?
    @Environment(\.compactDrillZone) private var compactDrillZone
    
    init(
        state: DrillState, 
        engine: LessonEngine, 
        practiceLogic: PatternPracticeLogic? = nil, 
        ghostLogic: GhostModeLogic? = nil, 
        onComplete: ((Bool) -> Void)? = nil
    ) {
        let logic = PatternVoiceLogic(
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
                    patternDictationHeader
                        .diagnosticBorder(.white.opacity(0.1))
                }
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 32) {
                        // Instruction Label (Standardized style)
                        
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
                                .diagnosticBorder(.black.opacity(0.2))
                                
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
                                    .diagnosticBorder(.black.opacity(0.1))
                                }
                                .frame(height: 80)
                                .diagnosticBorder(.blue.opacity(0.1))
                            }
                            .background(Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .fixedSize(horizontal: true, vertical: true)
                            .diagnosticBorder(.white.opacity(0.5))
                        }
                        .padding(.top, 20)
                        .diagnosticBorder(.pink.opacity(0.3))
                        
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
                                .diagnosticBorder(.white.opacity(0.2))
                            }
                            .buttonStyle(.plain)
                            .diagnosticBorder(.orange.opacity(0.3))
                        }
                        
                        // User Transcript
                        if !logic.recognizedText.isEmpty || logic.isRecording {
                            Text("\"" + logic.recognizedText + "\"")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .diagnosticBorder(.white.opacity(0.2))
                        }
                        
                        // Show Correction if wrong
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            patternDictationCorrectionView
                                .diagnosticBorder(.red.opacity(0.3))
                        }
                    }
                    .padding(.top, compactDrillZone ? 26 : 0)
                    .padding(.bottom, 120)
                    .diagnosticBorder(.white.opacity(0.05))
                }
                .diagnosticBorder(.white.opacity(0.1))
            }
            .diagnosticBorder(.blue.opacity(0.1))
            
            // 3. Footer (Suppressed when hosted by an orchestrator)
            patternDictationFooter
                .diagnosticBorder(.orange.opacity(0.2))
        }
        .background(compactDrillZone ? Color.clear : Color.black)
        .diagnosticBorder(.white.opacity(0.1))
    }

    // ── Header ─────────────────────────────────────────────────
    private var patternDictationHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // Mode Label (Ghost Mode)
                if logic.state.id.contains("ghost") == true {
                    Text("GHOST REHEARSAL")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundColor(CyberColors.neonPink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .overlay(Rectangle().stroke(CyberColors.neonPink, lineWidth: 1))
                        .padding(.bottom, 4)
                        .diagnosticBorder(.pink.opacity(0.5))
                }
                
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
                    .diagnosticBorder(.black.opacity(0.1))
                    
                    Text(String(format: "%.0f%% Mastery", logic.engine.getBlendedMastery(for: logic.state.patternId) * 100))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(CyberColors.neonCyan)
                .diagnosticBorder(.cyan.opacity(0.3))
                
                // 2. Main prompt with Replay Button
                HStack(alignment: .bottom, spacing: 12) {
                    Text(logic.prompt)
                        .font(.system(size: 38, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .diagnosticBorder(.white.opacity(0.5))
                    
                    Button(action: { logic.playAudio() }) {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(CyberColors.neonCyan)
                            .background(Circle().fill(Color.black))
                            .diagnosticBorder(.cyan.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 4)
                    .diagnosticBorder(.blue.opacity(0.2))
                }
                .diagnosticBorder(.white.opacity(0.1))
                
                if let ph = logic.phonetic, !ph.isEmpty {
                    Text(ph)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .offset(y: -4)
                        .diagnosticBorder(.gray.opacity(0.2))
                }
                
                // 3. TARGET Metadata
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
                    .diagnosticBorder(.blue.opacity(0.1))
                }
            }
            .padding(.leading, 24)
            .overlay(
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(Color.white).frame(width: 4).offset(x: 1, y: 1)
                    Rectangle().fill(CyberColors.neonPink).frame(width: 4)
                }
                .fixedSize(horizontal: true, vertical: false)
                .diagnosticBorder(.pink.opacity(0.3)),
                alignment: .leading
            )
            .diagnosticBorder(.blue.opacity(0.1))
            Spacer()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .diagnosticBorder(.white.opacity(0.1))
    }

    // ── Correction View ─────────────────────────────────────────
    private var patternDictationCorrectionView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CORRECT SOLUTION")
                .font(.caption)
                .tracking(1)
                .foregroundColor(.gray)
                .padding(.leading, 5)
                .diagnosticBorder(.gray.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(logic.state.drillData.target)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                
                if let ph = logic.state.drillData.phonetic, !ph.isEmpty {
                    Text(ph)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.black.opacity(0.5))
                        .diagnosticBorder(.black.opacity(0.1))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(CyberColors.neonGreen)
            .diagnosticBorder(.green.opacity(0.3))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .diagnosticBorder(.white.opacity(0.05))
    }

    // ── Footer ──────────────────────────────────────────────────
    private var patternDictationFooter: some View {
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
                .diagnosticBorder(color.opacity(0.3))
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
                .diagnosticBorder(CyberColors.neonCyan.opacity(0.3))
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(compactDrillZone ? Color.clear : Color.black)
        .diagnosticBorder(.white.opacity(0.1))
    }
}
