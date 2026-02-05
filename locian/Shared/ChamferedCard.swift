//
//  ChamferedCard.swift
//  locian
//
//  Created for reusable tech-styled card components
//

import SwiftUI

struct ChamferedCard<Content: View>: View {
    let content: Content
    let color: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let chamferSize: CGFloat
    let cornerRadius: CGFloat
    
    init(color: Color = .gray.opacity(0.2), 
         borderColor: Color = .white.opacity(0.1), 
         borderWidth: CGFloat = 1,
         chamferSize: CGFloat = 20, 
         cornerRadius: CGFloat = 0,
         @ViewBuilder content: () -> Content) {
        self.color = color
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.chamferSize = chamferSize
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            ChamferedShape(chamferSize: chamferSize, cornerRadius: cornerRadius)
                .fill(color)
            
            ChamferedShape(chamferSize: chamferSize, cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
            
            content
        }
        // Allow the card to be shaped by its frame
        .contentShape(ChamferedShape(chamferSize: chamferSize, cornerRadius: cornerRadius))
    }
}

struct ChamferedShape: Shape {
    let chamferSize: CGFloat
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        let c = chamferSize
        
        // Start Top-Left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Top Edge to Top-Right
        path.addLine(to: CGPoint(x: w, y: 0))
        
        // Right Edge to Chamfer Start
        path.addLine(to: CGPoint(x: w, y: h - c))
        
        // Chamfer Cut
        path.addLine(to: CGPoint(x: w - c, y: h))
        
        // Bottom Edge to Bottom-Left
        path.addLine(to: CGPoint(x: 0, y: h))
        
        // Close path (Left Edge)
        path.closeSubpath()
        
        return path
    }
}
