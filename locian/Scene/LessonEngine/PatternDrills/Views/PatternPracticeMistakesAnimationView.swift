import SwiftUI
import Combine

struct PatternPracticeMistakesAnimationView: View {
    let mistakes: [DrillState]
    let onComplete: () -> Void 
    let targetLanguage: String
    
    @State private var visibleIndices: Set<Int> = []
    
    @State private var viewOpacity: Double = 1.0
    @State private var currentHeaderText: String = "MISTAKES"
    
    @State private var visibleIndexSet: Set<Int> = []
    
    private var targetLanguageName: String {
        TargetLanguageMapping.shared.getDisplayNames(for: targetLanguage).english
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(currentHeaderText)
                .font(.system(size: 40, weight: .black))
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
                .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(mistakes.prefix(3).enumerated()), id: \.offset) { index, brick in
                    if visibleIndexSet.contains(index) {
                        HStack(spacing: 12) {
                            Text(brick.drillData.meaning)
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(.gray)
                            
                            Text(":")
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(brick.drillData.target)
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(CyberColors.neonPink)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 5)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black.ignoresSafeArea())
        .opacity(viewOpacity)
        .onAppear {
            setupUI()
            startVoiceChain()
        }
    }
    private func setupUI() {
        let variations = [
            "Let's review some mistakes.",
            "Here are the words you missed.",
            "Let's practice these again."
        ]
        currentHeaderText = variations.randomElement() ?? variations[0]
    }
    
    private func startVoiceChain() {
        visibleIndexSet.removeAll()
        
        print("🔊 [MistakeIntro] Skipping Intro Speech, starting sequence directly.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            speakMistakeSequentially(at: 0)
        }
    }
    
    private func speakMistakeSequentially(at index: Int) {
        guard index < min(mistakes.count, 3) else {
            // ... (fade out logic)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    viewOpacity = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
            return
        }
        
        
        // 1. Reveal Mistake instantly
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            _ = visibleIndexSet.insert(index)
        }
        
        // 2. Wait a beat then proceed to next mistake
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            speakMistakeSequentially(at: index + 1)
        }
    }
}
