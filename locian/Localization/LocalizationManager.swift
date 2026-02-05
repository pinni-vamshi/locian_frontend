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
        case .hindi:
            currentStrings = HindiStrings()
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
    case login = "login"
    case register = "register"
    case settings = "settings"
    case back = "back"
    case done = "done"
    case cancel = "cancel"
    case save = "save"
    case delete = "delete"
    case add = "add"
    case remove = "remove"
    case edit = "edit"
    
    // Tab Bar
    case learnTab = "learnTab"
    case addTab = "addTab"
    case progressTab = "progressTab"
    case settingsTab = "settingsTab"
    
    // Quiz
    // Vocabulary
    case loading = "loading"
    
    // Scene
    // Scene Places
    case user = "user"
    case unknownPlace = "unknownPlace"
    case noLanguageAvailable = "noLanguageAvailable"
    case noInternetConnection = "noInternetConnection"
    case retry = "retry"
    case tapToGetMoments = "tapToGetMoments"
    case startLearningThisMoment = "startLearningThisMoment"
    case daysLabel = "daysLabel"
                
     // New Settings Keys
    case systemLanguage = "systemLanguage"
    case targetLanguages = "targetLanguages"
    case pastLanguagesArchived = "pastLanguagesArchived"
    case theme = "theme"
    case logout = "logout"
    case learnNewLanguage = "learnNewLanguage"
    case profile = "profile"
    case addLanguagePair = "addLanguagePair"
    case otherPlaces = "otherPlaces"
    case deleteAllData = "deleteAllData"
    case deleteAccount = "deleteAccount"
    case selectLevel = "selectLevel"
    case proFeatures = "proFeatures"
    case showSimilarWordsToggle = "showSimilarWordsToggle"
    case speaks = "speaks"
    case neuralEngine = "neuralEngine"
                                
    // Scene & History Labels
    case cameraLabel = "cameraLabel"
    case galleryLabel = "galleryLabel"
    case nextUp = "nextUp"
    case historyLog = "historyLog"

    case moments = "moments"
    case pastMoments = "pastMoments"
    case welcomeLabel = "welcomeLabel"
    case noUpcomingPlaces = "noUpcomingPlaces"
    case noDetailsRecorded = "noDetailsRecorded"

    case startLearningLabel = "startLearningLabel"
    case continueLearningLabel = "continueLearningLabel"
    case noPastMomentsFor = "noPastMomentsFor"
    case useCameraToStartLearning = "useCameraToStartLearning"
    case previouslyLearning = "previouslyLearning"
    case noHistoryRecorded = "noHistoryRecorded"
    case tapNextUpToGenerate = "tapNextUpToGenerate"
    case generatingHistory = "generatingHistory"
    case generatingMoments = "generatingMoments"
    case analyzingImage = "analyzingImage"
    
    // Progress & Streak
    case startPracticingMessage = "startPracticingMessage"
    case consistencyQuote = "consistencyQuote"
    case practiceDateSavingDisabled = "practiceDateSavingDisabled"
    
    // Day Names (Short)
    case sunShort = "sunShort"
    case monShort = "monShort"
    case tueShort = "tueShort"
    case wedShort = "wedShort"
    case thuShort = "thuShort"
    case friShort = "friShort"
    case satShort = "satShort"
    
    // Settings
                    case noLanguagePairsAdded = "noLanguagePairsAdded"
    case setDefault = "setDefault"
    case defaultText = "defaultText"
        case signOutFromAccount = "signOutFromAccount"
        case permanentlyDeleteAccount = "permanentlyDeleteAccount"
    case currentLevel = "currentLevel"
    case selectPhoto = "selectPhoto"
    case camera = "camera"
    case photoLibrary = "photoLibrary"
    case selectTime = "selectTime"
    case hour = "hour"
    case minute = "minute"
    case addTime = "addTime"
    case areYouSureLogout = "areYouSureLogout"
    case areYouSureDeleteAccount = "areYouSureDeleteAccount"
    case nativeLanguage = "nativeLanguage"
    case selectNativeLanguage = "selectNativeLanguage"
    case targetLanguage = "targetLanguage"
    case selectTargetLanguage = "selectTargetLanguage"
        case targetLanguageDescription = "targetLanguageDescription"
                    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case currentlyLearning = "currentlyLearning"
    case learn = "learn"
        
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
    case locianHeading = "locianHeading"
    case locianDescription = "locianDescription"
    case awarenessHeading = "awarenessHeading"
    case awarenessDescription = "awarenessDescription"
            case breakdownHeading = "breakdownHeading"
    case breakdownDescription = "breakdownDescription"
    case progressHeading = "progressHeading"
    case progressDescription = "progressDescription"
    case readyHeading = "readyHeading"
    case readyDescription = "readyDescription"
    
    // Onboarding additional strings
    case loginOrRegister = "loginOrRegister"
    case pageIndicator = "pageIndicator"
    case selectLanguageDescription = "selectLanguageDescription"
    
    // Welcome View
    case fromWhereYouStand = "fromWhereYouStand"
    case toEveryWord = "toEveryWord"
    case everyWord = "everyWord"
    case youNeed = "youNeed"
    case lessonEngine = "lessonEngine"
    
    // Brain Awareness View
    case nodesLive = "nodesLive"
    case locEngineVersion = "locEngineVersion"
    case holoGridActive = "holoGridActive"
    case adaCr02 = "adaCr02"
    case your = "your"
    case places = "places"
    case lessons = "lessons"
    case yourPlaces = "yourPlaces"
    case yourLessons = "yourLessons"
    case nearbyCafes = "nearbyCafes"
    case unlockOrderFlow = "unlockOrderFlow"
    case modules = "modules"
    case activeHubs = "activeHubs"
    case synthesizeGym = "synthesizeGym"
    case vocabulary = "vocabulary"
    case locationOpportunity = "locationOpportunity"
    
    // Language Inputs View
    case module03 = "module03"
    case notJustMemorization = "notJustMemorization"
    case philosophy = "philosophy"
    case locianTeaches = "locianTeaches"
    case think = "think"
    case inTargetLanguage = "inTargetLanguage"
    case patternBasedLearning = "patternBasedLearning"
    case patternBasedDesc = "patternBasedDesc"
    case situationalIntelligence = "situationalIntelligence"
    case situationalDesc = "situationalDesc"
    case adaptiveDrills = "adaptiveDrills"
    case adaptiveDesc = "adaptiveDesc"
    
    // Language Progress View
    case systemReady = "systemReady"
    case quickSetup = "quickSetup"
    case levelB2 = "levelB2"
    case authorized = "authorized"
    case notificationsPermission = "notificationsPermission"
    case notificationsDesc = "notificationsDesc"
    case microphonePermission = "microphonePermission"
    case microphoneDesc = "microphoneDesc"
    case geolocationPermission = "geolocationPermission"
    case geolocationDesc = "geolocationDesc"
    case granted = "granted"
    case allow = "allow"
    case skip = "skip"

    // Onboarding Container
    case letsStart = "letsStart"
    case continueText = "continueText"
    
    // Onboarding Lesson
    case wordTenses = "wordTenses"
    case similarWords = "similarWords"
    case wordBreakdown = "wordBreakdown"
    case consonant = "consonant"
    case vowel = "vowel"
    
    // Quiz/Check
    case adaptiveQuiz = "adaptiveQuiz"
    case adaptiveQuizDescription = "adaptiveQuizDescription"
    case wordCheck = "wordCheck"
    case wordCheckDescription = "wordCheckDescription"
    case wordCheckExamplePrompt = "wordCheckExamplePrompt"
    case quizPrompt = "quizPrompt"
    case answerConfirmation = "answerConfirmation"
    case tryAgain = "tryAgain"
    case verify = "verify"
    case selectProfession = "selectProfession"
    
    // Login
    case selectProfessionInstruction = "selectProfessionInstruction"
    case showMore = "showMore"
    case showLess = "showLess"
    case forReview = "forReview"
    case username = "username"
    case phoneNumber = "phoneNumber"
    case guestLogin = "guestLogin"
    case authenticatingUser = "authenticatingUser" // Added for redesign
    case bySigningInYouAgreeToOur = "bySigningInYouAgreeToOur" // Added for redesign
    case termsOfService = "termsOfService" // Added for redesign
    case privacyPolicy = "privacyPolicy" // Added for redesign
    case selectUserProfession = "selectUserProfession" // Added for redesign
    
    // Quick Look
    // Streak
    case editYourStreaks = "editYourStreaks"
    case editStreaks = "editStreaks"
    case selectDatesToAddOrRemove = "selectDatesToAddOrRemove"
    case saving = "saving"
    
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
    case studiedTime = "studiedTime"
    case currentLabel = "currentLabel"
    case streakLabel = "streakLabel"
    case longestLabel = "longestLabel"
    
    // Chronotypes
    case earlyBird = "earlyBird"
    case earlyBirdDesc = "earlyBirdDesc"
    case dayWalker = "dayWalker"
    case dayWalkerDesc = "dayWalkerDesc"
    case nightOwl = "nightOwl"
    case nightOwlDesc = "nightOwlDesc"
    
    // UI Common
    
    // Phase 2 Keys
    case currentStreak = "currentStreak"
    case notSet = "notSet"
    case past = "past"
    case present = "present"
    case future = "future"
    case learnWord = "learnWord"
    case languageAddedSuccessfully = "languageAddedSuccessfully"
    case failedToAddLanguage = "failedToAddLanguage"
    case pleaseSelectLanguage = "pleaseSelectLanguage"
    case systemConfig = "systemConfig"
    case statusOnFire = "statusOnFire"
    case youPracticed = "youPracticed"
    case yesterday = "yesterday"
    case checkInNow = "checkInNow"
    case nextGoal = "nextGoal"
    case reward = "reward"
    case historyLogProgress = "historyLogProgress"
    
    // New Progress Design
    case streakStatus = "streakStatus"
    case streakLog = "streakLog"
    case consistency = "consistency"
    case consistencyHigh = "consistencyHigh"
    case consistencyMedium = "consistencyMedium"
    case consistencyLow = "consistencyLow"
    case progress = "progress"
    case current = "current"
    case longest = "longest"
    case days = "days"
    case reachMilestone = "reachMilestone"
    case nextMilestone = "nextMilestone"
    case actionRequired = "actionRequired"
    case logActivity = "logActivity"
    case maintainStreak = "maintainStreak"
    case manualEntry = "manualEntry"
    case longestStreakLabel = "longestStreakLabel"
    case streakData = "streakData"
    case activeLabel = "activeLabel"
    case missedLabel = "missedLabel"
    case saveChanges = "saveChanges"
    case discardChanges = "discardChanges"
    case editLabel = "editLabel"
    case lastPracticed = "lastPracticed"
    case addLanguagePairToSeeProgress = "addLanguagePairToSeeProgress"
    case noNewPlace = "noNewPlace"
    case addNewPlaceInstruction = "addNewPlaceInstruction"
    case start = "start"
    case callingAI = "callingAI"
    case preparingLesson = "preparingLesson"
    
    // Advanced Stats
    case skillBalance = "skillBalance"
    case fluencyVelocity = "fluencyVelocity"
    case vocabVault = "vocabVault"
    case chronotype = "chronotype"
    case timeMastery = "timeMastery"
    case wordsMastered = "wordsMastered"
    case patternsMastered = "patternsMastered"
    case avgResponseTime = "avgResponseTime"
    case patternGalaxy = "patternGalaxy"
    case typeYourMoment = "typeYourMoment"
    

}

// MARK: - Localized Strings Protocol (for LocalizationManager)
protocol LocalizedStrings {
    func getString(for key: StringKey) -> String
}
