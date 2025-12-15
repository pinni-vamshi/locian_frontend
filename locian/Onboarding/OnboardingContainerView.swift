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
    @State private var currentPage = 0
    @State private var headingOpacity: Double = 1.0
    @State private var descriptionOpacity: Double = 1.0
    @State private var headingScale: CGFloat = 1.0
    @State private var descriptionScale: CGFloat = 1.0
    @State private var middleStackOpacity: Double = 1.0
    @State private var middleStackScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top VStack - 20% Height (Fixed)
                VStack {
                    Text(getCurrentHeading())
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .scaleEffect(headingScale)
                        .opacity(headingOpacity)
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.20)
                
                // Middle VStack - 60% Height (Fixed)
                VStack {
                    getMiddleContent(for: currentPage)
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.60)
                .scaleEffect(middleStackScale)
                .opacity(middleStackOpacity)
                
                // Bottom VStack - 20% Height (Fixed)
                VStack(spacing: 8) {
                    if currentPage == 5 {
                        // Ready page - Show Login/Register button
                        Button(action: {
                            appState.completeOnboarding()
                        }) {
                            Text(languageManager.onboarding.loginOrRegister)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                        .buttonPressAnimation() // Centralized animation
                        .scaleEffect(descriptionScale)
                        .opacity(descriptionOpacity)
                    } else {
                        // Other pages - Show normal content
                        // Page number indicator
                        Text("\(currentPage + 1)\(languageManager.onboarding.pageIndicator)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .scaleEffect(descriptionScale)
                            .opacity(descriptionOpacity)
                        
                        Text(getCurrentDescription())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .scaleEffect(descriptionScale)
                            .opacity(descriptionOpacity)
                        
                        // Navigation instruction with arrows
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                                .scaleEffect(descriptionScale)
                                .opacity(descriptionOpacity)
                            
                            Text(languageManager.onboarding.tapToNavigate)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                                .scaleEffect(descriptionScale)
                                .opacity(descriptionOpacity)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                                .scaleEffect(descriptionScale)
                                .opacity(descriptionOpacity)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.20)
            }
        }
        .ignoresSafeArea()
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 30
                    let minimumDistance: CGFloat = 7
                    
                    if abs(value.translation.width) > minimumDistance {
                        if value.translation.width < -threshold && currentPage < 5 {
                            // Swipe left - next page
                            animateFluidTransition {
                                currentPage += 1
                            }
                        } else if value.translation.width > threshold && currentPage > 0 {
                            // Swipe right - previous page
                            animateFluidTransition {
                                currentPage -= 1
                            }
                        }
                    }
                }
        )
        .overlay(
            // Tap areas for navigation
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left tap area (previous page) - 40% of screen
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width * 0.4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if currentPage > 0 {
                                HapticFeedback.medium()
                                animateFluidTransition {
                                    currentPage -= 1
                                }
                            }
                        }
                    
                    // Middle area (no action) - 20% of screen
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width * 0.2)
                    
                    // Right tap area (next page) - 40% of screen
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width * 0.4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if currentPage < 5 {
                                HapticFeedback.medium()
                                animateFluidTransition {
                                    currentPage += 1
                                }
                            }
                        }
                }
            }
        )
    }
    
    private func animateFluidTransition(completion: @escaping () -> Void) {
        // Phase 1: Fade out and scale down (fluid exit)
        withAnimation(.easeInOut(duration: 0.4)) {
            headingOpacity = 0.0
            headingScale = 0.8
            descriptionOpacity = 0.0
            descriptionScale = 0.8
            middleStackOpacity = 0.0
            middleStackScale = 0.8
        }
        
        // Phase 2: Change content while invisible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
            
            // Phase 3: Fade in and scale up with bounce (fluid entrance)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
                headingOpacity = 1.0
                headingScale = 1.0
                descriptionOpacity = 1.0
                descriptionScale = 1.0
                middleStackOpacity = 1.0
                middleStackScale = 1.0
            }
        }
    }
    
    private func getCurrentHeading() -> String {
        switch currentPage {
        case 0: return languageManager.onboarding.locianHeading
        case 1: return languageManager.onboarding.awarenessHeading
        case 2: return languageManager.onboarding.inputsHeading
        case 3: return languageManager.onboarding.breakdownHeading
        case 4: return languageManager.onboarding.progressHeading
        case 5: return languageManager.onboarding.readyHeading
        default: return languageManager.onboarding.locianHeading
        }
    }
    
    private func getCurrentDescription() -> String {
        switch currentPage {
        case 0: return languageManager.onboarding.locianDescription
        case 1: return languageManager.onboarding.awarenessDescription
        case 2: return languageManager.onboarding.inputsDescription
        case 3: return languageManager.onboarding.breakdownDescription
        case 4: return languageManager.onboarding.progressDescription
        case 5: return languageManager.onboarding.readyDescription
        default: return languageManager.onboarding.locianDescription
        }
    }
    
    @ViewBuilder
    private func getMiddleContent(for page: Int) -> some View {
        switch page {
        case 0: // Welcome - Welcome view
            WelcomeView()
            
        case 1: // Awareness - Brain with pulsing rings
            BrainAwarenessView()
            
        case 2: // Inputs - Rotating language examples
            LanguageInputsView()
            
        case 3: // Analysis - Sentence breakdown
            AnimatedSentenceAnalysisView()
            
        case 4: // Progress - Language progress chart
            LanguageProgressView()
            
        case 5: // Ready - Get started button
            AnimatedReadyToStartView(appState: appState)
            
        default:
            WelcomeView()
        }
    }
}

#Preview {
    OnboardingContainerView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}
