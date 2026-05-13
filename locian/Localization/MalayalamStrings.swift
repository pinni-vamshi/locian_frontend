//
//  MalayalamStrings.swift
//  locian
//

import Foundation
import Combine

struct MalayalamStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "ചരിത്ര ലോഗ്",
            startLearning: "പഠനം തുടങ്ങുക",
            sunShort: "ഞാ",
            monShort: "തി",
            tueShort: "ചൊ",
            wedShort: "ബു",
            thuShort: "വ്യാ",
            friShort: "വെ",
            satShort: "ശനി",
            settings: "ക്രമീകരണങ്ങൾ",
            done: "തീർന്നു",
            cancel: "റദ്ദാക്കുക",
            delete: "നീക്കം ചെയ്യുക",
            edit: "എഡിറ്റ് ചെയ്യുക",
            error: "തെറ്റ്",
            ok: "ശരി",
            learnTab: "പഠിക്കുക",
            progressTab: "പുരോഗതി",
            loading: "ലോഡ് ചെയ്യുന്നു...",
            noInternetConnection: "ഇന്റർർനെറ്റ് കണക്ഷൻ ഇല്ല",
            retry: "വീണ്ടും ശ്രമിക്കുക")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "ആപ്പ് ഇന്റർഫേസ്",
            notifications: "അറിയിപ്പുകൾ",
            account: "അക്കൗണ്ട്",
            addLanguagePair: "ഭാഷാ ജോഡി ചേർക്കുക",
            logout: "ലോഗ് ഔട്ട്",
            nativeLanguage: "മാതൃ ഭാഷ",
            selectTargetLanguage: "ലക്ഷ്യ ഭാഷ തിരഞ്ഞെടുക്കുക",
            neonGreen: "നിയോൺ പച്ച",
            neonFuchsia: "നിയോൺ ഫ്യൂഷ്യാ",
            electricIndigo: "ഇലക്ട്രിക് ഇൻഡിഗോ",
            graphiteBlack: "ഗ്രാഫൈറ്റ് ബ്ലാക്ക്",
            student: "വിദ്യാർത്ഥി",
            softwareEngineer: "സോഫ്റ്വെയർ എഞ്ചിനീയർ",
            teacher: "അധ്യാപകൻ",
            doctor: "ഡോക്ടർ",
            artist: "കലാകാരൻ",
            businessProfessional: "ബിസിനസ്സ് പ്രൊഫഷണൽ",
            salesOrMarketing: "വിൽപ്പന അല്ലെങ്കിൽ മാർക്കറ്റിംഗ്",
            traveler: "യാത്രികൻ",
            homemaker: "ഗൃഹനാഥൻ/ഗൃഹനാഥ",
            chef: "ഷെഫ്",
            police: "പോലീസ്",
            bankEmployee: "ബാങ്ക് ഉദ്യോഗസ്ഥൻ",
            nurse: "നഴ്സ്",
            designer: "ഡിസൈനർ",
            engineerManager: "എഞ്ചിനീയറിംഗ് മാനേജർ",
            photographer: "ഫോട്ടോഗ്രാഫർ",
            contentCreator: "കന്റന്റ് ക്രിയേറ്റർ",
            entrepreneur: "സംരംഭകൻ",
            other: "മറ്റുള്ളവ",
            systemConfig: "സിസ്റ്റം // കോൺഫിഗറേഷൻ",
            currentLevel: "നിലവിലെ ലെവൽ",
            location: "സ്ഥാനം",
            areYouSureLogout: "നിങ്ങൾക്ക് ലോഗ് ഔട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?",
            areYouSureDeleteAccount: "നിങ്ങളുടെ അക്കൗണ്ട് ശാശ്വതമായി ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? ഈ നടപടി പിൻവലിക്കാൻ കഴിയില്ല.")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "നിങ്ങൾ ഇഷ്ടപ്പെടുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക",
            whichLanguageDoYouSpeakComfortably: "നിങ്ങൾ ഏത് ഭാഷയാണ് സൗകര്യപ്രദം സംസാരിക്കുന്നത്?",
            chooseTheLanguageYouWantToMaster: "ഇന്ന് നിങ്ങൾ പരിശീലിപ്പിക്കാൻ ആഗ്രഹിക്കുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "പുരോഗതി കാണാൻ ഭാഷാ ജോഡി ചേർക്കുക",
            streakStatus: "സ്ട്രീക്ക് നില",
            chronotype: "സമയപ്രകൃതി",
            activityDistribution: "പ്രവർത്തന വിതരണം (24മ)",
            earlyBird: "പുലരിപ്പക്ഷി",
            earlyBirdDesc: "രാവിലെയൊണ് കൂടുതൽ സജീവം",
            dayWalker: "പകൽ സഞ്ചാരി",
            dayWalkerDesc: "ഉച്ചക്ക് ശേഷമാണ് കൂടുതൽ സജീവം",
            nightOwl: "നിശാചരൻ",
            nightOwlDesc: "രാത്രിയിലാണ് കൂടുതൽ സജീവം")
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

        // Personalization Refresh
        case .smartNotificationExactPlace: return "നിങ്ങൾ %@-ൽ ആണെങ്കിൽ, ഈ സ്ഥലത്തെക്കുറിച്ച് വായിക്കുക!"
        default: return key.rawValue
        }
    }
}
