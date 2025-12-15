//
//  SequentialLoadingView.swift
//  locian
//
//  Created for unified loading animation views
//

import SwiftUI

struct LoadingStep {
    let icon: String
    let words: [String]
    let iconAnimation: IconAnimation
    
    enum IconAnimation {
        case pulse
        case rotate
        case none
    }
}

struct SequentialLoadingView: View {
    let steps: [LoadingStep]
    let stepDuration: TimeInterval
    let selectedColor: Color
    
    @State private var currentStep: Int = 0
    @State private var iconScale: Double = 1.0
    @State private var iconRotation: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    init(
        steps: [LoadingStep],
        stepDuration: TimeInterval = 4.5,
        selectedColor: Color = Color(red: 0.0, green: 1.0, blue: 0.5)
    ) {
        self.steps = steps
        self.stepDuration = stepDuration
        self.selectedColor = selectedColor
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if currentStep < steps.count {
                let step = steps[currentStep]
                
                VStack(spacing: 0) {
                    // Top 45% - Icon
                    ZStack {
                        Color.clear
                        
                        Image(systemName: step.icon)
                            .font(.system(size: 120, weight: .regular))
                            .foregroundColor(selectedColor)
                            .scaleEffect(iconScale)
                            .rotationEffect(.degrees(iconRotation))
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: iconScale)
                    }
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                    
                    // Bottom 55% - Text
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(step.words.indices, id: \.self) { index in
                            Text(step.words[index])
                                .font(.system(size: calculateFontSize(for: step.words[index]), weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(textOpacity)
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            startAnimation()
        }
        .blockBackNavigation()
    }
    
    private func startAnimation() {
        guard currentStep < steps.count else { return }
        
        let step = steps[currentStep]
        
        // Reset animations
        iconScale = 0.8
        iconRotation = step.iconAnimation == .rotate ? -10 : 0
        textOpacity = 0
        
        // Animate icon pop-in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            iconScale = 1.0
            if step.iconAnimation == .rotate {
                iconRotation = 10
            }
        }
        
        // Animate text fade-in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.4)) {
                textOpacity = 1.0
            }
        }
        
        // Continuous icon animation based on type
        switch step.iconAnimation {
        case .pulse:
            startPulseAnimation()
        case .rotate:
            startRotateAnimation()
        case .none:
            break
        }
        
        // Move to next step after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
            fadeOutAndNext()
        }
    }
    
    private func fadeOutAndNext() {
        // Fade out current step
        withAnimation(.easeOut(duration: 0.3)) {
            textOpacity = 0
            iconScale = 0.8
        }
        
        // Move to next step
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentStep < steps.count - 1 {
                currentStep += 1
                startAnimation()
            } else {
                // Loop back to first step
                currentStep = 0
                startAnimation()
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            iconScale = 1.1
        }
    }
    
    private func startRotateAnimation() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            iconRotation = 360
        }
    }
    
    private func calculateFontSize(for text: String) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 40 // Account for padding
        let maxFontSize: CGFloat = 60
        let minFontSize: CGFloat = 20
        
        for fontSize in stride(from: maxFontSize, through: minFontSize, by: -2) {
            let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).size(withAttributes: attributes)
            
            if size.width <= screenWidth {
                return fontSize
            }
        }
        
        return minFontSize
    }
}

