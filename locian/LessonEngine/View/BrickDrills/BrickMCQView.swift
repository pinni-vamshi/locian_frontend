import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - BrickMCQView
//   • Two-stage MCQ when the brick has a `base` field (rich data path).
//   • Legacy single-stage MCQ when it doesn't.
// ─────────────────────────────────────────────────────────────

struct BrickMCQView: View {
    @StateObject var logic: BrickMCQLogic
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
        let logic = BrickMCQLogic(
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
                if !compactDrillZone {
                    brickMCQHeader
                        .diagnosticBorder(.orange)
                }
                ScrollView {
                    VStack(spacing: 16) {
                        if compactDrillZone, logic.isLegacyMode {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(logic.state.drillData.target)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                if let phonetic = logic.state.drillData.phonetic, !phonetic.isEmpty {
                                    Text(phonetic)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(Color.white.opacity(0.5))
                                }
                                Text(logic.prompt)
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .diagnosticBorder(Color.green)
                        }
                        if logic.isLegacyMode {
                            legacyOptionsGrid
                                .diagnosticBorder(.green)
                        } else {
                            BrickMCQTwoStageContent(logic: logic)
                                .padding(.top, compactDrillZone ? 4 : 12)
                                .diagnosticBorder(.green)
                        }
                    }
                    .padding(.horizontal, compactDrillZone ? 0 : 0)
                    .padding(.bottom, 120)
                    .diagnosticBorder(.yellow)
                }
                .diagnosticBorder(.orange)
            }
            .diagnosticBorder(.red)
            brickMCQFooter
                .diagnosticBorder(.orange)
        }
        .background(compactDrillZone ? Color.clear : Color.black)
        .diagnosticBorder(.red)
    }

    /// Legacy path compares picked native gloss to `prompt` (brick meaning), not `drillData.target`.
    private var brickLegacyCorrectHighlight: String? {
        guard logic.isCorrect != nil else { return nil }
        return logic.isLegacyMode ? logic.prompt : logic.correctOption
    }

    // ── Header (progress + brick prompt) ──────────────────────────────
    private var brickMCQHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
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

                Text(logic.prompt)
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
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

    // ── Legacy options grid (single-stage fallback) ───────────────────
    private var legacyOptionsGrid: some View {
        VStack(spacing: 16) {

            MCQOptionsGrid(
                options: logic.legacyOptions,
                selectedOption: logic.selectedTargetOption,
                correctOption: brickLegacyCorrectHighlight,
                wrongPicked: nil,
                isAnswered: logic.isCorrect != nil,
                onSelect: { logic.selectOption($0) }
            )
            .padding(.horizontal)
        }
    }

    // ── Footer ────────────────────────────────────────────────────────
    private var brickMCQFooter: some View {
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
            } else if logic.isLegacyMode, logic.selectedTargetOption != nil {
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
        .background(compactDrillZone ? MockTokens.bg : Color.black)
    }
}
