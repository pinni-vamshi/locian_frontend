import SwiftUI

/// Horizontal full-sentence graph for inline Learn tab: user reply or Locian question, depending on `line`.
struct LearnInlineSentenceGraphStrip: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    enum Line {
        case userReply
        case locianQuestion
    }

    let pattern: RecommendationPattern?
    let line: Line

    private var sentence: String {
        switch line {
        case .userReply:
            return pattern?.target_pattern ?? ""
        case .locianQuestion:
            return pattern?.locian_question ?? ""
        }
    }

    private var bricks: [RecommendationBrickItem] {
        guard let p = pattern else { return [] }
        switch line {
        case .userReply:
            guard let b = p.bricks else { return [] }
            return (b.constants ?? []) + (b.variables ?? []) + (b.structural ?? [])
        case .locianQuestion:
            return p.locian_question_bricks ?? []
        }
    }

    private var orderedSentenceBricks: [RecommendationBrickItem] {
        let s = sentence
        guard !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return bricks }
        let orderedIndices = orderedBrickIndices(in: s, bricks: bricks)
        guard !orderedIndices.isEmpty else { return bricks }
        return orderedIndices.compactMap { idx in
            guard idx >= 0, idx < bricks.count else { return nil }
            return bricks[idx]
        }
    }

    var body: some View {
        Group {
            if pattern == nil {
                emptyLabel("No sentence selected.")
            } else if sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                emptyLabel(line == .userReply
                           ? "No user-reply sentence for this item yet."
                           : "No Locian question sentence for this item yet.")
            } else if orderedSentenceBricks.isEmpty {
                emptyLabel("No word graph data for this sentence yet.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    sentenceGraphRow
                        .padding(.horizontal, learnScaled(10, hSizeClass: horizontalSizeClass, min: 8, max: 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }

    private func emptyLabel(_ text: String) -> some View {
        Text(text)
            .font(learnFont(size: 13, weight: .medium, hSizeClass: horizontalSizeClass))
            .foregroundColor(Color.white.opacity(0.5))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var sentenceGraphRow: some View {
        let sharedRegionHeight = sentenceExplanationRegionHeight
        return HStack(alignment: .center, spacing: learnScaled(8, hSizeClass: horizontalSizeClass, min: 6, max: 12)) {
            ForEach(Array(orderedSentenceBricks.enumerated()), id: \.offset) { index, brick in
                unifiedSentenceNode(brick: brick, index: index, sharedRegionHeight: sharedRegionHeight)
                if index < orderedSentenceBricks.count - 1 {
                    sentenceConnector
                }
            }
        }
        .padding(.vertical, learnScaled(4, hSizeClass: horizontalSizeClass, min: 2, max: 8))
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
