//
//  LocalizationManager.swift
//  locian
//
//  Created for app language localization
//

import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            loadStrings()
        }
    }
    
    private var currentStrings: LocalizedStrings = EnglishStrings()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Sync with LanguageManager
        self.currentLanguage = LanguageManager.shared.currentLanguage
        
        // Observe LanguageManager changes
        LanguageManager.shared.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLanguage in
                guard let self = self else { return }
                self.currentLanguage = newLanguage
                // Explicitly notify observers
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
        
        loadStrings()
    }
    
    private func loadStrings() {
        print("📚 LOCALIZATION: Loading \(currentLanguage.rawValue) language file")
        
        // Resolve system language to actual language
        let languageToLoad: AppLanguage
        if currentLanguage == .system {
            languageToLoad = AppLanguage.detectSystemLanguage()
            print("📚 LOCALIZATION: System language detected as \(languageToLoad.rawValue)")
        } else {
            languageToLoad = currentLanguage
        }
        
        switch languageToLoad {
        case .system:
            // This shouldn't happen since we resolved .system above, but fallback to English
            currentStrings = EnglishStrings()
        case .english:
            currentStrings = EnglishStrings()
        case .japanese:
            currentStrings = JapaneseStrings()
        case .telugu:
            currentStrings = TeluguStrings()
        case .tamil:
            currentStrings = TamilStrings()
        case .french:
            currentStrings = FrenchStrings()
        case .german:
            currentStrings = GermanStrings()
        case .spanish:
            currentStrings = SpanishStrings()
        case .chinese:
            currentStrings = ChineseStrings()
        case .korean:
            currentStrings = KoreanStrings()
        case .russian:
            currentStrings = RussianStrings()
        case .malayalam:
            currentStrings = MalayalamStrings()
        }
        print("✅ LOCALIZATION: \(currentLanguage.rawValue) strings loaded successfully")
        // Notify observers that strings have changed
        objectWillChange.send()
    }
    
    // Get localized string
    func string(_ key: StringKey) -> String {
        return currentStrings.getString(for: key)
    }
}

// MARK: - String Keys
enum StringKey: String {
    // Settings
    case notifications = "notifications"
    case account = "account"
    
    // Common
    case settings = "settings"
    case done = "done"
    case cancel = "cancel"
    case delete = "delete"
    case edit = "edit"
    
    // Tab Bar
    case learnTab = "learnTab"
    case progressTab = "progressTab"
    
    // Quiz
    // Vocabulary
    case loading = "loading"
    
    // Scene
    // Scene Places
    case noInternetConnection = "noInternetConnection"
    case retry = "retry"
                
     // New Settings Keys
    case systemLanguage = "systemLanguage"
    case logout = "logout"
    case addLanguagePair = "addLanguagePair"
                                
    // Scene & History Labels
    case historyLog = "historyLog"


    case startLearningLabel = "startLearningLabel"
    
    // Progress & Streak
    
    // Day Names (Short)
    case sunShort = "sunShort"
    case monShort = "monShort"
    case tueShort = "tueShort"
    case wedShort = "wedShort"
    case thuShort = "thuShort"
    case friShort = "friShort"
    case satShort = "satShort"
    
    // Settings
    case currentLevel = "currentLevel"
    case areYouSureLogout = "areYouSureLogout"
    case areYouSureDeleteAccount = "areYouSureDeleteAccount"
    case nativeLanguage = "nativeLanguage"
    case selectTargetLanguage = "selectTargetLanguage"
        
    // Theme color names
    case neonGreen = "neonGreen"
    case neonFuchsia = "neonFuchsia"
    case electricIndigo = "electricIndigo"
    case graphiteBlack = "graphiteBlack"
    
    // Quiz
    // Common
    case error = "error"
    case ok = "ok"
    
    // Onboarding
    
    // Onboarding additional strings
    case selectLanguageDescription = "selectLanguageDescription"
    case whichLanguageDoYouSpeakComfortably = "whichLanguageDoYouSpeakComfortably"
    case chooseTheLanguageYouWantToMaster = "chooseTheLanguageYouWantToMaster"
    
    // (Onboarding localization removed — screens use hardcoded English)
    
    // Onboarding Lesson
    
    // Quiz/Check
    case adaptiveQuiz = "adaptiveQuiz"
    case adaptiveQuizDescription = "adaptiveQuizDescription"
    case wordCheck = "wordCheck"
    case wordCheckDescription = "wordCheckDescription"
    case wordCheckExamplePrompt = "wordCheckExamplePrompt"
    case quizPrompt = "quizPrompt"
    case answerConfirmation = "answerConfirmation"
    case tryAgain = "tryAgain"
    
    // Login
    case authenticatingUser = "authenticatingUser" // Added for redesign
    case selectUserProfession = "selectUserProfession" // Added for redesign
    
    // Quick Look
    // Streak
    
    // Professions
    case student = "student"
    case softwareEngineer = "softwareEngineer"
    case teacher = "teacher"
    case doctor = "doctor"
    case artist = "artist"
    case businessProfessional = "businessProfessional"
    case salesOrMarketing = "salesOrMarketing"
    case traveler = "traveler"
    case homemaker = "homemaker"
    case chef = "chef"
    case police = "police"
    case bankEmployee = "bankEmployee"
    case nurse = "nurse"
    case designer = "designer"
    case engineerManager = "engineerManager"
    case photographer = "photographer"
    case contentCreator = "contentCreator"
    case entrepreneur = "entrepreneur"
    case other = "other"
    
    // Stats Label
    case activityDistribution = "activityDistribution"
    
    // Chronotypes
    case earlyBird = "earlyBird"
    case earlyBirdDesc = "earlyBirdDesc"
    case dayWalker = "dayWalker"
    case dayWalkerDesc = "dayWalkerDesc"
    case nightOwl = "nightOwl"
    case nightOwlDesc = "nightOwlDesc"
    
    // UI Common
    
    // Phase 2 Keys
    case systemConfig = "systemConfig"
    
    // New Progress Design
    case streakStatus = "streakStatus"
    case addLanguagePairToSeeProgress = "addLanguagePairToSeeProgress"
    
    // Advanced Stats
    case chronotype = "chronotype"
    
    // Add Tab
    
    // Personalization Refresh
    
    
    
    // Notifications
    case smartNotificationExactPlace = "smartNotificationExactPlace"
}

// MARK: - Localized Strings Protocol (for LocalizationManager)
protocol LocalizedStrings {
    func getString(for key: StringKey) -> String
}
