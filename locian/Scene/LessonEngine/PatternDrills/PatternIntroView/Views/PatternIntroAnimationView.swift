import SwiftUI

struct PatternIntroAnimationView: View {
    let bricks: [DrillState]
    let onComplete: () -> Void
    let targetLanguage: String
    let userLanguage: String
    let patternMeaning: String
    let patternTarget: String
    @State private var visibleIndexSet: Set<Int> = []
    @State private var isSpeechActive = false
    @State private var viewOpacity: Double = 1.0

    
    @State private var currentHeaderText: String = "CORE COMPONENTS"
    @State private var voiceIntroText: String = ""
    
    private var targetLanguageName: String {
        TargetLanguageMapping.shared.getDisplayNames(for: targetLanguage).english
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ✅ Removed Top Spacer for Top-Alignment
            
            // ✅ Header Text: Appears immediately on entry
            Text(currentHeaderText)
                .font(.system(size: 40, weight: .black))
                .minimumScaleFactor(0.5)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
                .padding(.bottom, 24)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(bricks.prefix(3).enumerated()), id: \.offset) { index, brick in
                    if visibleIndexSet.contains(index) {
                        HStack(spacing: 12) {
                            Text(brick.drillData.meaning)
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(.white)
                            
                            Text(":")
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(brick.drillData.target)
                                .font(.system(size: 30, weight: .black))
                                .foregroundColor(CyberColors.neonPink)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 5)
            
            Spacer() // ✅ Pushes everything to the top
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
        .opacity(viewOpacity) // ✅ SMOOTH VIEW TRANSITION
        .onAppear {
            setupUI()
            startVoiceChain()
        }
    }
    
    private func setupUI() {
        // 1. Voice Variants (No more listing words at the end)
        let voiceVariants = [
            "Let's learn \"\(patternMeaning)\"! First, we'll check these words.",
            "Ready for \"\(patternMeaning)\"? These are the words we'll use.",
            "Let's build \"\(patternMeaning)\" together. First, we need these.",
            "To say \"\(patternMeaning)\" correctly, we should check these components.",
            "Time for \"\(patternMeaning)\"! Let's start with these basics."
        ]
        voiceIntroText = voiceVariants.randomElement() ?? voiceVariants[0]
        
        // 2. Visual Header (Keeping original variants exactly)
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
    
    /// ✅ VOICE AS MASTER CLOCK
    private func startVoiceChain() {
        visibleIndexSet.removeAll()
        
        // Voice plays the natural intro
        print("🔊 [PatternIntro] Phase 1: Intro Speech: '\(voiceIntroText)' in \(userLanguage)")
        
        AudioManager.shared.speak(segments: [.init(text: voiceIntroText, language: userLanguage)]) {
            DispatchQueue.main.async {
                revealWordsSequentially(at: 0)
            }
        }
    }
    
    private func revealWordsSequentially(at index: Int) {
        let maxBricks = min(bricks.count, 3)
        guard index < maxBricks else {
            // ✅ ALL WORDS COMPLETE: Smooth Fade then signal logic
            print("⏳ [PatternIntro] All words revealed. Fading out...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    viewOpacity = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("🏁 [PatternIntro] Animation Loop Finished.")
                onComplete()
            }
            return
        }
        
        // 1. Determine if we should say "and" (Only before the VERY LAST word)
        let isLast = index == (maxBricks - 1)
        let shouldSayAnd = isLast && maxBricks > 1
        
        if shouldSayAnd {
            // "and" -> Reveal -> Speak Word
            print("🔊 [PatternIntro] Connector: 'and' (Voice Only)")
            AudioManager.shared.speak(segments: [.init(text: "and", language: userLanguage)]) {
                DispatchQueue.main.async {
                    // Reveal visually AFTER 'and'
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        _ = visibleIndexSet.insert(index)
                    }
                    
                    let meaning = bricks[index].drillData.meaning
                    print("✨ [PatternIntro] Speaking last word: \(meaning)")
                    AudioManager.shared.speak(segments: [.init(text: meaning, language: userLanguage)]) {
                        DispatchQueue.main.async {
                            revealWordsSequentially(at: index + 1)
                        }
                    }
                }
            }
        } else {
            // Normal Reveal -> Speak Word
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                _ = visibleIndexSet.insert(index)
            }
            
            let meaning = bricks[index].drillData.meaning
            print("✨ [PatternIntro] Speaking word #\(index + 1): \(meaning)")
            AudioManager.shared.speak(segments: [.init(text: meaning, language: userLanguage)]) {
                DispatchQueue.main.async {
                    revealWordsSequentially(at: index + 1)
                }
            }
        }
    }
}
