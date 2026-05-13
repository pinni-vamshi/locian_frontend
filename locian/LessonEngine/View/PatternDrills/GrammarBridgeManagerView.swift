//
//  GrammarBridgeManagerView.swift
//  locian
//
//  Bridge between vocab intro and pattern practice: up to two grammar steps.
//  Prefers discover `grammar_bricks` (pattern_json Q/A native); falls back to
//  legacy `grammar_rules` + sentence brick indices + catalog.
//

import SwiftUI

struct GrammarBridgeManagerView: View {
    let state: DrillState
    @ObservedObject var engine: LessonEngine

    @State private var slotFirst: String?
    @State private var slotSecond: String?
    @State private var poolChips: [PoolChip] = []

    private struct PoolChip: Identifiable {
        let id = UUID()
        let text: String
    }

    private var orchestrator: LessonOrchestrator? { engine.orchestrator }

    private var pattern: PatternData? {
        engine.allPatterns.first { $0.id == state.patternId }
    }

    private var stepIndex: Int { orchestrator?.grammarBridgeStep ?? 0 }

    private var stepCount: Int {
        guard let p = pattern else { return 0 }
        return LessonOrchestrator.grammarBridgeStepCount(for: p, engine: engine)
    }

    /// Preferred path: rich bricks from discover.
    private var richBricks: [PatternGrammarBrick] {
        guard let p = pattern else { return [] }
        return LessonOrchestrator.effectiveGrammarBricks(for: p)
    }

    /// Legacy path when there are no usable `grammar_bricks`.
    private var legacyRules: [PatternGrammarRule] {
        guard let p = pattern, richBricks.isEmpty else { return [] }
        return LessonOrchestrator.effectiveGrammarRules(for: p, engine: engine)
    }

    private var currentBrick: PatternGrammarBrick? {
        guard !richBricks.isEmpty, stepIndex < richBricks.count else { return nil }
        return richBricks[stepIndex]
    }

    private var currentLegacyRule: PatternGrammarRule? {
        guard richBricks.isEmpty, stepIndex < legacyRules.count else { return nil }
        return legacyRules[stepIndex]
    }

    private var currentWordPair: (q: String, a: String)? {
        if let b = currentBrick, let p = wordPair(for: b) { return p }
        if let r = currentLegacyRule, let p = wordPair(for: r) { return p }
        return nil
    }

    private var currentRuleId: String? {
        currentBrick?.rule_id ?? currentLegacyRule?.rule_id
    }

