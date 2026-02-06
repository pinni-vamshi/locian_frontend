//
//  AppStrings.swift
//  locian
//
//  Protocol for app strings
//

import Foundation

protocol AppStrings {
    var settings: SettingsStrings { get }
    var login: LoginStrings { get }
    var onboarding: OnboardingStrings { get }
    var progress: ProgressStrings { get }
    var ui: UIStrings { get }
    var quiz: QuizStrings { get }
    var scene: SceneStrings { get }
    
    func getString(_ key: String) -> String
}

struct UIStrings {
        let camera: String
    let gallery: String
    let nextUp: String
    let historyLog: String

    let moments: String
    let pastMoments: String
    let noHistory: String
    let generatingHistory: String
    let generatingMoments: String
    let analyzingImage: String
    let tapNextUpToGenerate: String
    let noUpcomingPlaces: String
    let noDetails: String
    let callingAI: String     // New
    let preparingLesson: String // New

    let startLearning: String
    let continueLearning: String
    let noPastMoments: String
    let useCamera: String
    let previouslyLearning: String
    let sunShort: String
    let monShort: String
    let tueShort: String
    let wedShort: String
    let thuShort: String
    let friShort: String
    let satShort: String
    
    // Common UI elements
    let login: String
    let register: String
    let settings: String
        let back: String
            let done: String
    let cancel: String
    let save: String
    let delete: String
    let add: String
    let remove: String
    let edit: String
    let error: String
    let ok: String
    let welcomeLabel: String
    let currentStreak: String
    let notSet: String
    
    // Tab Bar
    let learnTab: String
    let addTab: String
    let progressTab: String
    let settingsTab: String
    
    // Scene & Loading
    let loading: String
    let unknownPlace: String
    let noLanguageAvailable: String
    let noInternetConnection: String
    let retry: String
    let tapToGetMoments: String
    let startLearningThisMoment: String
    let daysLabel: String
    let noNewPlace: String
    let addNewPlaceInstruction: String
    let start: String
    let typeYourMoment: String
    
    // Add Tab
    let imagesLabel: String
    let routinesLabel: String
    let whatAreYouDoing: String
    let chooseContext: String
    let typeHere: String
    let nearbyLabel: String
    let noNearbyPlaces: String
    }

struct SettingsStrings {
    let systemLanguage: String
    let targetLanguages: String
    let pastLanguagesArchived: String
    let theme: String
    let notifications: String
    let account: String
    let profile: String
    let addLanguagePair: String
        let logout: String
    let deleteAllData: String
    let deleteAccount: String
    let selectLevel: String
    let proFeatures: String
    let showSimilarWordsToggle: String
    let nativeLanguage: String
    let selectNativeLanguage: String
    let targetLanguage: String
    let selectTargetLanguage: String
        let targetLanguageDescription: String
                    let beginner: String
    let intermediate: String
    let advanced: String
    let currentlyLearning: String
        let learnNewLanguage: String
    let learn: String
        // Theme color names
    let neonGreen: String
    let neonFuchsia: String
    let electricIndigo: String
    let graphiteBlack: String
        
    // Professions
    let student: String
    let softwareEngineer: String
    let teacher: String
    let doctor: String
    let artist: String
    let businessProfessional: String
    let salesOrMarketing: String
    let traveler: String
    let homemaker: String
    let chef: String
    let police: String
    let bankEmployee: String
    let nurse: String
    let designer: String
    let engineerManager: String
    let photographer: String
    let contentCreator: String
    let entrepreneur: String
    let other: String
    let otherPlaces: String
    
    // Additional settings labels
    let speaks: String
    let neuralEngine: String
                let noLanguagePairsAdded: String
    let setDefault: String
    let defaultText: String
    let user: String
        let signOutFromAccount: String
        let permanentlyDeleteAccount: String
        let languageAddedSuccessfully: String
        let failedToAddLanguage: String
        let pleaseSelectLanguage: String
        let systemConfig: String
    let currentLevel: String
    let selectPhoto: String
    let camera: String
    let photoLibrary: String
    let selectTime: String
    let hour: String
    let minute: String
    let addTime: String
    let location: String
    let diagnosticBorders: String
    let areYouSureLogout: String
    let areYouSureDeleteAccount: String
}


