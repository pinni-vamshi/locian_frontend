import Foundation

/// Controller for Delete Account specific domain logic.
/// Lives in the DeleteAccount domain.
class DeleteAccountLogic {
    static let shared = DeleteAccountLogic()
    private init() {}
    
    /// Performs account deletion via backend and cleans up local state
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            appState.clearAllUserData()
            completion(false, "No session token found")
            return
        }
        
        DeleteAccountService.shared.deleteAccount(sessionToken: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        appState.clearAllUserData()
                        completion(true, nil)
                    } else {
                        // Failures during deletion are often network-related or session expiry
                        // but we treat them as critical app state errors
                        appState.isOffline = true
                        completion(false, response.error ?? "Account deletion failed")
                    }
                case .failure(let error):
                    appState.isOffline = true
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
