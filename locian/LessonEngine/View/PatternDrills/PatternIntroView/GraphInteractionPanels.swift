import SwiftUI

// MARK: - MCQ Panel

struct GraphMCQPanel: View {
    @StateObject private var logic: BrickMCQLogic
    var onBaseRevealed: () -> Void
    var onTargetRevealed: () -> Void
    var onAutoAdvance: () -> Void

    init(drill: DrillState, engine: LessonEngine,
         onBaseRevealed: @escaping () -> Void,
         onTargetRevealed: @escaping () -> Void,
         onAutoAdvance: @escaping () -> Void) {
        self._logic = StateObject(wrappedValue: BrickMCQLogic(state: drill, engine: engine))
        self.onBaseRevealed = onBaseRevealed
        self.onTargetRevealed = onTargetRevealed
        self.onAutoAdvance = onAutoAdvance
    }

    var body: some View {
        VStack(spacing: 0) {
            questionLabel
                .diagnosticBorder(.cyan)
            optionsGrid
                .diagnosticBorder(.green)
        }
        .diagnosticBorder(.yellow)
        // Base correctly picked → fill base box → target options appear automatically
        .onChange(of: logic.stage) { _, newStage in
            if case .expandedAtBase = newStage {
                onBaseRevealed()
            }
        }
        // Wrong base → auto-continue after brief flash, no user tap needed
        .onChange(of: logic.awaitingContinueAfterWrongBase) { _, waiting in
            guard waiting else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                logic.continueAfterWrongBase()
            }
        }
        // Final answer (two-stage target or legacy) → fill target box → auto-advance
        .onChange(of: logic.isCorrect) { _, newVal in
            guard newVal != nil else { return }
            onTargetRevealed()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { onAutoAdvance() }
        }
    }

    private var questionLabel: some View {
        ZStack {
            Color.black
            stageLabelContent
                .font(.custom("Helvetica Neue", size: 11).weight(.bold))
                .kerning(0.8)
                .lineLimit(3)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 48, maxHeight: 80)
        .overlay(Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1), alignment: .top)
        .id(stageIndex)
    }

    @ViewBuilder
    private var stageLabelContent: some View {
        switch logic.stage {
        case .pickingBase:
            // "HOW DO YOU SAY 'REST' IN SPANISH?" — uses baseNative (root form), not prompt (inflected)
            let rootWord = logic.baseNative ?? logic.prompt
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Text("HOW DO YOU SAY")
                        .foregroundColor(Color(white: 0.38))
                    Text("\u{201C}\(rootWord.uppercased())\u{201D}")
                        .foregroundColor(CyberColors.neonCyan)
                    Text("IN \(logic.targetLanguage.uppercased())?")
                        .foregroundColor(Color(white: 0.38))
                }
                if let kind = logic.formKind, !kind.isEmpty {
                    Text(kind.uppercased())
                        .foregroundColor(CyberColors.neonPink)
                        .font(.custom("Helvetica Neue", size: 9).weight(.bold))
                }
            }
        case .expandedAtBase(let base):
            // Show root word, ask for inflected form, then explain the grammar pattern below
            VStack(spacing: 3) {
                HStack(spacing: 4) {
                    Text(base.uppercased())
                        .foregroundColor(CyberColors.neonCyan)
                    Text("\u{2192}")
                        .foregroundColor(Color(white: 0.38))
                    Text("HOW DO YOU SAY")
                        .foregroundColor(Color(white: 0.38))
                    Text("\u{201C}\(logic.prompt.uppercased())\u{201D}")
                        .foregroundColor(CyberColors.neonCyan)
                    Text("?")
                        .foregroundColor(Color(white: 0.38))
                }
                if let patt = logic.pattern, !patt.isEmpty {
                    Text(patt)
                        .foregroundColor(CyberColors.neonYellow)
                        .font(.custom("Helvetica Neue", size: 10).weight(.medium))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        case .answered:
            HStack(spacing: 4) {
                Text("WHAT IS")
                    .foregroundColor(Color(white: 0.38))
                Text("\u{201C}\(logic.prompt.uppercased())\u{201D}")
                    .foregroundColor(CyberColors.neonCyan)
                Text("IN \(logic.targetLanguage.uppercased())?")
                    .foregroundColor(Color(white: 0.38))
            }
        }
    }

    private var stageIndex: Int {
        switch logic.stage {
        case .pickingBase:    return 0
        case .expandedAtBase: return 1
        case .answered:       return 2
        }
    }

    private var optionsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
            spacing: 8
        ) {
            ForEach(logic.options, id: \.self) { opt in optionButton(opt) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .id(stageIndex)  // force full grid rebuild when stage switches base→target
    }

    @ViewBuilder
    private func optionButton(_ opt: String) -> some View {
        let correct = logic.state.drillData.target
        let isSelectedTarget = logic.selectedTargetOption == opt
        let isWrongBase = logic.basePickedWrong == opt
        let isSelected = isSelectedTarget || isWrongBase

        let isRight: Bool = {
            if case .pickingBase = logic.stage { return opt == logic.correctBase }
            return opt.lowercased() == correct.lowercased()
        }()

        let bg: Color = {
            guard isSelected else { return Color.white.opacity(0.07) }
            if isWrongBase { return Color.red.opacity(0.75) }
            return isRight ? CyberColors.neonGreen : Color.red.opacity(0.75)
        }()

        Button {
            guard logic.isCorrect == nil && !logic.awaitingContinueAfterWrongBase else { return }
            logic.selectOption(opt)
            if logic.isLegacyMode { logic.checkAnswer() }
        } label: {
            Text(opt.lowercased())
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(bg)
        }
        .buttonStyle(.plain)
        .disabled(logic.isCorrect != nil || logic.awaitingContinueAfterWrongBase)
        .diagnosticBorder(Color.white.opacity(0.22))
    }
}

