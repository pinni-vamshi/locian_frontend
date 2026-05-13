//
//  CyberComponents.swift
//  locian
//
//  Created to match the "Stitch" design reference.
//  Dark, neon accents, terminal-like aesthetics.
//

import SwiftUI

struct CyberColors {
    static let neonPink = ThemeColors.secondaryAccent // Official System Pink
    static let neonCyan = ThemeColors.neonCyan
    static let neonYellow = ThemeColors.neonYellow
    static let darkSurface = ThemeColors.darkSurface
    static let textGray = ThemeColors.textGray
    
    // Additions for Feedback
    static let success = ThemeColors.success
    static let error = ThemeColors.error
    static let neonBlue = Color.blue.opacity(0.8)
    static let neonGreen = ThemeColors.neonGreen // Use central neon green
}




// MARK: - 5. Cyber Proceed Button (Redesign)
struct CyberProceedButton: View {
    let action: () -> Void
    var label: String = "ANSWER_CONFIRMED"
    var title: String = "PROCEED"
    var color: Color = .blue
    var systemImage: String = "arrow.right"
    var isEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 0) {
            // Text Content (Static)
            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.black.opacity(0.5))
                
                Text(title.uppercased())
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // The actual button (The Icon part)
            LocianButton(
                action: action,
                backgroundColor: .black,
                foregroundColor: color,
                shadowColor: color,
                shadowOffset: 3.0,
                borderWidth: 0.0,
                borderColor: .clear
            ) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .black))
                    .frame(width: 25, height: 25)
            }
            .disabled(!isEnabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ChamferedShape(chamferSize: 12, cornerRadius: 0)
                .fill(title == "CHECK" ? Color.white : color)
        )
        .padding(.horizontal)
    }
}
// MARK: - 7. Grid Pattern Decoration
struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 20
        
        for x in stride(from: 0, through: rect.width, by: step) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        for y in stride(from: 0, through: rect.height, by: step) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

// MARK: - 8. Tech Frame Border
struct TechFrameBorder: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Corners
            corner(at: .topLeading)
            corner(at: .topTrailing)
            corner(at: .bottomLeading)
            corner(at: .bottomTrailing)
            
            // Sub-borders
            Rectangle()
                .stroke(isSelected ? .black.opacity(0.1) : Color.white.opacity(0.05), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private func corner(at position: Alignment) -> some View {
        let size: CGFloat = 8
        let color = isSelected ? .black : CyberColors.neonCyan
        
        ZStack {
            // Uniform L-shaped corners for all 4 positions
            Rectangle()
                .fill(color)
                .frame(width: 2, height: size)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position)
            Rectangle()
                .fill(color)
                .frame(width: size, height: 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position)
        }
    }
}

// MARK: - 9. Cyber Grid Background
struct CyberGridBackground: View {
    var body: some View {
        GridPattern()
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
            .ignoresSafeArea()
    }
}



// MARK: - 13. Data Manifestation Components
struct TypingTextView: View {
    let text: String
    let isTyping: Bool
    @State private var displayedText: String = ""
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text).opacity(0)
            Text(displayedText)
        }
        .onChange(of: isTyping) { _, newValue in
            if newValue {
                typeOut()
            }
        }
    }
    
    private func typeOut() {
        displayedText = ""
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                displayedText.append(character)
            }
        }
    }
}
