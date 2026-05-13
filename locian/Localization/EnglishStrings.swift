// Placeholder to ensure no action if I was wrong about file. But search needs to happen first.
// I will use list_dir next.
//  locian
//

import Foundation
import Combine

struct EnglishStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "History Log",
            startLearning: "Start Learning",
            sunShort: "Sun",
            monShort: "Mon",
            tueShort: "Tue",
            wedShort: "Wed",
            thuShort: "Thu",
            friShort: "Fri",
            satShort: "Sat",
            settings: "Settings",
            done: "Done",
            cancel: "Cancel",
            delete: "Delete",
            edit: "Edit",
            error: "Error",
            ok: "OK",
            learnTab: "Learn",
            progressTab: "Progress",
            loading: "Loading...",
            noInternetConnection: "No internet connection",
            retry: "Retry")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "App Interface",
            notifications: "Notifications",
            account: "Account",
            addLanguagePair: "Add Language Pair",
            logout: "Logout",
            nativeLanguage: "Native Language",
            selectTargetLanguage: "Tap to Change Target Language",
            neonGreen: "Neon Green",
            neonFuchsia: "Neon Fuchsia",
            electricIndigo: "Electric Indigo",
            graphiteBlack: "Graphite Black",
            student: "Student",
            softwareEngineer: "Software Engineer",
            teacher: "Teacher",
            doctor: "Doctor",
            artist: "Artist",
            businessProfessional: "Business Professional",
            salesOrMarketing: "Sales or Marketing",
            traveler: "Traveler",
            homemaker: "Homemaker",
            chef: "Chef",
            police: "Police",
            bankEmployee: "Bank Employee",
            nurse: "Nurse",
            designer: "Designer",
            engineerManager: "Engineer Manager",
            photographer: "Photographer",
            contentCreator: "Content Creator",
            entrepreneur: "Entrepreneur",
            other: "Other",
            systemConfig: "SYSTEM // CONFIG",
            currentLevel: "Current Level",
            location: "Location",
            areYouSureLogout: "Are you sure you want to logout?",
            areYouSureDeleteAccount: "Are you sure you want to delete your account?")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT USER PROFESSION",
            authenticatingUser: "AUTHENTICATING USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "Select your preferred language",
            whichLanguageDoYouSpeakComfortably: "WHICH LANGUAGE DO YOU SPEAK COMFORTABLY?",
            chooseTheLanguageYouWantToMaster: "CHOOSE THE LANGUAGE YOU WANT TO MASTER TODAY")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "Add a language pair to see your progress",
            streakStatus: "Streak Status",
            chronotype: "CHRONOTYPE",
            activityDistribution: "ACTIVITY DISTRIBUTION (24H)",
            earlyBird: "EARLY BIRD",
            earlyBirdDesc: "Most active in the morning",
            dayWalker: "DAY WALKER",
            dayWalkerDesc: "Most active in the afternoon",
            nightOwl: "NIGHT OWL",
            nightOwlDesc: "Most active after dark")
    }

    var scene: SceneStrings {
        SceneStrings(
                                                                                                                                                                                                                                                                                                                                                                                            )
    }


    func getString(_ key: String) -> String {
        return key
    }
    
                                    func getString(for key: StringKey) -> String {
        switch key {
        case .notifications: return settings.notifications
        case .account: return settings.account
        case .settings: return ui.settings
        case .done: return ui.done
        case .cancel: return ui.cancel
        case .delete: return ui.delete
        case .edit: return ui.edit
        case .learnTab: return ui.learnTab
        case .progressTab: return ui.progressTab
        case .loading: return ui.loading
        case .noInternetConnection: return ui.noInternetConnection
        case .retry: return ui.retry
        case .systemLanguage: return settings.systemLanguage
        case .logout: return settings.logout
        case .addLanguagePair: return settings.addLanguagePair
        case .historyLog: return ui.historyLog


        case .startLearningLabel: return ui.startLearning
        case .sunShort: return ui.sunShort
        case .monShort: return ui.monShort
        case .tueShort: return ui.tueShort
        case .wedShort: return ui.wedShort
        case .thuShort: return ui.thuShort
        case .friShort: return ui.friShort
        case .satShort: return ui.satShort
        case .currentLevel: return settings.currentLevel
        case .areYouSureLogout: return settings.areYouSureLogout
        case .areYouSureDeleteAccount: return settings.areYouSureDeleteAccount
        
        
        case .nativeLanguage: return settings.nativeLanguage
        case .selectTargetLanguage: return settings.selectTargetLanguage
        case .neonGreen: return settings.neonGreen
        case .neonFuchsia: return settings.neonFuchsia
        case .electricIndigo: return settings.electricIndigo
        case .graphiteBlack: return settings.graphiteBlack
        case .error: return ui.error
        case .ok: return ui.ok
        case .selectLanguageDescription: return onboarding.selectLanguageDescription
        case .whichLanguageDoYouSpeakComfortably: return onboarding.whichLanguageDoYouSpeakComfortably
        case .chooseTheLanguageYouWantToMaster: return onboarding.chooseTheLanguageYouWantToMaster
        case .authenticatingUser: return login.authenticatingUser
        case .selectUserProfession: return login.selectUserProfession
        case .student: return settings.student
        case .softwareEngineer: return settings.softwareEngineer
        case .teacher: return settings.teacher
        case .doctor: return settings.doctor
        case .artist: return settings.artist
        case .businessProfessional: return settings.businessProfessional
        case .salesOrMarketing: return settings.salesOrMarketing
        case .traveler: return settings.traveler
        case .activityDistribution: return progress.activityDistribution
        case .earlyBird: return progress.earlyBird
        case .earlyBirdDesc: return progress.earlyBirdDesc
        case .dayWalker: return progress.dayWalker
        case .dayWalkerDesc: return progress.dayWalkerDesc
        case .nightOwl: return progress.nightOwl
        case .nightOwlDesc: return progress.nightOwlDesc
        case .homemaker: return settings.homemaker
        case .chef: return settings.chef
        case .police: return settings.police
        case .bankEmployee: return settings.bankEmployee
        case .nurse: return settings.nurse
        case .designer: return settings.designer
        case .engineerManager: return settings.engineerManager
        case .photographer: return settings.photographer
        case .contentCreator: return settings.contentCreator
        case .entrepreneur: return settings.entrepreneur
        case .other: return settings.other
        case .systemConfig: return settings.systemConfig
        case .streakStatus: return progress.streakStatus
        case .addLanguagePairToSeeProgress: return progress.addLanguagePairToSeeProgress
        
        // (Onboarding string mappings removed)
            
        // Advanced Stats
        case .chronotype: return progress.chronotype
        case .smartNotificationExactPlace: return "If you are at %@, read about this place!"
        default: return key.rawValue
        }
    }
}
