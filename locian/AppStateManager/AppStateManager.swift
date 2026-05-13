//
//  AppStateManager.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import Combine

enum StartupDiscoveryStatus {
    case idle
    case loading
    case succeeded
    case failed
}

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
    @Published var onboardingEntryPage: Int = 0
    
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
    
    // MARK: - Notifications State
    // Simple: 3x daily notifications scheduled via NotificationManager.scheduleDailyNotifications()
    
    
    // Removed profile image data as per request
    
    
    // Removed legacy nearby places/location cache
    
    // MARK: - App Persistence Toggles
    
    @Published var isLocationTrackingEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isLocationTrackingEnabled, forKey: "isLocationTrackingEnabled")
            if !isLocationTrackingEnabled {
                // IMMEDIATELY wipe memory in LocationManager
                LocationManager.shared.clearLocationMemory()
                LocationManager.shared.disableIntentEventMonitoring()
                print("🧹 [AppStateManager] Location Disabled. Memory wiped.")
            }
        }
    }
    
    @Published var showDiagnosticBorders: Bool = false {
        didSet {
            UserDefaults.standard.set(showDiagnosticBorders, forKey: "showDiagnosticBorders")
        }
    }

    // MARK: - Learn coach tour (Settings → Learn)

    /// Incremented from Settings. ``LearnTabView`` presents when this value is greater than
    /// ``learnCoachTourManualTriggerPresentedUpTo`` and then advances the latter to match — so tab switches
    /// never replay the same request.
    @Published var learnCoachTourManualTrigger: Int = 0

    /// Highest ``learnCoachTourManualTrigger`` value the Learn tab has already opened the tour for.
    @Published var learnCoachTourManualTriggerPresentedUpTo: Int = 0

    func requestLearnCoachTourFromSettings() {
        learnCoachTourManualTrigger += 1
    }
    

    
    // MARK: - Authentication State
    @Published var isAuthenticating: Bool = false
    @Published var authError: String?
    @Published var showAuthError: Bool = false
    @Published var selectedProfession: String = ""
    @Published var selectedPlaces: Set<String> = []
    @Published var selectedTargetLanguages: Set<String> = []
    
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

    // MARK: - Startup Discovery Orchestration (Moments -> Intent)
    @Published var startupMomentsStatus: StartupDiscoveryStatus = .idle
    @Published var startupIntentStatus: StartupDiscoveryStatus = .idle
    @Published var startupRecommendations: [PlaceRecommendation] = []
    @Published var startupDiscoveryErrorMessage: String?

    @Published var hasTriggeredStartupDiscovery: Bool = false
    
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
        

        
        // 🚀 PURE ON-DEMAND CLEANSE: Removed persistent audio caching

        // 🌐 Fetch Dynamic Language Combinations from Server (Async to avoid circular initialization)
        DispatchQueue.main.async {
            GetAvailableLanguagesService.shared.fetch()
        }
    }
    
    // MARK: - Load User Data (called after successful session validation)
    func loadUserData() {
        print("📁 [Cache] Loading user context from UserDefaults (Async)...")
        // Only load user data if we have a valid session token
        guard authToken != nil, !authToken!.isEmpty else {
            print("⚠️ [Cache] No auth token found. Skipping local data load.")
            clearUserData()
            return
        }

        // Perform decoding on a background thread to prevent Main Thread hitches during startup
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let cachedUsername = UserDefaults.standard.string(forKey: "username") ?? ""
            let cachedPhone = UserDefaults.standard.string(forKey: "userPhoneNumber") ?? ""
            let cachedProfession = UserDefaults.standard.string(forKey: "profession") ?? ""
            let cachedNative = UserDefaults.standard.string(forKey: "userNativeLanguage") ?? ""
            
            var cachedPairs: [LanguagePair] = []
            if let data = UserDefaults.standard.data(forKey: "userLanguagePairs"),
               let decoded = try? JSONDecoder().decode([LanguagePair].self, from: data) {
                cachedPairs = decoded
            }
            
            // Proactive model prep also on background
            var proactiveCodes = Set([cachedNative])
            cachedPairs.forEach { proactiveCodes.insert($0.target_language) }
            EmbeddingService.prepareModels(for: proactiveCodes)

            DispatchQueue.main.async {
                self.username = cachedUsername
                self.userPhoneNumber = cachedPhone
                self.profession = cachedProfession
                self.nativeLanguage = cachedNative
                self.userLanguagePairs = cachedPairs
                
                print("   ✅ [Cache] Background Load Complete.")
                print("   - Username: \(self.username)")
                print("   - Profession: \(self.profession)")
                print("   - Native Lang: \(self.nativeLanguage)")
            }
        }
    }
    
    
    // MARK: - Methods
    func completeOnboarding() {
        onboardingEntryPage = 0
        hasCompletedOnboarding = true
    }

    func reopenOnboarding(at page: Int = 0) {
        onboardingEntryPage = max(0, page)
        hasCompletedOnboarding = false
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
        startStartupDiscoverySequence(force: false)
    }

    /// Deterministic startup discovery: DiscoverMoments must succeed before intent/points discovery runs.
    func startStartupDiscoverySequence(force: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if hasTriggeredStartupDiscovery && !force {
            completion?(startupMomentsStatus == .succeeded)
            return
        }

        guard !isRefreshingContext || force else {
            print("⚠️ [AppStateManager] Startup discovery already in progress. Skipping duplicate.")
            completion?(false)
            return
        }

        hasTriggeredStartupDiscovery = true
        isRefreshingContext = true
        startupDiscoveryErrorMessage = nil
        startupIntentStatus = .idle
        
        // 🚀 PHASE 1: Trigger Moments discovery during startup.
        self.startupMomentsStatus = .loading
        print("\n🚀 [AppStateManager] Startup Discovery Started (Phase 1 [Moments])...")
        
        DiscoverMomentsService.shared.discoverMoments { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.startupMomentsStatus = .succeeded
                    self.startupRecommendations = response.recommendations
                    print("✅ [AppStateManager] Moment Discovery Succeeded. Recommendations: \(self.startupRecommendations.count)")
                case .failure(let error):
                    self.startupMomentsStatus = .failed
                    self.startupDiscoveryErrorMessage = error.localizedDescription
                    print("❌ [AppStateManager] Moment Discovery Failed: \(error.localizedDescription)")
                }
                
                // Finalize startup discovery
                self.startupIntentStatus = .idle
                self.isRefreshingContext = false
                print("🏁 [AppStateManager] Startup Discovery Completed.")
                
                completion?(self.startupMomentsStatus == .succeeded)
            }
        }
    }
    
}
