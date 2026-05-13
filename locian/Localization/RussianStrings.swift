//
//  RussianStrings.swift
//  locian
//

import Foundation
import Combine

struct RussianStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            historyLog: "Журнал Истории",
            startLearning: "Начать Учить",
            sunShort: "Вс",
            monShort: "Пн",
            tueShort: "Вт",
            wedShort: "Ср",
            thuShort: "Чт",
            friShort: "Пт",
            satShort: "Сб",
            settings: "Настройки",
            done: "Готово",
            cancel: "Отмена",
            delete: "Удалить",
            edit: "Редактировать",
            error: "Ошибка",
            ok: "OK",
            learnTab: "Учить",
            progressTab: "Прогресс",
            loading: "Загрузка...",
            noInternetConnection: "Нет подключения к интернету",
            retry: "Повторить")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "Интерфейс Приложения",
            notifications: "Уведомления",
            account: "Аккаунт",
            addLanguagePair: "Добавить Языковую Пару",
            logout: "Выйти",
            nativeLanguage: "Родной Язык",
            selectTargetLanguage: "Выбрать Целевой Язык",
            neonGreen: "Неоновый Зеленый",
            neonFuchsia: "Неоновая фуксия",
            electricIndigo: "Электрический индиго",
            graphiteBlack: "Графитовый черный",
            student: "Студент",
            softwareEngineer: "Инженер-Программист",
            teacher: "Учитель",
            doctor: "Врач",
            artist: "Художник",
            businessProfessional: "Бизнес-Профессионал",
            salesOrMarketing: "Продажи или Маркетинг",
            traveler: "Путешественник",
            homemaker: "Домохозяйка/Домохозяин",
            chef: "Шеф-Повар",
            police: "Полицейский",
            bankEmployee: "Банковский Служащий",
            nurse: "Медсестра/Медбрат",
            designer: "Дизайнер",
            engineerManager: "Инженер-Менеджер",
            photographer: "Фотограф",
            contentCreator: "Создатель Контента",
            entrepreneur: "Предприниматель",
            other: "Другое",
            systemConfig: "СИСТЕМА // КОНФИГ",
            currentLevel: "Текущий Уровень",
            location: "Местоположение",
            areYouSureLogout: "Вы уверены, что хотите выйти?",
            areYouSureDeleteAccount: "Вы уверены, что хотите безвозвратно удалить свой аккаунт? Это действие нельзя отменить.")
    }

    var login: LoginStrings {
        LoginStrings(
            selectUserProfession: "SELECT_USER_PROFESSION",
            authenticatingUser: "AUTHENTICATING_USER...")
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            selectLanguageDescription: "Выберите предпочтительный язык",
            whichLanguageDoYouSpeakComfortably: "НА КАКОМ ЯЗЫКЕ ВЫ ГОВОРИТЕ СВОБОДНО?",
            chooseTheLanguageYouWantToMaster: "ВЫБЕРИТЕ ЯЗЫК, КОТОРЫЙ ВЫ ХОТИТЕ ОСВОИТЬ СЕГОДНЯ")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            addLanguagePairToSeeProgress: "Добавьте языковую пару, чтобы увидеть прогресс",
            streakStatus: "Статус серии",
            chronotype: "Хронотип",
            activityDistribution: "Распределение активности (24ч)",
            earlyBird: "РАННЯЯ ПТАШКА",
            earlyBirdDesc: "Наиболее активен утром",
            dayWalker: "ДНЕВНОЙ ПУТНИК",
            dayWalkerDesc: "Наиболее активен днем",
            nightOwl: "НОЧНАЯ СОВА",
            nightOwlDesc: "Наиболее активен после наступления темноты")
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
        case .smartNotificationExactPlace: return "Если вы находитесь в %@, прочитайте об этом месте!"
        default: return key.rawValue
        }
    }
}
