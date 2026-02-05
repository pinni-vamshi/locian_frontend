//
//  AppStateManager.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    // MARK: - Theme State
    @Published var selectedTheme: String = "Neon Green" {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }
    
    // MARK: - Universal Color (Computed from selectedTheme)
    // Uses centralized ThemeColors helper - single source of truth
    var selectedColor: Color {
        return ThemeColors.getColor(for: selectedTheme)
    }
    
    // Static version for backward compatibility (uses instance theme via UserDefaults)
    static var selectedColor: Color {
            if let themeName = UserDefaults.standard.string(forKey: "selectedTheme") {
            return ThemeColors.getColor(for: themeName)
        }
        return ThemeColors.getColor(for: "Neon Green") // Default
    }
    
    // MARK: - Onboarding State
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    // MARK: - Auth State
    @Published var authToken: String? {
        didSet {
            if let token = authToken {
                UserDefaults.standard.set(token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }
    
    @Published var isLoggedIn: Bool = false
    @Published var isLoadingSession: Bool = false
    @Published var isOffline: Bool = false
    
    
    // MARK: - User Data (Persistent)
    @Published var username: String = "" {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    @Published var userPhoneNumber: String = "" {
        didSet {
            UserDefaults.standard.set(userPhoneNumber, forKey: "userPhoneNumber")
        }
    }
    
    @Published var profession: String = "" {
        didSet {
            UserDefaults.standard.set(profession, forKey: "profession")
        }
    }
    
    // MARK: - Notifications State
    @Published var notificationsMorning: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsMorning, forKey: "notificationsMorning")
            updateNotificationSchedules()
            }
        }
    
    @Published var notificationsAfternoon: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsAfternoon, forKey: "notificationsAfternoon")
            updateNotificationSchedules()
        }
    }
    
    @Published var notificationsEvening: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEvening, forKey: "notificationsEvening")
            updateNotificationSchedules()
        }
    }
    
    
    // MARK: - Quick Recall Toggle (for floating button)
    
    @Published var profileImageData: Data? {
        didSet {
            if let data = profileImageData {
                UserDefaults.standard.set(data, forKey: "profileImage")
            } else {
                UserDefaults.standard.removeObject(forKey: "profileImage")
            }
        }
    }
    
    // Removed legacy nearby places/location cache
    
    // MARK: - App Persistence Toggles
    @Published var isNotificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
        }
    }
    
    @Published var isLocationTrackingEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isLocationTrackingEnabled, forKey: "isLocationTrackingEnabled")
        }
    }
    
    @Published var showDiagnosticBorders: Bool = false {
        didSet {
            UserDefaults.standard.set(showDiagnosticBorders, forKey: "showDiagnosticBorders")
        }
    }
    
    // MARK: - Authentication State
    @Published var isAuthenticating: Bool = false
    @Published var authError: String?
    @Published var showAuthError: Bool = false
    
    // Internal Apple sign-in state
    var appleAuthNonce: String?
    var applePendingDetails: ApplePendingUserDetails?
    
    // MARK: - Language State
    @Published var showGlobalLanguageModal: Bool = false
    @Published var showFirstLaunchLanguageModal: Bool = false
    @Published var languageSelectionMode: LanguageSelectionFlowMode = .onboarding
    @Published var nativeLanguage: String = "" {
        didSet {
            UserDefaults.standard.set(nativeLanguage, forKey: "userNativeLanguage")
        }
    }
    @Published var userLanguagePairs: [LanguagePair] = [] {
        didSet {
            // Auto-save to UserDefaults when changed
            if let encoded = try? JSONEncoder().encode(userLanguagePairs) {
                UserDefaults.standard.set(encoded, forKey: "userLanguagePairs")
            }
        }
    }
    @Published var shouldAttemptInferInterest: Bool = false
    @Published var shouldFocusLanguagePairs: Bool = false
    @Published var isLoadingLanguages: Bool = false
    @Published var hasLoadedLanguages: Bool = false // Tracks if we've fetched languages this session
    
    // MARK: - App Language State
    @Published var appLanguage: String = "English" {
        didSet {
            // Auto-save to UserDefaults when changed
            UserDefaults.standard.set(appLanguage, forKey: "appLanguage")
        }
    }
    
    // Available app languages
    static let availableAppLanguages: [String] = [
        "English",
        "Japanese",
        "Hindi",
        "Telugu",
        "Tamil",
        "French",
        "German",
        "Spanish",
        "Chinese",
        "Korean",
        "Russian",
        "Malayalam"
    ]
    
    // MARK: - Image Analysis State
    @Published var isAnalyzingImage: Bool = false
    @Published var imageAnalysisResult: String?  // Only place_name (for UI display)
    @Published var imageAnalysisSituations: [UnifiedMomentSection]?  // Unified Structure
    @Published var imageAnalysisDetail: String?  // Detail field (for vocabulary generation)
    
    // MARK: - Studied Places (New)
    // EPHEMERAL - DO NOT PERSIST (In-Memory Only)
    @Published var timeline: TimelineData? = nil
    @Published var isLoadingTimeline: Bool = false // Tracks if timeline request is in flight
    @Published var hasInitialHistoryLoaded: Bool = false // Tracks if we've fetched initial history this session
    
    @Published var studiedHours: Set<Int> = [] // Hours when practice occurred
    
    // MARK: - Infer Interest State
    @Published var isInferringInterest: Bool = false
    @Published var inferredPlaceCategory: String? {
        didSet {
            if let category = inferredPlaceCategory {
                UserDefaults.standard.set(category, forKey: "inferredPlaceCategory")
            } else {
                UserDefaults.standard.removeObject(forKey: "inferredPlaceCategory")
            }
        }
    }
    
    // Track last inference time for cooldown (15 minutes) - persisted in UserDefaults
    var lastInferenceTime: Date? {
        get {
            if let timeInterval = UserDefaults.standard.object(forKey: "lastInferenceTime") as? TimeInterval {
                return Date(timeIntervalSince1970: timeInterval)
            }
            return nil
        }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "lastInferenceTime")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastInferenceTime")
            }
        }
    }
    
    
    // MARK: - Practice Words Selection State (Centralized)
    // Stores selected words for practice: first 5 clicked words, then non-clicked words
    // This remains consistent even when user navigates back
    
    // Removed legacy practice state cache
    
    // Removed legacy practice/conversation navigation and state
    
    
    // MARK: - Navigation State
    @Published var shouldShowSettingsView: Bool = false
    @Published var isLessonActive: Bool = false
    
    // MARK: - Conversation Quiz State
    
    // MARK: - Guest Login State
    @Published var isGuestLoginLoading: Bool = false
    @Published var showGuestLoginButton: Bool = false
    @Published var hasCheckedGuestLoginVisibility: Bool = false
    @Published var shouldCheckGuestLoginVisibility: Bool = false
    
    // MARK: - Deep Link State
    @Published var pendingDeepLinkPlace: String?
    @Published var pendingDeepLinkHour: Int?
    
    // MARK: - Initialization
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "Neon Green"
        
        // Confirm Ephemeral State
        print("ℹ️ [AppStateManager] Timeline is ephemeral. Starting clean (nil).")
        
        // Load persisted inferred place category
        self.inferredPlaceCategory = UserDefaults.standard.string(forKey: "inferredPlaceCategory")
        
        // Set English as default app language on first launch
        let hasSelectedLanguage = UserDefaults.standard.bool(forKey: "hasSelectedAppLanguage")
        if !hasSelectedLanguage {
            // First launch - set English as default and mark as selected
            // Don't show modal, just set it automatically
            LanguageManager.shared.currentLanguage = .english
            UserDefaults.standard.set(true, forKey: "hasSelectedAppLanguage")
            // Ensure appLanguage is also set
            self.appLanguage = "English"
        }
        
        // Load auth token to check if we should load user data
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
        
        // DO NOT load user data here - wait for session validation
        // Session validation will load user data if valid, or clear it if invalid
        // This prevents loading data when session is expired/invalid
        
        // Session validation will be done in ContentView.onAppear via checkUserSession()
        // Do NOT validate here to avoid race conditions and double validation
        
        // EARLY CACHE LOAD: Load language pairs immediately for streak display
        if let data = UserDefaults.standard.data(forKey: "userLanguagePairs"),
           let pairs = try? JSONDecoder().decode([LanguagePair].self, from: data) {
            self.userLanguagePairs = pairs
            print("📦 [AppStateManager] Loaded \(pairs.count) language pairs settings (init)")
        }
        
        // Load app persistence toggles
        self.isNotificationsEnabled = (UserDefaults.standard.object(forKey: "isNotificationsEnabled") as? Bool) ?? true
        self.isLocationTrackingEnabled = (UserDefaults.standard.object(forKey: "isLocationTrackingEnabled") as? Bool) ?? true
        self.showDiagnosticBorders = UserDefaults.standard.bool(forKey: "showDiagnosticBorders")
        
        // Initialize Smart Location Notifications
        SmartNotificationManager.shared.startMonitoring()
    }
    
    // MARK: - Load User Data (called after successful session validation)
    func loadUserData() {
        print("📁 [Cache] Loading user context from UserDefaults...")
        // Only load user data if we have a valid session token
        guard authToken != nil, !authToken!.isEmpty else {
            print("⚠️ [Cache] No auth token found. Skipping local data load.")
            clearUserData()
            return
        }
        
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.userPhoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") ?? ""
        self.profession = UserDefaults.standard.string(forKey: "profession") ?? ""
        self.nativeLanguage = UserDefaults.standard.string(forKey: "userNativeLanguage") ?? ""
        
        print("   - Username: \(username)")
        print("   - Profession: \(profession)")
        print("   - Native Lang: \(nativeLanguage)")
        
        // Load notification settings (default to true if not set)
        if UserDefaults.standard.object(forKey: "notificationsMorning") == nil {
            print("   - Notifications: Initializing defaults (all true)")
            self.notificationsMorning = true
            self.notificationsAfternoon = true
            self.notificationsEvening = true
        } else {
            self.notificationsMorning = UserDefaults.standard.bool(forKey: "notificationsMorning")
            self.notificationsEvening = UserDefaults.standard.bool(forKey: "notificationsEvening")
            print("   - Notifications: M-\(notificationsMorning) A-\(notificationsAfternoon) E-\(notificationsEvening)")
        }
        
        // ---------------------------------------------------------------------
        // 🚨 PROACTIVE NEURAL DOWNLOADS
        // Ensure both Native and Target models are ready as soon as user context is loaded
        // ---------------------------------------------------------------------
        var proactiveCodes = Set([self.nativeLanguage])
        self.userLanguagePairs.forEach { proactiveCodes.insert($0.target_language) }
        
        for code in proactiveCodes where !code.isEmpty {
            EmbeddingService.downloadModel(for: code) { success in
                 print("🧠 [Proactive] Model asset download for '\(code)': \(success ? "SUCCESS" : "FAILED/NOT_NEEDED")")
            }
        }
        
        // Profile image and language pairs are now loaded in init() or via loadUserData()
        // but loadUserData() still refreshes them to ensure consistency after login.
        self.profileImageData = UserDefaults.standard.data(forKey: "profileImage")
        
        if let data = UserDefaults.standard.data(forKey: "userLanguagePairs"),
           let pairs = try? JSONDecoder().decode([LanguagePair].self, from: data) {
            self.userLanguagePairs = pairs
        }
        
        
        // Update notification schedules with cached times (if available)
        self.updateNotificationSchedules()
    }
    
    // MARK: - Camera & Gallery Methods
    func openCamera(completion: @escaping (Bool) -> Void) {
        PermissionsService.requestCameraAccess { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func openPhotoLibrary(completion: @escaping (Bool) -> Void) {
        PermissionsService.requestPhotoLibraryAccess { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Methods
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    // MARK: - Session Validation
    // validateStoredSession() removed - replaced by checkUserSession() to avoid race conditions
    
    // MARK: - Practice Recording
    func recordPracticeCompletion(for targetLanguage: String) {
        guard !targetLanguage.isEmpty else { return }
        
        // 1. Get Today's Date String (matches API format)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        
        // 2. Find and Update the Language Pair
        if let index = userLanguagePairs.firstIndex(where: { $0.target_language.lowercased() == targetLanguage.lowercased() }) {
            var updatedPair = userLanguagePairs[index]
            
            // Only add if not already present
            if !updatedPair.practice_dates.contains(todayStr) {
                print("📝 [AppStateManager] Recording local practice for \(targetLanguage): \(todayStr)")
                updatedPair.practice_dates.append(todayStr)
                
                // 3. Update the array (Triggers Persistence via didSet)
                userLanguagePairs[index] = updatedPair
            } else {
                print("📝 [AppStateManager] Practice already recorded for today (\(todayStr))")
            }
        } else {
            print("⚠️ [AppStateManager] Could not find language pair for \(targetLanguage) to record practice")
        }
    }
    
    // MARK: - Streak Logic
    var maxLongestStreak: Int {
        userLanguagePairs.map { $0.calculatedLongestStreak }.max() ?? 0
    }
    
    var maxCurrentStreak: Int {
        userLanguagePairs.map { $0.calculatedCurrentStreak }.max() ?? 0
    }
}

