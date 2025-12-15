//
//  LanguageInputsView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct LanguageInputsView: View {
    @State private var currentLanguage = 0
    @State private var languageNameOpacity: Double = 0
    @State private var nativeScriptOpacity: Double = 0
    @State private var transliterationOpacity: Double = 0
    @State private var languageNameScale: CGFloat = 0.01
    @State private var nativeScriptScale: CGFloat = 0.01
    @State private var transliterationScale: CGFloat = 0.01
    
    private let languages = [
        ("Japanese", "こんにちは", "Konnichiwa"),
        ("Hindi", "नमस्ते", "Namaste"),
        ("Arabic", "مرحبا", "Marhaba"),
        ("Korean", "안녕하세요", "Annyeonghaseyo")
    ]
    
    var body: some View {
        VStack(spacing: 25) {
            // Language name
            Text(languages[currentLanguage].0)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(languageNameScale)
                .opacity(languageNameOpacity)
            
            // Native script
            Text(languages[currentLanguage].1)
                .font(.system(size: 36))
                .foregroundColor(.white)
                .scaleEffect(nativeScriptScale)
                .opacity(nativeScriptOpacity)
            
            // transliteration
            Text(languages[currentLanguage].2)
                .font(.system(size: 22))
                .foregroundColor(.white.opacity(0.8))
                .scaleEffect(transliterationScale)
                .opacity(transliterationOpacity)
        }
        .onAppear {
            startInitialAnimation()
            startLanguageRotation()
        }
    }
    
    private func startInitialAnimation() {
        // Language Name: Scale + opacity fade (0.3s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                languageNameScale = 1.0
                languageNameOpacity = 1.0
            }
        }
        
        // Native Script: Scale + opacity fade (0.4s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                nativeScriptScale = 1.0
                nativeScriptOpacity = 1.0
            }
        }
        
        // Transliteration: Scale + opacity fade (0.4s + 0.1s stagger = 0.5s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                transliterationScale = 1.0
                transliterationOpacity = 1.0
            }
        }
    }
    
    private func startLanguageRotation() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Smooth crossfade transition - no flashing
            withAnimation(.easeInOut(duration: 0.5)) {
                currentLanguage = (currentLanguage + 1) % languages.count
            }
        }
    }
}

#Preview {
    LanguageInputsView()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