struct LoginStrings {
    let login: String
    let verify: String
    let selectProfession: String
    let selectUserProfession: String // Added for redesign
    let username: String
    let phoneNumber: String
    let guestLogin: String
    let selectProfessionInstruction: String
    let showMore: String
    let showLess: String
    let forReview: String
    let authenticatingUser: String // Added for redesign
    let bySigningInYouAgreeToOur: String // Added for redesign
    let termsOfService: String // Added for redesign
    let privacyPolicy: String // Added for redesign
}

struct OnboardingStrings {
    let locianHeading: String
    let locianDescription: String
    let awarenessHeading: String
    let awarenessDescription: String
            let breakdownHeading: String
    let breakdownDescription: String
    let progressHeading: String
    let progressDescription: String
    let readyHeading: String
    let readyDescription: String
    let loginOrRegister: String
    let pageIndicator: String
    let selectLanguageDescription: String
    let whichLanguageDoYouSpeakComfortably: String
    let chooseTheLanguageYouWantToMaster: String
    
    // Welcome View
    let fromWhereYouStand: String
    let toEveryWord: String
    let everyWord: String
    let youNeed: String
    let lessonEngine: String
    
    // Brain Awareness View
    let nodesLive: String
    let locEngineVersion: String
    let holoGridActive: String
    let adaCr02: String
    let your: String
    let places: String
    let lessons: String
    let yourPlaces: String
    let yourLessons: String
    let nearbyCafes: String
    let unlockOrderFlow: String
    let modules: String
    let activeHubs: String
    let synthesizeGym: String
    let vocabulary: String
    let locationOpportunity: String
    
    // Language Inputs View
    let module03: String
    let notJustMemorization: String
    let philosophy: String
    let locianTeaches: String
    let think: String
    let inTargetLanguage: String
    let patternBasedLearning: String
    let patternBasedDesc: String
    let situationalIntelligence: String
    let situationalDesc: String
    let adaptiveDrills: String
    let adaptiveDesc: String
    
    // Language Progress View
    let systemReady: String
    let quickSetup: String
    let levelB2: String
    let authorized: String
    let notificationsPermission: String
    let notificationsDesc: String
    let microphonePermission: String
    let microphoneDesc: String
    let geolocationPermission: String
    let geolocationDesc: String
    let granted: String
    let allow: String
    let skip: String

    // Onboarding Container
    let letsStart: String
    let continueText: String
    
    // Lesson Specific
    let wordTenses: String
    let similarWords: String
    let wordBreakdown: String
    let consonant: String
    let vowel: String
    let past: String
    let present: String
    let future: String
    let learnWord: String
}

struct ProgressStrings {
    let progress: String
        let current: String
    let longest: String
    let lastPracticed: String
    let days: String
    let addLanguagePairToSeeProgress: String
    let startPracticingMessage: String
    let consistencyQuote: String
    let practiceDateSavingDisabled: String
    
    // Streak
                let editYourStreaks: String
    let editStreaks: String
    let selectDatesToAddOrRemove: String
    let saving: String
    let statusOnFire: String
    let youPracticed: String
    let yesterday: String
    let checkInNow: String
    let nextGoal: String
    let reward: String
    let historyLogProgress: String
    
    // New Progress Design
    let streakStatus: String
    let streakLog: String
    let consistency: String
    let consistencyHigh: String
    let consistencyMedium: String
    let consistencyLow: String
    let reachMilestone: String
    let nextMilestone: String
    let actionRequired: String
    let logActivity: String
    let maintainStreak: String
    let manualEntry: String
    let longestStreakLabel: String
    let streakData: String
    let activeLabel: String
    let missedLabel: String
    let saveChanges: String
    let discardChanges: String
    let editLabel: String
    
    // Advanced Stats
    let skillBalance: String
    let fluencyVelocity: String
    let vocabVault: String
    let chronotype: String
    let activityDistribution: String
    let studiedTime: String
    let currentLabel: String
    let streakLabel: String
    let longestLabel: String
    
    // Chronotypes
    let earlyBird: String
    let earlyBirdDesc: String
    let dayWalker: String
    let dayWalkerDesc: String
    let nightOwl: String
    let nightOwlDesc: String
    
    let timeMastery: String
    let wordsMastered: String
    let patternsMastered: String
    let avgResponseTime: String
    let patternGalaxy: String
}
struct QuizStrings {
    let loading: String
    
    // Onboarding Phase
    let adaptiveQuiz: String
    let adaptiveQuizDescription: String
    let wordCheck: String
    let wordCheckDescription: String
    let wordCheckExamplePrompt: String
    let quizPrompt: String
    let answerConfirmation: String
    let tryAgain: String
}

struct SceneStrings {
                                                
    // Places
                                                                                }
