import SwiftUI
import AuthenticationServices

// MARK: - AppStateManager Apple Auth Extension
extension AppStateManager {
    
    /// Entry point for configuring Apple Sign-In via domain logic controller
    func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest,
                               username: String?,
                               profession: String?,
                               phoneNumber: String?,
                               emailOverride: String?) {
        AppleAuthLogic.shared.configureAppleSignIn(
            request,
            username: username,
            profession: profession,
            phoneNumber: phoneNumber,
            emailOverride: emailOverride
        )
    }
    
    /// Entry point for handling Apple Sign-In results via domain logic controller
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        AppleAuthLogic.shared.handleAppleSignIn(result: result)
    }
}
