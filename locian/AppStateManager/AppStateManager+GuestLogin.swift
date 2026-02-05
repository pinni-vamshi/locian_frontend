import SwiftUI
import Combine

// MARK: - AppStateManager Guest Login Extension
extension AppStateManager {
    
    /// Entry point for guest login via logic controller
    func guestLogin(username: String? = nil, phoneNumber: String? = nil, profession: String? = nil) {
        GuestLoginLogic.shared.guestLogin(username: username, phoneNumber: phoneNumber, profession: profession)
    }
    
    /// Entry point for checking user session via logic controller
    func checkUserSession() {
        CheckSessionLogic.shared.checkUserSession()
    }
    
    /// Logout wrapper for backward compatibility
    func logout() {
        logoutLocalOnly()
    }
}
