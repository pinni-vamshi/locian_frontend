import SwiftUI

// MARK: - Shared Two-Stage MCQ Content
//
// Used by both `BrickMCQView` (standalone Ghost / Practice path) and
// `BrickMCQInteraction` (embedded Pattern Intro path).

struct BrickMCQTwoStageContent: View {
    @ObservedObject var logic: BrickMCQLogic

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            stageOneSection
                .diagnosticBorder(.orange)
            stageTwoSection
                .diagnosticBorder(.orange)
            whyCaptionIfNeeded
                .diagnosticBorder(.orange)
        }
        .padding(.horizontal, 16)
        .diagnosticBorder(.red)
    }

    // MARK: - Question line ("How do we say 'order' in Spanish?")

    @ViewBuilder
    private func questionLine(prefix: String, vocab: String, suffix: String?) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Text(prefix)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .diagnosticBorder(.blue)
            Text("\u{201C}\(vocab)\u{201D}")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(CyberColors.neonCyan)
                .diagnosticBorder(.cyan)
            if let suffix = suffix, !suffix.isEmpty {
                Text(suffix)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .diagnosticBorder(.blue)
            }
            Spacer(minLength: 0)
        }
        .fixedSize(horizontal: false, vertical: true)
        .diagnosticBorder(.green)
    }

    // MARK: - 1. Stage 1

    /// "to order" → "order"; falls back to the brick prompt when no baseNative.
    private var nativeWordToAsk: String {
        let bn = (logic.baseNative ?? "").trimmingCharacters(in: .whitespaces)
        if !bn.isEmpty {
            if bn.lowercased().hasPrefix("to ") {
                return String(bn.dropFirst(3))
            }
            return bn
        }
        return logic.prompt
    }

    @ViewBuilder
    private var stageOneSection: some View {
        switch logic.stage {
        case .pickingBase:
            VStack(alignment: .leading, spacing: 12) {
                questionLine(
                    prefix: "How do we say",
                    vocab: nativeWordToAsk,
                    suffix: "in \(logic.targetLanguage)?"
                )
                .diagnosticBorder(.blue)
                MCQOptionsGrid(
                    options: logic.baseOptions,
                    selectedOption: logic.awaitingContinueAfterWrongBase ? logic.basePickedWrong : nil,
                    correctOption: logic.awaitingContinueAfterWrongBase ? logic.correctBase : nil,
                    wrongPicked: logic.awaitingContinueAfterWrongBase ? nil : logic.basePickedWrong,
                    isAnswered: logic.awaitingContinueAfterWrongBase,
                    onSelect: { logic.selectBase($0) }
                )
                .diagnosticBorder(.green)
                if logic.awaitingContinueAfterWrongBase {
                    wrongBaseFooter
                        .diagnosticBorder(.red)
                }
            }
            .diagnosticBorder(.yellow)
        case .expandedAtBase(let pickedBase):
            confirmedBasePill(picked: pickedBase)
                .diagnosticBorder(.yellow)
        case .answered:
            confirmedBasePill(picked: logic.correctBase ?? "")
                .diagnosticBorder(.yellow)
        }
    }

    private func confirmedBasePill(picked: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(CyberColors.success)
                    .font(.system(size: 14, weight: .bold))
                    .diagnosticBorder(.blue)
                Text(picked)
                    .font(.system(size: 17, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .diagnosticBorder(.blue)
                if let bn = logic.baseNative, !bn.isEmpty {
                    Text("(\(bn))")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.black.opacity(0.6))
                        .diagnosticBorder(.blue)
                }
                Spacer()
                if let fk = logic.formKind, !fk.isEmpty {
                    Text("[\(fk.uppercased())]")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(CyberColors.neonCyan)
                        .diagnosticBorder(.cyan)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white)
            .diagnosticBorder(.green)

            if let p = logic.pattern, !p.isEmpty {
                Text(p)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
                    .padding(.horizontal, 4)
                    .diagnosticBorder(.blue)
            }
        }
        .diagnosticBorder(.yellow)
    }

    // MARK: - 3. Stage 2

    @ViewBuilder
    private var stageTwoSection: some View {
        if case .pickingBase = logic.stage {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                questionLine(
                    prefix: "Now pick the form for",
                    vocab: logic.prompt,
                    suffix: nil
                )
                .diagnosticBorder(.blue)

                let isAnswered: Bool = {
                    if case .answered = logic.stage { return true }
                    return false
                }()

                MCQOptionsGrid(
                    options: logic.targetOptions,
                    selectedOption: logic.selectedTargetOption,
                    correctOption: isAnswered ? logic.correctOption : nil,
                    wrongPicked: nil,
                    isAnswered: isAnswered,
                    onSelect: { logic.selectTarget($0) }
                )
                .diagnosticBorder(.green)
            }
            .diagnosticBorder(.yellow)
        }
    }

    // MARK: - Wrong-base footer (gates the auto-advance from Stage 1 → Stage 2)

    /// After a wrong base tap, choices lock until the user proceeds — same red feedback,
    /// but copy clarifies this advances the lesson (reveals correct base → stage 2),
    /// not “tap options again” (those rows stay `.disabled` in compact UI).
    private var wrongBaseFooter: some View {
        CyberProceedButton(
            action: { logic.continueAfterWrongBase() },
            label: "Continue",
            title: "Not quite",
            color: Color.red,
            systemImage: "arrow.right",
            isEnabled: true
        )
        .diagnosticBorder(.red)
    }

    // MARK: - 4. Why caption

    @ViewBuilder
    private var whyCaptionIfNeeded: some View {
        if case .answered(let ok) = logic.stage, !ok, let why = logic.why, !why.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("WHY")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .tracking(1.0)
                    .foregroundColor(.white.opacity(0.5))
                    .diagnosticBorder(.blue)
                Text(why)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CyberColors.neonGreen)
                    .diagnosticBorder(.green)
            }
            .diagnosticBorder(.yellow)
        } else {
            EmptyView()
        }
    }
}

