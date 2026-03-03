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
            "Let's fix the mistakes you just made.",
            "Let's retry the words you missed.",
            "Time to practice the tricky ones.",
            "Let's clear up those mistakes.",
            "Let's go over what we missed."
        ]
        currentHeaderText = variations.randomElement() ?? variations[0]
    }
    
    private func startVoiceChain() {
        visibleIndexSet.removeAll()
        
        // Voice plays the SAME intro text shown on screen
        print("🔊 [MistakeIntro] Phase 0: Intro Speech: '\(currentHeaderText)'")
        
        AudioManager.shared.speak(segments: [.init(text: currentHeaderText, language: "en-US")]) {
            DispatchQueue.main.async {
                speakMistakeSequentially(at: 0)
            }
        }
    }
    
    private func speakMistakeSequentially(at index: Int) {
        guard index < min(mistakes.count, 3) else {
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
        
        let brick = mistakes[index]
        let meaning = brick.drillData.meaning
        let target = brick.drillData.target
        
        // Full bilingual sentences for one-shot speech
        let audioVariants = [
            "In \(targetLanguageName), \(meaning) means \(target)",
            "For \(meaning), use the word \(target) in \(targetLanguageName)",
            "The \(targetLanguageName) word for \(meaning) is \(target)",
            "\(meaning) translates to \(target) in \(targetLanguageName)",
            "In \(targetLanguageName), we say \(target) for \(meaning)"
        ]
        
        let introSentence = audioVariants.randomElement() ?? audioVariants[0]
        print("🔊 [MistakeIntro] Phase \(index + 1): \(introSentence)")
        
        // 1. Reveal Mistake instantly
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            _ = visibleIndexSet.insert(index)
        }
        
        // 2. Speak Full Multi-Segment Sentence (High Fidelity)
        // We split the template to give the target word the NATIVE accent
        let prefix: String
        let suffix: String
        
        // Match the logic found in audioVariants above (Line 105)
        // Simple heuristic for this specific view's templates
        if introSentence.contains(" translates to ") {
            prefix = introSentence.components(separatedBy: target)[0]
            suffix = introSentence.components(separatedBy: target).count > 1 ? introSentence.components(separatedBy: target)[1] : ""
        } else if introSentence.contains(" word for ") {
            prefix = introSentence.components(separatedBy: target)[0]
            suffix = introSentence.components(separatedBy: target).count > 1 ? introSentence.components(separatedBy: target)[1] : ""
        } else if introSentence.contains(" means ") {
            prefix = introSentence.components(separatedBy: target)[0]
            suffix = introSentence.components(separatedBy: target).count > 1 ? introSentence.components(separatedBy: target)[1] : ""
        } else {
            prefix = introSentence.replacingOccurrences(of: target, with: "")
            suffix = ""
        }
        
        AudioManager.shared.speak(segments: [
            .init(text: prefix, language: "en-US"),
            .init(text: target, language: targetLanguage),
            .init(text: suffix, language: "en-US")
        ].filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            // 3. Wait a beat then proceed to next mistake
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speakMistakeSequentially(at: index + 1)
            }
        }
    }
}
