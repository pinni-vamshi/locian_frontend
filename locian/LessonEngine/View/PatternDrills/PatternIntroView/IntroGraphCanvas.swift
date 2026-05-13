import SwiftUI

// Custom alignment so all target boxes share the same horizontal rail
extension VerticalAlignment {
    struct IntroTargetBoxCenter: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat { d[VerticalAlignment.center] }
    }
    static let targetBoxCenter = VerticalAlignment(IntroTargetBoxCenter.self)
}

struct IntroGraphCanvas: View {
    let allBricks: [BrickItem]
    let teachBrickIds: Set<String>
    let activeBrick: BrickItem?
    let completedIds: Set<String>
    let activeTeachIndex: Int
    var activeBaseRevealed: Bool = false
    var activeTargetRevealed: Bool = false
    /// Vertical band for the diagram; scroll is horizontal only inside this height.
    var stripHeight: CGFloat

    private let targetBoxHeight: CGFloat = 38
    private let activeTargetBoxHeight: CGFloat = 76

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .targetBoxCenter, spacing: 0) {
                    ForEach(Array(allBricks.enumerated()), id: \.element.id) { idx, brick in
                        brickNode(brick, index: idx)
                            .id(brick.id)
                        if idx < allBricks.count - 1 { connector }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 24)
                .frame(minWidth: UIScreen.main.bounds.width)
                .frame(minHeight: stripHeight, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: stripHeight)
            .diagnosticBorder(.purple.opacity(0.35))
            .onChange(of: activeTeachIndex) {
                if let id = activeBrick?.id {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
            .onAppear {
                if let id = activeBrick?.id {
                    proxy.scrollTo(id, anchor: .center)
                }
            }
        }
    }

    // MARK: - Node dispatch

    @ViewBuilder
    private func brickNode(_ brick: BrickItem, index: Int) -> some View {
        let isTeach  = teachBrickIds.contains(brick.id)
        let isActive = activeBrick?.id == brick.id
        let isDone   = completedIds.contains(brick.id)
        let native   = brick.nativeBrick ?? brick.meaning
        let goesUp   = index % 2 == 0

        if !isTeach {
            nonTeachNode(brick: brick, native: native, goesUp: goesUp)
        } else {
            let hasBase = !(brick.base?.isEmpty ?? true)
            // Which box is currently being asked for this active brick?
            let isAskBase   = isActive && hasBase && !activeBaseRevealed
            let isAskTarget = isActive && !activeTargetRevealed && (!hasBase || activeBaseRevealed)
            teachNode(
                brick: brick, native: native,
                baseRevealed: isDone || (isActive && activeBaseRevealed),
                targetRevealed: isDone || (isActive && activeTargetRevealed),
                isAskBase: isAskBase,
                isAskTarget: isAskTarget,
                isActive: isActive, goesUp: goesUp
            )
        }
    }

    // MARK: - Non-teach node

    @ViewBuilder
    private func nonTeachNode(brick: BrickItem, native: String, goesUp: Bool) -> some View {
        let word = (brick.targetBrick ?? brick.word).lowercased()
        if goesUp {
            VStack(alignment: .center, spacing: 0) {
                nativeLabel(native, dim: false)
                Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1.5, height: 20)
                revealedTargetBox(word, height: targetBoxHeight, fontSize: 16)
                    .alignmentGuide(.targetBoxCenter) { d in d[VerticalAlignment.center] }
            }
        } else {
            VStack(alignment: .center, spacing: 0) {
                revealedTargetBox(word, height: targetBoxHeight, fontSize: 16)
                    .alignmentGuide(.targetBoxCenter) { d in d[VerticalAlignment.center] }
                Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1.5, height: 20)
                nativeLabel(native, dim: false)
            }
        }
    }

    // MARK: - Teach node

    @ViewBuilder
    private func teachNode(
        brick: BrickItem, native: String,
        baseRevealed: Bool, targetRevealed: Bool,
        isAskBase: Bool, isAskTarget: Bool,
        isActive: Bool, goesUp: Bool
    ) -> some View {
        let base     = (brick.base ?? brick.word).lowercased()
        let target   = (brick.targetBrick ?? brick.word).lowercased()
        let dim      = !isActive && !baseRevealed
        let lineCol  = dim ? Color(white: 0.18) : Color.white.opacity(0.28)
        let arrowCol = dim ? Color(white: 0.2)  : Color.white.opacity(0.4)

        if goesUp {
            VStack(alignment: .center, spacing: 0) {
                nativeLabel(native, dim: dim)
                Rectangle().fill(lineCol).frame(width: 1.5, height: 20)
                baseBox(base, revealed: baseRevealed, isAsking: isAskBase, isActive: isActive)
                Rectangle().fill(lineCol).frame(width: 1.5, height: 18)
                Image(systemName: "arrow.down")
                    .font(.system(size: isActive ? 16 : 9, weight: .bold))
                    .foregroundColor(arrowCol)
                targetBox(target, revealed: targetRevealed, isAsking: isAskTarget, isActive: isActive)
                    .alignmentGuide(.targetBoxCenter) { d in d[VerticalAlignment.center] }
            }
        } else {
            VStack(alignment: .center, spacing: 0) {
                targetBox(target, revealed: targetRevealed, isAsking: isAskTarget, isActive: isActive)
                    .alignmentGuide(.targetBoxCenter) { d in d[VerticalAlignment.center] }
                Image(systemName: "arrow.up")
                    .font(.system(size: isActive ? 16 : 9, weight: .bold))
                    .foregroundColor(arrowCol)
                Rectangle().fill(lineCol).frame(width: 1.5, height: 18)
                baseBox(base, revealed: baseRevealed, isAsking: isAskBase, isActive: isActive)
                Rectangle().fill(lineCol).frame(width: 1.5, height: 20)
                nativeLabel(native, dim: dim)
            }
        }
    }

    // MARK: - Atomic subviews

    @ViewBuilder
    private func nativeLabel(_ text: String, dim: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(dim ? Color(white: 0.28) : Color(white: 0.55))
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 90)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(dim ? Color(white: 0.09) : Color(white: 0.14))
    }

    @ViewBuilder
    private func baseBox(_ base: String, revealed: Bool, isAsking: Bool, isActive: Bool) -> some View {
        let h: CGFloat = isActive ? 48 : 24
        let w: CGFloat = isActive ? 108 : 54
        let size: CGFloat = isActive ? 22 : 11
        if revealed {
            Text(base)
                .font(.system(size: size, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(CyberColors.neonCyan)
                .fixedSize()
        } else {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: w, height: h)
                .overlay(Rectangle().stroke(
                    isAsking ? CyberColors.neonPink : Color(white: 0.18),
                    lineWidth: isAsking ? 2 : 1
                ))
        }
    }

    @ViewBuilder
    private func targetBox(_ target: String, revealed: Bool, isAsking: Bool, isActive: Bool) -> some View {
        let h: CGFloat = isActive ? activeTargetBoxHeight : targetBoxHeight
        let w: CGFloat = isActive ? 108 : 54
        let size: CGFloat = isActive ? 32 : 16
        if revealed {
            revealedTargetBox(target, height: h, fontSize: size)
        } else {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: w, height: h)
                .overlay(Rectangle().stroke(
                    isAsking ? CyberColors.neonPink : Color(white: 0.18),
                    lineWidth: isAsking ? 2 : 1
                ))
        }
    }

    private func revealedTargetBox(_ text: String, height: CGFloat, fontSize: CGFloat) -> some View {
        Text(text)
            .font(.system(size: fontSize, weight: .black))
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .frame(height: height)
            .background(Color.white)
            .fixedSize(horizontal: true, vertical: false)
    }

    // MARK: - Connector

    private var connector: some View {
        HStack(spacing: 2) {
            Rectangle().fill(ThemeColors.secondaryAccent).frame(width: 8, height: 2)
            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(ThemeColors.secondaryAccent)
            Rectangle().fill(ThemeColors.secondaryAccent).frame(width: 2, height: 2)
        }
        .alignmentGuide(.targetBoxCenter) { d in d[VerticalAlignment.center] }
    }
}
