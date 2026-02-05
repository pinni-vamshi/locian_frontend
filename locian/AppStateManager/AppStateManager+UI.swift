import SwiftUI
import Combine

extension AppStateManager {
    // MARK: - Button Visibility Check
    func checkButtonVisibility() {
        guard !hasCheckedGuestLoginVisibility else { return }
        
        // Mark as checked IMMEDIATELY to prevent race conditions/duplicate calls
        self.hasCheckedGuestLoginVisibility = true
        
        AuthAPIManager.shared.checkButtonVisibility { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let shouldShow = response.visibility.lowercased() == "on"
                    self.showGuestLoginButton = shouldShow
                case .failure:
                    self.showGuestLoginButton = false
                }
            }
        }
    }
    
}
