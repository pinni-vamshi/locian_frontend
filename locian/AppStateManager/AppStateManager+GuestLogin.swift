import SwiftUI
import Combine

extension AppStateManager {
    // MARK: - Guest Login
    func guestLogin(username: String? = nil, phoneNumber: String? = nil, profession: String? = nil) {
        isGuestLoginLoading = true
        
        let request = GuestLoginRequest(
            username: username ?? "Guest",
            phone_number: nil,
            profession: profession ?? "General User"
        )
        
        AuthAPIManager.shared.guestLogin(request: request) { result in
            DispatchQueue.main.async {
                self.isGuestLoginLoading = false
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        // Save session token
                        self.authToken = data.session_token
                        
                        // Save user data
                        self.username = data.username
                        self.userPhoneNumber = ""
                        self.profession = data.profession ?? ""
                        
                        // Set logged in state
                        self.isLoggedIn = true
                        
                        self.checkLanguagePairsAndShowModalIfNeeded()
                        self.promptForNotificationPermissionIfNeeded()
                    } else {
                        // Guest login failed
                        self.authError = response.error ?? "Guest login failed. Please try again."
                        self.showAuthError = true
                    }
                case .failure(_):
                    // Network error
                    self.authError = "No internet connection. Please check your network and try again."
                    self.showAuthError = true
                }
            }
        }
    }
    
    func logout() {
        logoutLocalOnly()
    }
    
    func checkUserSession() {
        print("\n🚀 [App-Launch] STARTING SESSION CHECK...")
        isLoadingSession = true

        // 1. Check if session token exists locally
        guard let token = authToken, !token.isEmpty else {
            print("🛑 [App-Launch] No token found. Redirecting to Login.")
            clearUserData()
            isLoggedIn = false
            isLoadingSession = false
            shouldCheckGuestLoginVisibility = true
            return
        }

        print("✅ [App-Launch] Valid token found in cache.")
        
        // 2. Set logged in state immediately (No redundant validation call)
        self.isLoggedIn = true
        self.isOffline = false
        self.isLoadingSession = false
        
        // 3. Load user data from cache (Profession, Native Lang, etc.)
        self.loadUserData()
        print("📦 [App-Launch] User context loaded from local cache.")

        // 4. Decision: Do we need to check languages via API?
        // If we already have a valid native language and at least one target pair, skip the API calls.
        if hasValidLanguagePair() {
            print("🚀 [App-Launch] Languages are valid in cache. BYPASSING language API calls.")
            print("   (Native: \(nativeLanguage), Targets: \(userLanguagePairs.count))")
            
            // Just ensure notifications are ready
            self.promptForNotificationPermissionIfNeeded()
            
            // The 'studied-places' call will be triggered by SceneView's SceneLifecycleModifier onAppear
            print("📡 [App-Launch] Ready for Timeline Fetch (SceneView will trigger).")
        } else {
            print("⚠️ [App-Launch] Language config missing or invalid. Triggering recovery flow...")
            // Fallback: Check/Set languages via API if cache is empty/invalid
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.checkLanguagePairsAndShowModalIfNeeded()
            }
            self.promptForNotificationPermissionIfNeeded()
        }
        
        print("🏁 [App-Launch] SESSION CHECK COMPLETE.\n")
    }
    
}
