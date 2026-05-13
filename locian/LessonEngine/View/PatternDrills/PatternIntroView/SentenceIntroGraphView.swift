import SwiftUI

struct SentenceIntroGraphView: View {
    let allBricks: [BrickItem]
    let orderedTeachBricks: [BrickItem]
    let brickDrills: [DrillState]
    let targetLanguage: String
    @ObservedObject var engine: LessonEngine
    let onContinue: () -> Void

    private var teachBrickIds: Set<String> { Set(orderedTeachBricks.map { $0.id }) }
    private var teachBricks: [BrickItem] { orderedTeachBricks }

    @State private var activeTeachIndex: Int = 0
    @State private var completedIds: Set<String> = []
    @State private var activeBaseRevealed: Bool = false
    @State private var activeTargetRevealed: Bool = false

    private var activeBrick: BrickItem? {
        guard activeTeachIndex < teachBricks.count else { return nil }
        return teachBricks[activeTeachIndex]
    }

    private var activeDrill: DrillState? {
        guard activeTeachIndex < brickDrills.count else { return nil }
        return brickDrills[activeTeachIndex]
    }

    var body: some View {
        GeometryReader { geo in
            // Fixed-height strip: graph scrolls horizontally only; lower area keeps question + interaction stable.
            let stripH = min(max(geo.size.height * 0.40, 272), 340)
            VStack(spacing: 0) {
                IntroGraphCanvas(
                    allBricks: allBricks,
                    teachBrickIds: teachBrickIds,
                    activeBrick: activeBrick,
                    completedIds: completedIds,
                    activeTeachIndex: activeTeachIndex,
                    activeBaseRevealed: activeBaseRevealed,
                    activeTargetRevealed: activeTargetRevealed,
                    stripHeight: stripH
                )
                .frame(maxWidth: .infinity)
                .clipped()

                VStack(spacing: 0) {
                    interactionPanel
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .diagnosticBorder(.mint.opacity(0.45))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(Color.black)
        .onAppear {
            engine.currentIntroBrickID = teachBricks.first?.id
        }
    }

    // MARK: - Interaction Panel

    @ViewBuilder
    private var interactionPanel: some View {
        if activeBrick == nil {
            // All bricks done — proceed to practice
            finishButton
                .diagnosticBorder(.orange.opacity(0.6))
        } else if let drill = activeDrill {
            let mode = BrickModeSelector.resolveMode(for: drill, engine: engine)
            Group {
                switch mode {
                case .componentTyping:
                    GraphTypingPanel(
                        drill: drill, engine: engine,
                        onTargetRevealed: { activeTargetRevealed = true },
                        onAutoAdvance: advance
                    )
                    .id(drill.id)
                case .speaking:
                    BrickVoiceView(
                        state: drill,
                        engine: engine,
                        onComplete: { _ in withAnimation { advance() } }
                    )
                    .environment(\.compactDrillZone, true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .id(drill.id)
                case .mastered:
                    Color.clear
                        .frame(maxWidth: .infinity, minHeight: 1)
                        .diagnosticBorder(.gray.opacity(0.4))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { advance() }
                        }
                default:
                    GraphMCQPanel(
                        drill: drill, engine: engine,
                        onBaseRevealed: { withAnimation(.easeInOut(duration: 0.25)) { activeBaseRevealed = true } },
                        onTargetRevealed: { withAnimation(.easeInOut(duration: 0.25)) { activeTargetRevealed = true } },
                        onAutoAdvance: advance
                    )
                    .id(drill.id)
                }
            }
            .diagnosticBorder(.orange)
            .transition(.opacity)
        }
    }

    // MARK: - Finish Button

    private var finishButton: some View {
        Button(action: onContinue) {
            HStack(spacing: 10) {
                Text("CONTINUE")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .tracking(2.5)
                    .foregroundColor(.black)
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(CyberColors.neonGreen)
        }
        .buttonStyle(.plain)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Advance

    func advance() {
        guard let brick = activeBrick else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            completedIds.insert(brick.id)
            activeBaseRevealed = false
            activeTargetRevealed = false
            activeTeachIndex += 1
        }
        if activeTeachIndex < teachBricks.count {
            engine.currentIntroBrickID = teachBricks[activeTeachIndex].id
        } else {
            engine.currentIntroBrickID = nil
        }
    }
}
