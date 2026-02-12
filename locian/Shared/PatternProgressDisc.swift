import SwiftUI

/// A circular disc that shows pattern mastery progress with a clockwise green sweep
struct PatternProgressDisc: View {
    let mastery: Double // 0.0 to 1.0
    let isActive: Bool // true = pink background, false = white background
    let size: CGFloat = 16
    
    var body: some View {
        ZStack {
            // Background disc (white or pink) - full circle
            Circle()
                .fill(isActive ? CyberColors.neonPink : Color.white)
                .frame(width: size, height: size)
            
            // Green progress sweep (clockwise from top) - overlays on top
            Circle()
                .trim(from: 0, to: min(mastery / 0.85, 1.0)) // 85% mastery = full circle
                .fill(Color.green)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90)) // Start from top
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
