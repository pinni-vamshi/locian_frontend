//
//  AppStrings.swift
//  locian
//
//  Protocol for app strings
//

import Foundation

protocol AppStrings {
    var quiz: QuizStrings { get }
    var settings: SettingsStrings { get }
    var vocabulary: VocabularyStrings { get }
    var scene: SceneStrings { get }
    var login: LoginStrings { get }
    var onboarding: OnboardingStrings { get }
    var common: CommonStrings { get }
    var customPractice: CustomPracticeStrings { get }
    var progress: ProgressStrings { get }
    
    func getString(_ key: String) -> String
}

// MARK: - String Groups
struct QuizStrings {
    let completed: String
    let masteredEnvironment: String
    let learnMoreAbout: String
    let backToHome: String
    let next: String
    let previous: String
    let check: String
    let tryAgain: String
    let shuffled: String
    let noQuizAvailable: String
    let question: String
    let correct: String
    let incorrect: String
    let notAttempted: String
}

struct SettingsStrings {
    let languagePairs: String
    let notifications: String
    let appearance: String
    let account: String
    let profile: String
    let addLanguagePair: String
    let enableNotifications: String
    let logout: String
    let deleteAllData: String
    let deleteAccount: String
    let selectLevel: String
    let selectAppLanguage: String
    let proFeatures: String
    let showSimilarWordsToggle: String
    let showWordTensesToggle: String
    let nativeLanguage: String
    let selectNativeLanguage: String
    let targetLanguage: String
    let selectTargetLanguage: String
    let nativeLanguageDescription: String
    let targetLanguageDescription: String
    let addPair: String
    let adding: String
    let failedToAddLanguagePair: String
    let settingAsDefault: String
    let beginner: String
    let intermediate: String
    let advanced: String
    let currentlyLearning: String
    let otherLanguages: String
    let learnNewLanguage: String
    let learn: String
    let tapToSelectNativeLanguage: String
    // Theme color names
    let neonGreen: String
    let cyanMist: String
    let violetHaze: String
    let softPink: String
    let pureWhite: String
}

struct VocabularyStrings {
    let exploreCategories: String
    let testYourself: String
    let slideToStartQuiz: String
    let similarWords: String
    let wordTenses: String
    let wordBreakdown: String
    let tapToSeeBreakdown: String
    let tapToHideBreakdown: String
    let tapWordsToExplore: String
    let loading: String
    let learnTheWord: String
    let tryFromMemory: String
    // Loading animation strings
    let adjustingTo: String
    let settingPlace: String
    let settingTime: String
    let generatingVocabulary: String
    let analyzingVocabulary: String
    let analyzingCategories: String
    let analyzingWords: String
    let creatingQuiz: String
    let organizingContent: String
    // Context words for loading animations
    let to: String
    let place: String
    let time: String
    let vocabulary: String
    let your: String
    let interested: String
    let categories: String
    let words: String
    let quiz: String
    let content: String
}

struct SceneStrings {
    let hi: String
    let learnFromSurroundings: String
    let learnFromSurroundingsDescription: String
    let locianChoosing: String
    let chooseLanguages: String
    let continueWith: String
    let slideToLearn: String
    let recommended: String
    let intoYourLearningFlow: String
    let intoYourLearningFlowDescription: String
    let customSituations: String
    let customSituationsDescription: String
    let max: String
    let recentPlacesTitle: String
    let allPlacesTitle: String
    let recentPlacesEmpty: String
    let showMore: String
    let showLess: String
    let takePhoto: String
    let chooseFromGallery: String
    let letLocianChoose: String
    let lociansChoice: String
    let cameraTileDescription: String
    let airport: String
    let aquarium: String
    let bakery: String
    let beach: String
    let bookstore: String
    let cafe: String
    let cinema: String
    let gym: String
    let hospital: String
    let hotel: String
    let home: String
    let library: String
    let market: String
    let museum: String
    let office: String
    let park: String
    let restaurant: String
    let shoppingMall: String
    let stadium: String
    let supermarket: String
    let temple: String
    let travelling: String
    let university: String
    let addCustomPlace: String
    let addPlace: String
    let enterCustomPlaceName: String
    let maximumCustomPlaces: String
    let welcome: String
    let user: String
    let tapToCaptureContext: String
    let customSection: String
    let examples: String
    let customPlacePlaceholder: String
    let exampleTravellingToOffice: String
    let exampleTravellingToHome: String
    let exampleExploringParis: String
    let exampleVisitingMuseum: String
    let exampleCoffeeShop: String
    let characterCount: String
    let situationExample1: String
    let situationExample2: String
    let situationExample3: String
    let situationExample4: String
    let situationExample5: String
}

struct LoginStrings {
    let login: String
    let verify: String
    let selectProfession: String
    let username: String
    let phoneNumber: String
    let guestLogin: String
    let guestLoginDescription: String
}

struct OnboardingStrings {
    let locianHeading: String
    let locianDescription: String
    let awarenessHeading: String
    let awarenessDescription: String
    let inputsHeading: String
    let inputsDescription: String
    let breakdownHeading: String
    let breakdownDescription: String
    let progressHeading: String
    let progressDescription: String
    let readyHeading: String
    let readyDescription: String
    let loginOrRegister: String
    let pageIndicator: String
    let tapToNavigate: String
    let selectAppLanguage: String
    let selectLanguageDescription: String
}

struct CommonStrings {
    let cancel: String
    let save: String
    let done: String
    let ok: String
    let back: String
    let next: String
    let continueText: String
}

struct CustomPracticeStrings {
    let custom: String
    let hint: String
    let practiceDescription: String
    let practiceTitle: String
    let practiceFollowUp: String
    let camera: String
    let cameraDescription: String
    let useCamera: String
    let cameraButtonDescription: String
    let typeConversation: String
    let typeConversationDescription: String
    let conversationPlaceholder: String
    let submit: String
    let fullCustomText: String
    let examples: String
    let conversationExample1: String
    let conversationExample2: String
    let conversationExample3: String
    let describeConversation: String
    let fullTextPlaceholder: String
    let startCustomPractice: String
}

struct ProgressStrings {
    let progress: String
    let edit: String
    let current: String
    let longest: String
    let lastPracticed: String
    let days: String
    let addLanguagePairToSeeProgress: String
}