// MARK: - MCQOptionsGrid (2x2)

struct MCQOptionsGrid: View {
    let options: [String]
    let selectedOption: String?
    let correctOption: String?
    let wrongPicked: String?
    let isAnswered: Bool
    let onSelect: (String) -> Void

    @Environment(\.compactDrillZone) private var compactDrillZone

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isThisCorrect: Bool? = {
                    guard isAnswered else { return nil }
                    if option == correctOption { return true }
                    if selectedOption == option { return false }
                    return nil
                }()
                let isWrongFlash = (wrongPicked == option)

                CyberOption(
                    text: option,
                    phonetic: nil,
                    index: index,
                    isSelected: selectedOption == option,
                    isCorrect: isThisCorrect ?? (isWrongFlash ? false : nil),
                    showCorrectHint: isAnswered && option == correctOption,
                    action: { onSelect(option) }
                )
                .diagnosticBorder(.cyan)
            }
        }
        .diagnosticBorder(.green)
        .diagnosticBorder(.orange)
    }
}

private struct CyberOption: View {
    let text: String
    var phonetic: String? = nil
    let index: Int
    let isSelected: Bool
    var isCorrect: Bool? = nil
    var showCorrectHint: Bool = false
    let action: () -> Void

    private var stateColor: Color {
        guard let correct = isCorrect else {
            return isSelected ? CyberColors.neonPink : .white
        }
        return correct ? Color.green : Color.red
    }

    private var accentColor: Color {
        if isCorrect != nil { return .black }
        return isSelected ? CyberColors.neonCyan : Color.white.opacity(0.3)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack {
                    Text(String(format: "%02d", index + 1))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(isCorrect == nil ? (isSelected ? CyberColors.neonPink : Color.white.opacity(0.2)) : .black.opacity(0.5))
                    Spacer()
                    if isSelected || isCorrect != nil || showCorrectHint {
                        Image(systemName: isCorrect == false ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(isCorrect != nil ? .black : stateColor)
                    }
                }
                .padding([.horizontal, .top], 10)
                .diagnosticBorder(.blue)

                Spacer()

                VStack(spacing: 4) {
                    Text(text)
                        .font(.system(size: text.count > 10 ? 16 : 22, weight: .black))
                        .foregroundColor(isCorrect != nil ? .black : .white)
                        .multilineTextAlignment(.center)

                    if let ph = phonetic, !ph.isEmpty {
                        Text(ph)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor((isCorrect != nil) ? .black.opacity(0.5) : .gray)
                    }
                }
                .padding(.horizontal, 8)
                .diagnosticBorder(.blue)

                Spacer()

                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(accentColor)
                        .frame(width: 8, height: 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .bottom], 10)
                .diagnosticBorder(.blue)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                ChamferedShape(chamferSize: 12, cornerRadius: 0)
                    .fill(isCorrect == nil ? Color.black.opacity(0.4) : stateColor)
            )
            .overlay(
                ChamferedShape(chamferSize: 12, cornerRadius: 0)
                    .stroke(isCorrect == nil ? (isSelected ? CyberColors.neonPink : Color.white.opacity(0.1)) : .clear, lineWidth: 1)
            )
            .overlay(
                showCorrectHint
                ? ChamferedShape(chamferSize: 12, cornerRadius: 0).stroke(Color.green, lineWidth: 3)
                : nil
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCorrect)
            .diagnosticBorder(.green)
        }
        .disabled(isCorrect != nil && !showCorrectHint)
        .diagnosticBorder(.orange)
    }
}
