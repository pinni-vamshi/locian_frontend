import SwiftUI

/// A simple circular progress ring showing pattern mastery
struct PatternProgressDisc: View {
    let mastery: Double // 0.0 to 1.0
    let isActive: Bool // true = pink background, false = white background
    let size: CGFloat = 16
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(mastery / 0.85, 1.0)) // 85% mastery = full circle
                .stroke(
                    isActive ? CyberColors.neonPink : Color.green,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.easeInOut(duration: 0.5), value: mastery) // Smooth animation
        }
    }
}

/// Row of pattern progress discs showing all patterns in the lesson
struct PatternProgressRow: View {
    let patterns: [String] // Pattern IDs
    let currentPatternId: String
    let engine: LessonEngine
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(patterns, id: \.self) { patternId in
                let mastery = engine.getBlendedMastery(for: "\(patternId)-d0")
                let isActive = (patternId == currentPatternId)
                
                PatternProgressDisc(mastery: mastery, isActive: isActive)
            }
        }
    }
}
