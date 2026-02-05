import Foundation

/// Controller for Guest Login specific domain logic.
/// Lives in the GuestLogin domain.
class GuestLoginLogic {
    static let shared = GuestLoginLogic()
    private init() {}
    
    /// Perfroms a guest login and updates AppStateManager
    func guestLogin(username: String? = nil, phoneNumber: String? = nil, profession: String? = nil) {
        let appState = AppStateManager.shared
        appState.isGuestLoginLoading = true
        
        let request = GuestLoginRequest(
            username: username ?? "Guest",
            phone_number: nil,
            profession: profession ?? "General User"
        )
        
        GuestLoginService.shared.guestLogin(request: request) { result in
            DispatchQueue.main.async {
                appState.isGuestLoginLoading = false
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        // Save session token
                        appState.authToken = data.session_token
                        
                        // Save user data
                        appState.username = data.username
                        appState.userPhoneNumber = ""
                        appState.profession = data.profession ?? ""
                        
                        // Set logged in state
                        appState.isLoggedIn = true
                        
                        appState.checkLanguagePairsAndShowModalIfNeeded()
                        PermissionsService.ensureNotificationAccess { _ in
                            UserDefaults.standard.set(true, forKey: "hasRequestedNotificationPermission")
                        }
                    } else {
                        appState.authError = response.error ?? "Guest login failed. Please try again."
                        appState.showAuthError = true
                    }
                case .failure(_):
                    appState.authError = "No internet connection. Please check your network and try again."
                    appState.showAuthError = true
                }
            }
        }
    }
}
