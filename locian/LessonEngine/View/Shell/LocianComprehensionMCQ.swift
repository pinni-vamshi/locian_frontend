//
//  LocianComprehensionMCQ.swift
//  locian
//
//  Matches HTML `.audio-bar` + `.opts`: hear strip + letter-key MCQ rows.
//  Header / ledger / stage-head live in ActiveTurnView (DrillScreen layout).
//

import SwiftUI

struct LocianComprehensionMCQ: View {
    let questionTarget: String
    let questionMeaning: String
    let distractors: [String]
    /// Whether the component renders the big L2 headline at the top.
    /// Set to `false` when the parent layout (e.g. the conveyor's grey
    /// header zone) already shows the question text and only the
    /// interactive part of the MCQ should appear here.
    var showsHeadline: Bool = true
    var onAnswered: (Bool) -> Void

    @State private var options: [String] = []
    @State private var selected: String? = nil
    @State private var didAnswer = false
    @State private var isCorrect: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsHeadline {
                Text(locianHeadlineTarget)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(MockTokens.fg)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .diagnosticBorder(.blue)
            }

            // Cue label sits directly above the option list (not as a separate
            // top-stack track) so the headline + label + options read as one
            // grouped block.
            hearLocianPrompt
                .padding(.top, showsHeadline ? 18 : 0)
                .padding(.bottom, 10)
                .diagnosticBorder(.blue)

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { opt in
                    let isSelected = selected == opt
                    let isRight = opt == questionMeaning
                    let bg: Color = {
                        guard isSelected else { return Color.white.opacity(0.07) }
                        return isRight ? Color.green : Color.red.opacity(0.75)
                    }()
                    Button { pick(opt) } label: {
                        Text(opt)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(isSelected ? .black : .white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(bg)
                    }
                    .buttonStyle(.plain)
                    .disabled(didAnswer)
                }
            }
            .diagnosticBorder(.yellow)

            if didAnswer {
                feedbackFooter
                    .padding(.top, 10)
                    .diagnosticBorder(.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear(perform: setup)
        .diagnosticBorder(.orange)
    }

    /// Footer banner that gates the auto-advance: shows CORRECT (green) or
    /// INCORRECT (red) and waits for the user to tap CONTINUE.
    private var feedbackFooter: some View {
        let color: Color = isCorrect ? CyberColors.success : Color.red
        let title: String = isCorrect ? "CORRECT!" : "INCORRECT"
        return CyberProceedButton(
            action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onAnswered(isCorrect)
            },
            label: isCorrect ? "ANSWER_CONFIRMED" : "TRY_AGAIN",
            title: title,
            color: color,
            systemImage: "arrow.right",
            isEnabled: true
        )
    }

    /// HTML `.prompt`: pink "HEAR · " + muted "WHAT IS LOCIAN SAYING?" — sits
    /// directly above the option list so the user's eye flows from the target
    /// headline → cue label → options.
    private var hearLocianPrompt: some View {
        (Text("HEAR · ").foregroundColor(MockTokens.pink)
            + Text("WHAT IS LOCIAN SAYING?").foregroundColor(MockTokens.muted))
            .font(.system(size: 10, weight: .regular, design: .monospaced))
            .tracking(1.6)
            .textCase(.uppercase)
    }

    /// Locian step: big line is **target** language; MCQ choices stay native meanings.
    private var locianHeadlineTarget: String {
        let t = questionTarget.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty { return t }
        return questionMeaning
    }

    private func setup() {
        var pool = Array(Set(distractors)).filter { $0 != questionMeaning && !$0.isEmpty }
        pool.shuffle()
        let chosen = Array(pool.prefix(2)) + [questionMeaning]
        options = chosen.shuffled()
    }

    /// Tap a choice → mark answered and show the red/green footer.
    /// Auto-advance is gone: caller is notified only when CONTINUE is tapped.
    private func pick(_ opt: String) {
        guard !didAnswer else { return }
        selected = opt
        isCorrect = (opt == questionMeaning)
        withAnimation(.easeOut(duration: 0.18)) {
            didAnswer = true
        }
    }
}
