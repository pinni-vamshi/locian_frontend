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
            // Fixed-height strip: graph scrolls horizontally + vertically inside the strip; lower area stays stable.
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

                interactionPanel
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
            introFinishedColumn
        } else if let drill = activeDrill {
            activeInteractionColumn(drill: drill)
        }
    }

    /// Same vertical band as drill UI: top = prompt slot, middle flexes, CTA pinned to bottom.
    private var introFinishedColumn: some View {
        VStack(spacing: 0) {
            introDoneQuestionStrip
            Spacer(minLength: 0)
            finishButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .diagnosticBorder(.orange.opacity(0.6))
        .transition(.opacity)
    }

    /// Prompt strip aligned with `GraphMCQPanel` question row (48–80pt) showing intro complete.
    private var introDoneQuestionStrip: some View {
        ZStack {
            Color.black
            Text("DONE")
                .font(.custom("Helvetica Neue", size: 11).weight(.bold))
                .kerning(0.8)
                .foregroundColor(CyberColors.neonGreen)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 48, maxHeight: 80)
        .overlay(Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1), alignment: .top)
        .diagnosticBorder(.cyan)
    }

    @ViewBuilder
    private func activeInteractionColumn(drill: DrillState) -> some View {
        let mode = BrickModeSelector.resolveMode(for: drill, engine: engine)
        VStack(spacing: 0) {
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
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .diagnosticBorder(.orange)
        .transition(.opacity)
    }

    // MARK: - Finish (stays in interaction stack only; matches drill `CyberProceedButton` footers)

    private var finishButton: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            CyberProceedButton(
                action: { onContinue() },
                label: "NEXT_STORY_STEP",
                title: "CONTINUE",
                color: CyberColors.success,
                systemImage: "arrow.right",
                isEnabled: true
            )
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .transition(.opacity)
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
