//
//  ContentView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateManager.shared
    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingContainerView(appState: appState)
            } else if appState.isLoadingSession {
                LoadingView(appState: appState)
            } else if appState.isLoggedIn {
                MainTabView(appState: appState)
            } else {
                LoginView(appState: appState)
            }
        }
        .onAppear {
            if appState.hasCompletedOnboarding {
                appState.checkUserSession()
            }
            // Permission request removed to respect onboarding flow
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SessionExpired"))) { _ in
            // Perform local logout when session expires due to API errors
            appState.logoutLocalOnly()
        }
        // First Launch Language Selection Modal - Shows before onboarding
        .fullScreenCover(isPresented: $appState.showFirstLaunchLanguageModal) {
            FirstLaunchLanguageSelectionModal(appState: appState)
        }
        // Global Language Modal Sheet - Available from anywhere (Half Modal)
        .fullScreenCover(isPresented: $appState.showGlobalLanguageModal) {
            LanguageSelectionModal(appState: appState, mode: appState.languageSelectionMode)
                .interactiveDismissDisabled(!appState.hasValidLanguagePair())
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
        VStack(spacing: 30) {
            if appState.isOffline {
                // No Internet State
                Image(systemName: "wifi.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text(localizationManager.string(.noInternetConnection))
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                
                Button(localizationManager.string(.retry)) {
                    appState.checkUserSession()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(20)
                .buttonPressAnimation() // Centralized animation
                
                Button(action: {
                    appState.logoutLocalOnly()
                }) {
                    Text(languageManager.settings.logout)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .underline()
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Normal Loading State
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text(localizationManager.string(.loading))
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea()
    }
}

// MARK: - Scene View (Now using SceneView from Scene folder)

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
