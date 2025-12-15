import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State var showingLanguageModal = false
    @State var languageModalMode: LanguageSelectionFlowMode = .addLearning
    @State var showingNativeLanguageModal = false
    @State var selectedNativeLanguageInModal: String = "" // Local state for modal selection
    @State var isUpdatingNativeLanguage = false
    @State var nativeLanguageStatusMessage: String = ""
    @State var nativeLanguageErrorMessage: String = ""
    @State var loadingDefaultIndex: Int? = nil
    @State var loadingDeleteIndex: Int? = nil
    @State var selectedPairForLevel: LanguagePair?
    @State var selectedPairForStreak: LanguagePair?
    @State var isProfileImageSelected: Bool = false
    @State var showingImagePicker = false
    @State var showingImagePickerCamera = false
    @State var showingImagePickerGallery = false
    @State private var cachedProfileImage: UIImage? = nil
    @State var isUpdatingProfession = false
    @State var professionUpdateError: String? = nil
    @State var showingLogoutConfirmation = false
    @State var showingDeleteAccountConfirmation = false
    @State var isLoggingOut = false
    @State var isDeletingAccount = false
    @State var logoutErrorMessage: String? = nil
    @State var isLanguagePairsExpanded = false
    @State var isAppLanguageExpanded = false
    @State var isPreviouslyLearningExpanded = false
    @State var isThemeExpanded = false
    @State var isNotificationsExpanded = false
    @State var isAdvancedFeaturesExpanded = false
    @State var isAccountExpanded = false
    @State var notificationTimes: [String] = [] // Only custom user-added times
    @State var customNotificationTimes: [String] = [] // User-added custom times
    @State var showingTimePicker = false
    
    // Load only custom notification times (no API times)
    func loadNotificationTimes() {
        // Only use custom user-added times
        notificationTimes = customNotificationTimes.sorted()
    }
    
    // Load custom notification times from UserDefaults, or set defaults if none exist
    func loadCustomNotificationTimes() {
        if let data = UserDefaults.standard.data(forKey: "customNotificationTimes"),
           let times = try? JSONDecoder().decode([String].self, from: data),
           !times.isEmpty {
            customNotificationTimes = times
        } else {
            // Set default times if none exist
            customNotificationTimes = ["10:00", "14:00", "18:30"]
            saveCustomNotificationTimes()
        }
    }
    
    // Save custom notification times to UserDefaults
    func saveCustomNotificationTimes() {
        if let encoded = try? JSONEncoder().encode(customNotificationTimes) {
            UserDefaults.standard.set(encoded, forKey: "customNotificationTimes")
        }
    }
    
    // Add custom notification time
    func addCustomNotificationTime(_ time: String) {
        if !customNotificationTimes.contains(time) {
            customNotificationTimes.append(time)
            saveCustomNotificationTimes()
            loadNotificationTimes()
            // Update notification schedules (only custom times)
            appState.updateNotificationSchedulesWithCustomTimes(customTimes: customNotificationTimes)
        }
    }
    
    // Remove custom notification time
    func removeCustomNotificationTime(_ time: String) {
        if let index = customNotificationTimes.firstIndex(of: time) {
            customNotificationTimes.remove(at: index)
            saveCustomNotificationTimes()
            loadNotificationTimes()
            // Update notification schedules (only custom times)
            appState.updateNotificationSchedulesWithCustomTimes(customTimes: customNotificationTimes)
        }
    }
    @State var viewOpacity: Double = 0
    @State var viewScale: CGFloat = 0.95
    @State var minHeadingFontSize: CGFloat = 50.0
    
    init(appState: AppStateManager) {
        self.appState = appState
    }
    
    // Computed binding for profile image with caching
    var profileImageBinding: Binding<UIImage?> {
        Binding(
            get: {
                // Use cached image if available
                if let cached = cachedProfileImage {
                    return cached
                }
                // Otherwise, create from data (cache will be updated in onAppear/onChange)
                if let data = appState.profileImageData, let image = UIImage(data: data) {
                    return image
                }
                return nil
            },
            set: { newImage in
                if let image = newImage, let data = image.jpegData(compressionQuality: 0.5) {
                    appState.profileImageData = data
                    // Update cache
                    cachedProfileImage = image
                } else {
                    appState.profileImageData = nil
                    // Clear cache
                    cachedProfileImage = nil
                }
            }
        )
    }
    
    // Theme colors - using localized names
    // Uses centralized ThemeColors helper - single source of truth
    var themeColors: [(name: String, localizedName: String, color: Color)] {
        return ThemeColors.themeColors(languageManager: languageManager)
    }
    
    // Helper function to format profession display
    func formatProfessionDisplay(_ profession: String) -> String {
        // Use localized profession strings
        let key = profession.lowercased().replacingOccurrences(of: "_", with: "")
        switch key {
        case "student": return LocalizationManager.shared.string(.student)
        case "softwareengineer": return LocalizationManager.shared.string(.softwareEngineer)
        case "teacher": return LocalizationManager.shared.string(.teacher)
        case "doctor": return LocalizationManager.shared.string(.doctor)
        case "artist": return LocalizationManager.shared.string(.artist)
        case "businessprofessional": return LocalizationManager.shared.string(.businessProfessional)
        case "salesormarketing": return LocalizationManager.shared.string(.salesOrMarketing)
        case "traveler": return LocalizationManager.shared.string(.traveler)
        case "homemaker": return LocalizationManager.shared.string(.homemaker)
        case "chef": return LocalizationManager.shared.string(.chef)
        case "police": return LocalizationManager.shared.string(.police)
        case "bankemployee": return LocalizationManager.shared.string(.bankEmployee)
        case "nurse": return LocalizationManager.shared.string(.nurse)
        case "designer": return LocalizationManager.shared.string(.designer)
        case "engineermanager": return LocalizationManager.shared.string(.engineerManager)
        case "photographer": return LocalizationManager.shared.string(.photographer)
        case "contentcreator": return LocalizationManager.shared.string(.contentCreator)
        case "other": return LocalizationManager.shared.string(.other)
        default:
            // Fallback to Title Case if profession not found
            return profession.split(separator: "_")
                .map { $0.capitalized }
                .joined(separator: " ")
        }
    }
    
    // Helper function to get available languages for native language modal
    func getAvailableLanguages() -> [LanguageSelectionModal.LanguageOption] {
        return [
            LanguageSelectionModal.LanguageOption(code: "ar", english: "Arabic", native: "العربية"),
            LanguageSelectionModal.LanguageOption(code: "zh", english: "Chinese", native: "中文"),
            LanguageSelectionModal.LanguageOption(code: "nl", english: "Dutch", native: "Nederlands"),
            LanguageSelectionModal.LanguageOption(code: "en", english: "English", native: "English"),
            LanguageSelectionModal.LanguageOption(code: "fr", english: "French", native: "Français"),
            LanguageSelectionModal.LanguageOption(code: "de", english: "German", native: "Deutsch"),
            LanguageSelectionModal.LanguageOption(code: "hi", english: "Hindi", native: "हिन्दी"),
            LanguageSelectionModal.LanguageOption(code: "it", english: "Italian", native: "Italiano"),
            LanguageSelectionModal.LanguageOption(code: "ja", english: "Japanese", native: "日本語"),
            LanguageSelectionModal.LanguageOption(code: "ko", english: "Korean", native: "한국어"),
            LanguageSelectionModal.LanguageOption(code: "ml", english: "Malayalam", native: "മലയാളം"),
            LanguageSelectionModal.LanguageOption(code: "pt", english: "Portuguese", native: "Português"),
            LanguageSelectionModal.LanguageOption(code: "ru", english: "Russian", native: "Русский"),
            LanguageSelectionModal.LanguageOption(code: "es", english: "Spanish", native: "Español"),
            LanguageSelectionModal.LanguageOption(code: "sv", english: "Swedish", native: "Svenska"),
            LanguageSelectionModal.LanguageOption(code: "ta", english: "Tamil", native: "தமிழ்"),
            LanguageSelectionModal.LanguageOption(code: "te", english: "Telugu", native: "తెలుగు"),
            LanguageSelectionModal.LanguageOption(code: "tr", english: "Turkish", native: "Türkçe")
        ]
    }
    
    // Helper function to calculate auto font size for language pairs
    func calculateAutoFontSize(text: String, availableWidth: CGFloat) -> CGFloat {
        let maxFontSize: CGFloat = 18
        let minFontSize: CGFloat = 10
        
        for fontSize in stride(from: maxFontSize, through: minFontSize, by: -1) {
            let font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).size(withAttributes: attributes)
            
            if size.width <= availableWidth {
                return fontSize
            }
        }
        
        return minFontSize
    }
    
    // Helper function to calculate required font size for section headings
    func calculateHeadingFontSize(text: String, availableWidth: CGFloat, maxFontSize: CGFloat = 45) -> CGFloat {
        let minFontSize: CGFloat = maxFontSize * 0.3 // Minimum scale factor
        
        // Use smaller step size for more precise calculation
        for fontSize in stride(from: maxFontSize, through: minFontSize, by: -0.5) {
            let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).size(withAttributes: attributes)
            
            // Add small margin to account for any rendering differences
            if size.width <= (availableWidth - 2) {
                return fontSize
            }
        }
        
        return minFontSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    // 1. Profile Section
                    profileSection
                    
                    // 2. Language Pair Section
                    languageSection(minFontSize: minHeadingFontSize)
                    
                    // 3. App Language Section
                    appLanguageSection(minFontSize: minHeadingFontSize)
                    
                    // 4. Notifications Section
                    notificationsSection(minFontSize: minHeadingFontSize)
                    
                    // 5. Pro Features Section (moved right after Notifications)
                    advancedFeaturesSection(minFontSize: minHeadingFontSize)
                    
                    // 6. Theme Section
                    themeSection(minFontSize: minHeadingFontSize)
                    
                    // 7. Account Section
                    accountSection(minFontSize: minHeadingFontSize)
                    
                    Spacer(minLength: 20)
                    
                    // Description text at bottom
                    Text(LocalizationManager.shared.string(.tapOnAnySection))
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, 15)
                        .padding(.bottom, 50)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
            }
            .opacity(viewOpacity)
            .scaleEffect(viewScale)
            .background(Color.black)
            .onChange(of: geometry.size.width) { _, _ in
                // Recalculate font size when view width changes
                let availableWidth = geometry.size.width - 40
                let sectionHeadings = [
                    LocalizationManager.shared.string(.languagePairs),
                    languageManager.settings.selectAppLanguage,
                    LocalizationManager.shared.string(.notifications),
                    LocalizationManager.shared.string(.aesthetics),
                    languageManager.settings.proFeatures,
                    LocalizationManager.shared.string(.account)
                ]
                let requiredSizes = sectionHeadings.map { heading in
                    calculateHeadingFontSize(text: heading, availableWidth: availableWidth)
                }
                minHeadingFontSize = requiredSizes.min() ?? 45.0
            }
            .onChange(of: languageManager.currentLanguage) { _, _ in
                // Recalculate font size when language changes
                let availableWidth = geometry.size.width - 40
                let sectionHeadings = [
                    LocalizationManager.shared.string(.languagePairs),
                    languageManager.settings.selectAppLanguage,
                    LocalizationManager.shared.string(.notifications),
                    LocalizationManager.shared.string(.aesthetics),
                    languageManager.settings.proFeatures,
                    LocalizationManager.shared.string(.account)
                ]
                let requiredSizes = sectionHeadings.map { heading in
                    calculateHeadingFontSize(text: heading, availableWidth: availableWidth)
                }
                minHeadingFontSize = requiredSizes.min() ?? 45.0
            }
            .onAppear {
                // Calculate initial font size
                let availableWidth = geometry.size.width - 40
                let sectionHeadings = [
                    LocalizationManager.shared.string(.languagePairs),
                    languageManager.settings.selectAppLanguage,
                    LocalizationManager.shared.string(.notifications),
                    LocalizationManager.shared.string(.aesthetics),
                    languageManager.settings.proFeatures,
                    LocalizationManager.shared.string(.account)
                ]
                let requiredSizes = sectionHeadings.map { heading in
                    calculateHeadingFontSize(text: heading, availableWidth: availableWidth)
                }
                minHeadingFontSize = requiredSizes.min() ?? 45.0
            }
        }
        .onAppear {
            // Animate view appearance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                viewOpacity = 1.0
                viewScale = 1.0
            }
            
            // Load custom notification times from UserDefaults (or set defaults)
            loadCustomNotificationTimes()
            // Load notification times (only custom)
            loadNotificationTimes()
            // Update notification schedules with current times
            appState.updateNotificationSchedulesWithCustomTimes(customTimes: customNotificationTimes)
            
            // Cache profile image on appear (only if not already cached)
            if cachedProfileImage == nil, let data = appState.profileImageData {
                cachedProfileImage = UIImage(data: data)
            }
            
            if appState.shouldFocusLanguagePairs {
                focusLanguagePairsSection()
            }
        }
        .onChange(of: appState.profileImageData) { oldValue, newValue in
            // Only update cache when profileImageData actually changes
            if let data = newValue {
                cachedProfileImage = UIImage(data: data)
            } else {
                cachedProfileImage = nil
            }
        }
        .onChange(of: appState.shouldFocusLanguagePairs) { _, shouldFocus in
            if shouldFocus {
                focusLanguagePairsSection()
            }
        }
        .fullScreenCover(isPresented: $showingLanguageModal) {
            LanguageSelectionModal(appState: appState, mode: languageModalMode)
                .id(languageModalMode) // Force recreation when mode changes
                .onAppear {
                }
        }
        .sheet(item: $selectedPairForLevel) { pair in
            LevelSelectionModal(appState: appState, pair: pair) {
                selectedPairForLevel = nil
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $selectedPairForStreak) { pair in
            StreakModal(appState: appState, pair: pair) {
                selectedPairForStreak = nil
            }
        }
        .fullScreenCover(isPresented: $showingNativeLanguageModal) {
            NativeLanguageModal(
                appState: appState,
                selectedNativeLanguage: $selectedNativeLanguageInModal, // Use local state binding
                isSubmitting: $isUpdatingNativeLanguage,
                statusMessage: $nativeLanguageStatusMessage,
                errorMessage: $nativeLanguageErrorMessage,
                availableLanguages: getAvailableLanguages(),
                languageOptions: {
                    getAvailableLanguages().filter { option in
                        // Filter out current native language
                        let currentCode = appState.nativeLanguage
                        let optionCode = appState.getLanguageCode(for: option.english)
                        return optionCode.lowercased() != currentCode.lowercased()
                    }
                },
                onSave: {
                    // Get the selected language name from local modal state
                    guard !selectedNativeLanguageInModal.isEmpty else {
                        nativeLanguageErrorMessage = "Please select a native language"
                        return
                    }
                    
                    isUpdatingNativeLanguage = true
                    nativeLanguageStatusMessage = ""
                    nativeLanguageErrorMessage = ""
                    
                    // Call API with selected language
                    appState.updateNativeLanguage(newNativeLanguage: selectedNativeLanguageInModal) { success in
                        DispatchQueue.main.async {
                            isUpdatingNativeLanguage = false
                            if success {
                                // Only update appState.nativeLanguage after successful API response
                                let selectedCode = appState.getLanguageCode(for: selectedNativeLanguageInModal)
                                appState.nativeLanguage = selectedCode
                                
                                nativeLanguageStatusMessage = "Native language updated successfully"
                                // Close modal after a short delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showingNativeLanguageModal = false
                                }
                            } else {
                                nativeLanguageErrorMessage = "Failed to update native language"
                            }
                        }
                    }
                }
            )
            .onAppear {
                // Initialize local state with current native language when modal opens
                let currentCode = appState.nativeLanguage
                let availableLanguages = getAvailableLanguages()
                selectedNativeLanguageInModal = availableLanguages.first { option in
                    appState.getLanguageCode(for: option.english).lowercased() == currentCode.lowercased()
                }?.english ?? ""
            }
        }
        .alert(LocalizationManager.shared.string(.error),
               isPresented: Binding(
                get: { logoutErrorMessage != nil },
                set: { if !$0 { logoutErrorMessage = nil } }
               )) {
            Button(LocalizationManager.shared.string(.ok), role: .cancel) {
                logoutErrorMessage = nil
            }
        } message: {
            Text(logoutErrorMessage ?? "")
        }
    }
    
    // Section implementations moved to dedicated extension files
    
    // Language pair section moved to extension
    
    // MARK: - App Language Section
    // App language section moved to extension
    
    // MARK: - Theme Section
    // Theme section moved to extension
    
    // Notifications section moved to extension
    
    // MARK: - Account Section
    // Account section moved to extension
    
    // MARK: - Helper Functions
    func performLogout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        appState.logoutViaBackend { success, errorMessage in
            isLoggingOut = false
            if success {
                NotificationCenter.default.post(name: NSNotification.Name("UserDidLogOut"), object: nil)
            } else {
                logoutErrorMessage = errorMessage ?? "Logout failed. Please try again."
            }
        }
    }
    
    private func performDeleteAccount() {
        isDeletingAccount = true
        appState.deleteAccount { success, _ in
            isDeletingAccount = false
            // The ContentView will automatically show LoginView when isLoggedIn is false
            // Show error to user if needed
        }
    }

    private func focusLanguagePairsSection() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isLanguagePairsExpanded = true
            isAppLanguageExpanded = false
            isThemeExpanded = false
            isNotificationsExpanded = false
            isAdvancedFeaturesExpanded = false
            isAccountExpanded = false
        }
        appState.shouldFocusLanguagePairs = false
    }
}

