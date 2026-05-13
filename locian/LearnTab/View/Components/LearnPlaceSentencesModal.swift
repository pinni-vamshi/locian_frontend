import SwiftUI

struct LearnPlaceSentencesModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let recommendation: PlaceRecommendation
    let initialSentenceIndex: Int

    @State private var selectedSentenceIndex: Int = 0
    @State private var graphMode: SentenceGraphMode = .userReply

    private enum SentenceGraphMode: String, CaseIterable, Identifiable {
        case userReply = "USER"
        case locianQuestion = "LOCIAN"
        var id: String { rawValue }
    }

    private var patterns: [RecommendationPattern] {
        recommendation.patterns ?? []
    }

    private var currentPattern: RecommendationPattern? {
        guard selectedSentenceIndex >= 0, selectedSentenceIndex < patterns.count else { return nil }
        return patterns[selectedSentenceIndex]
    }

    private var currentSentenceText: String {
        switch graphMode {
        case .userReply:
            return currentPattern?.target_pattern ?? ""
        case .locianQuestion:
            return currentPattern?.locian_question ?? ""
        }
    }

    private var currentBricks: [RecommendationBrickItem] {
        switch graphMode {
        case .userReply:
            guard let bricks = currentPattern?.bricks else { return [] }
            return (bricks.constants ?? []) + (bricks.variables ?? []) + (bricks.structural ?? [])
        case .locianQuestion:
            return currentPattern?.locian_question_bricks ?? []
        }
    }

    private var orderedSentenceBricks: [RecommendationBrickItem] {
        let sentence = currentSentenceText
        guard !sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return currentBricks }
        let orderedIndices = orderedBrickIndices(in: sentence, bricks: currentBricks)
        guard !orderedIndices.isEmpty else { return currentBricks }
        return orderedIndices.compactMap { idx in
            guard idx >= 0, idx < currentBricks.count else { return nil }
            return currentBricks[idx]
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    sentenceRail
                    graphModeControl
                    sentenceGraphArea
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 20))
                .padding(.top, learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 20))
                .padding(.bottom, learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(recommendation.place_id.uppercased())
                        .font(learnFont(size: 13, weight: .black, hSizeClass: horizontalSizeClass))
                        .foregroundColor(ThemeColors.secondaryAccent)
                        .lineLimit(1)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(learnFont(size: 14, weight: .bold, hSizeClass: horizontalSizeClass))
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.black)
        .onAppear {
            if patterns.isEmpty {
                selectedSentenceIndex = 0
            } else {
                selectedSentenceIndex = max(0, min(initialSentenceIndex, patterns.count - 1))
            }
        }
    }

    private var sentenceRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(patterns.enumerated()), id: \.offset) { index, pattern in
                    let selected = index == selectedSentenceIndex
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSentenceIndex = index
                        }
                    } label: {
                        Text(sentenceTitle(for: pattern))
                            .font(learnFont(size: 13, weight: .semibold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(selected ? .black : .white)
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selected ? Color.white : Color.white.opacity(0.1))
                            .overlay(
                                Rectangle()
                                    .stroke(selected ? Color.clear : Color.white.opacity(0.25), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var sentenceGraphArea: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                if currentPattern != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentSentenceText)
                            .font(learnFont(size: 19, weight: .bold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if currentSentenceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(graphMode == .userReply
                             ? "No user-reply sentence for this item yet."
                             : "No Locian question sentence for this item yet.")
                            .font(learnFont(size: 13, weight: .medium, hSizeClass: horizontalSizeClass))
                            .foregroundColor(Color.white.opacity(0.5))
                    } else if orderedSentenceBricks.isEmpty {
                        Text("No word graph data for this sentence yet.")
                            .font(learnFont(size: 13, weight: .medium, hSizeClass: horizontalSizeClass))
                            .foregroundColor(Color.white.opacity(0.5))
                    } else {
                        connectedSentenceGraph
                            .padding(.top, learnScaled(26, hSizeClass: horizontalSizeClass, min: 22, max: 34))
                    }
                } else {
                    Text("No sentence selected.")
                        .font(learnFont(size: 13, weight: .medium, hSizeClass: horizontalSizeClass))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 14)
        }
    }

    private var graphModeControl: some View {
        HStack(spacing: 8) {
            ForEach(SentenceGraphMode.allCases) { mode in
                let selected = graphMode == mode
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.18)) {
                        graphMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(learnFont(size: 11, weight: .bold, hSizeClass: horizontalSizeClass))
                        .foregroundColor(selected ? .black : .white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selected ? Color.white : Color.white.opacity(0.08))
                        .overlay(
                            Rectangle()
                                .stroke(selected ? Color.clear : Color.white.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func sentenceTitle(for pattern: RecommendationPattern) -> String {
        let text = (pattern.target_pattern ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return "Sentence" }
        return text
    }

    private var connectedSentenceGraph: some View {
        let sharedRegionHeight = sentenceExplanationRegionHeight
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(orderedSentenceBricks.enumerated()), id: \.offset) { index, brick in
                    unifiedSentenceNode(brick: brick, index: index, sharedRegionHeight: sharedRegionHeight)
                    if index < orderedSentenceBricks.count - 1 {
                        sentenceConnector
                    }
                }
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 0)
        }
    }

    @ViewBuilder
    private func unifiedSentenceNode(brick: RecommendationBrickItem, index: Int, sharedRegionHeight: CGFloat) -> some View {
        let chain = stageChain(for: brick)
        VStack(spacing: 0) {
            topExplanationRegion(chain: chain, appearsAbove: index.isMultiple(of: 2))
                .frame(height: sharedRegionHeight, alignment: .bottom)

            stageNode(text: chain.stages.last ?? "?", isTarget: true)

            bottomExplanationRegion(chain: chain, appearsAbove: index.isMultiple(of: 2))
                .frame(height: sharedRegionHeight, alignment: .top)
        }
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, 0)
        .padding(.vertical, 0)
    }

    private var sentenceConnector: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(ThemeColors.secondaryAccent)
                .frame(width: learnScaled(6, hSizeClass: horizontalSizeClass, min: 6, max: 10), height: 2)
            Image(systemName: "arrow.right")
                .font(.system(size: learnScaled(11, hSizeClass: horizontalSizeClass, min: 11, max: 14), weight: .bold))
                .foregroundColor(ThemeColors.secondaryAccent)
            Rectangle()
                .fill(ThemeColors.secondaryAccent)
                .frame(width: learnScaled(1, hSizeClass: horizontalSizeClass, min: 1, max: 2), height: 2)
        }
        .padding(.horizontal, 0)
    }

    private var verticalConnector: some View {
        Rectangle()
            .fill(Color.white.opacity(0.8))
            .frame(width: 1.5, height: learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
    }

    private func stageNode(text: String, isTarget: Bool) -> some View {
        Text(text.lowercased())
            .font(learnFont(
                size: isTarget ? 17 : 15,
                weight: isTarget ? .black : .semibold,
                hSizeClass: horizontalSizeClass
            ))
            .foregroundColor(isTarget ? ThemeColors.secondaryAccent : .white)
            .lineLimit(1)
            .padding(.horizontal, isTarget ? 10 : 8)
            .padding(.vertical, isTarget ? 7 : 6)
            .background(Color.white.opacity(0.08))
            .fixedSize()
    }

    private func transitionMeaningRow(text: String) -> some View {
        Text(text.uppercased())
            .font(learnFont(size: 9, weight: .bold, hSizeClass: horizontalSizeClass))
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.white)
    }

    @ViewBuilder
    private func topExplanationRegion(chain: StageChain, appearsAbove: Bool) -> some View {
        if appearsAbove {
            explanationStack(chain: chain, appearsAbove: true)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func bottomExplanationRegion(chain: StageChain, appearsAbove: Bool) -> some View {
        if appearsAbove {
            Color.clear
        } else {
            explanationStack(chain: chain, appearsAbove: false)
        }
    }

    @ViewBuilder
    private func explanationStack(chain: StageChain, appearsAbove: Bool) -> some View {
        let detailStages = Array(chain.stages.dropLast())
        let finalTransition = chain.transitions.last
        let middleTransitions = chain.transitions.count > 1 ? Array(chain.transitions.dropLast()) : []

        if detailStages.isEmpty, let finalTransition {
            VStack(spacing: 0) {
                verticalConnector
                transitionMeaningRow(text: finalTransition)
                verticalConnector
            }
        } else if appearsAbove {
            VStack(spacing: 0) {
                ForEach(Array(detailStages.enumerated()), id: \.offset) { idx, stage in
                    stageNode(text: stage, isTarget: false)
                    if idx < middleTransitions.count {
                        verticalConnector
                        transitionMeaningRow(text: middleTransitions[idx])
                        verticalConnector
                    }
                }
                if let finalTransition {
                    verticalConnector
                    transitionMeaningRow(text: finalTransition)
                    verticalConnector
                }
            }
        } else {
            let reversedStages = Array(detailStages.reversed())
            let reversedMiddle = Array(middleTransitions.reversed())
            VStack(spacing: 0) {
                if let finalTransition {
                    transitionMeaningRow(text: finalTransition)
                    verticalConnector
                }
                ForEach(Array(reversedStages.enumerated()), id: \.offset) { idx, stage in
                    stageNode(text: stage, isTarget: false)
                    if idx < reversedMiddle.count {
                        verticalConnector
                        transitionMeaningRow(text: reversedMiddle[idx])
                        verticalConnector
                    }
                }
            }
        }
    }

    private var sentenceExplanationRegionHeight: CGFloat {
        let values = orderedSentenceBricks.map { explanationRegionHeight(for: stageChain(for: $0)) }
        return values.max() ?? 0
    }

    private func explanationRegionHeight(for chain: StageChain) -> CGFloat {
        let detailCount = max(0, chain.stages.count - 1)
        guard detailCount > 0 else { return 0 }

        // Approximate enough vertical room for stacked stages/labels/connectors.
        // Symmetric top/bottom regions keep target nodes on one exact baseline.
        let stageH = learnScaled(30, hSizeClass: horizontalSizeClass, min: 28, max: 34)
        let labelH = learnScaled(20, hSizeClass: horizontalSizeClass, min: 18, max: 24)
        let connectorH = learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16)
        let transitionCount = max(1, chain.transitions.count)

        let computed = CGFloat(detailCount) * stageH
            + CGFloat(transitionCount) * (labelH + connectorH)
            + connectorH

        return min(max(computed, learnScaled(84, hSizeClass: horizontalSizeClass, min: 80, max: 100)),
                   learnScaled(220, hSizeClass: horizontalSizeClass, min: 200, max: 250))
    }

    private struct StageChain {
        let stages: [String]
        let transitions: [String]
    }

    private func stageChain(for brick: RecommendationBrickItem) -> StageChain {
        if let pj = brick.patternJson {
            var stages: [String] = []
            var transitions: [String] = []
            let base = pj.base?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let target = pj.target?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !base.isEmpty {
                stages.append(base)
            } else if !target.isEmpty {
                stages.append(target)
            }

            if let ops = pj.ops, !ops.isEmpty {
                for op in ops {
                    let label = op.label.trimmingCharacters(in: .whitespacesAndNewlines)
                    transitions.append(label.isEmpty ? "change" : label)
                    let result = (op.result ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !result.isEmpty {
                        stages.append(result)
                    } else if !target.isEmpty {
                        stages.append(target)
                    }
                }
            }

            if !target.isEmpty {
                if stages.isEmpty {
                    stages.append(target)
                } else if stages.last?.lowercased() != target.lowercased() {
                    stages.append(target)
                }
            }

            if transitions.isEmpty, stages.count >= 2 {
                transitions = Array(repeating: "change", count: stages.count - 1)
            }

            if stages.isEmpty {
                let fallback = (brick.targetBrick ?? brick.word).trimmingCharacters(in: .whitespacesAndNewlines)
                return StageChain(stages: [fallback.isEmpty ? "?" : fallback], transitions: [])
            }

            var alignedTransitions = transitions
            if alignedTransitions.count > max(0, stages.count - 1) {
                alignedTransitions = Array(alignedTransitions.prefix(stages.count - 1))
            } else if alignedTransitions.count < max(0, stages.count - 1) {
                alignedTransitions += Array(repeating: "change", count: (stages.count - 1) - alignedTransitions.count)
            }
            return StageChain(stages: stages, transitions: alignedTransitions)
        }

        let fallback = (brick.targetBrick ?? brick.word).trimmingCharacters(in: .whitespacesAndNewlines)
        return StageChain(stages: [fallback.isEmpty ? "?" : fallback], transitions: [])
    }

    private func orderedBrickIndices(in sentence: String, bricks: [RecommendationBrickItem]) -> [Int] {
        guard !sentence.isEmpty, !bricks.isEmpty else { return [] }

        let normalizedTokens = sentence
            .split(separator: " ", omittingEmptySubsequences: true)
            .map { normalizedWord(String($0)) }
            .filter { !$0.isEmpty }
        guard !normalizedTokens.isEmpty else { return [] }

        var tokenToBrick: [Int: Int] = [:]
        let indexedBricks = Array(bricks.enumerated()).sorted { lhs, rhs in
            let leftCount = candidatePhrases(for: lhs.element).first?.split(separator: " ").count ?? 1
            let rightCount = candidatePhrases(for: rhs.element).first?.split(separator: " ").count ?? 1
            return leftCount > rightCount
        }

        for (brickIndex, brick) in indexedBricks {
            let phrases = candidatePhrases(for: brick)
            for phrase in phrases {
                let phraseTokens = phrase
                    .split(separator: " ", omittingEmptySubsequences: true)
                    .map { normalizedWord(String($0)) }
                    .filter { !$0.isEmpty }
                guard !phraseTokens.isEmpty, phraseTokens.count <= normalizedTokens.count else { continue }

                let lastStart = normalizedTokens.count - phraseTokens.count
                for start in 0...lastStart {
                    let end = start + phraseTokens.count
                    if Array(normalizedTokens[start..<end]) != phraseTokens { continue }
                    let hasConflict = (start..<end).contains { tokenToBrick[$0] != nil }
                    if hasConflict { continue }
                    for tokenIndex in start..<end {
                        tokenToBrick[tokenIndex] = brickIndex
                    }
                    break
                }
            }
        }

        var ordered: [Int] = []
        var seen = Set<Int>()
        for tokenIndex in normalizedTokens.indices {
            guard let brickIndex = tokenToBrick[tokenIndex], !seen.contains(brickIndex) else { continue }
            ordered.append(brickIndex)
            seen.insert(brickIndex)
        }

        for idx in bricks.indices where !seen.contains(idx) {
            ordered.append(idx)
        }
        return ordered
    }

    private func candidatePhrases(for brick: RecommendationBrickItem) -> [String] {
        [brick.targetBrick, brick.word]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func normalizedWord(_ token: String) -> String {
        token
            .lowercased()
            .replacingOccurrences(of: #"^[^\p{L}\p{N}]+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+$"#, with: "", options: .regularExpression)
    }
}