// MARK: - Typing Panel

struct GraphTypingPanel: View {
    @StateObject private var logic: BrickTypingLogic
    var onTargetRevealed: () -> Void
    var onAutoAdvance: () -> Void
    @FocusState private var focused: Bool

    init(drill: DrillState, engine: LessonEngine,
         onTargetRevealed: @escaping () -> Void,
         onAutoAdvance: @escaping () -> Void) {
        self._logic = StateObject(wrappedValue: BrickTypingLogic(state: drill, engine: engine))
        self.onTargetRevealed = onTargetRevealed
        self.onAutoAdvance = onAutoAdvance
    }

    var body: some View {
        VStack(spacing: 0) {
            questionLabel
                .diagnosticBorder(.cyan)

            HStack(spacing: 0) {
                TextField(
                    "",
                    text: Binding(get: { logic.userInput }, set: { logic.userInput = $0 }),
                    prompt: Text("type in \(logic.targetLanguage.lowercased())…")
                        .foregroundColor(Color.white.opacity(0.28))
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                )
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($focused)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .disabled(logic.isCorrect != nil)

                if !logic.userInput.isEmpty && logic.isCorrect == nil {
                    Button { logic.clearInput() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.white.opacity(0.35))
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 16)
                    .diagnosticBorder(.orange.opacity(0.35))
                }
            }
            .background(Color.white.opacity(0.06))
            .overlay(
                Rectangle().fill(logic.isCorrect == nil ? CyberColors.neonPink : (logic.isCorrect == true ? CyberColors.neonGreen : Color.red))
                    .frame(height: 2),
                alignment: .bottom
            )
            .diagnosticBorder(.green)

            if !logic.userInput.isEmpty && logic.isCorrect == nil {
                Button(action: { logic.checkAnswer() }) {
                    HStack(spacing: 8) {
                        Text("CHECK")
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .tracking(2)
                        Image(systemName: "checkmark").font(.system(size: 12, weight: .black))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CyberColors.neonCyan)
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .diagnosticBorder(.orange)
            }
        }
        .diagnosticBorder(.yellow)
        .onAppear { focused = true }
        .onChange(of: logic.isCorrect) { _, newVal in
            guard newVal != nil else { return }
            focused = false
            onTargetRevealed()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { onAutoAdvance() }
        }
    }

    private var questionLabel: some View {
        ZStack {
            Color.black
            HStack(spacing: 4) {
                Text("WHAT IS")
                    .foregroundColor(Color(white: 0.38))
                Text("\u{201C}\(logic.prompt.uppercased())\u{201D}")
                    .foregroundColor(CyberColors.neonCyan)
                Text("IN \(logic.targetLanguage.uppercased())?")
                    .foregroundColor(Color(white: 0.38))
            }
            .font(.custom("Helvetica Neue", size: 11).weight(.bold))
            .kerning(0.8)
            .lineLimit(2)
            .minimumScaleFactor(0.6)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 48, maxHeight: 72)
        .overlay(Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1), alignment: .top)
    }
}