    private var catalog: [String: GrammarRuleCatalogEntry]? {
        engine.lessonData?.grammar_rule_catalog
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if stepCount == 0 {
                Color.clear
                    .frame(height: 1)
                    .onAppear { engine.orchestrator?.finishGrammarBridge() }
            } else if let pair = currentWordPair, let rid = currentRuleId {
                Text("\(stepIndex + 1) / \(stepCount)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(MockTokens.muted2)

                ruleCard(ruleId: rid, brick: currentBrick)

                Text("Tap the words to fill the slots in order: anchor → answer.")
                    .font(LearnHelvetica.font(size: 12, weight: .regular))
                    .foregroundColor(MockTokens.muted)

                slotsRow

                wordBank

                CyberProceedButton(
                    action: { engine.orchestrator?.advanceGrammarBridge() },
                    label: stepIndex + 1 < stepCount ? "NEXT_GRAMMAR" : "INTO_PRACTICE",
                    title: "CONTINUE",
                    color: CyberColors.success,
                    systemImage: "arrow.right",
                    isEnabled: isPlacementCorrect(pair: pair)
                )
                .padding(.top, 4)
            } else {
                Color.clear
                    .frame(height: 1)
                    .onAppear { engine.orchestrator?.finishGrammarBridge() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 12)
        .onAppear {
            if stepCount > 0, currentWordPair != nil {
                rebuildPool()
            }
        }
        .onChange(of: stepIndex) { _, _ in
            slotFirst = nil
            slotSecond = nil
            rebuildPool()
        }
    }

    // MARK: - Rule presentation

    @ViewBuilder
    private func ruleCard(ruleId: String, brick: PatternGrammarBrick? = nil) -> some View {
        let entry = catalog?[ruleId]
        let label = entry?.label?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let explain = entry?.explain?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let patternFallback = brick?.pattern?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let whyFallback = brick?.why?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        VStack(alignment: .leading, spacing: 8) {
            if !label.isEmpty {
                Text(label)
                    .font(.custom("Helvetica-Bold", size: 15))
                    .foregroundColor(MockTokens.fg)
            } else if !patternFallback.isEmpty {
                Text(patternFallback)
                    .font(.custom("Helvetica-Bold", size: 15))
                    .foregroundColor(MockTokens.fg)
            }
            if !explain.isEmpty {
                Text(explain)
                    .font(LearnHelvetica.font(size: 13, weight: .regular))
                    .foregroundColor(MockTokens.muted2)
            } else if !whyFallback.isEmpty {
                Text(whyFallback)
                    .font(LearnHelvetica.font(size: 13, weight: .regular))
                    .foregroundColor(MockTokens.muted2)
            }
            let hasLabel = !label.isEmpty || !patternFallback.isEmpty
            let hasExplain = !explain.isEmpty || !whyFallback.isEmpty
            if !hasLabel && !hasExplain {
                Text("Rule: \(ruleId)")
                    .font(LearnHelvetica.font(size: 12, weight: .regular))
                    .foregroundColor(MockTokens.muted)
            }
            if let c = entry?.contrast {
                HStack(alignment: .top, spacing: 12) {
                    if let n = c.native_form?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
                        Text(n)
                            .font(LearnHelvetica.font(size: 12, weight: .regular))
                            .foregroundColor(MockTokens.muted2)
                    }
                    if let t = c.target_form?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty {
                        Text(t)
                            .font(LearnHelvetica.font(size: 12, weight: .regular))
                            .foregroundColor(MockTokens.fg)
                    }
                }
            } else if let bc = brick?.pattern_json?.contrast {
                HStack(alignment: .top, spacing: 12) {
                    if let n = bc.native_linguistic?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
                        Text(n)
                            .font(LearnHelvetica.font(size: 12, weight: .regular))
                            .foregroundColor(MockTokens.muted2)
                    }
                    if let t = bc.target_linguistic?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty {
                        Text(t)
                            .font(LearnHelvetica.font(size: 12, weight: .regular))
                            .foregroundColor(MockTokens.fg)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Slots + bank

    private var slotsRow: some View {
        HStack(spacing: 10) {
            slotCell(title: "1", text: slotFirst) {
                releaseFirst()
            }
            slotCell(title: "2", text: slotSecond) {
                releaseSecond()
            }
        }
    }

    private func slotCell(title: String, text: String?, onTap: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(MockTokens.muted2)
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.28), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                if let text {
                    Text(text)
                        .font(LearnHelvetica.font(size: 14, weight: .semibold))
                        .foregroundColor(MockTokens.fg)
                        .multilineTextAlignment(.center)
                        .padding(8)
                } else {
                    Text("—")
                        .foregroundColor(MockTokens.muted)
                }
            }
            .frame(minHeight: 48)
            .frame(maxWidth: .infinity)
            .onTapGesture(perform: onTap)
        }
    }

    private var wordBank: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 76), spacing: 8, alignment: .center)],
            spacing: 8
        ) {
            ForEach(poolChips) { chip in
                Button {
                    pickFromPool(chip)
                } label: {
                    Text(chip.text)
                        .font(LearnHelvetica.font(size: 13, weight: .semibold))
                        .foregroundColor(MockTokens.fg)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Interaction

    private func pickFromPool(_ chip: PoolChip) {
        guard let idx = poolChips.firstIndex(where: { $0.id == chip.id }) else { return }
        if slotFirst == nil {
            slotFirst = poolChips.remove(at: idx).text
        } else if slotSecond == nil {
            slotSecond = poolChips.remove(at: idx).text
        }
    }

    private func releaseFirst() {
        guard let t = slotFirst else { return }
        slotFirst = nil
        poolChips.append(PoolChip(text: t))
    }

    private func releaseSecond() {
        guard let t = slotSecond else { return }
        slotSecond = nil
        poolChips.append(PoolChip(text: t))
    }

    private func rebuildPool() {
        guard let pair = currentWordPair else {
            poolChips = []
            return
        }
        var texts: [String] = [pair.q, pair.a]
        let ordered = engine.orderedSentenceBricks(for: state.patternId)
        var seen = Set(texts.map { norm($0) })
        for b in ordered {
            let t = Self.displayToken(b)
            guard !t.isEmpty else { continue }
            let k = norm(t)
            if seen.contains(k) { continue }
            seen.insert(k)
            texts.append(t)
            if texts.count >= 6 { break }
        }
        poolChips = texts.shuffled().map { PoolChip(text: $0) }
    }

    private func wordPair(for brick: PatternGrammarBrick) -> (q: String, a: String)? {
        let q = brick.pattern_json?.question?.native?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let a = brick.pattern_json?.reply?.native?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !q.isEmpty, !a.isEmpty else { return nil }
        return (q, a)
    }

    private func wordPair(for rule: PatternGrammarRule) -> (q: String, a: String)? {
        let ordered = engine.orderedSentenceBricks(for: state.patternId)
        guard rule.q_anchor_index >= 0, rule.q_anchor_index < ordered.count,
              rule.a_brick_index >= 0, rule.a_brick_index < ordered.count else { return nil }
        let q = Self.displayToken(ordered[rule.q_anchor_index])
        let a = Self.displayToken(ordered[rule.a_brick_index])
        guard !q.isEmpty, !a.isEmpty else { return nil }
        return (q, a)
    }

    private func isPlacementCorrect(pair: (q: String, a: String)) -> Bool {
        norm(slotFirst) == norm(pair.q) && norm(slotSecond) == norm(pair.a)
    }

    private func norm(_ s: String?) -> String {
        (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func displayToken(_ brick: BrickItem) -> String {
        let n = (brick.nativeBrick ?? brick.meaning).trimmingCharacters(in: .whitespacesAndNewlines)
        if !n.isEmpty { return n }
        return brick.word.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
