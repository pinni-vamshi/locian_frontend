//
//  AppStrings.swift
//  locian
//
//  Protocol for app strings
//

import Foundation
import Combine

protocol AppStrings {
    var settings: SettingsStrings { get }
    var login: LoginStrings { get }
    var onboarding: OnboardingStrings { get }
    var progress: ProgressStrings { get }
    var ui: UIStrings { get }
    var scene: SceneStrings { get }
    
    func getString(_ key: String) -> String
}

struct UIStrings {
    let historyLog: String
    let startLearning: String
    let sunShort: String
    let monShort: String
    let tueShort: String
    let wedShort: String
    let thuShort: String
    let friShort: String
    let satShort: String
    let settings: String
    let done: String
    let cancel: String
    let delete: String
    let edit: String
    let error: String
    let ok: String
    let learnTab: String
    let progressTab: String
    let loading: String
    let noInternetConnection: String
    let retry: String
}

struct SettingsStrings {
    let systemLanguage: String
    let notifications: String
    let account: String
    let addLanguagePair: String
    let logout: String
    let nativeLanguage: String
    let selectTargetLanguage: String
    let neonGreen: String
    let neonFuchsia: String
    let electricIndigo: String
    let graphiteBlack: String
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
    let systemConfig: String
    let currentLevel: String
    let location: String
    let areYouSureLogout: String
    let areYouSureDeleteAccount: String
}


struct LoginStrings {
    let selectUserProfession: String
    let authenticatingUser: String
}

struct OnboardingStrings {
    let selectLanguageDescription: String
    let whichLanguageDoYouSpeakComfortably: String
    let chooseTheLanguageYouWantToMaster: String
}

struct ProgressStrings {
    let addLanguagePairToSeeProgress: String
    let streakStatus: String
    let chronotype: String
    let activityDistribution: String
    let earlyBird: String
    let earlyBirdDesc: String
    let dayWalker: String
    let dayWalkerDesc: String
    let nightOwl: String
    let nightOwlDesc: String
}
struct SceneStrings {
                                                
    // Places
                                                                                }
