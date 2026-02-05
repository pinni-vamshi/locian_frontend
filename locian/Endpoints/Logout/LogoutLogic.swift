import Foundation

/// Controller for Logout specific domain logic.
/// Lives in the Logout domain.
class LogoutLogic {
    static let shared = LogoutLogic()
    private init() {}
    
    /// Performs logout via backend and cleans up local state
    func logoutViaBackend(completion: @escaping (Bool, String?) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            appState.clearAllUserData()
            completion(true, nil)
            return
        }
        
        LogoutService.shared.logout(sessionToken: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        appState.clearAllUserData()
                        completion(true, response.message)
                    } else {
                        let message = response.error ?? response.message ?? "Logout failed. Please try again."
                        completion(false, message)
                    }
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
