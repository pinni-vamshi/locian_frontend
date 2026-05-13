//
//  ConversationLessonView.swift
//  locian
//
//  Lesson shell — single-subject staging:
//   • Only the live turn is on screen at any time (ActiveTurnView).
//   • User reply only on the conveyor: pattern intro (vocabIntro) → practice → …
//     Locian comprehension MCQ is not shown — learner lands straight on reply teaching.
//
//  Mounted from LearnTabView as the sole lesson destination.
//

import SwiftUI

struct ConversationLessonView: View {
    @StateObject private var engine = LessonEngine()
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss

    let lessonData: GenerateSentenceData

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                if engine.isSessionComplete {
                    header
                        .padding(.horizontal, 8)
                        .padding(.bottom, 6)
                        .diagnosticBorder(.orange)
                    LessonCompletionView(engine: engine, onFinish: { dismiss() })
                        .diagnosticBorder(.orange)
                } else if let _ = engine.orchestrator?.activeState {
                    ArchBar(
                        engine: engine,
                        topic: lessonData.place_name ?? lessonData.micro_situation,
                        partner: lessonData.conversation_context,
                        onBack: { dismiss() }
                    )
                    .diagnosticBorder(.orange)

                    body(activeId: engine.orchestrator?.activeState?.patternId)
                        .diagnosticBorder(.orange)
                } else {
                    header
                        .padding(.horizontal, 8)
                        .padding(.bottom, 6)
                        .diagnosticBorder(.orange)
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CyberColors.neonCyan))
                        .onAppear { boot() }
                        .diagnosticBorder(.orange)
                    Spacer()
                }
            }
            .diagnosticBorder(.red)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { appState.isLessonActive = true }
        .onDisappear { appState.isLessonActive = false }
    }

    // MARK: - Layout

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .diagnosticBorder(.blue)
            }
            .diagnosticBorder(.cyan)
            Spacer()
        }
        .diagnosticBorder(.green)
    }

    @ViewBuilder
    private func body(activeId: String?) -> some View {
        // Single-subject staging — only the live turn is on screen.
        ActiveTurnView(
            engine: engine,
            activePatternId: activePattern()?.id
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .diagnosticBorder(.yellow)
    }

    // MARK: - Engine wiring

    private func boot() {
        if engine.lessonData == nil {
            engine.initialize(with: lessonData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                engine.startLesson()
            }
        }
    }

    private func pattern(for id: String) -> PatternData? {
        engine.allPatterns.first(where: { $0.id == id })
    }

    private func activePattern() -> PatternData? {
        guard let pid = engine.orchestrator?.activeState?.patternId else { return nil }
        return pattern(for: pid)
    }

}
