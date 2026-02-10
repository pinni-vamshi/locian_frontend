import SwiftUI

struct PrerequisiteView: View {
    @ObservedObject var logic: PrerequisiteLogic
    let item: PrerequisiteLogic.PrerequisiteItem
    
    @State private var isShowingHint: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            // 1. Context (The Goal)
            VStack(alignment: .leading, spacing: 8) {
                Text("CONTEXT")
                    .font(.system(size: 12, weight: .black))
                    .tracking(2)
                    .foregroundColor(CyberColors.neonCyan.opacity(0.6))
                
                Text(logic.patternState.drillData.meaning)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(CyberColors.neonCyan.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            // 2. Main Teaching Word
            VStack(spacing: 12) {
                Text(item.brick.meaning.uppercased())
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                /* Phonetic sound display removed per request. Used for speech only. */
            }
            .padding(.horizontal, 40)
            
            // 3. Hint / Reveal
            Button(action: {
                withAnimation(.spring()) {
                    isShowingHint.toggle()
                }
            }) {
                VStack(spacing: 4) {
                    if isShowingHint {
                        Text(item.brick.word)
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(CyberColors.neonPink)
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                            Text("TAP TO REVEAL")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 4. Action Button
            Button(action: {
                logic.showMCQ()
            }) {
                HStack {
                    Text("PRACTICE THIS")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(CyberColors.neonCyan)
                .cornerRadius(32)
                .shadow(color: CyberColors.neonCyan.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Manager View
struct PrerequisiteManagerView: View {
    @StateObject var logic: PrerequisiteLogic
    
    init(state: DrillState, engine: LessonEngine) {
        _logic = StateObject(wrappedValue: PrerequisiteLogic(patternState: state, engine: engine))
    }
    
    var body: some View {
        Group {
            if logic.isComplete {
                Color.clear.onAppear {
                    // Logic handles advance directly now
                }
            } else if let item = logic.currentItem {
                if logic.isShowingMCQ {
                    if let mcqState = logic.materializeMCQState() {
                        BrickModeSelector.interactionView(
                            for: mcqState, 
                            engine: logic.engine, 
                            showPrompt: true, 
                            onComplete: { logic.next() }
                        )
                        .id("mcq-\(item.id)")
                    }
                } else {
                    PrerequisiteView(logic: logic, item: item)
                        .id("teach-\(item.id)")
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            print("🚀 [PrerequisiteManager] started.")
        }
    }
}