#Preview {
    SettingsView(appState: AppStateManager())
}

// MARK: - Level Selection Modal
struct LevelSelectionModal: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var languageManager = LanguageManager.shared
    let pair: LanguagePair
    let onDismiss: () -> Void
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    
    private var levels: [String] {
        ["BEGINNER", "INTERMEDIATE", "ADVANCED"]
    }
    
    private func getLocalizedLevel(_ level: String) -> String {
        switch level.uppercased() {
        case "BEGINNER":
            return languageManager.settings.beginner
        case "INTERMEDIATE":
            return languageManager.settings.intermediate
        case "ADVANCED":
            return languageManager.settings.advanced
        default:
            return level.capitalizingFirstLetter()
        }
    }
    
    var body: some View {
        let accentColor: Color = appState.selectedTheme == "Pure White" ? .white : appState.selectedColor
        let backgroundColor = accentColor
        
        VStack(spacing: 30) {
            // Header
            HStack {
                Text(languageManager.settings.selectLevel)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(LocalizationManager.shared.string(.done)) {
                    onDismiss()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Current level
            VStack(spacing: 10) {
                Text("\(LocalizationManager.shared.string(.currentLevel)): \(getLocalizedLevel(pair.user_level))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Text("\(pair.native_language.getLanguageName()) → \(pair.target_language.getLanguageName())")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            
            // Level buttons
            VStack(spacing: 12) {
                ForEach(levels, id: \.self) { level in
                    let isCurrentLevel = pair.user_level.uppercased() == level
                    Button(action: {
                        updateLevel(to: level)
                    }) {
                            Text(getLocalizedLevel(level))
                            .font(.system(size: isCurrentLevel ? 60 : 24,
                                          weight: isCurrentLevel ? .heavy : .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(isCurrentLevel ? 0.35 : 0.75)
                            .foregroundColor(isCurrentLevel ? .black : .black.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, isCurrentLevel ? 18 : 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .buttonPressAnimation()
                    .disabled(isLoading || isCurrentLevel)
                    .opacity(isLoading ? 0.5 : 1.0)
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 20)
            
            // Status messages
            if !isLoading && !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .ignoresSafeArea()
    }
    
    private func updateLevel(to level: String) {
        errorMessage = ""
        isLoading = true
        
        appState.updateLanguagePairLevel(nativeLanguage: pair.native_language, targetLanguage: pair.target_language, newLevel: level) { success in
            isLoading = false
            
            if success {
                onDismiss()
            } else {
                errorMessage = "Failed to update level. Please try again."
            }
        }
    }
}

// MARK: - String Extension
extension String {
    func capitalizingFirstLetter() -> String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst().lowercased()
    }
    
    func getLanguageName() -> String {
        let mapping: [String: String] = [
            "ar": "Arabic",
            "zh": "Chinese",
            "nl": "Dutch",
            "en": "English",
            "fr": "French",
            "de": "German",
            "hi": "Hindi",
            "it": "Italian",
            "ja": "Japanese",
            "ko": "Korean",
            "ml": "Malayalam",
            "pt": "Portuguese",
            "ru": "Russian",
            "es": "Spanish",
            "sv": "Swedish",
            "ta": "Tamil",
            "tr": "Turkish"
        ]
        return mapping[self] ?? self
    }
    
    func getLanguageDisplayName() -> String {
        let mapping: [String: (english: String, native: String)] = [
            "ar": ("Arabic", "العربية"),
            "arabic": ("Arabic", "العربية"),
            "zh": ("Chinese", "中文"),
            "chinese": ("Chinese", "中文"),
            "nl": ("Dutch", "Nederlands"),
            "dutch": ("Dutch", "Nederlands"),
            "en": ("English", "English"),
            "english": ("English", "English"),
            "fr": ("French", "Français"),
            "french": ("French", "Français"),
            "de": ("German", "Deutsch"),
            "german": ("German", "Deutsch"),
            "hi": ("Hindi", "हिन्दी"),
            "hindi": ("Hindi", "हिन्दी"),
            "it": ("Italian", "Italiano"),
            "italian": ("Italian", "Italiano"),
            "ja": ("Japanese", "日本語"),
            "japanese": ("Japanese", "日本語"),
            "ko": ("Korean", "한국어"),
            "korean": ("Korean", "한국어"),
            "ml": ("Malayalam", "മലയാളം"),
            "malayalam": ("Malayalam", "മലയാളം"),
            "pt": ("Portuguese", "Português"),
            "portuguese": ("Portuguese", "Português"),
            "ru": ("Russian", "Русский"),
            "russian": ("Russian", "Русский"),
            "es": ("Spanish", "Español"),
            "spanish": ("Spanish", "Español"),
            "sv": ("Swedish", "Svenska"),
            "swedish": ("Swedish", "Svenska"),
            "ta": ("Tamil", "தமிழ்"),
            "tamil": ("Tamil", "தமிழ்"),
            "te": ("Telugu", "తెలుగు"),
            "telugu": ("Telugu", "తెలుగు"),
            "tr": ("Turkish", "Türkçe"),
            "turkish": ("Turkish", "Türkçe")
        ]
        let key = self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let lang = mapping[key] {
            return "\(lang.english) (\(lang.native))"
        }
        return self
    }
}

// MARK: - Streak Modal (moved to StreakModal.swift)
// StreakModal and EditStreakModal are now in a separate file: StreakModal.swift

