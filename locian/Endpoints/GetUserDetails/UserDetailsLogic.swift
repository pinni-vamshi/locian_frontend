import Foundation

/// Controller for user profile and settings-related domain logic.
/// Lives in the GetUserDetails domain.
class UserDetailsLogic {
    static let shared = UserDetailsLogic()
    private init() {}
    
    /// Fetches latest user details and updates AppStateManager
    func refreshUserDetails(completion: @escaping (Bool, String?) -> Void) {
        let appState = AppStateManager.shared
        guard let token = appState.authToken, !token.isEmpty else {
            completion(false, "No active session found.")
            return
        }
        
        GetUserDetailsService.shared.getUserDetails(sessionToken: token, profession: nil) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success, let data = response.data else {
                        completion(false, response.errorMessage ?? "Failed to fetch details.")
                        return
                    }
                    
                    self.processUserDetailsResponse(data)
                    completion(true, response.message ?? "User details refreshed.")
                    
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    
    /// Updates local AppStateManager state based on API data
    private func processUserDetailsResponse(_ data: GetUserDetailsData) {
        let appState = AppStateManager.shared
        
        if appState.authToken != data.session_token {
            appState.authToken = data.session_token
        }
        
        appState.username = data.username
        if let profession = data.profession, !profession.isEmpty {
            appState.profession = profession
        }
    }
}
