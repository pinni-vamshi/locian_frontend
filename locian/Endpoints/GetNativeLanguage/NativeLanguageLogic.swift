import Foundation

/// Logic controller for the GetNativeLanguage endpoint.
/// Handles fetching and updating the user's native tongue.
class NativeLanguageLogic {
    static let shared = NativeLanguageLogic()
    private init() {}
    
    /// Fetches the native language from the server and updates AppStateManager
    func loadNativeLanguage(completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        GetNativeLanguageService.shared.getNativeLanguage(sessionToken: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data, let nativeLang = data.native_language, !nativeLang.isEmpty {
                        // Validate and set
                        if let validCode = NativeLanguageMapping.shared.normalizeAndValidate(nativeLang) {
                            appState.nativeLanguage = validCode
                            completion(true)
                            return
                        }
                    }
                    completion(false)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    /// Updates the native language on the server
    func updateNativeLanguage(newNativeLanguage: String, completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let normalizedCode = NativeLanguageMapping.shared.normalizeAndValidate(newNativeLanguage) ?? newNativeLanguage.lowercased()
        
        UpdateNativeLanguageService.shared.updateNativeLanguage(
            sessionToken: token,
            nativeLanguage: normalizedCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        appState.nativeLanguage = normalizedCode
                        // Refresh all pairs to ensure consistency
                        self.loadNativeLanguage { _ in
                            TargetLanguageLogic.shared.loadTargetLanguages { _ in }
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
    
    /// Auto-sets native language based on phone locale
    func setNativeLanguageFromPhone(completion: @escaping (Bool) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let phoneLanguageCode: String
        if #available(iOS 16.0, *) {
            phoneLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            phoneLanguageCode = Locale.current.languageCode ?? "en"
        }
        
        let validCode = NativeLanguageMapping.shared.normalizeAndValidate(phoneLanguageCode) ?? "en"
        
        if !appState.nativeLanguage.isEmpty && appState.nativeLanguage == validCode {
            completion(true)
            return
        }
        
        GetNativeLanguageService.shared.getNativeLanguage(sessionToken: token, nativeLanguage: validCode) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.data, let nativeLang = data.native_language, !nativeLang.isEmpty {
                        appState.nativeLanguage = nativeLang
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
}
