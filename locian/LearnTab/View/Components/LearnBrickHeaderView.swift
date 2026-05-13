import SwiftUI
import Foundation

struct LearnBrickHeaderView: View {
    let activeRecommendation: PlaceRecommendation?
    let currentPattern: RecommendationPattern?
    @Binding var learnStripShowsTarget: Bool
    @Binding var learnGrammarScope: LearnTabState.LearnGrammarScope
    let showSentenceGraphToggle: Bool
    let locianQuestionTargetTokens: [SentenceToken]
    let locianQuestionNativeTokens: [SentenceToken]
    @Binding var selectedQuestionBrickIndex: Int?
    @Binding var selectedBrickIndex: Int?
    let currentQuestionBricks: [RecommendationBrickItem]
    let onPauseRequested: () -> Void
    let onPlayAudio: (RecommendationBrickItem, String, String) -> Void
    let isLocianQuestionSpeaking: Bool
    let onDoubleTapLocianQuestion: () -> Void

    @State private var locianPulseOn: Bool = false
    @State private var locianPulseTimer: Timer?

    private let conversationChromeIconSize: CGFloat = 26

    private var rowHeight: CGFloat { learnStripShowsTarget ? 68 : 50 }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {

            if let rec = activeRecommendation {
                if let q = currentPattern?.locian_question, !q.isEmpty {
                    let nativeQ = currentPattern?.locian_question_native?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let translitQ = currentPattern?.locian_question_transliteration?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                    // ── Column 1: icon + colon — fixed width, full height, content centred ──
                    HStack(alignment: .center, spacing: 4) {
                        Image("AppIconImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: conversationChromeIconSize, height: conversationChromeIconSize)
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .scaleEffect(isLocianQuestionSpeaking ? (locianPulseOn ? 1.08 : 1.0) : 1.0)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: onDoubleTapLocianQuestion)
                            .diagnosticBorder(.yellow)
                        Text(":")
                            .font(LearnHelvetica.font(size: 14, weight: .heavy))
                            .foregroundColor(Color.white.opacity(0.38))
                            .diagnosticBorder(.yellow)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    .diagnosticBorder(.orange)

                    // ── Column 2: text — vertically centred in slot ──
                    VStack(alignment: .leading, spacing: 2) {
                        if learnStripShowsTarget {
                            locianQuestionFlow(tokens: locianQuestionTargetTokens, fallback: q)
                                .diagnosticBorder(.blue)
                            if !translitQ.isEmpty {
                                Text(translitQ)
                                    .font(LearnHelvetica.font(size: 9, weight: .regular))
                                    .foregroundColor(Color.white.opacity(0.45))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .diagnosticBorder(.cyan)
                            }
                        } else {
                            locianQuestionFlow(
                                tokens: locianQuestionNativeTokens,
                                fallback: nativeQ.isEmpty ? q : nativeQ
                            )
                            .diagnosticBorder(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2, perform: onDoubleTapLocianQuestion)
                    .diagnosticBorder(.green)

                } else {
                    // ── Fallback: no question yet ──
                    HStack(alignment: .top, spacing: 4) {
                        Image("AppIconImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: conversationChromeIconSize, height: conversationChromeIconSize)
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        Text(":")
                            .font(LearnHelvetica.font(size: 14, weight: .heavy))
                            .foregroundColor(Color.white.opacity(0.38))
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    Text("AT THE \(rec.place_id.uppercased())")
                        .font(LearnHelvetica.font(size: 9, weight: .bold))
                        .foregroundColor(ThemeColors.secondaryAccent)
                        .kerning(2)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            } else {
                Text("SELECT A PLACE")
                    .font(LearnHelvetica.font(size: 9, weight: .bold))
                    .foregroundColor(ThemeColors.secondaryAccent)
                    .kerning(2)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            // ── Column 3: mode toggle — right-pinned, full height, content centred ──
            if currentPattern != nil {
                learnStripModeToggle
                    .frame(maxHeight: .infinity, alignment: .center)
                    .diagnosticBorder(.purple)
            }
        }
        .padding(.horizontal, 2)
        .padding(.top, 6)
        .frame(maxWidth: .infinity)
        .frame(height: rowHeight, alignment: .top)
        .clipped()
        .diagnosticBorder(.mint, width: 1)
        .onChange(of: isLocianQuestionSpeaking) { _, newValue in
            locianPulseTimer?.invalidate()
            locianPulseTimer = nil

            guard newValue else {
                locianPulseOn = false
                return
            }

            locianPulseOn = true
            locianPulseTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.22)) {
                    locianPulseOn.toggle()
                }
            }
        }
        .onDisappear {
            locianPulseTimer?.invalidate()
            locianPulseTimer = nil
        }
    }

    @ViewBuilder
    private func locianQuestionFlow(tokens: [SentenceToken], fallback: String) -> some View {
        if tokens.isEmpty {
            Text(fallback)
                .font(LearnHelvetica.font(size: 15, weight: .black))
                .foregroundColor(Color.white.opacity(0.5))
                .kerning(1.2)
                .lineLimit(3)
                .truncationMode(.tail)
        } else {
            FlowLayout(data: tokens, spacing: 0) { token in
                if let brickIndex = token.brickIndex {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                            selectedQuestionBrickIndex = brickIndex
                            selectedBrickIndex = nil
                        }
                        onPauseRequested()
                        if brickIndex < currentQuestionBricks.count {
                            onPlayAudio(currentQuestionBricks[brickIndex], token.text, "question-header")
                        }
                    }) {
                        Text(token.text)
                            .font(LearnHelvetica.font(size: 15, weight: .black))
                            .kerning(1.2)
                            .foregroundColor(
                                selectedQuestionBrickIndex == brickIndex
                                    ? .white : Color.white.opacity(0.5)
                            )
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(height: 1)
                            }
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(token.text)
                        .font(LearnHelvetica.font(size: 15, weight: .black))
                        .kerning(1.2)
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Native (Aa) ↔ target (文). Optional second control: word vs full sentence graph (`showSentenceGraphToggle`).
    private var learnStripModeToggle: some View {
        HStack(spacing: showSentenceGraphToggle ? 10 : 0) {
            scriptLineToggleButton

            if showSentenceGraphToggle {
                Text("|")
                    .font(LearnHelvetica.font(size: 10, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.35))
                    .padding(.horizontal, 2)

                sentenceGraphScopeToggleButton
            }
        }
    }

    private var scriptLineToggleButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeInOut(duration: 0.2)) { learnStripShowsTarget.toggle() }
        } label: {
            Text(learnStripShowsTarget ? "文" : "Aa")
                .font(LearnHelvetica.font(size: learnStripShowsTarget ? 15 : 12, weight: .black))
                .foregroundColor(ThemeColors.secondaryAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(minHeight: 28, alignment: .center)
                .background(Color.white)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(learnStripShowsTarget ? "Learning language line" : "Native line")
        .accessibilityHint("Tap to switch between native and learning-language lines.")
    }

    private var sentenceGraphScopeToggleButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeInOut(duration: 0.2)) {
                learnGrammarScope = learnGrammarScope == .word ? .sentence : .word
            }
        } label: {
            Group {
                if learnGrammarScope == .word {
                    Text("-")
                        .font(LearnHelvetica.font(size: 20, weight: .black))
                } else {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundColor(ThemeColors.secondaryAccent)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(minWidth: 28, minHeight: 28, alignment: .center)
            .background(Color.white)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(learnGrammarScope == .word ? "Word graph" : "Sentence graph")
        .accessibilityHint("Tap to switch between word graph and full sentence graph.")
    }
}
