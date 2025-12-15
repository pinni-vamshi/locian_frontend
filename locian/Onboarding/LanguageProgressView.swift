//
//  LanguageProgressView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct LanguageProgressView: View {
    @State private var selectedLanguage = 0
    @State private var languageButtonOpacity: [Double] = [0, 0, 0, 0]
    @State private var languageButtonScale: [CGFloat] = [0.01, 0.01, 0.01, 0.01]
    @State private var traitCircleOpacity: [Double] = [0, 0, 0, 0]
    @State private var traitCircleScale: [CGFloat] = [0.01, 0.01, 0.01, 0.01]
    @State private var traitLabelOpacity: [Double] = [0, 0, 0, 0]
    @State private var traitLabelScale: [CGFloat] = [0.01, 0.01, 0.01, 0.01]
    @State private var progressOpacity: [Double] = [0, 0, 0, 0]
    @State private var progressScale: [CGFloat] = [0.01, 0.01, 0.01, 0.01]
    @State private var middleStackOpacity: Double = 1.0
    @State private var middleStackScale: CGFloat = 1.0
    
    private let languages = ["Japanese", "Spanish", "Russian", "Hindi"]
    private let traits = [
        ("Grammar", "doc.text"),
        ("Comprehension", "brain.head.profile"),
        ("Vocabulary", "books.vertical"),
        ("Pronunciation", "waveform")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top VStack - 20% Height (Fixed)
                VStack {
                    // Language Buttons
                    HStack(spacing: 12) {
                        ForEach(0..<languages.count, id: \.self) { index in
                            Button(action: {
                                selectedLanguage = index
                            }) {
                                Text(languages[index])
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedLanguage == index ? .black : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedLanguage == index ? Color.white : Color.clear)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                            }
                            .buttonPressAnimation() // Centralized animation
                            .scaleEffect(languageButtonScale[index])
                            .opacity(languageButtonOpacity[index])
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.20)
                
                // Middle VStack - 60% Height (Fixed)
                VStack {
                    // Trait Circles in 2x2 Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                        ForEach(0..<traits.count, id: \.self) { index in
                            VStack(spacing: 8) {
                                // Trait Circle with Progress Ring
                                ZStack {
                                    // Background circle
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    // Progress ring
                                    Circle()
                                        .trim(from: 0, to: getProgressValue(for: index))
                                        .stroke(Color.white, lineWidth: 4)
                                        .frame(width: 80, height: 80)
                                        .rotationEffect(.degrees(-90))
                                        .scaleEffect(progressScale[index])
                                        .opacity(progressOpacity[index])
                                    
                                    // Icon
                                    Image(systemName: traits[index].1)
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(traitCircleScale[index])
                                .opacity(traitCircleOpacity[index])
                                
                                // Trait Label
                                Text(traits[index].0)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .scaleEffect(traitLabelScale[index])
                                    .opacity(traitLabelOpacity[index])
                                
                                // Progress Percentage
                                Text("\(Int(getProgressValue(for: index) * 100))%")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .scaleEffect(progressScale[index])
                                    .opacity(progressOpacity[index])
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.80)
                .scaleEffect(middleStackScale)
                .opacity(middleStackOpacity)
            }
        }
        .onAppear {
            startInitialAnimation()
        }
    }
    
    private func startInitialAnimation() {
        // Language Buttons: Staggered entrance (0.3s base + stagger)
        for i in 0..<languages.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                    languageButtonScale[i] = 1.0
                    languageButtonOpacity[i] = 1.0
                }
            }
        }
        
        // Trait Circles: Staggered entrance (0.4s base + stagger)
        for i in 0..<traits.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                    traitCircleScale[i] = 1.0
                    traitCircleOpacity[i] = 1.0
                }
            }
        }
        
        // Trait Labels: Staggered entrance (0.5s base + stagger)
        for i in 0..<traits.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                    traitLabelScale[i] = 1.0
                    traitLabelOpacity[i] = 1.0
                }
            }
        }
        
        // Progress Rings: Staggered entrance (0.7s base + stagger)
        for i in 0..<traits.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                    progressScale[i] = 1.0
                    progressOpacity[i] = 1.0
                }
            }
        }
    }
    
    private func getProgressValue(for index: Int) -> CGFloat {
        let progressValues: [CGFloat] = [0.85, 0.72, 0.68, 0.91] // Different progress for each trait
        return progressValues[index]
    }
}

#Preview {
    LanguageProgressView()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
