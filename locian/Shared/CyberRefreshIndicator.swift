//
//  CyberRefreshIndicator.swift
//  locian
//
//  Created by vamshi krishna pinni on 16/01/26.
//

import SwiftUI

enum CyberRefreshState: Equatable {
    case idle
    case pulling(progress: Double)
    case loading
    case finishing
}

struct CyberRefreshIndicator: View {
    var state: CyberRefreshState
    var height: CGFloat
    var accentColor: Color = ThemeColors.primaryAccent
    
    // Animation States
    @State private var scanPosition: CGFloat = -1.0
    
    var body: some View {
        ZStack {
            // Background Vignette
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.8)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                ZStack {
                    if state != .idle {
                        // Always show LOCIAN text
                        Text("LOCIAN")
                            .font(.system(size: 100, weight: .black, design: .default))
                            .foregroundColor(.white)
                            .lineLimit(1) // Ensure single line
                            .fixedSize() // Prevent wrapping/truncation, allow bleed
                            .padding(.top, 20) // Move down a tiny bit from top
                            .opacity(textOpacity)
                            .scaleEffect(textScale)
                            .diagnosticBorder(.white, width: 0.5)
                    }
                }
                .diagnosticBorder(.blue.opacity(0.3), width: 1)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .diagnosticBorder(.cyan.opacity(0.3), width: 1)
        }
        .diagnosticBorder(.white.opacity(0.1), width: 1)
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    // MARK: - Computed Properties
    
    private var textOpacity: Double {
        switch state {
        case .idle: return 0
        case .pulling(let progress): return Double(progress)
        case .loading, .finishing: return 1.0
        }
    }
    
    private var textScale: CGFloat {
        switch state {
        case .idle: return 0.8
        case .pulling(let progress): return 0.8 + (0.2 * progress)
        case .loading, .finishing: return 1.0
        }
    }
}
