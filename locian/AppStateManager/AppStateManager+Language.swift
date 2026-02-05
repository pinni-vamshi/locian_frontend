import SwiftUI
import Combine

enum LanguageSelectionFlowMode: Identifiable {
    case addLearning
    case changeNative
    case changeUserLanguage
    case onboarding
    
    var id: Self { self }
}

class LanguageMapping {
    static let shared = LanguageMapping()
    private init() {}
    
    let availableLanguageCodes = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko", "hi", "ar", "tr", "pl", "nl", "sv", "no", "da", "fi", "el", "he"]
    
    private let languageNames: [String: (english: String, native: String)] = [
        "en": ("English", "English"), "es": ("Spanish", "Español"), "fr": ("French", "Français"),
        "de": ("German", "Deutsch"), "it": ("Italian", "Italiano"), "pt": ("Portuguese", "Português"),
        "ru": ("Russian", "Русский"), "zh": ("Chinese", "中文"), "ja": ("Japanese", "日本語"),
        "ko": ("Korean", "한국어"), "hi": ("Hindi", "हिन्दी"), "ar": ("Arabic", "العربية"),
        "tr": ("Turkish", "Türkçe"), "pl": ("Polish", "Polski"), "nl": ("Dutch", "Nederlands"),
        "sv": ("Swedish", "Svenska"), "no": ("Norwegian", "Norsk"), "da": ("Danish", "Dansk"),
        "fi": ("Finnish", "Suomi"), "el": ("Greek", "Ελληνικά"), "he": ("Hebrew", "עברית")
    ]
    
    func isValidLanguageCode(_ code: String) -> Bool { availableLanguageCodes.contains(code.lowercased()) }
    func getDisplayNames(for code: String) -> (english: String, native: String) {
        let normalized = code.lowercased()
        return languageNames[normalized] ?? (normalized.uppercased(), normalized.uppercased())
    }
    func getLanguageCodeForAPI(for input: String) -> String {
        if isValidLanguageCode(input) { return input.lowercased() }
        for (code, names) in languageNames {
            if names.english.lowercased() == input.lowercased() || names.native.lowercased() == input.lowercased() { return code }
        }
        return input.lowercased()
    }
    func normalizeAndValidateLanguage(_ input: String) -> String? {
        let code = getLanguageCodeForAPI(for: input)
        return isValidLanguageCode(code) ? code : nil
    }
    func validateLanguagePair(nativeLanguage: String, targetLanguage: String) -> (isValid: Bool, nativeCode: String?, targetCode: String?) {
        let nCode = normalizeAndValidateLanguage(nativeLanguage)
        let tCode = normalizeAndValidateLanguage(targetLanguage)
        return (isValid: nCode != nil && tCode != nil, nativeCode: nCode, targetCode: tCode)
    }
}

extension AppStateManager {
    // MARK: - Language Methods
    func showLanguageModal(mode: LanguageSelectionFlowMode = .addLearning) {
        
        guard !showGlobalLanguageModal else {
            return
        }
        
        
        languageSelectionMode = mode
        showGlobalLanguageModal = true
        
    }
    
    func hideLanguageModal() {
        showGlobalLanguageModal = false
        languageSelectionMode = .addLearning
    }
    
    func checkLanguagePairsAndShowModalIfNeeded() {
        // Don't show if already showing a modal
        guard !showGlobalLanguageModal else {
            return
        }
        
        // STEP 1: Set app interface language to device language (LocalizationManager)
        // This is already handled by the system - app follows device language
        
        // STEP 2: Auto-set native language to phone language via API
        setNativeLanguageFromPhone { [weak self] success in
            guard let self = self else { return }
            
            // Only proceed if native was set successfully
            if success {
                // STEP 3: Check target languages
                self.checkTargetLanguagesAndShowModalIfNeeded()
            }
            // If failed, native is not set - user will see empty in settings
        }
    }
    
    // MARK: - Auto-Set Native Language from Phone
    
    /// Sets native language to the phone's language automatically
    /// ONLY updates local state on API SUCCESS
    private func setNativeLanguageFromPhone(completion: @escaping (Bool) -> Void) {
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // Get phone language code
        let phoneLanguageCode: String
        if #available(iOS 16.0, *) {
            phoneLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            phoneLanguageCode = Locale.current.languageCode ?? "en"
        }
        
        // Validate phone language code
        let languageMapping = LanguageMapping.shared
        let validCode = languageMapping.normalizeAndValidateLanguage(phoneLanguageCode) ?? "en"
        
        // Check if already set to this language (from cache/UserDefaults)
        if !nativeLanguage.isEmpty && nativeLanguage == validCode {
            completion(true)
            return
        }
        
