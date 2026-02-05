import SwiftUI
import AuthenticationServices
import Security
import CryptoKit

struct ApplePendingUserDetails {
    var username: String?
    var profession: String?
    var phoneNumber: String?
    var emailOverride: String?
}

extension AppStateManager {
    // MARK: - Apple Sign-In Configuration
    func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest,
                              username: String?,
                              profession: String?,
                              phoneNumber: String?,
                              emailOverride: String?) {
        authError = nil
        showAuthError = false
        isAuthenticating = true
        
        let nonce = randomNonceString()
        appleAuthNonce = nonce
        applePendingDetails = ApplePendingUserDetails(
            username: sanitized(username),
            profession: sanitized(profession),
            phoneNumber: sanitized(phoneNumber),
            emailOverride: sanitized(emailOverride)
        )
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    // MARK: - Apple Sign-In Completion
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            isAuthenticating = false
            authError = error.localizedDescription
            showAuthError = true
            clearAppleAuthState()
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                isAuthenticating = false
                authError = "Invalid Apple ID credential."
                showAuthError = true
                clearAppleAuthState()
                return
            }
            
            guard let codeData = credential.authorizationCode else {
                isAuthenticating = false
                authError = "Missing authorization code from Apple."
                showAuthError = true
                clearAppleAuthState()
                return
            }
            
            guard let code = String(data: codeData, encoding: .utf8),
                  !code.isEmpty else {
                isAuthenticating = false
                authError = "Missing authorization code from Apple."
                showAuthError = true
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
            
            let trimmedUsername = applePendingDetails?.username
            let trimmedProfession = applePendingDetails?.profession
            let trimmedPhone = applePendingDetails?.phoneNumber
            let trimmedEmail = resolvedEmail
            
            let requestBody = AppleLoginRequest(
                code: code,
                id_token: sanitized(idToken ?? ""),
                nonce: appleAuthNonce,
                username: trimmedUsername,
                profession: trimmedProfession,
                email: trimmedEmail,
                phone_number: trimmedPhone,
                full_name: fullNamePayload,
                first_name: resolvedFirstName,
                last_name: resolvedLastName
            )
            
            AuthAPIManager.shared.loginWithApple(request: requestBody) { [weak self] (apiResult: Result<AppleLoginResponse, Error>) in
                guard let self = self else { return }
                
                self.isAuthenticating = false
                
                switch apiResult {
                case .failure(let error):
                    self.authError = error.localizedDescription
                    self.showAuthError = true
                    self.clearAppleAuthState()
                    
                case .success(let response):
                    guard response.success,
                          let data = response.data,
                          !data.session_token.isEmpty else {
                        let backendMessage = sanitized(response.message) ?? sanitized(response.error)
                        self.authError = backendMessage ?? "Apple login failed. Please try again."
                        self.showAuthError = true
                        self.clearAppleAuthState()
                        return
                    }
                    
                    self.persistAppleSession(
                        data: data,
                        fallbackUsername: trimmedUsername,
                        fallbackProfession: trimmedProfession,
                        fallbackPhone: trimmedPhone,
                        fallbackEmail: trimmedEmail
                    )
                    
                    self.clearAppleAuthState()
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func persistAppleSession(data: AppleLoginData,
                                     fallbackUsername: String?,
                                     fallbackProfession: String?,
                                     fallbackPhone: String?,
                                     fallbackEmail: String?) {
        authToken = data.session_token
        if let resolvedUsername = sanitized(data.username) ?? fallbackUsername {
            username = resolvedUsername
        }
        if let resolvedProfession = sanitized(data.profession) ?? fallbackProfession {
            profession = resolvedProfession
        }
        if let resolvedPhone = sanitized(data.phone_number) ?? fallbackPhone {
            userPhoneNumber = resolvedPhone
        }
        
        // No dedicated email property yet; can be added if needed.
        
        isLoggedIn = true
        checkLanguagePairsAndShowModalIfNeeded()
        promptForNotificationPermissionIfNeeded()
    }
    
    private func clearAppleAuthState() {
        appleAuthNonce = nil
        applePendingDetails = nil
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if Int(random) < charset.count {
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
        guard let value = value else { return nil }
        return sanitized(value)
    }
    
    private func sanitized(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    private func debugPreview(for value: String, head: Int = 6, tail: Int = 6) -> String {
        guard !value.isEmpty else { return "[empty]" }
        if value.count <= head + tail + 3 {
            return value
        }
        let start = value.prefix(head)
        let end = value.suffix(tail)
        return "\(start)…\(end)"
    }
}

