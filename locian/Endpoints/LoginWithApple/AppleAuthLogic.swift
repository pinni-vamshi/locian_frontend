import Foundation
import AuthenticationServices
import CryptoKit
import Security

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
        
        switch result {
        case .failure(let error):
            appState.isAuthenticating = false
            appState.authError = error.localizedDescription
            appState.showAuthError = true
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
                        appState.authError = error.localizedDescription
                        appState.showAuthError = true
                        self?.clearAppleAuthState()
                        
                    case .success(let response):
                        guard response.success, let data = response.data, !data.session_token.isEmpty else {
                            let backendMessage = self?.sanitized(response.message) ?? self?.sanitized(response.error)
                            appState.authError = backendMessage ?? "Apple login failed. Please try again."
                            appState.showAuthError = true
                            self?.clearAppleAuthState()
                            return
                        }
                        
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
        appState.checkLanguagePairsAndShowModalIfNeeded()
        PermissionsService.ensureNotificationAccess { _ in
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
                SecRandomCopyBytes(kSecRandomDefault, 1, &random)
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
