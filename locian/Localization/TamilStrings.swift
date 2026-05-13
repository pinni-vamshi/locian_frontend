//
//  TamilStrings.swift
//  locian
//

import Foundation
import Combine

struct TamilStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "வரலாற்று தாள்",
            startLearning: "கற்கத் தொடங்குங்கள்",
            sunShort: "ஞா",
            monShort: "தி",
            tueShort: "செ",
            wedShort: "பு",
            thuShort: "வி",
            friShort: "வெ",
            satShort: "ச",
            settings: "அமைப்புகள்",
            done: "முடிந்தது",
            cancel: "ரத்து செய்க",
            delete: "நீக்கு",
            edit: "திருத்து",
            error: "பிழை",
            ok: "சரி",
            learnTab: "கற்க",
            progressTab: "முன்னேற்றம்",
            loading: "ஏற்றுகிறது...",
            noInternetConnection: "இணைய இணைப்பு இல்லை",
            retry: "மீண்டும் முயற்சிக்கవు")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "செயலி இடைமுகம்",
            notifications: "அறிவிப்புகள்",
            account: "கணக்கு",
            addLanguagePair: "மொழி ஜோடியைச் சேர்க்கவும்",
            logout: "வெளியேறு",
            nativeLanguage: "தாய் மொழி",
            selectTargetLanguage: "இலக்கு மொழியைத் தேர்ந்தெடுக்கவும்",
            neonGreen: "நியான் பச்சை",
            neonFuchsia: "நியான் ஃப்யூஷியா",
            electricIndigo: "எலக்ட்ரிக் இண்டிகோ",
            graphiteBlack: "கிராஃபைட் கருப்பு",
            student: "மாணவர்",
            softwareEngineer: "மென்பொருள் பொறியாளர்",
            teacher: "ஆசிரியர்",
            doctor: "மருத்துவர்",
            artist: "கலைஞர்",
            businessProfessional: "வியாபார நிபுணர்",
            salesOrMarketing: "விற்பனை அல்லது சந்தைப்படுத்தல்",
            traveler: "பயணி",
            homemaker: "வீட்டுப்பணியாளர்",
            chef: "செஃப்",
            police: "காவல்",
            bankEmployee: "வங்கி நிருவனர்",
            nurse: "செவிலியர்",
            designer: "வடிவமைப்பாளர்",
            engineerManager: "பொறியியல் மேலாளர்",
            photographer: "படப்பிடிப்பாளர்",
            contentCreator: "உள்ளடக்க உருவாக்குநர்",
            entrepreneur: "தொழில்முனைவோர்",
            other: "மற்றவை",
            systemConfig: "கணினி // கட்டமைப்பு",
            currentLevel: "தற்போதைய நிலை",
            location: "இருப்பிடம்",
            areYouSureLogout: "நீங்கள் நிச்சயமாக வெளியேற விரும்புகிறீர்களா?",
            areYouSureDeleteAccount: "உங்கள் கணக்கை நிரந்தரமாக நீக்க விரும்புகிறீர்களா? இந்த நடவடிக்கையை மாற்ற முடியாது?")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "பயனர் தொழிலைத் தேர்ந்தெடுக்கவும்",
            authenticatingUser: "பயனர் அங்கீகரிக்கப்படுகிறார்...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்",
            whichLanguageDoYouSpeakComfortably: "நீங்கள் எந்த மொழியை வசதியாக பேசுகிறீர்கள்?",
            chooseTheLanguageYouWantToMaster: "இன்று நீங்கள் கற்க விரும்பும் மொழியை தேர்ந்தெடுக்கவும்")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "உங்கள் முன்னேற்றத்தைக் காண மொழி ஜோடியைச் சேர்க்கவும்",
            streakStatus: "தொடர் நிலை",
            chronotype: "காலவகை",
            activityDistribution: "செயல்பாட்டுப் பகிர்வு (24ம)",
            earlyBird: "அதிகாலைப் பறவை",
            earlyBirdDesc: "காலையில் மிகவும் சுறுசுறுப்பாக இருப்பார்",
            dayWalker: "பகல் நேரத்தவர்",
            dayWalkerDesc: "மதியத்தில் மிகவும் சுறுசுறுப்பாக இருப்பார்",
            nightOwl: "இரவு ஆந்தை",
            nightOwlDesc: "இருட்டிய பின் மிகவும் சுறுசுறுப்பாக இருப்பார்")
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
        case .smartNotificationExactPlace: return "நீங்கள் %@ இல் இருந்தால், இந்த இடத்தைப் பற்றி படிக்கவும்!"
        default: return key.rawValue
        }
    }
}
