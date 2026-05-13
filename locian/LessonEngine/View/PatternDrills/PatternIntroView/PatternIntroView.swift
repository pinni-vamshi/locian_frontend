import SwiftUI

/// A lightweight Pattern Intro View that doesn't need a heavy Logic file.
/// Used for the "Recap" phase of a pattern.
struct PatternIntroView: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    @ObservedObject var logic: PatternIntroLogic

    @State private var isHintExpanded: Bool = false
    @Environment(\.compactDrillZone) private var compactDrillZone

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Inside the conversation shell, the top 40% already shows the
                // sentence + meaning + progress, so this internal header is
                // pure duplication. Hide it in compact mode.
                if !compactDrillZone {
                    headerSection
                        .diagnosticBorder(.white.opacity(0.1))
                }

                if logic.isPlayingIntro {
                    PatternIntroAnimationView(
                        bricks: logic.brickDrills,
                        onComplete: { logic.onIntroComplete() },
                        targetLanguage: engine.lessonData?.target_language ?? "es",
                        userLanguage: engine.lessonData?.user_language ?? "en",
                        patternMeaning: drill.drillData.meaning,
                        patternTarget: drill.drillData.target,
                        animatingIndices: $logic.animatingIndices,
                        onWordReveal: { id in
                            engine.currentIntroBrickID = id
                            engine.revealedIntroBrickIDs.insert(id)
                            let allDone = engine.lastIntroBrickIDs.allSatisfy { engine.revealedIntroBrickIDs.contains($0) }
                            if allDone {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        engine.introAllRevealed = true
                                    }
                                }
                            }
                        }
                    )
                    .transition(.opacity)
                    .diagnosticBorder(.pink.opacity(0.2))
                } else {
                    SentenceIntroGraphView(
                        allBricks: logic.allSentenceBricks,
                        orderedTeachBricks: logic.bridgeBricks,
                        brickDrills: logic.brickDrills,
                        targetLanguage: engine.lessonData?.target_language ?? "es",
                        engine: engine,
                        onContinue: { logic.engine.orchestrator?.finishVocabIntro() }
                    )
                    .transition(.opacity)
                    .diagnosticBorder(.blue.opacity(0.2))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black)
        .diagnosticBorder(.white.opacity(0.1))
    }

    @ViewBuilder
    private var headerSection: some View {
        // ─── Pattern Intro Header (self-contained) ───────────────────────
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {

                // 1. PROGRESS badge with inline progress circles + pattern mastery
                HStack(spacing: 8) {
                    Text("PROGRESS")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .tracking(1.0)

                    PatternProgressRow(
                        patterns: engine.rawPatterns.map { $0.id },
                        currentPatternId: drill.patternId,
                        engine: engine
                    )

                    Text(String(format: "%.0f%% Pattern", engine.getBlendedMastery(for: drill.patternId) * 100))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.leading, 4)

                    // Active brick mastery indicator
                    if let activeBrick = logic.currentDrill {
                        let brickMastery = engine.getDecayedMastery(for: activeBrick.drillData.target)
                        let brickWord = activeBrick.drillData.meaning.uppercased()

                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 1, height: 14)

                        Text("\(brickWord) · \(String(format: "%.0f%%", brickMastery * 100))")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberColors.neonPink)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(CyberColors.neonCyan)

                // 2. Main meaning sentence with active brick word highlighted in pink
                highlightedMeaningText
                    .font(.system(size: 38, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)

                // 3. SEE TRANSLATION hint button (expandable)
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isHintExpanded.toggle()
                    }
                }) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(CyberColors.neonPink)
                            .rotationEffect(.degrees(isHintExpanded ? 180 : 0))
                            .padding(.top, 2)

                        if isHintExpanded {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(drill.drillData.target)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.black)

                                if let phonetic = drill.drillData.phonetic, !phonetic.isEmpty {
                                    Text(phonetic)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.black.opacity(0.5))
                                }
                            }
                        } else {
                            Text(logic.hintLabel)      // "SEE SPANISH TRANSLATION"
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(CyberColors.neonGreen)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 24)
            .overlay(
                // Left vertical pink line (Pattern Intro identity)
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
        // ─────────────────────────────────────────────────────────────────
    }

    /// Builds a rich Text that highlights the active brick's meaning words
    /// in neon pink inside the full native-language sentence.
    private var highlightedMeaningText: Text {
        let sentence = drill.drillData.meaning

        // Build a set of lowercase words to highlight
        var highlightWords: Set<String> = []

        if logic.isPlayingIntro {
            // Highlight ALL bricks currently being introduced in the animation
            for idx in logic.animatingIndices {
                if idx < logic.brickDrills.count {
                    let brickMeaning = logic.brickDrills[idx].drillData.meaning
                    highlightWords.formUnion(
                        brickMeaning.lowercased()
                            .components(separatedBy: .whitespacesAndNewlines)
                            .filter { !$0.isEmpty }
                    )
                }
            }
        } else {
            // Standard interactive mode: highlight only the current drill's target words
            let brickMeaning = logic.currentDrill?.drillData.meaning ?? ""
            highlightWords = Set(
                brickMeaning
                    .lowercased()
                    .components(separatedBy: .whitespacesAndNewlines)
                    .filter { !$0.isEmpty }
            )
        }

        guard !highlightWords.isEmpty else {
            return Text(sentence).foregroundColor(.black)
        }

        let tokens = sentence.components(separatedBy: " ")
        var result = Text("")

        for (i, token) in tokens.enumerated() {
            // Strip punctuation for comparison only
            let clean = token.lowercased().trimmingCharacters(in: .punctuationCharacters)
            let isHighlighted = highlightWords.contains(clean)

            let space: Text = i > 0 ? Text(" ") : Text("")
            let wordText: Text = isHighlighted
                ? Text(token).foregroundColor(CyberColors.neonPink)
                : Text(token).foregroundColor(.black)

            result = result + space + wordText
        }

        return result
    }
}
