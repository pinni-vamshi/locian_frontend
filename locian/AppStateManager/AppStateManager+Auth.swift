import SwiftUI
import Combine

extension AppStateManager {
    // MARK: - Clear User Data (called when session invalid/expired)
    func clearUserData() {
        
        // Clear user data
        authToken = nil
        username = ""
        userPhoneNumber = ""
        profession = ""
        nativeLanguage = ""
        userLanguagePairs = []
        profileImageData = nil
        inferredPlaceCategory = nil
        shouldAttemptInferInterest = false
        
        // Clear from UserDefaults
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
        UserDefaults.standard.removeObject(forKey: "profession")
        UserDefaults.standard.removeObject(forKey: "profileImage")
        UserDefaults.standard.removeObject(forKey: "userNativeLanguage")
        UserDefaults.standard.removeObject(forKey: "userLanguagePairs")
        
        // Clear notification data (keep preferences but clear API times)
        
        
    }
    
    // MARK: - Clear All Data (Centralized)
    func clearAllUserData() {
        // Clear auth token
        self.authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        
        // Clear user data
        self.username = ""
        self.userPhoneNumber = ""
        self.profession = ""
        self.profileImageData = nil
        
        
        // Cancel all scheduled notifications
        NotificationManager.shared.cancelAllNotifications()
        
        // Clear language state
        self.nativeLanguage = ""
        self.userLanguagePairs = []
        UserDefaults.standard.removeObject(forKey: "userNativeLanguage")
        UserDefaults.standard.removeObject(forKey: "userLanguagePairs")
        
        // Clear timeline/studied places (FIX: Persisting across accounts bug)
        self.timeline = nil
        self.hasInitialHistoryLoaded = false
        self.isLoadingTimeline = false
        
        // Clear inferred interest state
        self.inferredPlaceCategory = nil
        self.lastInferenceTime = nil
        
        // Location history removed - API handles everything
        
        // Recent places are now handled by API - no local cache to clear
        
        // Clear custom places
        UserDefaults.standard.removeObject(forKey: "com.locian.customPlaces")
        
        // Clear streak cache for all languages
        // Note: We clear all streak caches by iterating through userLanguagePairs
        // But since we're clearing userLanguagePairs above, we'll clear all streak-related UserDefaults keys
        let streakKeys = UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix("streak_data_") }
        for key in streakKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        
        
        
        
        // Clear all navigation states
        self.shouldShowSettingsView = false
        // Reset logged in state
        self.isLoggedIn = false
        self.isLoadingSession = false
        self.isOffline = false

        // Allow guest login visibility to be refreshed on next visit
        self.showGuestLoginButton = false
        self.hasCheckedGuestLoginVisibility = false
        self.shouldCheckGuestLoginVisibility = true
        
        // Clear all UserDefaults except onboarding state
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Restore onboarding state (don't reset it)
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
    }
    
    // MARK: - Logout (Local only, no backend call)
    func logoutLocalOnly(completion: (() -> Void)? = nil) {
        clearAllUserData()
        completion?()
    }
    
    // MARK: - Logout (Requires backend confirmation)
    func logoutViaBackend(completion: @escaping (Bool, String?) -> Void) {
        LogoutLogic.shared.logoutViaBackend(completion: completion)
    }
    
    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        DeleteAccountLogic.shared.deleteAccount(completion: completion)
    }
}
