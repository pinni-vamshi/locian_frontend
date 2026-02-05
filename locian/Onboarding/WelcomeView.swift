//
//  WelcomeView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct WelcomeView: View {
    
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    // Neon Colors
    // Neon Colors
    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: Header
                HStack {
                    Text("Locian")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // MARK: Separator
                Rectangle()
                    .fill(
                        LinearGradient(colors: [neonPink, .clear], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(height: 2)
                    .padding(.top, 20)
                
                Spacer()
                
                // MARK: Diamond Logo
                ZStack {
                    // Outer glow
                    Rectangle()
                        .stroke(neonPink, lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(45))
                        .shadow(color: neonPink.opacity(0.6), radius: 20, x: 0, y: 0)
                    
                    // Inner elements
                    Text("文A")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(neonPink)
                    
                    // Small cyan dot accent
                    Rectangle()
                        .fill(neonCyan)
                        .frame(width: 8, height: 8)
                        .offset(x: 45, y: -45) // Top right corner relative to center
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                Text(localizationManager.string(.lessonEngine))
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(neonPink)
                    .tracking(2)
                    .padding(.top, 60)
                    .opacity(logoOpacity)
                
                Spacer()
                
                // MARK: Main Text
                VStack(spacing: 12) {
                    Text(localizationManager.string(.fromWhereYouStand))
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(localizationManager.string(.toEveryWord))
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(neonCyan)
                        .padding(.vertical, 8)
                    
                    Text(localizationManager.string(.everyWord))
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(neonPink)
                    
                    Text(localizationManager.string(.youNeed))
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(neonPink)
                } // End of VStack
                 .opacity(textOpacity)
                
                Spacer()
                
                // Content gets bottom padding from global footer
                Spacer().frame(height: 120)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
