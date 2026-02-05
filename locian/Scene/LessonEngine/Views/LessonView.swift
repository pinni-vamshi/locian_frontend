import SwiftUI

struct LessonView: View {
    @StateObject private var session: LessonSessionManager
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    let lessonData: GenerateSentenceData
    
    init(lessonData: GenerateSentenceData) {
        self.lessonData = lessonData
        _session = StateObject(wrappedValue: LessonSessionManager())
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
                    if let state = session.activeState {
                         if state.isBrick {
                             BrickModeSelector(drill: state, session: session)
                                 .id(state.id)
                                 .transition(.opacity)
                         } else {
                             switch state.currentMode {
                             case .vocabIntro:
                                 PatternIntroManagerView(state: state, session: session)
                                     .id("intro-\(state.id)")
                             case .ghostManager:
                                 GhostModeManagerView(targetPattern: state, session: session)
                                     .id("ghost-\(state.id)")
                             default:
                                 PatternDrillManagerView(state: state, session: session)
                                     .id("practice-\(state.id)")
                             }
                         }
                    } else if session.isSessionComplete {
                        VStack(spacing: 20) {
                            Text("LESSON COMPLETE")
                                .font(.largeTitle)
                                .fontWeight(.black)
                                .foregroundColor(CyberColors.neonPink)
                            
                            CyberProceedButton(
                                action: { 
                                    dismiss()
                                },
                                label: "FINISH",
                                title: "RETURN HOME",
                                color: CyberColors.neonCyan,
                                systemImage: "house.fill",
                                isEnabled: true
                            )
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: CyberColors.neonCyan))
                            .onAppear {
                                session.startSession(with: lessonData)
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
