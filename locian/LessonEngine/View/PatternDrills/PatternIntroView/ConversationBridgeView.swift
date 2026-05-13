//
//  ConversationBridgeView.swift
//  locian
//
//  Replaces PatternIntroAnimationView for the vocabIntro stage.
//
//  Layout:
//    • Starts from the anchor brick (highest importance / anchor:true).
//    • Expands LEFT then RIGHT one node at a time using the brick's
//      expansionBefore / expansionAfter fields from the demo data.
//    • Each expansion: rule label animates in first (0.4s), then the
//      node slides in from the correct direction (0.5s spring).
//    • Nodes stay visible (dim) after being introduced — the full
//      bridge is always visible as context.
//    • When all nodes are shown, waits briefly then calls onComplete.
//
//  Node states:
//    .pending   — not yet revealed (invisible)
//    .revealing — currently animating in
//    .taught    — fully visible, dim (already introduced)
//    .active    — fully visible, lit (currently being drilled — used
//                 in compact mode, not during animation phase)
//

import SwiftUI

// MARK: - Node state

private enum BridgeNodeState {
    case pending, revealing, taught
}

// MARK: - Bridge node model

private struct BridgeNode: Identifiable {
    let id: String
    let brick: BrickItem
    var state: BridgeNodeState = .pending
    /// Position in the final left→right sentence order.
    let sentenceIndex: Int
}

// MARK: - View

struct ConversationBridgeView: View {
    let bricks: [BrickItem]          // parallel to brickDrills, in sentence order
    let anchorIndex: Int             // index into bricks of the anchor node
    let onComplete: () -> Void

    @State private var nodes: [BridgeNode] = []
    @State private var revealQueue: [Int] = []    // sentence-order indices to reveal next
    @State private var activeRuleLabel: String? = nil
    @State private var ruleLabelVisible: Bool = false
    @State private var isFinishing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Rule label — flashes before each node expansion
            ruleLabelBanner
                .padding(.bottom, 16)

