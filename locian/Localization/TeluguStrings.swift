//
//  TeluguStrings.swift
//  locian
//

import Foundation
import Combine

struct TeluguStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "చరిత్ర లాగ్",
            startLearning: "నేర్చుకోవడం ప్రారంభించండి",
            sunShort: "ఆది",
            monShort: "సోమ",
            tueShort: "మంగళ",
            wedShort: "బుధ",
            thuShort: "గురు",
            friShort: "శుక్ర",
            satShort: "శని",
            settings: "సెట్టింగులు",
            done: "పూర్తయింది",
            cancel: "రద్దు చేయండి",
            delete: "తొలగించండి",
            edit: "సవరించు",
            error: "లోపం",
            ok: "సరే",
            learnTab: "నేర్చుకోండి",
            progressTab: "ప్రగతి",
            loading: "లోడ్ అవుతోంది...",
            noInternetConnection: "ఇంటర్‌నెట్ కనెక్షన్ లేదు",
            retry: "మళ్ళీ ప్రయత్నించండి")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "యాప్ ఇంటర్‌ఫేస్",
            notifications: "నోటిఫికేషన్లు",
            account: "ఖాతా",
            addLanguagePair: "భాషా జంటను జోడించండి",
            logout: "లాగ్ అవుట్",
            nativeLanguage: "మాతృ భాష",
            selectTargetLanguage: "లక్ష్య భాషను ఎంచుకోండి",
            neonGreen: "నియాన్ ఆకుపచ్చ",
            neonFuchsia: "నియాన్ ఫ్యూషియా",
            electricIndigo: "ఎలక్ట్రిక్ ఇండిగో",
            graphiteBlack: "గ్రాఫైట్ బ్లాక్",
            student: "విద్యార్థి",
            softwareEngineer: "సాఫ్ట్‌వేర్ ఇంజనీర్",
            teacher: "ఉపాధ్యాయుడు",
            doctor: "వైద్యుడు",
            artist: "కళాకారుడు",
            businessProfessional: "వ్యాపార నిపుణుడు",
            salesOrMarketing: "అమ్మకాలు లేదా మార్కెటింగ్",
            traveler: "ప్రయాణికుడు",
            homemaker: "గృహిణి/గృహస్థుడు",
            chef: "షెఫ్",
            police: "పోలీసు",
            bankEmployee: "బ్యాంక్ ఉద్యోగి",
            nurse: "నర్స్",
            designer: "డిజైనర్",
            engineerManager: "ఇంజనీరింగ్ మేనేజర్",
            photographer: "ఫోటోగ్రాఫర్",
            contentCreator: "కంటెంట్ క్రియేటర్",
            entrepreneur: "పారిశ్రామికవేత్త",
            other: "ఇతర",
            systemConfig: "సిస్టమ్ // కాన్ఫిగ్",
            currentLevel: "ప్రస్తుత స్థాయి",
            location: "స్థానం",
            areYouSureLogout: "మీరు ఖచ్చితంగా లాగ్ అవుట్ అవ్వాలనుకుంటున్నారా?",
            areYouSureDeleteAccount: "మీరు మీ ఖాతాను శాశ్వతంగా తొలగించాలనుకుంటున్నారా? ఈ చర్యను తిరిగి పొందలేము.")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "మీ ఇష్టమైన భాషను ఎంచుకోండి",
            whichLanguageDoYouSpeakComfortably: "మీరు ఏ భాష ను సుఖంగా మాట్లాడుతారు?",
            chooseTheLanguageYouWantToMaster: "ఈ రోజు మీరు నేర్చుకోవాలనుకునే భాషను ఎంచుకోండి")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "మీ ప్రగతిని చూడటానికి భాషా జంటను జోడించండి",
            streakStatus: "స్ట్రీక్ స్థితి",
            chronotype: "కాలప్రకృతి",
            activityDistribution: "కార్యకలాప పంపిణీ (24 గం)",
            earlyBird: "తెల్లవారుజాము పక్షి",
            earlyBirdDesc: "ఉదయాన్నే చురుకుగా ఉంటారు",
            dayWalker: "పగలు తిరిగే వారు",
            dayWalkerDesc: "మధ్యాహ్నం చురుకుగా ఉంటారు",
            nightOwl: "రాత్రి గుడ్లగూబ",
            nightOwlDesc: "చీకటి పడ్డాక చురుకుగా ఉంటారు")
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
        case .smartNotificationExactPlace: return "మీరు %@ వద్ద ఉంటే, ఈ స్థలం గురించి చదవండి!"
        default: return key.rawValue
        }
    }
}
