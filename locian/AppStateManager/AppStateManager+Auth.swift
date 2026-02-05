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
        imageAnalysisResult = nil
        // Clear image analysis detail
        // imageAnalysisDetail = nil // This property doesn't exist in AppStateManager
        // inferredPlaceCategory = nil // This property doesn't exist in AppStateManager
        // shouldAttemptInferInterest = false // This property doesn't exist in AppStateManager
        
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
        
        // Reset notification settings to defaults (all true)
        self.notificationsMorning = true
        self.notificationsAfternoon = true
        self.notificationsEvening = true
        
        // Cancel all scheduled notifications
        NotificationService.shared.cancelAllNotifications()
        
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
        
        
        // Clear image analysis
        self.imageAnalysisResult = nil
        
        
        // Clear file storage data (previous images, quiz state, word cache, location history, etc.)
        FileStorageManager.shared.delete(forKey: "com.locian.previousImages")
        FileStorageManager.shared.delete(forKey: "com.locian.wordCache")
        FileStorageManager.shared.delete(forKey: "location_history_entries")
        FileStorageManager.shared.delete(forKey: "lastQuizResponseRawJSON")
        
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
        guard let token = authToken, !token.isEmpty else {
            clearAllUserData()
            completion(true, nil)
            return
        }
        
        let request = LogoutRequest(session_token: token)
        
        AuthAPIManager.shared.logout(request: request) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
            case .success(let response):
                if response.success {
                    self.clearAllUserData()
                    completion(true, response.message)
                } else {
                    let message = response.error ?? response.message ?? "Logout failed. Please try again."
                    completion(false, message)
                }
            }
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let token = authToken else {
            clearAllUserData()
            completion(false, "No session token found")
            return
        }
        
        let request = DeleteAccountRequest(session_token: token, confirm_deletion: true)
        
        AuthAPIManager.shared.deleteAccount(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        // Clear all user data and caches on successful deletion
                        self.clearAllUserData()
                        // Ensure user is logged out and taken to login screen
                        self.isLoggedIn = false
                        self.isLoadingSession = false
                        self.isOffline = false
                        completion(true, nil)
                    } else {
                        self.isOffline = true
                        self.isLoadingSession = true
                        self.isLoggedIn = false
                        completion(false, response.error ?? "Account deletion failed")
                    }
                case .failure(let error):
                    self.isOffline = true
                    self.isLoadingSession = true
                    self.isLoggedIn = false
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    func refreshNotificationSchedules() {
        let customTimes: [String]
        if let data = UserDefaults.standard.data(forKey: "customNotificationTimes"),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            customTimes = saved
        } else {
            customTimes = []
        }
        updateNotificationSchedulesWithCustomTimes(customTimes: customTimes)
    }
}
