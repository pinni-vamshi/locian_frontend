import SwiftUI

struct PatternIntroAnimationView: View {
    let bricks: [DrillState]
    let onComplete: () -> Void
    let targetLanguage: String
    let userLanguage: String
    let patternMeaning: String
    let patternTarget: String
    @Binding var animatingIndices: Set<Int>
    var onWordReveal: ((String) -> Void)? = nil
    @State private var visibleIndexSet: Set<Int> = []
    @State private var isSpeechActive = false
    @State private var viewOpacity: Double = 1.0
    @State private var currentHeaderText: String = "CORE COMPONENTS"

    private var targetLanguageName: String {
        TargetLanguageMapping.shared.getDisplayNames(for: targetLanguage).english
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Random header — smaller font
            Text(currentHeaderText)
                .font(.system(size: 22, weight: .black))
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
                .padding(.bottom, 24)

            // Target words only — appear one by one, no native label
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(bricks.prefix(3).enumerated()), id: \.offset) { index, brick in
                    if visibleIndexSet.contains(index) {
                        Text(brick.drillData.target)
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(CyberColors.neonPink)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 5)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
        .opacity(viewOpacity)
        .onAppear {
            setupUI()
            startVoiceChain()
        }
    }

    private func setupUI() {
        let visualVariants = [
            "LET'S CHECK OUT THESE WORDS",
            "HERE ARE YOUR CORE WORDS",
            "READY TO MASTER THESE BASICS?",
            "WE START WITH THESE WORDS",
            "LET'S BUILD THIS PATTERN TOGETHER",
            "LEARNING THESE KEY WORDS FIRST"
        ]
        currentHeaderText = visualVariants.randomElement() ?? visualVariants[0]
    }

    private func startVoiceChain() {
        visibleIndexSet.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.revealWordsSequentially(at: 0)
        }
    }

    private func revealWordsSequentially(at index: Int) {
        let maxBricks = min(bricks.count, 3)
        guard index < maxBricks else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.0)) { viewOpacity = 0.0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { onComplete() }
            return
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            _ = visibleIndexSet.insert(index)
            _ = animatingIndices.insert(index)
        }
        if index < bricks.count {
            onWordReveal?(bricks[index].id)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            revealWordsSequentially(at: index + 1)
        }
    }
}
