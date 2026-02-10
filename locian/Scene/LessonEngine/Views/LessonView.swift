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
                    
                    Text(lessonData.micro_situation?.uppercased() ?? "LOCIAN")
                        .font(.system(size: 16, weight: .heavy))
                        .tracking(2)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Balancer
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
                .background(Color.black.ignoresSafeArea(edges: .top))
                
                // --- MAIN CONTENT ---
                ZStack {
                    if let state = engine.orchestrator?.activeState {
                         if state.isBrick {
                             BrickModeSelector(drill: state, engine: engine)
                                 .id(state.id)
                                 .transition(.opacity)
                         } else {
                             switch state.currentMode {
                             case .prerequisites:
                                 PrerequisiteManagerView(state: state, engine: engine)
                                     .id("prereq-\(state.id)")
                             case .vocabIntro:
                                 PatternIntroManagerView(state: state, engine: engine)
                                     .id("intro-\(state.id)")
                             case .ghostManager:
                                 GhostModeManagerView(targetPattern: state, engine: engine)
                                     .id("ghost-\(state.id)")
                             default:
                                 PatternDrillManagerView(state: state, engine: engine)
                                     .id("practice-\(state.id)")
                             }
                         }
                    } else if engine.isSessionComplete {
LessonCompletionView(onFinish: {
                            dismiss()
                        })
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: CyberColors.neonCyan))
                            .onAppear {
                                print("🚀 [LessonView] Booting Engine with Data...")
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
            print("\n🎬 [LessonView] View Mounted")
            appState.isLessonActive = true
        }
        .onDisappear {
            print("🛑 [LessonView] View Unmounted")
            appState.isLessonActive = false
        }
    }
}
