//
//  TransformationGraphView.swift
//  locian
//
//  Word boxes sit on a horizontal flow line. Between each pair of boxes a
//  connector carries:
//    • a fixed-width horizontal arrow (gap is always the same)
//    • a perpendicular stem + op-chip that alternates ABOVE (even ops) and
//      BELOW (odd ops) the flow line, extending outside the word-box height
//
//  The connector VStack is symmetric around the arrow — equal clear space
//  on the opposite side — so HStack(alignment:.center) keeps the arrow
//  exactly at word-box mid-height.
//
//  `from` / `to` letters render black-on-white chips on the word surface.
//  `why_json` trail is a breadcrumb below the diagram.

import SwiftUI

struct TransformationGraphView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let brick: RecommendationBrickItem

    /// Visible width of the horizontal scroll view — used so short graphs center
    /// (ScrollView proposes infinite width to its child, which otherwise left-aligns).
    @State private var scrollViewportWidth: CGFloat = 0

    private var arrowLineWidth: CGFloat { learnScaled(64, hSizeClass: horizontalSizeClass, min: 60, max: 82) }
    private var stemLen: CGFloat { learnScaled(62, hSizeClass: horizontalSizeClass, min: 56, max: 78) }
    private var chipEst: CGFloat { learnScaled(30, hSizeClass: horizontalSizeClass, min: 28, max: 38) }

    /// Word-stage tiles: max height keeps rows compact; bump when you need more room for three lines.
    private var wordStageBoxMaxHeight: CGFloat { learnScaled(66, hSizeClass: horizontalSizeClass, min: 60, max: 72) }

    var body: some View {
        if let pj = brick.patternJson, let stages = stages(from: pj), !stages.isEmpty {
            VStack(alignment: .center, spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer(minLength: 0)
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(Array(stages.enumerated()), id: \.offset) { idx, stage in
                                stageNode(stage)
                                if idx < stages.count - 1 {
                                    connector(opIndex: idx, ops: pj.ops ?? [])
                                }
                            }
                        }
                        .padding(.horizontal, learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12))
                        .padding(.vertical, learnScaled(4, hSizeClass: horizontalSizeClass, min: 3, max: 8))
                        Spacer(minLength: 0)
                    }
                    .frame(minWidth: max(scrollViewportWidth, 1))
                }
                .frame(maxWidth: .infinity)
                .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { newWidth in
                    scrollViewportWidth = newWidth
                }
            }
            .padding(.vertical, learnScaled(18, hSizeClass: horizontalSizeClass, min: 14, max: 26))
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
            EmptyView()
        }
    }

    // MARK: - Stage model

    private struct Stage {
        let surface: String
        let isAnchor: Bool
        let role: String
        let nativeWord: String?
    }

    private func stages(from pj: PatternJson) -> [Stage]? {
        let base   = pj.base?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let target = pj.target?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !base.isEmpty || !target.isEmpty else { return nil }

        let baseNative   = brick.baseNative?.trimmingCharacters(in: .whitespacesAndNewlines)
        let targetNative = brick.meaning.trimmingCharacters(in: .whitespacesAndNewlines)

        var out: [Stage] = []
        out.append(Stage(
            surface: base.isEmpty ? target : base,
            isAnchor: true,
            role: "BASE",
            nativeWord: (baseNative?.isEmpty == false) ? baseNative : nil
        ))

        if let ops = pj.ops, !ops.isEmpty {
            for (i, op) in ops.enumerated() {
                let s = (op.result ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let isLast = i == ops.count - 1
                out.append(Stage(
                    surface: s.isEmpty ? target : s,
                    isAnchor: isLast,
                    role: isLast ? "TARGET" : "",
                    nativeWord: isLast && !targetNative.isEmpty ? targetNative : nil
                ))
            }
        } else if !target.isEmpty, target != base {
            out.append(Stage(
                surface: target,
                isAnchor: true,
                role: "TARGET",
                nativeWord: !targetNative.isEmpty ? targetNative : nil
            ))
        }
        return out
    }

    // MARK: - Word box

    @ViewBuilder
    private func stageNode(_ stage: Stage) -> some View {
        let highlights = highlightsFor(stage)

        VStack(alignment: .center, spacing: 2) {
            // Role label (invisible placeholder keeps height consistent for intermediate nodes)
            Text(stage.role.isEmpty ? " " : stage.role)
                .font(.system(size: learnScaled(8, hSizeClass: horizontalSizeClass, min: 7, max: 9), weight: .black, design: .monospaced))
                .kerning(1.0)
                .foregroundColor(stage.role == "BASE"
                                 ? Color(white: 0.55)
                                 : ThemeColors.secondaryAccent)
                .opacity(stage.role.isEmpty ? 0 : 1)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            attributedSurface(stage.surface, highlights: highlights)
                .font(.system(size: learnScaled(18, hSizeClass: horizontalSizeClass, min: 16, max: 21), weight: stage.isAnchor ? .bold : .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: true, vertical: false)

            // Native: larger on first (BASE) and last (TARGET) anchor boxes only.
            if let native = stage.nativeWord {
                Text(native)
                    .font(.system(size: learnScaled(12, hSizeClass: horizontalSizeClass, min: 11, max: 14), weight: .medium))
                    .foregroundColor(Color(white: 0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: true, vertical: false)
            } else {
                // Same line metrics as anchor natives so column heights stay aligned.
                Text(" ")
                    .font(.system(size: learnScaled(12, hSizeClass: horizontalSizeClass, min: 11, max: 14), weight: .medium))
                    .opacity(0)
            }
        }
        .padding(.horizontal, learnScaled(14, hSizeClass: horizontalSizeClass, min: 12, max: 18))
        .padding(.vertical, learnScaled(4, hSizeClass: horizontalSizeClass, min: 3, max: 6))
        .frame(maxHeight: wordStageBoxMaxHeight)
        .background(Rectangle().fill(
            Color.white.opacity(0.08)
        ))
        .contentShape(Rectangle())
    }

    // MARK: - Connector

    // Layout for even ops (TOP):
    //
    //   ┌──────────┐   ← chip       ┐
    //   │          │                │ extends outside box top
    //   └──────────┘                │
    //        │         ← stem       ┘
    //   ──────────→    ← arrow      ← at word-box mid-height
    //   (clear mirror height)       ← balances the VStack center
    //
    // Layout for odd ops (BOTTOM): mirrored vertically.
    //
    // The mirror spacer (same height as chip+stem) is placed on the
    // opposite side of the arrow, making the VStack symmetric so
    // HStack(alignment:.center) lands the arrow at box mid-height.

    @ViewBuilder
    private func connector(opIndex: Int, ops: [PatternOp]) -> some View {
        let op         = opIndex < ops.count ? ops[opIndex] : nil
        let onTop      = opIndex % 2 == 0

        VStack(alignment: .center, spacing: 0) {

            if onTop {
                // ── chip + stem above the arrow ──────────────────────────
                opChipView(op)
                stemView()
            } else {
                // ── mirror spacer (balances the bottom chip+stem) ────────
                Color.clear.frame(height: chipEst + stemLen)
            }

            // ── fixed-width horizontal arrow ─────────────────────────────
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: arrowLineWidth, height: 2)
                Image(systemName: "chevron.right")
                    .font(.system(size: learnScaled(12, hSizeClass: horizontalSizeClass, min: 11, max: 15), weight: .heavy))
                    .foregroundColor(.white)
            }

            if onTop {
                // ── mirror spacer ────────────────────────────────────────
                Color.clear.frame(height: stemLen + chipEst)
            } else {
                // ── stem + chip below the arrow ──────────────────────────
                stemView()
                opChipView(op)
            }
        }
        .frame(width: arrowLineWidth + learnScaled(24, hSizeClass: horizontalSizeClass, min: 22, max: 30))
    }

    @ViewBuilder
    private func opChipView(_ op: PatternOp?) -> some View {
        if let op {
            Text(op.label)
                .font(.system(size: learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 13), weight: .black, design: .monospaced))
                .kerning(1.0)
                .foregroundColor(.black)
                .padding(.horizontal, learnScaled(8, hSizeClass: horizontalSizeClass, min: 7, max: 10))
                .padding(.vertical, learnScaled(4, hSizeClass: horizontalSizeClass, min: 3, max: 6))
                .background(Rectangle().fill(
                    Color.white
                ))
            .fixedSize()
        } else {
            Color.clear.frame(height: chipEst)
        }
    }

    @ViewBuilder
    private func stemView() -> some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 2, height: stemLen)
    }

    // MARK: - Letter highlight helpers

    private func highlightsFor(_ stage: Stage) -> [String] {
        guard let pj = brick.patternJson,
              let ops = pj.ops,
              let graphStages = stages(from: pj) else { return [] }

        var out: [String] = []
        for (opIdx, op) in ops.enumerated() {
            guard opIdx + 1 < graphStages.count else { continue }
            if graphStages[opIdx].surface == stage.surface, let from = op.from, !from.isEmpty {
                out.append(from)
            }
            if graphStages[opIdx + 1].surface == stage.surface, let to = op.to, !to.isEmpty {
                out.append(to)
            }
        }
        return Array(Set(out))
    }

    private func attributedSurface(_ surface: String, highlights: [String]) -> some View {
        let mutable = NSMutableAttributedString(string: surface)
        let fullRange = NSRange(location: 0, length: (surface as NSString).length)
        mutable.addAttribute(.foregroundColor, value: UIColor.white, range: fullRange)

        for segment in highlights where !segment.isEmpty {
            let r = (surface as NSString).range(of: segment, options: .caseInsensitive)
            if r.location != NSNotFound {
                mutable.addAttribute(.foregroundColor, value: UIColor.black, range: r)
                mutable.addAttribute(.backgroundColor, value: UIColor.white.withAlphaComponent(0.6), range: r)
            }
        }
        return Text(AttributedString(mutable))
    }

}
