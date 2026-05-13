import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - BrickTypingView (self-contained — logic feeds data in)
// ─────────────────────────────────────────────────────────────

struct BrickTypingView: View {
    @StateObject var logic: BrickTypingLogic
    var onComplete: ((Bool) -> Void)?
    @FocusState private var isFocused: Bool
    @Environment(\.compactDrillZone) private var compactDrillZone
    
    init(
        state: DrillState, 
        engine: LessonEngine, 
        practiceLogic: PatternPracticeLogic? = nil, 
        ghostLogic: GhostModeLogic? = nil, 
        onComplete: ((Bool) -> Void)? = nil
    ) {
        let logic = BrickTypingLogic(
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
                    brickTypingHeader
                        .diagnosticBorder(.white.opacity(0.1))
                }
                
                // 2. Body — input field and correction
                ScrollView {
                    VStack(spacing: 24) {
                        // Instruction Label (Standardized style)

                        brickTypingInputArea
                            .focused($isFocused)
                            .padding(.horizontal, 24)
                            .diagnosticBorder(.green.opacity(0.2))
                        
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            brickTypingCorrectionView
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
            
            // 3. Footer (suppressed when hosted)
                            brickTypingFooter
                                .diagnosticBorder(.orange.opacity(0.2))

        }
        .background(compactDrillZone ? Color.clear : Color.black)
        .diagnosticBorder(.white.opacity(0.1))
        .onAppear {
            isFocused = true
        }
    }

    // ── Header ─────────────────────────────────────────────────
    private var brickTypingHeader: some View {
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
                
                // 2. Main prompt
                Text(logic.prompt)
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .diagnosticBorder(.white.opacity(0.5))
                
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

    // ── Input Area ──────────────────────────────────────────────
    private var brickTypingInputArea: some View {
        let bgColor: Color
        if let correct = logic.isCorrect {
            bgColor = correct ? Color.green : Color.red
        } else {
            bgColor = Color.gray.opacity(0.2)
        }
        
        return TextField("Type here...", text: $logic.userInput)
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
            .padding(12)
            .frame(height: 56)
            .background(bgColor)
            .overlay(
                Rectangle()
                    .frame(width: 7)
                    .foregroundColor(CyberColors.neonCyan)
                    .diagnosticBorder(.cyan.opacity(0.5)),
                alignment: .leading
            )
            .disabled(logic.isCorrect != nil)
            .padding(.leading, 5)
            .padding(.trailing, 20)
            .diagnosticBorder(.white.opacity(0.1))
    }

    // ── Correction View ─────────────────────────────────────────
    private var brickTypingCorrectionView: some View {
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
    private var brickTypingFooter: some View {
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
            } else if !logic.userInput.isEmpty {
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
        .background(Color.black)
        .diagnosticBorder(.white.opacity(0.1))
    }
}
