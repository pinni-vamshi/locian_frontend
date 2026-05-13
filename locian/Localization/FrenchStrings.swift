//
//  FrenchStrings.swift
//  locian
//

import Foundation
import Combine

struct FrenchStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "Journal d'Historique",
            startLearning: "Commencer à Apprendre",
            sunShort: "Dim",
            monShort: "Lun",
            tueShort: "Mar",
            wedShort: "Mer",
            thuShort: "Jeu",
            friShort: "Ven",
            satShort: "Sam",
            settings: "Réglages",
            done: "Terminé",
            cancel: "Annuler",
            delete: "Supprimer",
            edit: "Modifier",
            error: "Erreur",
            ok: "OK",
            learnTab: "Apprendre",
            progressTab: "Progrès",
            loading: "Chargement...",
            noInternetConnection: "Pas de connexion internet",
            retry: "Réessayer")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "Interface de l'Application",
            notifications: "Notifications",
            account: "Compte",
            addLanguagePair: "Ajouter une Paire de Langues",
            logout: "Déconnexion",
            nativeLanguage: "Langue Maternelle",
            selectTargetLanguage: "Sélectionner la Langue Cible",
            neonGreen: "Vert Néon",
            neonFuchsia: "Fuchsia néon",
            electricIndigo: "Indigo électrique",
            graphiteBlack: "Noir graphite",
            student: "Étudiant",
            softwareEngineer: "Ingénieur Logiciel",
            teacher: "Enseignant",
            doctor: "Médecin",
            artist: "Artiste",
            businessProfessional: "Professionnel d'Affaires",
            salesOrMarketing: "Ventes ou Marketing",
            traveler: "Voyageur",
            homemaker: "Ménagère/Ménager",
            chef: "Chef",
            police: "Police",
            bankEmployee: "Employé de Banque",
            nurse: "Infirmière/Infirmier",
            designer: "Designer",
            engineerManager: "Ingénieur Manager",
            photographer: "Photographe",
            contentCreator: "Créateur de Contenu",
            entrepreneur: "Entrepreneur",
            other: "Autre",
            systemConfig: "SYSTÈME // CONFIG",
            currentLevel: "Niveau Actuel",
            location: "Localisation",
            areYouSureLogout: "Êtes-vous sûr de vouloir vous déconnecter ?",
            areYouSureDeleteAccount: "Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "Sélectionnez votre langue préférée",
            whichLanguageDoYouSpeakComfortably: "QUELLE LANGUE PARLEZ-VOUS CONFORTABLEMENT?",
            chooseTheLanguageYouWantToMaster: "CHOISISSEZ LA LANGUE QUE VOUS VOULEZ MAÎTRISER AUJOURD'HUI")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "Ajoutez une paire de langues pour voir vos progrès",
            streakStatus: "Statut de série",
            chronotype: "CHRONOTYPE",
            activityDistribution: "DISTRIBUTION DE L'ACTIVITÉ (24H)",
            earlyBird: "LÈVE-TÔT",
            earlyBirdDesc: "Plus actif le matin",
            dayWalker: "MARCHEUR DE JOUR",
            dayWalkerDesc: "Plus actif l'après-midi",
            nightOwl: "HIBOU NOCTURNE",
            nightOwlDesc: "Plus actif après la tombée de la nuit")
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
        case .smartNotificationExactPlace: return "Si vous êtes à %@, lisez à propos de cet endroit !"
        default: return key.rawValue
        }
    }
}
