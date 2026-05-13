import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - PatternMCQView (self-contained — logic feeds data in)
// ─────────────────────────────────────────────────────────────

struct PatternMCQView: View {
    @StateObject var logic: PatternMCQLogic
    var onComplete: ((Bool) -> Void)?
    @Environment(\.compactDrillZone) private var compactDrillZone
    
    init(
        state: DrillState, 
        engine: LessonEngine, 
        practiceLogic: PatternPracticeLogic? = nil, 
        ghostLogic: GhostModeLogic? = nil, 
        onComplete: ((Bool) -> Void)? = nil
    ) {
        let logic = PatternMCQLogic(
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
                // 1. Header (hidden in conversation shell — HTML puts sentence in `.audio-bar`)
                if !compactDrillZone {
                    patternMCQHeader
                        .diagnosticBorder(.white.opacity(0.1))
                }

                // 2. Body
                ScrollView {
                    VStack(spacing: compactDrillZone ? 12 : 24) {
                        patternMCQOptionGrid
                            .diagnosticBorder(.green.opacity(0.2))
                    }
                    .padding(.top, compactDrillZone ? 12 : 0)
                    .padding(.bottom, 120)
                    .diagnosticBorder(.white.opacity(0.05))
                }
                .diagnosticBorder(.white.opacity(0.1))
            }
            .diagnosticBorder(.blue.opacity(0.1))
            
            // 3. Footer (Suppressed when hosted by an orchestrator)
                            patternMCQFooter
                                .diagnosticBorder(.orange.opacity(0.2))

        }
        .background(compactDrillZone ? Color.clear : Color.black)
        .diagnosticBorder(.white.opacity(0.1))
        .onAppear {
            if compactDrillZone {
                logic.engine.isCompactPatternMCQVisible = true
            }
        }
        .onDisappear {
            if compactDrillZone {
                logic.engine.isCompactPatternMCQVisible = false
            }
        }

    }
    
    // ── Header ─────────────────────────────────────────────────
    private var patternMCQHeader: some View {
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
                
                // 2. Main prompt (Spanish/Target)
                Text(logic.prompt)
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .diagnosticBorder(.white.opacity(0.5))
                
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

    // ── Option Grid ────────────────────────────────────────────
    private var patternMCQOptionGrid: some View {
        VStack(spacing: 16) {
            ForEach(Array(logic.options.enumerated()), id: \.offset) { index, option in
                let isAnswered = logic.isCorrect != nil
                let isCorrectOption: Bool? = {
                    guard isAnswered else { return nil }
                    if option == logic.state.drillData.target { return true }
                    if logic.selectedOption == option { return false }
                    return nil
                }()
                let isSelected = logic.selectedOption == option
                let stateColor: Color = {
                    guard let c = isCorrectOption else { return isSelected ? CyberColors.neonPink : .white }
                    return c ? Color.green : Color.red
                }()

                Button(action: {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    logic.selectOption(option)
                }) {
                    HStack(spacing: 12) {
                        ZStack(alignment: .topLeading) {
                            Rectangle().fill(isCorrectOption != nil ? .clear : Color.white).frame(width: 10, height: 10).offset(x: 1, y: 1)
                            Rectangle().fill(isCorrectOption != nil ? .black : (isSelected ? CyberColors.neonCyan : Color.white.opacity(0.3))).frame(width: 10, height: 10)
                        }
                        .padding(.leading, 16)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(option)
                                .font(.system(size: isCorrectOption != nil ? 20 : 16, weight: isCorrectOption != nil ? .bold : .medium))
                                .foregroundColor(isCorrectOption != nil ? .black : .white)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        VStack {
                            Text(String(format: "%02d", index + 1))
                                .font(.caption2).fontDesign(.monospaced)
                                .foregroundColor(isCorrectOption == nil ? (isSelected ? CyberColors.neonPink : Color.white.opacity(0.2)) : .black.opacity(0.5))
                                .padding([.top, .trailing], 8)
                            Spacer()
                            if isSelected || isCorrectOption != nil {
                                Image(systemName: isCorrectOption == false ? "xmark.circle.fill" : "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(isCorrectOption != nil ? .black : stateColor)
                                    .padding([.bottom, .trailing], 8)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .frame(minHeight: 60)
                    .background(
                        ChamferedShape(chamferSize: 16, cornerRadius: 0)
                            .fill(isCorrectOption == nil ? Color.black.opacity(0.4) : stateColor)
                    )
                    .overlay(
                        ChamferedShape(chamferSize: 16, cornerRadius: 0)
                            .stroke(isCorrectOption == nil ? (isSelected ? CyberColors.neonPink : Color.white.opacity(0.1)) : .clear, lineWidth: 1)
                    )
                    .overlay(
                        isAnswered && option == logic.state.drillData.target
                        ? ChamferedShape(chamferSize: 16, cornerRadius: 0).stroke(Color.green, lineWidth: 3)
                        : nil
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCorrectOption)
                }
            }
        }
        .padding(.horizontal)
    }

    // ── Footer ──────────────────────────────────────────────────
    private var patternMCQFooter: some View {
        VStack(spacing: 0) {
            if logic.isAnswered {
                Divider().background(Color.white.opacity(0.1))
                let isCorrect = (logic.isCorrect == true)
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
            } else if logic.selectedOption != nil {
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
        .background(compactDrillZone ? MockTokens.bg : Color.black)
        .diagnosticBorder(.white.opacity(0.1))
    }
}
