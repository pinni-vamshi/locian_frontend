import Foundation

/// Logic controller for the GetTargetLanguages endpoint.
/// Handles management of learning language pairs.
class TargetLanguageLogic {
    static let shared = TargetLanguageLogic()
    private init() {}
    
    /// Fetches target languages from the server and updates AppStateManager
    func loadTargetLanguages(completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        GetTargetLanguagesService.shared.getTargetLanguages(sessionToken: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let success = self.processTargetLanguagesResponse(response)
                    completion(success)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    /// Adds a new language pair
    func addLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // Convert language names to codes using respective mappings
        let nativeCode = NativeLanguageMapping.shared.normalizeAndValidate(nativeLanguage) ?? nativeLanguage.lowercased()
        let targetCode = TargetLanguageMapping.shared.normalizeAndValidate(targetLanguage) ?? targetLanguage.lowercased()
        
        GetTargetLanguagesService.shared.getTargetLanguages(
            sessionToken: token,
            action: "ADD",
            targetLanguage: targetCode,
            nativeLanguage: nativeCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success == true {
                        // Success: Set as default automatically
                        self.setDefaultLanguagePair(nativeLanguage: nativeCode, targetLanguage: targetCode) { success in
                            appState.shouldAttemptInferInterest = true
                            if success {
                                completion(true)
                            } else {
                                _ = self.processTargetLanguagesResponse(response)
                                completion(true)
                            }
                        }
                    } else {
                        // Handle "already exists" case
                        if let error = response.error, error.contains("already exists") {
                            self.setDefaultLanguagePair(nativeLanguage: nativeCode, targetLanguage: targetCode) { success in
                                appState.shouldAttemptInferInterest = true
                                completion(success)
                            }
                        } else {
                            completion(false)
                        }
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    /// Sets a language pair as default (Unified Endpoint)
    func setDefaultLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let nativeCode = NativeLanguageMapping.shared.normalizeAndValidate(nativeLanguage) ?? nativeLanguage.lowercased()
        let targetCode = TargetLanguageMapping.shared.normalizeAndValidate(targetLanguage) ?? targetLanguage.lowercased()
        
        GetTargetLanguagesService.shared.getTargetLanguages(
            sessionToken: token,
            action: "SET_DEFAULT",
            targetLanguage: targetCode,
            nativeLanguage: nativeCode
        ) { result in
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
    
    /// Deletes a language pair (Unified Endpoint)
    func deleteLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let nativeCode = NativeLanguageMapping.shared.normalizeAndValidate(nativeLanguage) ?? nativeLanguage.lowercased()
        let targetCode = TargetLanguageMapping.shared.normalizeAndValidate(targetLanguage) ?? targetLanguage.lowercased()
        
        GetTargetLanguagesService.shared.getTargetLanguages(
            sessionToken: token,
            action: "DELETE",
            targetLanguage: targetCode,
            nativeLanguage: nativeCode
        ) { result in
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

    /// Updates the user's proficiency level for a specific language pair
    func updateLanguagePairLevel(nativeLanguage: String, targetLanguage: String, newLevel: String, completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // Convert language names to codes using respective mappings
        let nativeCode = NativeLanguageMapping.shared.normalizeAndValidate(nativeLanguage) ?? nativeLanguage.lowercased()
        let targetCode = TargetLanguageMapping.shared.normalizeAndValidate(targetLanguage) ?? targetLanguage.lowercased()
        
        UpdateLanguageLevelService.shared.updateLanguageLevel(
            sessionToken: token,
            targetLanguage: targetCode,
            nativeLanguage: nativeCode,
            userLevel: newLevel
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        // Refresh to sync local state
                        self.loadTargetLanguages { _ in }
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
    
    /// Processes Unified Response (Used by GET, ADD, DELETE, SET_DEFAULT)
    func processTargetLanguagesResponse(_ response: GetTargetLanguagesResponse) -> Bool {
        let appState = AppStateManager.shared
        let targetLanguages = response.target_languages ?? response.data?.target_languages
        
        guard let targets = targetLanguages else {
            return false
        }
        
        let pairs = targets.compactMap { targetLang -> LanguagePair? in
            let nativeLang = targetLang.native_language ?? appState.nativeLanguage
            
            guard let validatedNative = NativeLanguageMapping.shared.normalizeAndValidate(nativeLang),
                  let validatedTarget = TargetLanguageMapping.shared.normalizeAndValidate(targetLang.target_language) else {
                return nil
            }
            
            return LanguagePair(
                native_language: validatedNative,
                target_language: validatedTarget,
                is_default: targetLang.is_default,
                user_level: targetLang.user_level,
                practice_dates: targetLang.practice_dates
            )
        }
        
        appState.userLanguagePairs = pairs
        
        if !pairs.isEmpty {
            appState.shouldAttemptInferInterest = true
            if let defaultPair = pairs.first(where: { $0.is_default }) {
                NeuralValidator.downloadAssets(for: defaultPair.target_language)
            }
        }
        
        return !pairs.isEmpty
    }
}
