import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - PatternBuilderView (self-contained — logic feeds data in)
// ─────────────────────────────────────────────────────────────

struct PatternBuilderView: View {
    @StateObject private var logic: PatternBuilderLogic
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.compactDrillZone) private var compactDrillZone
    var onComplete: ((Bool) -> Void)?

    init(
        state: DrillState,
        engine: LessonEngine,
        practiceLogic: PatternPracticeLogic? = nil,
        ghostLogic: GhostModeLogic? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) {
        let logic = PatternBuilderLogic(
            state: state,
            engine: engine,
            appState: nil,
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
                // 1. Header (Native prompt + progress) — only in legacy/full screen
                if !compactDrillZone {
                    patternBuilderHeader
                        .diagnosticBorder(.orange)
                }

                // 2. Body
                ScrollView {
                    VStack(alignment: .center, spacing: compactDrillZone ? 20 : 35) {

                        // Section 2: Built sentence with fixed lines
                        builtSentenceArea
                            .diagnosticBorder(.green)

                        // Section 3: Word pool
                        if !logic.checked {
                            wordPool
                                .diagnosticBorder(.green)
                        } else {
                            VStack(spacing: 24) {
                                if logic.isCorrect == false {
                                    CorrectSolutionView(solution: logic.state.drillData.target)
                                        .diagnosticBorder(.cyan)
                                }
                                ExploreSimilarWordsSection(logic: logic)
                                    .diagnosticBorder(.cyan)
                            }
                            .padding(.horizontal)
                            .diagnosticBorder(.green)
                        }
                    }
                    .padding(.top, compactDrillZone ? 8 : 0)
                    .padding(.bottom, 140)
                    .diagnosticBorder(.yellow)
                }
                .diagnosticBorder(.orange)
            }
            .background(compactDrillZone ? Color.clear : Color.black)
            .diagnosticBorder(.red)

            // 3. Footer
            patternBuilderFooter
                .diagnosticBorder(.orange)
        }
        .background(compactDrillZone ? Color.clear : Color.black)
        .onAppear {
            logic.appState = appState
        }
        .diagnosticBorder(.red)
    }

    // ── Built Sentence Area ─────────────────────────────────────
    @ViewBuilder
    private var builtSentenceArea: some View {
        if compactDrillZone {
            compactBuiltSentence
        } else {
            legacyBuiltSentence
        }
    }

    /// Compact (Phase B) — pink-left-border stage card with cloze-style underline blanks.
    private var compactBuiltSentence: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(MockTokens.pink)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 6) {
                Text("BUILD · TARGET")
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .tracking(1.6)
                    .foregroundColor(MockTokens.muted)

                FlowLayout(
                    data: Array(logic.selectedTokens.enumerated()),
                    id: \.element.id,
                    spacing: 8,
                    alignment: .leading
                ) { index, token in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        logic.removeToken(at: index)
                    } label: {
                        Text(token.text)
                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            .foregroundColor(builtTokenColor(token: token, index: index))
                            .lineLimit(1)
                            .padding(.bottom, 2)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(builtTokenColor(token: token, index: index).opacity(0.6))
                                    .frame(height: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .disabled(logic.checked)
                }

                if logic.selectedTokens.isEmpty {
                    Text("Tap words below to build the reply")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(MockTokens.muted2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MockTokens.g0)
        .padding(.horizontal, 14)
    }

    private func builtTokenColor(token: Token, index: Int) -> Color {
        guard logic.checked else { return MockTokens.fg }
        return logic.getWordColor(token.text, index: index) == CyberColors.neonGreen
            ? MockTokens.green
            : .red
    }

    /// Legacy (full-screen) — original 28pt mono cyan layout, kept for non-compact callers.
    private var legacyBuiltSentence: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 44) {
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 2)
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 2)
            }
            .padding(.top, 38)

            FlowLayout(data: Array(logic.selectedTokens.enumerated()), id: \.element.id, spacing: 12, alignment: .center) { index, token in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    logic.removeToken(at: index)
                } label: {
                    Text(token.text)
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(logic.checked
                                         ? (logic.getWordColor(token.text, index: index) == CyberColors.neonGreen ? CyberColors.neonGreen : .red)
                                         : CyberColors.neonCyan)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                .disabled(logic.checked)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // ── Word Pool ──────────────────────────────────────────────
    @ViewBuilder
    private var wordPool: some View {
        if compactDrillZone {
            compactWordPool
        } else {
            legacyWordPool
        }
    }

    /// Compact (Phase B) — flat dark tiles per HTML mock; used tiles are removed entirely.
    private var compactWordPool: some View {
        let pool = logic.availableTokens.enumerated().filter { !$0.element.isUsed }
        return VStack(alignment: .leading, spacing: 10) {
            Text("TAP · POOL")
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .tracking(1.6)
                .foregroundColor(MockTokens.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            FlowLayout(data: Array(pool), id: \.element.id, spacing: 8, alignment: .leading) { index, token in
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    logic.selectToken(at: index)
                } label: {
                    Text(token.text)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundColor(MockTokens.fg)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(MockTokens.g0)
                        .overlay(Rectangle().stroke(MockTokens.g2, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(logic.checked)
            }
        }
        .padding(.horizontal, 14)
    }

    /// Legacy (full-screen) — original cyan/ghost-text layout.
    private var legacyWordPool: some View {
        VStack(spacing: 20) {
            Text("TAP TO RECONSTRUCT")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.gray)
                .tracking(2)

            FlowLayout(data: Array(logic.availableTokens.enumerated()), id: \.element.id, spacing: 12, alignment: .center) { index, token in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    logic.selectToken(at: index)
                } label: {
                    Text(token.text)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(token.isUsed ? .clear : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(token.isUsed ? Color.white.opacity(0.1) : CyberColors.neonCyan)
                        .clipShape(ChamferedShape(chamferSize: 8, cornerRadius: 0))
                }
                .disabled(token.isUsed || logic.checked)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }

    // ── Header ─────────────────────────────────────────────────
    private var patternBuilderHeader: some View {
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

                    Text(String(format: "%.0f%% Mastery",
                                logic.engine.getBlendedMastery(for: logic.state.patternId) * 100))
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

            Spacer()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            ZStack(alignment: .topLeading) {
                Rectangle().fill(Color.white).frame(width: 4).offset(x: 1, y: 1)
                Rectangle().fill(CyberColors.neonPink).frame(width: 4)
            },
            alignment: .leading
        )
    }

    // ── Footer ──────────────────────────────────────────────────
    private var patternBuilderFooter: some View {
        VStack(spacing: 0) {
            if logic.checked {
                Divider().background(Color.white.opacity(0.1))
                let isCorrect = logic.isCorrect ?? false
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
        .background(compactDrillZone ? MockTokens.bg : Color.black)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Local Components (Inlined decorations & sections)
// ─────────────────────────────────────────────────────────────

fileprivate struct CorrectSolutionView: View {
    let solution: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CORRECT SOLUTION")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundColor(.black.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.top, 5)

            Text(solution)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
        }
        .background(CyberColors.neonGreen)
        .cornerRadius(0)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

fileprivate struct ExploreSimilarWordsSection: View {
    @ObservedObject var logic: PatternBuilderLogic

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("EXPLORE SIMILAR WORDS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(CyberColors.neonPink)

            FlowLayout(data: logic.exploreWords, id: \.word, spacing: 12) { item in
                TechWordButton(
                    word: item.word,
                    meaning: item.meaning,
                    isSelected: logic.selectedExploreWord == item.word,
                    action: { logic.selectExploreWord(item.word) }
                )
            }

            if logic.isSearching {
                ProgressView()
                .tint(CyberColors.neonCyan)
                .frame(maxWidth: .infinity)
                .padding()
            } else if !logic.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(logic.searchResults) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.word.uppercased())
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)

                                if let pron = item.pronunciation {
                                    Text("[\(pron)]")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                            }

                            Text(item.translation)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)

                            if let example = item.explanation {
                                Text(example)
                                    .font(.system(size: 12, weight: .regular, design: .serif).italic())
                                    .foregroundColor(CyberColors.neonPink)
                                    .padding(.top, 2)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

fileprivate struct TechWordButton: View {
    let word: String
    let meaning: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.uppercased())
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(isSelected ? .black : .white)

                Text(meaning.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? .black.opacity(0.7) : CyberColors.neonCyan.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        CyberColors.neonPink
                    } else {
                        Color.black.opacity(0.6)
                    }

                    GridPatternDecoration()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            )
            .overlay(
                TechFrameBorderDecoration(isSelected: isSelected)
            )
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct GridPatternDecoration: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 8
        for x in stride(from: 0, through: rect.maxX, by: step) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        for y in stride(from: 0, through: rect.maxY, by: step) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }
}

fileprivate struct TechFrameBorderDecoration: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(isSelected ? .black : Color.white.opacity(0.3), lineWidth: 1)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let len: CGFloat = 6
                let color = isSelected ? Color.black : CyberColors.neonCyan

                Path { p in
                    p.move(to: CGPoint(x: 0, y: len))
                    p.addLine(to: CGPoint(x: 0, y: 0))
                    p.addLine(to: CGPoint(x: len, y: 0))

                    p.move(to: CGPoint(x: w - len, y: 0))
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.addLine(to: CGPoint(x: w, y: len))

                    p.move(to: CGPoint(x: w, y: h - len))
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: w - len, y: h))

                    p.move(to: CGPoint(x: len, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h - len))
                }
                .stroke(color, lineWidth: 2)
            }
        }
    }
}
