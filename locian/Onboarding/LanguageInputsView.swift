//
//  LanguageInputsView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct LanguageInputsView: View {
    
    @State private var itemsVisible = false
    
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    // Neon Colors
    // Neon Colors
    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // FIXED HEADER SECTION
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.string(.module03))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            Text(localizationManager.string(.notJustMemorization))
                                .font(.system(size: 36, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    // Philosophy Bar
                    HStack(spacing: 12) {
                        Rectangle().fill(neonCyan).frame(width: 40, height: 2)
                        Text(localizationManager.string(.philosophy))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(neonCyan)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    
                    // Body Text
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.string(.locianTeaches))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            Text(localizationManager.string(.think))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(neonPink)
                            Text(" " + localizationManager.string(.inTargetLanguage))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20) // Add some spacing before scroll area
                }
                
                // SCROLLABLE CONTENT SECTION
                ScrollView {
                    VStack(spacing: 16) {
                        checklistCard(
                            iconColor: neonCyan,
                            title: localizationManager.string(.patternBasedLearning),
                            desc: localizationManager.string(.patternBasedDesc),
                            delay: 0.2
                        )
                        
                        checklistCard(
                            iconColor: neonPink,
                            title: localizationManager.string(.situationalIntelligence),
                            desc: localizationManager.string(.situationalDesc),
                            delay: 0.4
                        )
                        
                        checklistCard(
                            iconColor: neonCyan,
                            title: localizationManager.string(.adaptiveDrills),
                            desc: localizationManager.string(.adaptiveDesc),
                            delay: 0.6
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    Spacer().frame(height: 120) // Bottom padding for global footer
                }
            }
        }
        .onAppear {
            itemsVisible = true
        }
    }
    
    @ViewBuilder
    func checklistCard(iconColor: Color, title: String, desc: String, delay: Double) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Line
            Rectangle().fill(iconColor).frame(width: 2)
            
            // Check
            Image(systemName: "checkmark.circle")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(iconColor)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(desc)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color(white: 0.05))
        .opacity(itemsVisible ? 1.0 : 0.0)
        .offset(x: itemsVisible ? 0 : 50)
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure full width and left alignment
        .animation(.spring(dampingFraction: 0.8).delay(delay), value: itemsVisible)
    }
}

#Preview {
    LanguageInputsView()
        .preferredColorScheme(.dark)
}

