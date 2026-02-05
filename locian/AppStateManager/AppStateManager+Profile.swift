import Foundation

// MARK: - AppStateManager Profile Extension
extension AppStateManager {
    
    /// Fetches the latest user details via the domain logic controller.
    func refreshUserDetails(completion: @escaping (Bool, String?) -> Void) {
        UserDetailsLogic.shared.refreshUserDetails(completion: completion)
    }
}