        // Call API to SET native language
        let request = GetNativeLanguageRequest(session_token: token, native_language: validCode)
        
        LanguageAPIManager.shared.getNativeLanguage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // ONLY set native language on API success
                    if response.success, let data = response.data, let nativeLang = data.native_language, !nativeLang.isEmpty {
                        self?.nativeLanguage = nativeLang
                        completion(true)
                    } else {
                        // API returned but no valid data - don't set anything
                        completion(false)
                    }
                case .failure:
                    // API failed - don't set anything locally
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Check Target Languages and Show Modal
    
    /// Checks if user has target languages, shows modal if empty
    /// Flow: 1) Check device cache first, 2) If not found, call API, 3) If still not found, show modal
    private func checkTargetLanguagesAndShowModalIfNeeded() {
        // STEP 1: Check cache first (userLanguagePairs from UserDefaults)
        if hasValidLanguagePair() {
            // Already have valid targets in cache - done
            return
        }
        
        // STEP 2: Not in cache - call API to check
        loadTargetLanguages { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // STEP 3: After API call, check again
                if self.hasValidLanguagePair() {
                    // Found in API - done
                    return
                }
                
                // STEP 4: Not in cache AND not in API - ask user to set
                self.showLanguageModal(mode: .addLearning)
            }
        }
    }
    
    // MARK: - Language Validation Helper
    
    /// Check if user has at least one valid language pair
    func hasValidLanguagePair() -> Bool {
        // Check if we have at least one language pair
        guard !userLanguagePairs.isEmpty else {
            return false
        }
        
        // Check if native language is set and valid
        let trimmedNative = nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNative.isEmpty else {
            return false
        }
        
        // Check if at least one target language exists
        let hasTarget = userLanguagePairs.contains { pair in
            !pair.target_language.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return hasTarget
    }
    
    // MARK: - Language Validation & Modal Flow

    /// Main entry point: Checks languages and shows modals if needed
    private func checkLanguagesAndShowModalIfNeeded(completion: @escaping (Bool) -> Void) {
        // Prevent multiple simultaneous checks
        guard !isLoadingLanguages else {
            completion(false)
            return
        }

        // Global offline guard
        if isOffline {
            authError = "No internet connection. Please try again."
            showAuthError = true
            completion(false)
            return
        }

        // STEP 1: Check native language cache first
        let languageMapping = LanguageMapping.shared
        let hasNativeInCache = checkNativeLanguage(languageMapping: languageMapping)

        if !hasNativeInCache {
            // Native not in cache - call native API
            loadNativeLanguage { nativeSuccess in
                DispatchQueue.main.async {
                    // After native API call, check if valid data found
                    let hasNative = self.checkNativeLanguage(languageMapping: languageMapping)

                    if !hasNative {
                        // No valid native data found - show native modal
                        self.showLanguageModal(mode: .changeUserLanguage)
                        completion(false)
                    } else {
                        // Native found - now check target
                        self.checkTargetLanguageFlow(languageMapping: languageMapping, completion: completion)
                    }
                }
            }
            return
        }

        // Native found in cache - now check target
        checkTargetLanguageFlow(languageMapping: languageMapping, completion: completion)
    }

    private func checkTargetLanguageFlow(languageMapping: LanguageMapping, completion: @escaping (Bool) -> Void) {
        // STEP 2: Check target language cache
        let hasTargetInCache = checkTargetLanguage(languageMapping: languageMapping)

        if !hasTargetInCache {
            // Target not in cache - call target API
            loadTargetLanguages { targetSuccess in
                DispatchQueue.main.async {
                    // After target API call, check if valid data found
                    let hasTarget = self.checkTargetLanguage(languageMapping: languageMapping)

                    if !hasTarget {
                        // No valid target data found - show target modal
                        self.showLanguageModal(mode: .addLearning)
                        completion(false)
                    } else {
                        // Both found - no modal needed
                        completion(true)
                    }
                }
            }
            return
        }

        // Both found in cache - no modal needed
        completion(true)
    }

    /// Checks if native language exists and is valid
    private func checkNativeLanguage(languageMapping: LanguageMapping) -> Bool {
        let nativeCode = nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if native is not empty and is valid
        guard !nativeCode.isEmpty else {
            return false
        }

        // Validate using centralized mapping
        let isValid = languageMapping.isValidLanguageCode(nativeCode)
        return isValid
    }

    /// Checks if default target language exists and is valid
    private func checkTargetLanguage(languageMapping: LanguageMapping) -> Bool {
        // Find default language pair
        guard let defaultPair = userLanguagePairs.first(where: { $0.is_default }) else {
            return false
        }

        let targetLanguage = defaultPair.target_language.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if target is not empty
        guard !targetLanguage.isEmpty else {
            return false
        }

        // Normalize and validate - handles both codes and names
        guard let normalizedCode = languageMapping.normalizeAndValidateLanguage(targetLanguage) else {
            return false
        }

        // Validate using centralized mapping
        let isValid = languageMapping.isValidLanguageCode(normalizedCode)
        return isValid
    }
    
    func loadNativeLanguage(completion: @escaping (Bool) -> Void) {
        isLoadingLanguages = true
        
        guard let token = authToken, !token.isEmpty else {
            isLoadingLanguages = false
            completion(false)
            return
        }
        
        let request = GetNativeLanguageRequest(session_token: token)
        
        LanguageAPIManager.shared.getNativeLanguage(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    
                    if response.success, let data = response.data, let nativeLang = data.native_language, !nativeLang.isEmpty {
                        
                        // Validate and set native language using centralized mapping
                        let languageMapping = LanguageMapping.shared
                        if let validCode = languageMapping.normalizeAndValidateLanguage(nativeLang) {
                            
                            self.nativeLanguage = validCode
                            self.isLoadingLanguages = false // Complete if no target load needed
                            completion(true)
                        } else {
                            self.nativeLanguage = ""
                            self.isLoadingLanguages = false
                            completion(false)
                        }
                    } else {
                        self.nativeLanguage = ""
                        self.isLoadingLanguages = false
                        completion(false)
                    }
                case .failure(_):
                    self.isLoadingLanguages = false
                    completion(false)
                }
            }
        }
    }
    
    func loadTargetLanguages(completion: @escaping (Bool) -> Void) {
        isLoadingLanguages = true
        
        guard let token = authToken, !token.isEmpty else {
            isLoadingLanguages = false
            completion(false)
            return
        }
        
        let request = GetTargetLanguagesRequest(session_token: token)
        
        LanguageAPIManager.shared.getTargetLanguages(request: request) { result in
            DispatchQueue.main.async {
                switch result {

                case .success(let response):
                    let success = self.processTargetLanguagesResponse(response)
                    self.isLoadingLanguages = false
                    completion(success)
                case .failure(_):
                    self.isLoadingLanguages = false
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Legacy Method (for backward compatibility - calls both endpoints)
    // MARK: - Legacy Method (for backward compatibility - calls both endpoints)
    func loadAvailableLanguagePairs(completion: @escaping (Bool) -> Void) {
        // Load native first, then targets
        loadNativeLanguage { nativeSuccess in
            self.loadTargetLanguages { targetSuccess in
                let success = nativeSuccess && targetSuccess
                if success {
                    DispatchQueue.main.async {
                        self.hasLoadedLanguages = true
                    }
                }
                completion(success)
            }
        }
    }
    
    // Async wrapper for Pull-to-Refresh
    func forceRefreshLanguages() async {
        return await withCheckedContinuation { continuation in
            // Force reload by calling the load method (which hits API)
            // We ignore the 'hasLoadedLanguages' check here because it's a forced refresh
            self.loadAvailableLanguagePairs { success in
                continuation.resume()
            }
        }
    }
    
    func addLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // Convert language names to codes
        let nativeCode = getLanguageCode(for: nativeLanguage)
        let targetCode = getLanguageCode(for: targetLanguage)
        
        // UNIFIED API: Use GetTargetLanguagesRequest with action="ADD"
        let request = GetTargetLanguagesRequest(
            session_token: token,
            action: "ADD",
            target_language: targetCode,
            native_language: nativeCode
        )
        
        // Calls the unified endpoint
        LanguageAPIManager.shared.addLanguagePair(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success == true {
                        // Success: Defer processing to avoid flashing "Archived" state
                        // let _ = self.processTargetLanguagesResponse(response)
                        
                        // Chain: Set this pair as default automatically
                        self.setDefaultLanguagePair(nativeLanguage: nativeCode, targetLanguage: targetCode) { success in
                           if success {
                               self.shouldAttemptInferInterest = true
                               completion(true)
                           } else {
                               // Fallback: If set default failed, at least show the added language
                               let _ = self.processTargetLanguagesResponse(response)
                               self.shouldAttemptInferInterest = true
                               completion(true)
                           }
                        }
                    } else {
                        // Handle failure / errors
                         let errorMessage = response.error ?? "Unknown error"
                         
                         // If "already exists", try setting default anyway
                         if errorMessage.contains("already exists") {
                             self.setDefaultLanguagePair(nativeLanguage: nativeCode, targetLanguage: targetCode) { success in
                                self.shouldAttemptInferInterest = true
                                completion(success)
                             }
                             return
                         }
                         
                         completion(false)
                    }
                    
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    /// Get language code for API calls - uses centralized language mapping system
    func getLanguageCode(for languageName: String) -> String {
        return LanguageMapping.shared.getLanguageCodeForAPI(for: languageName)
    }
    
    // Set default language pair (Unified Endpoint)
    func setDefaultLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // UNIFIED API: action="SET_DEFAULT"
        let request = GetTargetLanguagesRequest(
            session_token: token,
            action: "SET_DEFAULT",
            target_language: getLanguageCode(for: targetLanguage),
            native_language: getLanguageCode(for: nativeLanguage)
        )
        
        LanguageAPIManager.shared.setDefaultLanguagePair(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success == true {
                        let success = self.processTargetLanguagesResponse(response)
                        completion(success)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // Delete language pair (Unified Endpoint)
    func deleteLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // UNIFIED API: action="DELETE"
        let request = GetTargetLanguagesRequest(
            session_token: token,
            action: "DELETE",
            target_language: getLanguageCode(for: targetLanguage),
            native_language: getLanguageCode(for: nativeLanguage)
        )
        
        LanguageAPIManager.shared.deleteLanguagePair(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success == true {
                        let success = self.processTargetLanguagesResponse(response)
                        completion(success)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // Update language pair level
    func updateLanguagePairLevel(nativeLanguage: String, targetLanguage: String, newLevel: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // Convert language names to codes
        let nativeCode = getLanguageCode(for: nativeLanguage)
        let targetCode = getLanguageCode(for: targetLanguage)
        
        let request = UpdateLanguageLevelRequest(
            session_token: token,
            target_language: targetCode,
            native_language: nativeCode,
            new_level: newLevel,
            new_native_language: nil
        )
        
        LanguageAPIManager.shared.updateLanguageLevel(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        
                        // Update local array - refresh from API
                        if self.userLanguagePairs.firstIndex(where: { $0.native_language == nativeLanguage && $0.target_language == targetLanguage }) != nil {
                            // Refresh language pairs from API
                            self.loadAvailableLanguagePairs { _ in }
                        }
                        
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // Update native language
    func updateNativeLanguage(newNativeLanguage: String, completion: @escaping (Bool) -> Void) {
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let request = UpdateNativeLanguageRequest(
            session_token: token,
            new_native_language: getLanguageCode(for: newNativeLanguage)
        )
        
        LanguageAPIManager.shared.updateNativeLanguage(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        // Update local native language
                        self.nativeLanguage = self.getLanguageCode(for: newNativeLanguage)
                        
                        // Refresh from API to get latest data
                        self.loadAvailableLanguagePairs { hasPairs in
                        }
                        
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Unified Response Processing
    
    /// Processes the target languages response (Used by GET, ADD, DELETE, SET_DEFAULT)
    /// updates userLanguagePairs and handles validation
    private func processTargetLanguagesResponse(_ response: GetTargetLanguagesResponse) -> Bool {
        // Support both flat response (target_languages at root) and nested (inside data)
        let targetLanguages = response.target_languages ?? response.data?.target_languages
        
        guard let targets = targetLanguages else {
            return false
        }
        
        
        // Convert target languages to language pairs
        // Use centralized language mapping system
        let languageMapping = LanguageMapping.shared
        let currentNative = self.nativeLanguage
        
        let pairs = targets.compactMap { targetLang -> LanguagePair? in
            // Use native_language from target language if available, otherwise use current native
            let nativeLang = targetLang.native_language ?? currentNative
            
            // Validate language pair using centralized mapping
            let validation = languageMapping.validateLanguagePair(
                nativeLanguage: nativeLang,
                targetLanguage: targetLang.target_language
            )
            
            if validation.isValid, let validatedNativeCode = validation.nativeCode, let validatedTargetCode = validation.targetCode {
                // Create pair with validated native code
                let pair = LanguagePair(
                    native_language: validatedNativeCode,
                    target_language: validatedTargetCode,
                    is_default: targetLang.is_default,
                    user_level: targetLang.user_level,
                    practice_dates: targetLang.practice_dates
                )
                print("📦 [API] Processed language pair '\(validatedTargetCode)' with \(targetLang.practice_dates.count) practice dates: \(targetLang.practice_dates)")
                return pair
            } else {
            }
            return nil
        }
        
        
        self.userLanguagePairs = pairs
        
        if !pairs.isEmpty {
            self.shouldAttemptInferInterest = true
            
            // PROACTIVE DOWNLOAD: Check Default Language on API Sync
            if let defaultPair = pairs.first(where: { $0.is_default }) {
                print("   🚀 [API-Sync] Found default language: \(defaultPair.target_language)")
                NeuralValidator.downloadAssets(for: defaultPair.target_language)
            }
        }
        self.refreshNotificationSchedules()
        
        return !pairs.isEmpty
    }
    
    func isNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                return true
            default:
                return false
            }
        }
        return false
    }
}
