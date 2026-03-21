import AuthenticationServices
import CryptoKit
import Security
import Combine

struct ApplePendingUserDetails {
    var username: String?
    var profession: String?
    var phoneNumber: String?
    var emailOverride: String?
}

/// Controller for Apple Sign-In domain logic.
/// Lives in the LoginWithApple domain.
class AppleAuthLogic {
    static let shared = AppleAuthLogic()
    private init() {}
    
    private var appleAuthNonce: String?
    private var applePendingDetails: ApplePendingUserDetails?
    
    // MARK: - Configuration
    
    func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest,
                               username: String?,
                               profession: String?,
                               phoneNumber: String?,
                               emailOverride: String?) {
        let appState = AppStateManager.shared
        appState.authError = nil
        appState.showAuthError = false
        appState.isAuthenticating = true
        
        let nonce = randomNonceString()
        self.appleAuthNonce = nonce
        self.applePendingDetails = ApplePendingUserDetails(
            username: sanitized(username),
            profession: sanitized(profession),
            phoneNumber: sanitized(phoneNumber),
            emailOverride: sanitized(emailOverride)
        )
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    // MARK: - Handling Results
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        let appState = AppStateManager.shared
        print("🍎 [AppleAuthLogic] handleAppleSignIn result received")
        
        switch result {
        case .failure(let error):
            appState.isAuthenticating = false
            
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    print("🍎 [AppleAuthLogic] User cancelled Apple Sign-In")
                    // If user cancelled, we just stop without showing a scary error alert
                    appState.resetAuthStatus()
                case .failed:
                    print("🍎 [AppleAuthLogic] Apple Sign-In failed: \(error.localizedDescription)")
                    appState.authError = "Apple Sign-In failed. Please try again."
                    appState.showAuthError = true
                case .invalidResponse:
                    print("🍎 [AppleAuthLogic] Invalid response from Apple: \(error.localizedDescription)")
                    appState.authError = "Invalid response from Apple."
                    appState.showAuthError = true
                case .notHandled:
                    print("🍎 [AppleAuthLogic] Apple Sign-In not handled: \(error.localizedDescription)")
                    appState.authError = "Apple Sign-In was not handled. Please try again."
                    appState.showAuthError = true
                case .unknown:
                    print("🍎 [AppleAuthLogic] Unknown Apple Sign-In error: \(error.localizedDescription)")
                    appState.authError = "An unknown error occurred during Apple Sign-In."
                    appState.showAuthError = true
                default:
                    print("🍎 [AppleAuthLogic] Other Apple Sign-In error code: \(authError.code)")
                    appState.authError = error.localizedDescription
                    appState.showAuthError = true
                }
            } else {
                print("🍎 [AppleAuthLogic] Non-Apple error during sign-in: \(error.localizedDescription)")
                appState.authError = error.localizedDescription
                appState.showAuthError = true
            }
            clearAppleAuthState()
            
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                appState.isAuthenticating = false
                appState.authError = "Invalid Apple ID credential."
                appState.showAuthError = true
                clearAppleAuthState()
                return
            }
            
            guard let codeData = credential.authorizationCode,
                  let code = String(data: codeData, encoding: .utf8),
                  !code.isEmpty else {
                appState.isAuthenticating = false
                appState.authError = "Missing authorization code from Apple."
                appState.showAuthError = true
                clearAppleAuthState()
                return
            }
            
            let idTokenData = credential.identityToken
            let idToken = idTokenData.flatMap { String(data: $0, encoding: .utf8) }
            
            let fullNameComponents = credential.fullName
            let resolvedEmail = sanitized(credential.email) ?? applePendingDetails?.emailOverride
            let resolvedFirstName = sanitized(fullNameComponents?.givenName)
            let resolvedLastName = sanitized(fullNameComponents?.familyName)
            
            let fullNamePayload: AppleFullNamePayload?
            if resolvedFirstName != nil || resolvedLastName != nil {
                fullNamePayload = AppleFullNamePayload(firstName: resolvedFirstName, lastName: resolvedLastName)
            } else {
                fullNamePayload = nil
            }
            
            let requestBody = AppleLoginRequest(
                code: code,
                id_token: sanitized(idToken ?? ""),
                nonce: appleAuthNonce,
                username: applePendingDetails?.username,
                profession: applePendingDetails?.profession,
                email: resolvedEmail,
                phone_number: applePendingDetails?.phoneNumber,
                full_name: fullNamePayload,
                first_name: resolvedFirstName,
                last_name: resolvedLastName
            )
            
            LoginWithAppleService.shared.loginWithApple(request: requestBody) { [weak self] result in
                DispatchQueue.main.async {
                    appState.isAuthenticating = false
                    
                    switch result {
                    case .failure(let error):
                        print("🍎 [AppleAuthLogic] Backend API Failure: \(error.localizedDescription)")
                        appState.authError = error.localizedDescription
                        appState.showAuthError = true
                        self?.clearAppleAuthState()
                        
                    case .success(let response):
                        print("🍎 [AppleAuthLogic] Backend API Success: \(response.success)")
                        guard response.success, let data = response.data, !data.session_token.isEmpty else {
                            let backendMessage = self?.sanitized(response.message) ?? self?.sanitized(response.error)
                            print("🍎 [AppleAuthLogic] Backend API logic failure: \(backendMessage ?? "No message")")
                            appState.authError = backendMessage ?? "Apple login failed. Please try again."
                            appState.showAuthError = true
                            self?.clearAppleAuthState()
                            return
                        }
                        
                        print("🍎 [AppleAuthLogic] Session obtained. Persisting...")
                        self?.persistAppleSession(
                            data: data,
                            fallbackUsername: requestBody.username,
                            fallbackProfession: requestBody.profession,
                            fallbackPhone: requestBody.phone_number
                        )
                        self?.clearAppleAuthState()
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func persistAppleSession(data: AppleLoginData,
                                     fallbackUsername: String?,
                                     fallbackProfession: String?,
                                     fallbackPhone: String?) {
        let appState = AppStateManager.shared
        appState.authToken = data.session_token
        
        if let resolvedUsername = sanitized(data.username) ?? fallbackUsername {
            appState.username = resolvedUsername
        }
        if let resolvedProfession = sanitized(data.profession) ?? fallbackProfession {
            appState.profession = resolvedProfession
        }
        if let resolvedPhone = sanitized(data.phone_number) ?? fallbackPhone {
            appState.userPhoneNumber = resolvedPhone
        }
        
        appState.isLoggedIn = true
        appState.loadInitialData()
        appState.checkLanguagePairsAndShowModalIfNeeded()
        NotificationManager.shared.ensureNotificationAccess { _ in
            UserDefaults.standard.set(true, forKey: "hasRequestedNotificationPermission")
        }
    }
    
    private func clearAppleAuthState() {
        appleAuthNonce = nil
        applePendingDetails = nil
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }
            randoms.forEach { random in
                if remainingLength > 0 && Int(random) < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func sanitized(_ value: String?) -> String? {
        guard let v = value else { return nil }
        let trimmed = v.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
