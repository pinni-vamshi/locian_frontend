//
//  AnimatedSentenceAnalysisView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct AnimatedSentenceAnalysisView: View {
    @State private var currentSentence = 0
    @State private var tenseBadgeOpacity: Double = 0
    @State private var nativeSentenceOpacity: Double = 0
    @State private var transliterationOpacity: Double = 0
    @State private var wordBreakdownOpacity: Double = 0
    @State private var similarWordsOpacity: Double = 0
    @State private var tenseBadgeScale: CGFloat = 0.01
    @State private var nativeSentenceScale: CGFloat = 0.01
    @State private var transliterationScale: CGFloat = 0.01
    @State private var wordBreakdownScale: CGFloat = 0.01
    @State private var similarWordsScale: CGFloat = 0.01
    
    private let sentences = [
        ("Present", "I am learning", "I am learning", ["I", "am", "learning"], ["studying", "practicing", "mastering"]),
        ("Past", "I learned yesterday", "I learned yesterday", ["I", "learned", "yesterday"], ["studied", "practiced", "mastered"]),
        ("Future", "I will learn tomorrow", "I will learn tomorrow", ["I", "will", "learn", "tomorrow"], ["will study", "will practice", "will master"])
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Tense Badge
            Text(sentences[currentSentence].0)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(25)
                .scaleEffect(tenseBadgeScale)
                .opacity(tenseBadgeOpacity)
            
            // Native Sentence (24pt)
            Text(sentences[currentSentence].1)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .scaleEffect(nativeSentenceScale)
                .opacity(nativeSentenceOpacity)
            
            // Transliteration (18pt, 70% opacity)
            Text(sentences[currentSentence].2)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .scaleEffect(transliterationScale)
                .opacity(transliterationOpacity)
            
            // Word-by-Word Breakdown
            HStack(spacing: 8) {
                ForEach(Array(sentences[currentSentence].3.enumerated()), id: \.offset) { index, word in
                    VStack(spacing: 4) {
                        Text(word)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        
                        Text(getTranslation(for: word))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .scaleEffect(wordBreakdownScale)
            .opacity(wordBreakdownOpacity)
            
            // Similar Words
            HStack(spacing: 6) {
                ForEach(sentences[currentSentence].4, id: \.self) { word in
                    Text(word)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .scaleEffect(similarWordsScale)
            .opacity(similarWordsOpacity)
        }
        .onAppear {
            startInitialAnimation()
            startSentenceRotation()
        }
    }
    
    private func getTranslation(for word: String) -> String {
        let translations = [
            "I": "I", "am": "am", "learning": "learning",
            "learned": "learned", "yesterday": "yesterday",
            "will": "will", "tomorrow": "tomorrow"
        ]
        return translations[word] ?? word
    }
    
    private func startInitialAnimation() {
        // Tense Badge: Scale + opacity fade (0.3s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                tenseBadgeScale = 1.0
                tenseBadgeOpacity = 1.0
            }
        }
        
        // Native Sentence: Scale + opacity fade (0.4s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                nativeSentenceScale = 1.0
                nativeSentenceOpacity = 1.0
            }
        }
        
        // Transliteration: Scale + opacity fade (0.4s + 0.1s stagger = 0.5s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                transliterationScale = 1.0
                transliterationOpacity = 1.0
            }
        }
        
        // Word Breakdown: Additional delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                wordBreakdownScale = 1.0
                wordBreakdownOpacity = 1.0
            }
        }
        
        // Similar Words: Final element
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                similarWordsScale = 1.0
                similarWordsOpacity = 1.0
            }
        }
    }
    
    private func startSentenceRotation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentSentence = (currentSentence + 1) % sentences.count
            }
        }
    }
}

#Preview {
    AnimatedSentenceAnalysisView()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
