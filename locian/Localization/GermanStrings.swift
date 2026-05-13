//
//  GermanStrings.swift
//  locian
//

import Foundation
import Combine

struct GermanStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "Verlaufsprotokoll",
            startLearning: "Lernen Beginnen",
            sunShort: "So",
            monShort: "Mo",
            tueShort: "Di",
            wedShort: "Mi",
            thuShort: "Do",
            friShort: "Fr",
            satShort: "Sa",
            settings: "Einstellungen",
            done: "Fertig",
            cancel: "Abbrechen",
            delete: "Löschen",
            edit: "Bearbeiten",
            error: "Fehler",
            ok: "OK",
            learnTab: "Lernen",
            progressTab: "Fortschritt",
            loading: "Laden...",
            noInternetConnection: "Keine Internetverbindung",
            retry: "Wiederholen")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "App-Oberfläche",
            notifications: "Benachrichtigungen",
            account: "Konto",
            addLanguagePair: "Sprachpaar Hinzufügen",
            logout: "Abmelden",
            nativeLanguage: "Mutter Sprache",
            selectTargetLanguage: "Zielsprache Auswählen",
            neonGreen: "Neongrün",
            neonFuchsia: "Neon-Fuchsia",
            electricIndigo: "Elektrisches Indigo",
            graphiteBlack: "Graphitschwarz",
            student: "Student",
            softwareEngineer: "Software-Ingenieur",
            teacher: "Lehrer",
            doctor: "Arzt",
            artist: "Künstler",
            businessProfessional: "Geschäftsmann",
            salesOrMarketing: "Vertrieb oder Marketing",
            traveler: "Reisender",
            homemaker: "Hausmann/Hausfrau",
            chef: "Koch",
            police: "Polizei",
            bankEmployee: "Bankangestellter",
            nurse: "Krankenschwester/Krankenpfleger",
            designer: "Designer",
            engineerManager: "Ingenieur-Manager",
            photographer: "Fotograf",
            contentCreator: "Content-Ersteller",
            entrepreneur: "Unternehmer",
            other: "Andere",
            systemConfig: "SYSTEM // KONFIG",
            currentLevel: "Aktuelles Niveau",
            location: "Standort",
            areYouSureLogout: "Sind Sie sicher, dass Sie sich abmelden möchten?",
            areYouSureDeleteAccount: "Sind Sie sicher, dass Sie Ihr Konto dauerhaft löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden?")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "Wählen Sie Ihre bevorzugte Sprache",
            whichLanguageDoYouSpeakComfortably: "WELCHE SPRACHE SPRECHEN SIE BEQUEM?",
            chooseTheLanguageYouWantToMaster: "WÄHLEN SIE DIE SPRACHE, DIE SIE HEUTE MEISTERN MÖCHTEN")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "Fügen Sie ein Sprachpaar hinzu, um Ihren Fortschritt zu sehen",
            streakStatus: "Strähnenstatus",
            chronotype: "CHRONOTYP",
            activityDistribution: "AKTIVITÄTSVERTEILUNG (24H)",
            earlyBird: "FRÜHAUFSSTEHER",
            earlyBirdDesc: "Morgens am aktivsten",
            dayWalker: "TAGWÄCHTER",
            dayWalkerDesc: "Nachmittags am aktivsten",
            nightOwl: "NACHTEULE",
            nightOwlDesc: "Nach Einbruch der Dunkelheit am aktivsten")
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
        case .smartNotificationExactPlace: return "Wenn Sie bei %@ sind, lesen Sie über diesen Ort!"
        default: return key.rawValue
        }
    }
}
