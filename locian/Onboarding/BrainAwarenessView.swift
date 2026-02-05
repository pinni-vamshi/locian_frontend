//
//  BrainAwarenessView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct BrainAwarenessView: View {

    @State private var radarScale: CGFloat = 0.5
    @State private var radarOpacity: Double = 0.0
    @State private var cardsOffset: CGFloat = 100
    @State private var cardsOpacity: Double = 0.0
    
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    // Neon Colors
    // Neon Colors
    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView()
                
                titleView()
                
                radarView()
                
                ScrollView {
                    VStack(spacing: 0) {
                        cardsView()
                        
                        Spacer()
                        
                        Spacer().frame(height: 120) // Bottom padding for global footer
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                radarScale = 1.0
                radarOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                cardsOffset = 0
                cardsOpacity = 1.0
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
    
    @ViewBuilder
    private func radarView() -> some View {
        ZStack {
            // Ring 1 (Inner) - Radius 60 (Diameter 120)
            Circle()
                .stroke(LinearGradient(colors: [neonCyan.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                .frame(width: 120, height: 120)
            
            // Ring 2 (Middle) - Radius 90 (Diameter 180)
            Circle()
                .stroke(LinearGradient(colors: [neonCyan.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                .frame(width: 180, height: 180)
            
            // Ring 3 (Outer) - Radius 120 (Diameter 240)
            Circle()
                .stroke(LinearGradient(colors: [neonCyan.opacity(0.15), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                .frame(width: 240, height: 240)
            
            // Planet/Grid Icon
            Image(systemName: "globe")
                .font(.system(size: 30))
                .foregroundColor(neonCyan)
            
            // Place Icons with Black Backgrounds
            
            // Home (Ring 1 - Top)
            Image(systemName: "house.fill")
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(6)
                .background(Circle().fill(neonPink))
                .offset(y: -60)
            
            // School (Ring 2 - Bottom Right)
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(6)
                .background(Circle().fill(neonCyan))
                .offset(x: 64, y: 64)
                
            // Park (Ring 2 - Bottom Left)
            Image(systemName: "tree.fill")
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(6)
                .background(Circle().fill(neonCyan))
                .offset(x: -64, y: 64)
        }
        .frame(height: 280)
        .scaleEffect(radarScale)
        .opacity(radarOpacity)
    }
    
    @ViewBuilder
    private func titleView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(localizationManager.string(.your))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
            + Text(" " + localizationManager.string(.places))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(neonCyan)
            
            Text(localizationManager.string(.your))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
            + Text(" " + localizationManager.string(.lessons))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(neonPink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    
    @ViewBuilder
    private func cardsView() -> some View {
        VStack(spacing: 12) {
            // Card 1
            HStack(spacing: 16) {
                Rectangle().fill(neonPink).frame(width: 4)
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(neonPink)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.string(.nearbyCafes))
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                    + Text(localizationManager.string(.unlockOrderFlow))
                        .foregroundColor(neonPink)
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(localizationManager.string(.modules))
                        .foregroundColor(neonPink)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
            }
            .padding(16)
            .background(Color(white: 0.1))
            
            // Card 2
            HStack(spacing: 16) {
                Rectangle().fill(neonCyan).frame(width: 4)
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(neonCyan)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.string(.activeHubs))
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                    + Text(localizationManager.string(.synthesizeGym))
                        .foregroundColor(neonCyan)
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(localizationManager.string(.vocabulary))
                        .foregroundColor(neonCyan)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
            }
            .padding(16)
            .background(Color(white: 0.1))
            
            // Card 3
            HStack(spacing: 16) {
                Rectangle().fill(Color.gray).frame(width: 4)
                Image(systemName: "safari.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
                
                Text(localizationManager.string(.locationOpportunity))
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(16)
            .background(Color(white: 0.1))
        }
        .padding(.horizontal, 24)
        .offset(y: cardsOffset)
        .opacity(cardsOpacity)
    }
    
}

#Preview {
    BrainAwarenessView()
        .preferredColorScheme(.dark)
}
