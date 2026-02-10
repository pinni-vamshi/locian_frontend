import Foundation

/// Controller for session management domain logic.
/// Lives in the CheckSession domain.
class CheckSessionLogic {
    static let shared = CheckSessionLogic()
    private init() {}
    
    /// Entry point for app launch session verification
    func checkUserSession() {
        let appState = AppStateManager.shared
        print("\n🚀 [App-Launch] STARTING SESSION CHECK...")
        appState.isLoadingSession = true

        // 1. Check if session token exists locally
        guard let token = appState.authToken, !token.isEmpty else {
            print("🛑 [App-Launch] No token found. Redirecting to Login.")
            appState.clearUserData()
            appState.isLoggedIn = false
            appState.isLoadingSession = false
            appState.shouldCheckGuestLoginVisibility = true
            return
        }

        print("✅ [App-Launch] Valid token found in cache.")
        
        // 2. Set logged in state immediately (No redundant validation call)
        appState.isLoggedIn = true
        appState.isOffline = false
        appState.isLoadingSession = false
        
        // 3. Load user data from cache (Profession, Native Lang, etc.)
        appState.loadUserData()
        print("📦 [App-Launch] User context loaded from local cache.")
        
        // 4. Load initial data (studied places + recommendations)
        appState.loadInitialData()
        print("📡 [App-Launch] Initial data loading triggered...")

        // 5. Decision: Do we need to check languages via API?
        if appState.hasValidLanguagePair() {
            print("🚀 [App-Launch] Languages are valid in cache. BYPASSING language API calls.")
            
            // Just ensure notifications are ready
            PermissionsService.shared.ensureNotificationAccess { _ in
                UserDefaults.standard.set(true, forKey: "hasRequestedNotificationPermission")
            }
            
            print("📡 [App-Launch] Ready for Timeline Fetch (SceneView will trigger).")
        } else {
            print("⚠️ [App-Launch] Language config missing or invalid. Triggering recovery flow...")
            // Fallback: Check/Set languages via API if cache is empty/invalid
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                appState.checkLanguagePairsAndShowModalIfNeeded()
            }
            PermissionsService.shared.ensureNotificationAccess { _ in
                UserDefaults.standard.set(true, forKey: "hasRequestedNotificationPermission")
            }
        }
        
        print("🏁 [App-Launch] SESSION CHECK COMPLETE.\n")
    }
}
