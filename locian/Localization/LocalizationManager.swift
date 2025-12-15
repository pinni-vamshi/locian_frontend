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
            .sink { [weak self] newLanguage in
                self?.currentLanguage = newLanguage
            }
            .store(in: &cancellables)
        
        loadStrings()
    }
    
    private func loadStrings() {
        switch currentLanguage {
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
    case languagePairs = "languagePairs"
    case notifications = "notifications"
    case aesthetics = "aesthetics"
    case account = "account"
    case appLanguage = "appLanguage"
    
    // Common
    case login = "login"
    case register = "register"
    case settings = "settings"
    case home = "home"
    case back = "back"
    case next = "next"
    case previous = "previous"
    case done = "done"
    case cancel = "cancel"
    case save = "save"
    case delete = "delete"
    case add = "add"
    case remove = "remove"
    case edit = "edit"
    
    // Quiz
    case quizCompleted = "quizCompleted"
    case sessionCompleted = "sessionCompleted"
    case masteredEnvironment = "masteredEnvironment"
    case learnMoreAbout = "learnMoreAbout"
    case backToHome = "backToHome"
    case tryAgain = "tryAgain"
    case check = "check"
    
    // Vocabulary
    case exploreCategories = "exploreCategories"
    case testYourself = "testYourself"
    case similarWords = "similarWords"
    case wordTenses = "wordTenses"
    case wordBreakdown = "wordBreakdown"
    
    // Scene
    case analyzingImage = "analyzingImage"
    case imageAnalysisCompleted = "imageAnalysisCompleted"
    case imageSelected = "imageSelected"
    case placeNotSelected = "placeNotSelected"
    case locianChoose = "locianChoose"
    case chooseLanguages = "chooseLanguages"
    
    // Scene Places
    case lociansChoice = "lociansChoice"
    case airport = "airport"
    case cafe = "cafe"
    case gym = "gym"
    case library = "library"
    case office = "office"
    case park = "park"
    case restaurant = "restaurant"
    case shoppingMall = "shoppingMall"
    case travelling = "travelling"
    case university = "university"
    
    // Settings
    case enableNotifications = "enableNotifications"
    case thisPlace = "thisPlace"
    case tapOnAnySection = "tapOnAnySection"
    case addNewLanguagePair = "addNewLanguagePair"
    case noLanguagePairsAdded = "noLanguagePairsAdded"
    case setDefault = "setDefault"
    case defaultText = "defaultText"
    case user = "user"
    case noPhone = "noPhone"
    case signOutFromAccount = "signOutFromAccount"
    case removeAllPracticeData = "removeAllPracticeData"
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
    case addPair = "addPair"
    case adding = "adding"
    case failedToAddLanguagePair = "failedToAddLanguagePair"
    case settingAsDefault = "settingAsDefault"
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    // Theme color names
    case neonGreen = "neonGreen"
    case cyanMist = "cyanMist"
    case solarAmber = "solarAmber"
    case violetHaze = "violetHaze"
    case silverPulse = "silverPulse"
    case softPink = "softPink"
    
    // Quiz
    case goBack = "goBack"
    case fillInTheBlank = "fillInTheBlank"
    case arrangeWordsInOrder = "arrangeWordsInOrder"
    case tapWordsBelowToAdd = "tapWordsBelowToAdd"
    case availableWords = "availableWords"
    case correctAnswer = "correctAnswer"
    
    // Common
    case error = "error"
    case ok = "ok"
    case close = "close"
    
    // Onboarding
    case locianHeading = "locianHeading"
    case locianDescription = "locianDescription"
    case awarenessHeading = "awarenessHeading"
    case awarenessDescription = "awarenessDescription"
    case inputsHeading = "inputsHeading"
    case inputsDescription = "inputsDescription"
    case breakdownHeading = "breakdownHeading"
    case breakdownDescription = "breakdownDescription"
    case progressHeading = "progressHeading"
    case progressDescription = "progressDescription"
    case readyHeading = "readyHeading"
    case readyDescription = "readyDescription"
    
    // Onboarding additional strings
    case loginOrRegister = "loginOrRegister"
    case pageIndicator = "pageIndicator"
    case tapToNavigate = "tapToNavigate"
    case selectAppLanguage = "selectAppLanguage"
    case selectLanguageDescription = "selectLanguageDescription"
    
    // Login
    case username = "username"
    case phoneNumber = "phoneNumber"
    case sending = "sending"
    case verifying = "verifying"
    case verifyOTP = "verifyOTP"
    case sendOTP = "sendOTP"
    case resendOTP = "resendOTP"
    case resendOTPIn = "resendOTPIn"
    case changePhoneNumber = "changePhoneNumber"
    case loginOrRegisterDescription = "loginOrRegisterDescription"
    case guestLogin = "guestLogin"
    case guestLoginDescription = "guestLoginDescription"
    
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
    case other = "other"
}

// MARK: - Localized Strings Protocol (for LocalizationManager)
protocol LocalizedStrings {
    func getString(for key: StringKey) -> String
}

