import SwiftUI

struct LessonView: View {
    @StateObject private var engine: LessonEngine
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    let lessonData: GenerateSentenceData
    
    init(lessonData: GenerateSentenceData) {
        self.lessonData = lessonData
        // Initialize the Engine directly
        let newEngine = LessonEngine()
        _engine = StateObject(wrappedValue: newEngine)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- CUSTOM HEADER ---
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    // Pattern Progress Discs (right-aligned)
                    if let orchestrator = engine.orchestrator, let state = orchestrator.activeState {
                        PatternProgressRow(
                            patterns: engine.rawPatterns.map { $0.id },
                            currentPatternId: state.patternId,
                            engine: engine
                        )
                        .padding(.trailing, 8)
                    }
                }


                .padding(.horizontal, 8)
                .padding(.bottom, 10)
                .background(Color.black.ignoresSafeArea(edges: .top))
                
                // --- MAIN CONTENT ---
                ZStack {
                    if let orchestrator = engine.orchestrator, let state = orchestrator.activeState {
                        switch state.currentMode {
                        case .vocabIntro:
                            PatternIntroManagerView(state: state, engine: engine)
                                .id("intro-\(state.id)")
                        case .ghostManager:
                            GhostModeManagerView(targetPattern: state, engine: engine)
                                .id("ghost-\(state.id)")
                        default:
                            FullDrillManagerView(state: state, engine: engine)
                                .id("practice-\(state.id)")
                        }
                    } else if engine.isSessionComplete {
LessonCompletionView(onFinish: {
                            dismiss()
                        })
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: CyberColors.neonCyan))
                            .onAppear {
                                engine.initialize(with: lessonData)
                                
                                // Kickstart the flow
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    engine.startLesson()
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            appState.isLessonActive = true
        }
        .onDisappear {
            appState.isLessonActive = false
        }
    }
}
