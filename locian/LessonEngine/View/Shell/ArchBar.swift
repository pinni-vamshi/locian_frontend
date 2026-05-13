//
//  ArchBar.swift
//  locian
//
//  Top architecture bar — matches the HTML lesson-engine mock:
//    Row 1:  "* TOPIC · PARTNER"               PHASE 1 · SCRIPTED
//    Row 2:  ▭ ▭ ▭ ▭ ▭ ▭ ▭ ▭ ▭ ▭   ⎯ GATE ⎯   ∞
//

import SwiftUI

struct ArchBar: View {
    @ObservedObject var engine: LessonEngine
    let topic: String?
    let partner: String?
    var onBack: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            row1
                .diagnosticBorder(.yellow)
            chainRow
                .diagnosticBorder(.yellow)
        }
        .padding(.horizontal, 6)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                .diagnosticBorder(.purple)
        }
        .diagnosticBorder(.red)
    }

    // MARK: - Row 1: place + phase

    private var row1: some View {
        HStack(alignment: .center, spacing: 0) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(MockTokens.fg)
                        .frame(width: 38, height: 32)
                        .contentShape(Rectangle())
                        .diagnosticBorder(.blue)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 6)
                .diagnosticBorder(.cyan)
            }

            HStack(spacing: 6) {
                Text("*")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(MockTokens.pink)
                    .diagnosticBorder(.blue)
                Text(headline)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(1.6)
                    .foregroundColor(MockTokens.fg)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .diagnosticBorder(.blue)
            }
            .diagnosticBorder(.green)

            Spacer(minLength: 8)

            masteryPanel
                .diagnosticBorder(.green)
        }
    }

    // MARK: - Mastery Panel (replaces PHASE 1 · SCRIPTED)

    @ViewBuilder
    private var masteryPanel: some View {
        if let patternId = engine.orchestrator?.activeState?.patternId {
            let sentMastery = engine.getBlendedMastery(for: patternId)
            let brickIds: [String] = {
                // During intro: use the ordered teach list.
                // During practice: fall back to the precomputed pattern map.
                if !engine.lastIntroBrickIDs.isEmpty { return engine.lastIntroBrickIDs }
                return engine.patternBrickMap[patternId] ?? []
            }()
            let activeBrickId = engine.currentIntroBrickID

            HStack(spacing: 8) {
                // ── Sentence mastery ──
                VStack(alignment: .trailing, spacing: 1) {
                    Text("SEN")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(MockTokens.muted)
                        .tracking(1.2)
                    Text(String(format: "%.0f%%", sentMastery * 100))
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(masteryColor(sentMastery))
                }

                if !brickIds.isEmpty {
                    Rectangle()
                        .fill(MockTokens.g2)
                        .frame(width: 1, height: 24)

                    // ── Per-brick bars ──
                    HStack(alignment: .bottom, spacing: 3) {
                        ForEach(brickIds, id: \.self) { brickId in
                            let m = engine.getDecayedMastery(for: brickId)
                            let isActive = brickId == activeBrickId
                            VStack(spacing: 2) {
                                Text(String(format: "%.0f", m * 100))
                                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                                    .foregroundColor(isActive ? MockTokens.pink : masteryColor(m).opacity(0.8))
                                    .lineLimit(1)
                                Rectangle()
                                    .fill(isActive ? MockTokens.pink : masteryColor(m))
                                    .frame(width: 5, height: isActive ? 18 : 12)
                                    .shadow(color: isActive ? MockTokens.pink.opacity(0.9) : .clear, radius: 4)
                            }
                        }
                    }
                }
            }
            .padding(.trailing, 4)
        }
    }

    private func masteryColor(_ m: Double) -> Color {
        if m < 0.30 { return .red }
        if m < 0.60 { return .orange }
        if m < 0.85 { return MockTokens.green }
        return MockTokens.fg
    }

    private var headline: String {
        let topicText = (topic ?? "").uppercased()
        let partnerText = (partner ?? "").uppercased()
        if topicText.isEmpty && partnerText.isEmpty { return "CONVERSATION" }
        if topicText.isEmpty { return partnerText }
        if partnerText.isEmpty { return topicText }
        return "\(topicText) · \(partnerText)"
    }

    // MARK: - Row 2: dot/bar chain + gate + ∞

    private var chainRow: some View {
        let patterns = engine.allPatterns
        let activeIndex = patterns.firstIndex(where: { $0.id == engine.orchestrator?.activeState?.patternId })

        return HStack(alignment: .center, spacing: 5) {
            ForEach(Array(patterns.enumerated()), id: \.element.id) { idx, _ in
                bar(state: barState(for: idx, active: activeIndex))
                    .diagnosticBorder(.blue)
            }

            Text("⎯ GATE ⎯")
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .tracking(1.2)
                .foregroundColor(MockTokens.muted)
                .padding(.horizontal, 4)
                .diagnosticBorder(.blue)

            Text("∞")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundColor(MockTokens.muted)
                .diagnosticBorder(.blue)
        }
        .frame(height: 10)
        .diagnosticBorder(.green)
    }

    private enum BarState { case done, now, upcoming }

    private func barState(for index: Int, active: Int?) -> BarState {
        guard let active else { return .upcoming }
        if index < active { return .done }
        if index == active { return .now }
        return .upcoming
    }

    @ViewBuilder
    private func bar(state: BarState) -> some View {
        let color: Color = {
            switch state {
            case .done:     return MockTokens.fg
            case .now:      return MockTokens.pink
            case .upcoming: return MockTokens.g3
            }
        }()
        Rectangle()
            .fill(color)
            .frame(height: 3)
            .frame(maxWidth: .infinity)
            .shadow(color: state == .now ? MockTokens.pink.opacity(0.7) : .clear, radius: 4)
    }
}