            // Horizontal bridge scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(nodes.filter { $0.state != .pending }) { node in
                        nodeView(node)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: expansionEdge(for: node))
                                        .combined(with: .opacity),
                                    removal: .opacity
                                )
                            )

                        if node.sentenceIndex < nodes.filter({ $0.state != .pending }).count - 1 {
                            connectorArrow
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .animation(.spring(response: 0.5, dampingFraction: 0.75), value: nodes.map { $0.state == .pending })
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
        .opacity(isFinishing ? 0 : 1)
        .animation(.easeOut(duration: 0.6), value: isFinishing)
        .onAppear(perform: setup)
    }

    // MARK: - Rule label banner

    private var ruleLabelBanner: some View {
        ZStack(alignment: .leading) {
            Color.clear.frame(height: 28)
            if let label = activeRuleLabel {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .kerning(1.4)
                    .foregroundColor(CyberColors.neonCyan)
                    .opacity(ruleLabelVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: ruleLabelVisible)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Node view

    @ViewBuilder
    private func nodeView(_ node: BridgeNode) -> some View {
        let isRevealing = node.state == .revealing

        VStack(alignment: .center, spacing: 6) {
            // Role badge
            if let kind = node.brick.baseKind, !kind.isEmpty {
                Text(roleLabel(kind))
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .kerning(1.2)
                    .foregroundColor(roleColor(kind).opacity(0.8))
            }

            // Target word / chunk
            Text(node.brick.targetBrick ?? node.brick.word)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(isRevealing ? .white : Color(white: 0.6))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Native meaning
            Text(node.brick.nativeBrick ?? node.brick.meaning)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(white: 0.4))
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(minWidth: 70)
        .background(
            Rectangle()
                .fill(isRevealing
                      ? roleColor(node.brick.baseKind ?? "").opacity(0.12)
                      : Color(white: 0.07))
        )
        .overlay(
            Rectangle()
                .stroke(isRevealing
                        ? roleColor(node.brick.baseKind ?? "").opacity(0.5)
                        : Color(white: 0.15),
                        lineWidth: 1)
        )
        .animation(.easeOut(duration: 0.25), value: node.state == .revealing)
    }

    // MARK: - Connector

    private var connectorArrow: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color(white: 0.2))
                .frame(width: 24, height: 1)
            Image(systemName: "chevron.right")
                .font(.system(size: 8, weight: .heavy))
                .foregroundColor(Color(white: 0.25))
        }
    }

    // MARK: - Setup & reveal sequence

    private func setup() {
        guard !bricks.isEmpty else { onComplete(); return }

        // Build nodes in sentence order
        var built: [BridgeNode] = []
        for (i, brick) in bricks.enumerated() {
            built.append(BridgeNode(id: brick.id, brick: brick, sentenceIndex: i))
        }
        nodes = built

        // Build reveal order: anchor first, then expand outward
        let anchor = min(anchorIndex, bricks.count - 1)
        var order: [Int] = [anchor]

        var left = anchor - 1
        var right = anchor + 1
        while left >= 0 || right < bricks.count {
            if left >= 0 { order.append(left); left -= 1 }
            if right < bricks.count { order.append(right); right += 1 }
        }
        revealQueue = order

        // Start reveal after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            revealNext()
        }
    }

    private func revealNext() {
        guard !revealQueue.isEmpty else {
            finishAnimation()
            return
        }

        let idx = revealQueue.removeFirst()
        guard idx < nodes.count else { revealNext(); return }

        let brick = nodes[idx].brick

        // Determine rule label from the expansion field of the brick being revealed
        let label: String? = {
            if idx < anchorIndex {
                // Expanding left — label comes from this brick's expansionAfter (points right)
                return brick.expansionAfter?.label
            } else if idx > anchorIndex {
                // Expanding right — label comes from this brick's expansionBefore (points left)
                return brick.expansionBefore?.label
            }
            return nil
        }()

        if let label {
            // Flash rule label, then reveal node
            activeRuleLabel = label
            withAnimation { ruleLabelVisible = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { ruleLabelVisible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    revealNode(at: idx)
                }
            }
        } else {
            // Anchor — no rule label, reveal immediately
            revealNode(at: idx)
        }
    }

    private func revealNode(at idx: Int) {
        guard idx < nodes.count else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            nodes[idx].state = .revealing
        }

        // After a beat, dim it to "taught" and move to next
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.4)) {
                nodes[idx].state = .taught
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                revealNext()
            }
        }
    }

    private func finishAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { isFinishing = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onComplete()
            }
        }
    }

    // MARK: - Helpers

    private func expansionEdge(for node: BridgeNode) -> Edge {
        node.sentenceIndex <= anchorIndex ? .leading : .trailing
    }

    private func roleLabel(_ kind: String) -> String {
        let k = kind.lowercased()
        if k.contains("verb") { return "VERB" }
        if k.contains("noun") { return "NOUN" }
        if k.contains("adj") { return "ADJ" }
        if k.contains("adv") || k.contains("frequency") || k.contains("degree") || k.contains("time") { return "ADV" }
        if k.contains("prep") { return "PREP" }
        if k.contains("conj") { return "CONJ" }
        if k.contains("chunk") || k.contains("phrase") { return "CHUNK" }
        if k.contains("expression") || k.contains("greeting") { return "EXPR" }
        if k.contains("proper") { return "NAME" }
        return kind.prefix(6).uppercased()
    }

    private func roleColor(_ kind: String) -> Color {
        let k = kind.lowercased()
        if k.contains("verb") { return CyberColors.neonCyan }
        if k.contains("noun") || k.contains("proper") { return .white }
        if k.contains("adj") { return CyberColors.neonYellow }
        if k.contains("adv") || k.contains("frequency") || k.contains("degree") || k.contains("time") { return Color.orange }
        if k.contains("prep") { return Color(white: 0.6) }
        if k.contains("conj") { return Color.purple }
        if k.contains("chunk") || k.contains("phrase") { return CyberColors.neonGreen }
        if k.contains("expression") || k.contains("greeting") { return CyberColors.neonPink }
        return Color(white: 0.5)
    }
}

// MARK: - Compact bridge strip (used during drill phase)

/// A smaller read-only version of the bridge shown at the top of the
/// drill interaction zone. Highlights the brick currently being drilled.
struct ConversationBridgeStrip: View {
    let bricks: [BrickItem]
    let activeBrickId: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(bricks.enumerated()), id: \.element.id) { idx, brick in
                    let isActive = brick.id == activeBrickId

                    VStack(spacing: 3) {
                        Text(brick.targetBrick ?? brick.word)
                            .font(.system(size: 13, weight: isActive ? .bold : .regular))
                            .foregroundColor(isActive ? .white : Color(white: 0.38))
                            .lineLimit(1)

                        // Active indicator dot
                        Circle()
                            .fill(isActive ? CyberColors.neonCyan : Color.clear)
                            .frame(width: 4, height: 4)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        isActive
                            ? roleColor(brick.baseKind ?? "").opacity(0.10)
                            : Color.clear
                    )

                    if idx < bricks.count - 1 {
                        Rectangle()
                            .fill(Color(white: 0.15))
                            .frame(width: 16, height: 1)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.04))
        .overlay(
            Rectangle()
                .fill(Color(white: 0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func roleColor(_ kind: String) -> Color {
        let k = kind.lowercased()
        if k.contains("verb") { return CyberColors.neonCyan }
        if k.contains("noun") { return .white }
        if k.contains("adj") { return CyberColors.neonYellow }
        if k.contains("chunk") || k.contains("phrase") { return CyberColors.neonGreen }
        return Color(white: 0.5)
    }
}
