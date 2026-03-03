import SwiftUI
import Combine
import Foundation

enum LanguageSelectionFlowMode: Identifiable {
    case addLearning
    case changeNative
    case changeUserLanguage
    case onboarding
    
    var id: Self { self }
}

// MARK: - AppStateManager Language Extension
extension AppStateManager {
    
    // MARK: - UI Trigger Methods
    func showLanguageModal(mode: LanguageSelectionFlowMode = .addLearning) {
        if mode == .changeUserLanguage || mode == .changeNative {
            self.shouldShowNativeLanguageModal = true
        } else {
            self.shouldShowTargetLanguageModal = true
        }
    }
    
    func hideLanguageModal() {
        self.shouldShowNativeLanguageModal = false
        self.shouldShowTargetLanguageModal = false
    }
    
    // MARK: - App Flow Orchestration
    
    /// Entry point for checking language state at startup or login
    func checkLanguagePairsAndShowModalIfNeeded() {
        guard !shouldShowNativeLanguageModal && !shouldShowTargetLanguageModal else { return }
        
        NativeLanguageLogic.shared.setNativeLanguageFromPhone { [weak self] success in
            if success {
                self?.checkTargetLanguagesAndShowModalIfNeeded()
            }
        }
    }
    
    private func checkTargetLanguagesAndShowModalIfNeeded() {
        if hasValidLanguagePair() { return }
        
        TargetLanguageLogic.shared.loadTargetLanguages { [weak self] _ in
            DispatchQueue.main.async {
                if !(self?.hasValidLanguagePair() ?? false) {
                    self?.showLanguageModal(mode: .addLearning)
                }
            }
        }
    }
    
    // MARK: - State Helpers
    
    func hasValidLanguagePair() -> Bool {
        guard !userLanguagePairs.isEmpty else { return false }
        let trimmedNative = nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNative.isEmpty else { return false }
        
        return userLanguagePairs.contains { ($0.target_language.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty == false }
    }
    
    /// Returns the active language pair for display, or a placeholder if none exists.
    /// Centralizes the fallback logic to avoid hardcoding in Views.
    func getDisplayLanguagePair() -> LanguagePair {
        if let pair = userLanguagePairs.first(where: { $0.is_default }) ?? userLanguagePairs.first {
            return pair
        }
        
        // Placeholder
        let native = nativeLanguage.isEmpty ? "English" : nativeLanguage
        // "ADD LANGUAGE" is a placeholder key. In a real app, this might be localized.
        return LanguagePair(
            native_language: native,
            target_language: "ADD LANGUAGE",
            is_default: true,
            user_level: "Beginner",
            practice_dates: []
        )
    }
    
    // MARK: - API Wrappers (Delegated to Domain Logic)
    
    func loadAvailableLanguagePairs(completion: @escaping (Bool) -> Void) {
        NativeLanguageLogic.shared.loadNativeLanguage { nativeSuccess in
            TargetLanguageLogic.shared.loadTargetLanguages { targetSuccess in
                completion(nativeSuccess && targetSuccess)
            }
        }
    }
    
    func addLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        TargetLanguageLogic.shared.addLanguagePair(nativeLanguage: nativeLanguage, targetLanguage: targetLanguage, completion: completion)
    }
    
    func updateNativeLanguage(newNativeLanguage: String, completion: @escaping (Bool) -> Void) {
        NativeLanguageLogic.shared.updateNativeLanguage(newNativeLanguage: newNativeLanguage, completion: completion)
    }
    
    func updateLanguagePairLevel(nativeLanguage: String, targetLanguage: String, newLevel: String, completion: @escaping (Bool) -> Void) {
        TargetLanguageLogic.shared.updateLanguagePairLevel(nativeLanguage: nativeLanguage, targetLanguage: targetLanguage, newLevel: newLevel, completion: completion)
    }
    
    func setDefaultLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        TargetLanguageLogic.shared.setDefaultLanguagePair(nativeLanguage: nativeLanguage, targetLanguage: targetLanguage, completion: completion)
    }
    
    func deleteLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        TargetLanguageLogic.shared.deleteLanguagePair(nativeLanguage: nativeLanguage, targetLanguage: targetLanguage, completion: completion)
    }
}
