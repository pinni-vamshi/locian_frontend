//
//  OnboardingContainerView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct OnboardingContainerView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var currentPage = 0
    @State private var isPermissionsReady = false // Track permission status
    
    // Neon Colors
    private let neonPink = ThemeColors.secondaryAccent
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Content
            getMiddleContent(for: currentPage)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .id(currentPage) 
            
            // Fixed Bottom Footer
            VStack(spacing: 20) {
                // Pagination
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        if index == currentPage {
                            Rectangle().fill(neonPink).frame(width: 24, height: 4)
                        } else {
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 24, height: 4)
                        }
                    }
                }
                
                // Action Button
                Button(action: nextPage) {
                    HStack {
                        Spacer()
                        Text(currentPage == 3 ? localizationManager.string(.letsStart) : localizationManager.string(.continueText))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .tracking(3)
                        Spacer()

                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .background(canProceed ? neonPink : Color.gray.opacity(0.3)) // Disable visual
                }
                .disabled(!canProceed) // Disable interaction
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                    .frame(height: 150)
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .animation(.easeInOut(duration: 0.5), value: currentPage)
        .ignoresSafeArea()
    }
    
    private var canProceed: Bool {
        return true
    }
    
    @ViewBuilder
    private func getMiddleContent(for page: Int) -> some View {
        switch page {
        case 0: WelcomeView()
        case 1: BrainAwarenessView()
        case 2: LanguageInputsView()
        case 3: LanguageProgressView(isReady: $isPermissionsReady)
        default: WelcomeView()
        }
    }
    
    private func nextPage() {
        withAnimation {
            if currentPage < 3 {
                currentPage += 1
            } else {
                appState.completeOnboarding()
            }
        }
    }
}

#Preview {
    OnboardingContainerView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}
