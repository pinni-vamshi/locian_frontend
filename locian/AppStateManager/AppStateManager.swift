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
    
    // MARK: - Progress State
    /// Calculated study points based on practice streak and diversity of locations.
    /// (Practice Days * 10)
    var totalStudyPoints: Int {
        let practiceDaysCount = userLanguagePairs.first(where: { $0.is_default })?.practice_dates.count ?? 0
        return practiceDaysCount * 10
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
    
    @Published var minAnimationIntervalCompleted: Bool = false
    
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
    
    @Published var intentTimeline: [String: TimeSpanSnapshot]?
    
    @Published var currentTimeSpan: String? {
        didSet {
            UserDefaults.standard.set(currentTimeSpan, forKey: "currentTimeSpan")
        }
    }
    
    @Published var geoContexts: [String: GeoContextData] = [:]
    
    // MARK: - Notifications State
    // Simplified state: tracking is now derived from NotificationManager history
    
    @Published var lastNotificationFireDate: Date? {
        didSet {
            if let date = lastNotificationFireDate {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "lastNotificationFireDate")
            }
        }
    }
    
    // Removed redundant refresh tracking
    
    @Published var notifiedMomentIDs: Set<String> = [] {
        didSet { UserDefaults.standard.set(Array(notifiedMomentIDs), forKey: "notifiedMomentIDs") }
    }
    
    // Removed ignore streak tracking
    
    @Published var lastOpenedNotificationDate: Date? {
        didSet {
            if let date = lastOpenedNotificationDate {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "lastOpenedNotificationDate")
            }
        }
    }
    
    
    // Removed profile image data as per request
    
    
    // Removed legacy nearby places/location cache
    
    // MARK: - App Persistence Toggles
    
    @Published var isLocationTrackingEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isLocationTrackingEnabled, forKey: "isLocationTrackingEnabled")
            if !isLocationTrackingEnabled {
                // IMMEDIATELY wipe memory in LocationManager
                LocationManager.shared.clearLocationMemory()
                self.geoContexts = [:]
                self.intentTimeline = nil
                print("🧹 [AppStateManager] Location Disabled. Memory wiped.")
            }
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
    @Published var selectedProfession: String = ""
    
    // MARK: - Auth Status Management
    func resetAuthStatus() {
        authError = nil
        showAuthError = false
        isAuthenticating = false
    }
    
    // MARK: - Language State
    @Published var shouldShowNativeLanguageModal: Bool = false
    @Published var shouldShowTargetLanguageModal: Bool = false
    @Published var showFirstLaunchLanguageModal: Bool = false
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
    
    @Published var isRefreshingContext: Bool = false
    
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
    
    // MARK: - Deep Link State
    @Published var pendingDeepLinkPlace: String?
    @Published var pendingDeepLinkHour: Int?
    
    // MARK: - API Diagnostics
    @Published var dynamicApiMetadata: [(label: String, value: String)] = []
    
    // MARK: - Initialization
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "Neon Green"
        
        // Confirm Ephemeral State
        print("ℹ️ [AppStateManager] Timeline is ephemeral. Starting clean (nil).")
        
        // Load content for Learn Tab
        print("⚡️ [AppStateManager] Session Valid -> Ready for initial fetch.")
        
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
           let decoded = try? JSONDecoder().decode([LanguagePair].self, from: data) {
            self.userLanguagePairs = decoded
        } else {
            self.userLanguagePairs = []
        }
        
        // Load app persistence toggles
        self.isLocationTrackingEnabled = (UserDefaults.standard.object(forKey: "isLocationTrackingEnabled") as? Bool) ?? true
        self.showDiagnosticBorders = UserDefaults.standard.bool(forKey: "showDiagnosticBorders")
        
        // Initialize Smart Location Notifications - Async to avoid Init Cycle with AppStateManager.shared
        DispatchQueue.main.async {
            NotificationManager.shared.startMonitoring()
        }
        
        if let fireInterval = UserDefaults.standard.object(forKey: "lastNotificationFireDate") as? TimeInterval {
            self.lastNotificationFireDate = Date(timeIntervalSince1970: fireInterval)
        }
        
        if let momentIDs = UserDefaults.standard.stringArray(forKey: "notifiedMomentIDs") {
            self.notifiedMomentIDs = Set(momentIDs)
        }
        
        // Ephemeral only - never load from disk
        self.intentTimeline = nil
        self.geoContexts = [:]
        self.currentTimeSpan = nil
        

        
        // 🚀 PURE ON-DEMAND CLEANSE: Removed persistent audio caching

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
        
        if let data = UserDefaults.standard.data(forKey: "userLanguagePairs"),
           let decoded = try? JSONDecoder().decode([LanguagePair].self, from: data) {
            self.userLanguagePairs = decoded
        }
        
        print("   - Username: \(username)")
        print("   - Profession: \(profession)")
        print("   - Native Lang: \(nativeLanguage)")
        
        
        // ---------------------------------------------------------------------
        // 🚨 PROACTIVE NEURAL DOWNLOADS
        // Ensure both Native and Target models are ready as soon as user context is loaded
        // ---------------------------------------------------------------------
        var proactiveCodes = Set([self.nativeLanguage])
        self.userLanguagePairs.forEach { proactiveCodes.insert($0.target_language) }
        EmbeddingService.prepareModels(for: proactiveCodes)
        
    
        
        // Engagement Tracking
        // Interaction state cleaned up
        if let notified = UserDefaults.standard.stringArray(forKey: "notifiedMomentIDs") {
            self.notifiedMomentIDs = Set(notified)
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
    
    // MARK: - Initial Data Loading
    
    /// Fetch studied places and initialize recommendations during app launch
    func loadInitialData() {
        print("\n🚀 [AppStateManager] Unified Discovery Sequence Started...")
        
        guard !isRefreshingContext else {
            print("⚠️ [AppStateManager] Discovery already in progress. Skipping duplicate.")
            return
        }
        
        self.isRefreshingContext = true
        
        let group = DispatchGroup()
        
        // 1. Discover Daily Intent Map (Brain Profile / Study Points)
        group.enter()
        print("🧠 [AppStateManager] Phase 1: Fetching Daily Intent Map (Points/Timeline)...")
        UserIntentContextLogic.shared.discoverDailyIntent { success in
            print("🧠 [AppStateManager] Phase 1 Complete (Success: \(success))")
            group.leave()
        }
        
        // 2. Discover Moments (Handled by LearnTabState directly in V3)
        // Legacy Phase 2 removed as per V3 requirement.
        
        // Finalize: Unlock UI
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            print("🏁 [AppStateManager] Unified Discovery Sequence COMPLETED.")
            self.isRefreshingContext = false
        }
    }
}
