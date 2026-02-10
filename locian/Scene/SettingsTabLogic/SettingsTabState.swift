//
//  SettingsTabState.swift
//  locian
//

import SwiftUI
import Combine

class SettingsTabState: ObservableObject {
    @ObservedObject var appState: AppStateManager
    
    // MARK: - Sub-Logic Types
    struct NeuralStatus {
        let state: String // LOADING, LOADED, DOWN, FAILED
        let mode: String  // CONTEXTUAL, STATIC, LEVENSHTEIN (rendered as REGULAR)
    }
    
    // MARK: - Logic Properties
    @Published var neuralStatuses: [String: NeuralStatus] = [:]
    let professionOptions = ProfessionMapping.allProfessions
    
    // Presentation States (Moved from View)
    @Published var showingLanguageModal = false
    @Published var showingLogoutAlert = false
    @Published var showingDeleteAlert = false
    
    // MARK: - Computed Properties for View
    var defaultPair: LanguagePair? {
        appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
    }
    
    var defaultTargetLanguageName: String {
        guard let pair = defaultPair else { return "UNKNOWN" }
        return TargetLanguageMapping.shared.getDisplayNames(for: pair.target_language).english.uppercased()
    }
    
    var neuralLanguageCodes: [String] {
        var codes = [String]()
        let nativeCode = appState.nativeLanguage
        if !nativeCode.isEmpty { codes.append(nativeCode) }
        
        let targetPairs = appState.userLanguagePairs.filter { $0.target_language.lowercased() != nativeCode.lowercased() }
        codes.append(contentsOf: targetPairs.map { $0.target_language })
        return codes
    }
    
    // MARK: - UI Expansion States
    @Published var isLanguagePairsExpanded = false
    @Published var isAppLanguageExpanded = false
    @Published var isPreviouslyLearningExpanded = false
    @Published var isNotificationsExpanded = false
    @Published var isAccountExpanded = false
    
    // MARK: - Refresh Logic
    @Published var pullRefreshState: CyberRefreshState = .idle
    @Published var scrollOffset: CGFloat = 0.0
    @Published var isRefreshFinished: Bool = false
    @Published var animateIn = false
    
    // MARK: - Account Actions State
    @Published var isLoggingOut = false
    @Published var isDeletingAccount = false
    @Published var logoutErrorMessage: String? = nil
    
    // MARK: - Personalization Refresh UI State
    @Published var isRefreshingPersonalization = false
    @Published var showRefreshSuccess = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppStateManager) {
        self.appState = appState
        setupBindings()
        
        // Initial neural check
        checkNeuralStatus()
    }
    
    private func setupBindings() {
        // Automatically refresh neural status whenever anything changes in appState
        appState.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkNeuralStatus()
            }
            .store(in: &cancellables)

        appState.$shouldFocusLanguagePairs
            .sink { [weak self] focus in
                if focus { self?.focusLanguagePairs() }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Neural Monitoring Logic
    
    func checkNeuralStatus() {
        var codes = Set<String>()
        
        // 1. Add Native Language
        let native = appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        if !native.isEmpty { codes.insert(native) }
        
        // 2. Add all Target Languages from pairs
        appState.userLanguagePairs.forEach { pair in
            let target = pair.target_language.trimmingCharacters(in: .whitespacesAndNewlines)
            if !target.isEmpty { codes.insert(target) }
        }
        
        if codes.isEmpty { return }
        
        // Use the centralized EmbeddingService for all checks
        for code in codes {
            let mode = EmbeddingService.getAvailableMode(for: code)
            let isAvailable = EmbeddingService.isModelAvailable(for: code)
            
            if isAvailable {
                neuralStatuses[code] = NeuralStatus(state: "LOADED", mode: mode)
            } else {
                // If not available, we trigger a background download if not already tracked
                if neuralStatuses[code] == nil || neuralStatuses[code]?.state == "DOWN" {
                    neuralStatuses[code] = NeuralStatus(state: "LOADING", mode: mode)
                    EmbeddingService.downloadModel(for: code) { _ in
                         // The periodic binding update will trigger another checkNeuralStatus() later
                    }
                }
            }
        }
    }
    
    // MARK: - UI Interaction Methods
    
    func focusLanguagePairs() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isLanguagePairsExpanded = true
            isAppLanguageExpanded = false
            isNotificationsExpanded = false
            isAccountExpanded = false
        }
        appState.shouldFocusLanguagePairs = false
    }
    
    func updateLevel(pair: LanguagePair, to level: String) {
        appState.updateLanguagePairLevel(nativeLanguage: pair.native_language, targetLanguage: pair.target_language, newLevel: level) { _ in }
    }
    
    func setDefault(pair: LanguagePair, completion: @escaping () -> Void) {
        appState.setDefaultLanguagePair(nativeLanguage: pair.native_language, targetLanguage: pair.target_language) { [weak self] _ in
            self?.appState.loadAvailableLanguagePairs { _ in completion() }
        }
    }
    
    func deletePair(pair: LanguagePair, completion: @escaping () -> Void) {
        appState.deleteLanguagePair(nativeLanguage: pair.native_language, targetLanguage: pair.target_language) { _ in completion() }
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
    
    // MARK: - Context Personalization
    
    func refreshPersonalization(completion: @escaping (Bool) -> Void) {
        guard !isRefreshingPersonalization else { return }
        
        isRefreshingPersonalization = true
        showRefreshSuccess = false
        
        // Use dedicated service
        RefreshContextService.refreshContext { [weak self] result in
            DispatchQueue.main.async {
                self?.isRefreshingPersonalization = false
                
                switch result {
                case .success(let response):
                    if response.success {
                        print("✅ [SettingsTabState] Context refresh successful")
                        self?.showRefreshSuccess = true
                        
                        // Hide success checkmark after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self?.showRefreshSuccess = false
                            }
                        }
                        
                        completion(true)
                    } else {
                        print("⚠️ [SettingsTabState] Context refresh returned failure: \(response.message ?? "Unknown")")
                        completion(false)
                    }
                case .failure(let error):
                    print("❌ [SettingsTabState] Context refresh failed: \(error.localizedDescription)")
                    completion(false)
                }
            }
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
            checkNeuralStatus()
            
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
    
    // MARK: - Color Helpers
    
    func statusColor(_ status: String?) -> Color {
        switch status {
        case "LOADED": return .green
        case "FAILED": return .red
        case "DOWN": return .blue
        default: return .gray
        }
    }
    
    func modeColor(_ mode: String) -> Color {
        switch mode {
        case "CONTEXTUAL": return .cyan
        case "STATIC": return Color(white: 0.6)
        default: return .yellow
        }
    }
}
