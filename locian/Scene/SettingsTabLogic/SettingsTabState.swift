//
//  SettingsTabState.swift
//  locian
//

import SwiftUI
import Combine

class SettingsTabState: ObservableObject {
    @ObservedObject var appState: AppStateManager
    
    // Sub-Logic Controllers
    @Published var profile: ProfileLogic
    @Published var notifications: NotificationLogic
    @Published var language: LanguageLogic
    
    // UI Expansion States
    @Published var isLanguagePairsExpanded = false
    @Published var isAppLanguageExpanded = false
    @Published var isPreviouslyLearningExpanded = false
    @Published var isNotificationsExpanded = false
    @Published var isAccountExpanded = false
    
    // Refresh Logic
    @Published var pullRefreshState: CyberRefreshState = .idle
    @Published var scrollOffset: CGFloat = 0.0
    @Published var isRefreshFinished: Bool = false
    @Published var animateIn = false
    
    // Account Actions State
    @Published var isLoggingOut = false
    @Published var isDeletingAccount = false
    @Published var logoutErrorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppStateManager) {
        self.appState = appState
        self.profile = ProfileLogic(appState: appState)
        self.notifications = NotificationLogic(appState: appState)
        self.language = LanguageLogic(appState: appState)
        setupBindings()
        
        // Initial neural check
        language.checkNeuralStatus()
    }
    
    private func setupBindings() {
        // Forward updates from child logic objects to trigger SettingsView re-rendering
        language.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        profile.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        notifications.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        appState.$shouldFocusLanguagePairs
            .sink { [weak self] focus in
                if focus { self?.focusLanguagePairs() }
            }
            .store(in: &cancellables)
    }
    
    func focusLanguagePairs() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isLanguagePairsExpanded = true
            isAppLanguageExpanded = false
            isNotificationsExpanded = false
            isAccountExpanded = false
        }
        appState.shouldFocusLanguagePairs = false
    }
    
    func performLogout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        appState.logoutViaBackend { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoggingOut = false
                if success {
                    NotificationCenter.default.post(name: NSNotification.Name("UserDidLogOut"), object: nil)
                } else {
                    self?.logoutErrorMessage = error ?? "Logout failed"
                }
            }
        }
    }
    
    func performDeleteAccount() {
        isDeletingAccount = true
        appState.deleteAccount { [weak self] _, _ in
            DispatchQueue.main.async { self?.isDeletingAccount = false }
        }
    }
    
    func handleRefresh(offset: CGFloat) {
        if abs(self.scrollOffset - offset) > 0.5 { self.scrollOffset = offset }
        if isRefreshFinished {
            if offset < 10 {
                withAnimation(.spring()) {
                    pullRefreshState = .idle
                    isRefreshFinished = false
                }
            }
            return
        }
        if pullRefreshState == .loading || pullRefreshState == .finishing { return }
        
        if offset > 110 {
            pullRefreshState = .loading
            isRefreshFinished = false
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            language.checkNeuralStatus()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { self.pullRefreshState = .finishing }
                self.isRefreshFinished = true
            }
        } else if offset > 0 {
            pullRefreshState = .pulling(progress: Double(offset) / 110.0)
        } else {
            pullRefreshState = .idle
        }
    }
}
