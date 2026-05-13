//
//  SpanishStrings.swift
//  locian
//

import Foundation
import Combine

struct SpanishStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "Registro de Historial",
            startLearning: "Empezar a Aprender",
            sunShort: "Dom",
            monShort: "Lun",
            tueShort: "Mar",
            wedShort: "Mié",
            thuShort: "Jue",
            friShort: "Vie",
            satShort: "Sáb",
            settings: "Ajustes",
            done: "Hecho",
            cancel: "Cancelar",
            delete: "Eliminar",
            edit: "Editar",
            error: "Error",
            ok: "OK",
            learnTab: "Aprender",
            progressTab: "Progreso",
            loading: "Cargando...",
            noInternetConnection: "Sin conexión a internet",
            retry: "Reintentar")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "Interfaz de la Aplicación",
            notifications: "Notificaciones",
            account: "Cuenta",
            addLanguagePair: "Agregar Par de Idiomas",
            logout: "Cerrar Sesión",
            nativeLanguage: "Idioma Nativo",
            selectTargetLanguage: "Seleccionar Idioma Objetivo",
            neonGreen: "Verde Neón",
            neonFuchsia: "Fucsia neón",
            electricIndigo: "Índigo eléctrico",
            graphiteBlack: "Negro grafito",
            student: "Estudiante",
            softwareEngineer: "Ingeniero de Software",
            teacher: "Profesor",
            doctor: "Médico",
            artist: "Artista",
            businessProfessional: "Profesional de Negocios",
            salesOrMarketing: "Ventas o Marketing",
            traveler: "Viajero",
            homemaker: "Ama/o de Casa",
            chef: "Chef",
            police: "Policía",
            bankEmployee: "Empleado Bancario",
            nurse: "Enfermero/a",
            designer: "Diseñador",
            engineerManager: "Gerente de Ingeniería",
            photographer: "Fotógrafo",
            contentCreator: "Creador de Contenido",
            entrepreneur: "Emprendedor",
            other: "Otro",
            systemConfig: "SISTEMA // CONFIG",
            currentLevel: "Nivel Actual",
            location: "Ubicación",
            areYouSureLogout: "¿Estás seguro de que quieres cerrar sesión?",
            areYouSureDeleteAccount: "¿Estás seguro de que deseas eliminar permanentemente tu cuenta? Esta acción no se puede deshacer.")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "Seleccione su idioma preferido",
            whichLanguageDoYouSpeakComfortably: "¿QUÉ IDIOMA HABLAS CÓMODAMENTE?",
            chooseTheLanguageYouWantToMaster: "ELIGE EL IDIOMA QUE QUIERES DOMINAR HOY")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "Agrega un par de idiomas para ver tu progreso",
            streakStatus: "Estado de Racha",
            chronotype: "CRONOTIPO",
            activityDistribution: "DISTRIBUCIÓN DE ACTIVIDAD (24H)",
            earlyBird: "MADRUGADOR",
            earlyBirdDesc: "Más activo por la mañana",
            dayWalker: "CAMINANTE DIURNO",
            dayWalkerDesc: "Más activo por la tarde",
            nightOwl: "BÚHO NOCTURNO",
            nightOwlDesc: "Más activo después de anochecer")
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
        case .smartNotificationExactPlace: return "¡Si estás en %@, lee sobre este lugar!"
        default: return key.rawValue
        }
    }
}
