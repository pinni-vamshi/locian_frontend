import Foundation

/// Controller for session management domain logic.
/// Lives in the CheckSession domain.
class CheckSessionLogic {
    static let shared = CheckSessionLogic()
    private init() {}
    
    /// Entry point for app launch session verification
    func checkUserSession() {
        let appState = AppStateManager.shared
        // STARTING SESSION CHECK...
        appState.isLoadingSession = true

        // 1. Check if session token exists locally
        guard let token = appState.authToken, !token.isEmpty else {
            // No token found. Redirecting to Login.
            appState.clearUserData()
            appState.isLoggedIn = false
            appState.isLoadingSession = false
            return
        }

        // Valid token found in cache.
        
        // 2. Set logged in state immediately (No redundant validation call)
        appState.isLoggedIn = true
        appState.isOffline = false
        appState.isLoadingSession = false
        
        // 3. Load user data from cache (Profession, Native Lang, etc.)
        appState.loadUserData()
        // User context loaded from local cache.
        
        // 4. Trigger REAL-TIME History & Recommendation Load (Discovery will handle live data)
        print("🚀 [CheckSessionLogic] Triggering real-time initial data load...")
        appState.loadInitialData()
        // Initial data loading triggered...

        // 5. Decision: Do we need to check languages via API?
        if appState.hasValidLanguagePair() {
            // Languages are valid in cache. BYPASSING language API calls.
            
            // Sequence Notification Permission AFTER Location Discovery (Delay 8s)
            // Only ask once per install to prevent spam
            if !UserDefaults.standard.bool(forKey: "hasRequestedNotificationPermission") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    NotificationManager.shared.ensureNotificationAccess { _ in
                        UserDefaults.standard.set(true, forKey: "hasRequestedNotificationPermission")
                    }
                }
            }
            
            // Ready for Timeline Fetch (SceneView will trigger).
        } else {
            // Language config missing or invalid. Triggering recovery flow...
            // Fallback: Check/Set languages via API if cache is empty/invalid
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                appState.checkLanguagePairsAndShowModalIfNeeded()
            }
            
            // Sequence Notification Permission AFTER Language Modal and Location (Delay 15s)
            if !UserDefaults.standard.bool(forKey: "hasRequestedNotificationPermission") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                    NotificationManager.shared.ensureNotificationAccess { _ in
                        UserDefaults.standard.set(true, forKey: "hasRequestedNotificationPermission")
                    }
                }
            }
        }
        
        
        // SESSION CHECK COMPLETE.
    }
}
