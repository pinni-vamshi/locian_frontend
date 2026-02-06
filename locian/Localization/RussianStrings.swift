//
//  RussianStrings.swift
//  locian
//

import Foundation

struct RussianStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "Камера",
            gallery: "Галерея",
            nextUp: "Далее",
            historyLog: "Журнал Истории",

            moments: "Моменты",
            pastMoments: "Прошлые Моменты",
            noHistory: "Нет Истории",
            generatingHistory: "Генерация Истории",
            generatingMoments: "ГЕНЕРАЦИЯ...",
            analyzingImage: "АНАЛИЗ ИЗОБРАЖЕНИЯ...",
            tapNextUpToGenerate: "Нажмите Далее для Генерации",
            noUpcomingPlaces: "Нет Предстоящих Мест",
            noDetails: "Нет Деталей",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "Начать Учить",
            continueLearning: "Продолжить Учить",
            noPastMoments: "Нет Прошлых Моментов",
            useCamera: "Использовать Камеру",
            previouslyLearning: "Ранее Изучал",
            sunShort: "Вс",
            monShort: "Пн",
            tueShort: "Вт",
            wedShort: "Ср",
            thuShort: "Чт",
            friShort: "Пт",
            satShort: "Сб",
            login: "Войти",
            register: "Регистрация",
            settings: "Настройки",
            back: "Назад",
            done: "Готово",
            cancel: "Отмена",
            save: "Сохранить",
            delete: "Удалить",
            add: "Добавить",
            remove: "Убрать",
            edit: "Редактировать",
            error: "Ошибка",
            ok: "OK",
            welcomeLabel: "Добро пожаловать",
            currentStreak: "ТЕКУЩАЯ_СЕРИЯ",
            notSet: "Не установлено",
            learnTab: "Учить",
            addTab: "Добавить",
            progressTab: "Прогресс",
            settingsTab: "Настройки",
            loading: "Загрузка...",
            unknownPlace: "Неизвестное место",
            noLanguageAvailable: "Нет доступных языков",
            noInternetConnection: "Нет подключения к интернету",
            retry: "Повторить",
            tapToGetMoments: "Нажмите для моментов",
            startLearningThisMoment: "Начать учить сейчас",
            daysLabel: "Дней",
            noNewPlace: "Добавить новое место",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "Пуск",
            typeYourMoment: "Напишите свой момент...",
            imagesLabel: "ИЗОБРАЖЕНИЯ",
            routinesLabel: "РУТИНЫ",
            whatAreYouDoing: "Что вы сейчас делаете?",
            chooseContext: "Выберите контекст для начала обучения",
            typeHere: "ПЕЧАТАЙТЕ ЗДЕСЬ",
            nearbyLabel: "РЯДОМ",
            noNearbyPlaces: "Поблизости не найдено мест")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "Интерфейс Приложения",
            targetLanguages: "Целевые Языки",
            pastLanguagesArchived: "Ранее Изучаемые",
            theme: "Тема",
            notifications: "Уведомления",
            account: "Аккаунт",
            profile: "Профиль",
            addLanguagePair: "Добавить Языковую Пару",
            logout: "Выйти",
            deleteAllData: "Удалить Все Данные",
            deleteAccount: "Удалить Аккаунт Навсегда",
            selectLevel: "Выбрать Уровень",
            proFeatures: "Про Функции",
            showSimilarWordsToggle: "Показать Похожие Слова",
            nativeLanguage: "Родной Язык",
            selectNativeLanguage: "Выбрать Родной Язык",
            targetLanguage: "Целевой Язык",
            selectTargetLanguage: "Выбрать Целевой Язык",
            targetLanguageDescription: "Язык, который вы хотите изучить",
            beginner: "Начинающий",
            intermediate: "Средний",
            advanced: "Продвинутый",
            currentlyLearning: "Сейчас Изучаю",
            learnNewLanguage: "Изучить Новый Язык",
            learn: "Учить",
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
            otherPlaces: "Другие Места",
            speaks: "Говорит",
            neuralEngine: "Нейронный Движок",
            noLanguagePairsAdded: "Нет Добавленных Языковых Пар",
            setDefault: "Установить По Умолчанию",
            defaultText: "По Умолчанию",
            user: "Пользователь",
            signOutFromAccount: "Выйти из Аккаунта",
            permanentlyDeleteAccount: "Удалить Аккаунт Навсегда",
            languageAddedSuccessfully: "Язык успешно добавлен",
            failedToAddLanguage: "Не удалось добавить язык. Пожалуйста, попробуйте еще раз.",
            pleaseSelectLanguage: "Пожалуйста, выберите язык",
            systemConfig: "СИСТЕМА // КОНФИГ",
            currentLevel: "Текущий Уровень",
            selectPhoto: "Выбрать Фото",
            camera: "Камера",
            photoLibrary: "Фототека",
            selectTime: "Выбрать Время",
            hour: "Час",
            minute: "Минута",
            addTime: "Добавить Время",
            location: "Местоположение",
            diagnosticBorders: "Рамки Диагностики",
            areYouSureLogout: "Вы уверены, что хотите выйти?",
            areYouSureDeleteAccount: "Вы уверены, что хотите безвозвратно удалить свой аккаунт? Это действие нельзя отменить.")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "Войти",
            verify: "Проверить",
            selectProfession: "Выбрать Профессию",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "Имя Пользователя",
            phoneNumber: "Номер Телефона",
            guestLogin: "Гостевой Вход",
            selectProfessionInstruction: "Выберите профессию для начала",
            showMore: "Показать больше",
            showLess: "Показать меньше",
            forReview: "[Для проверки]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "Изучайте языки естественно через повседневную жизнь",
            awarenessHeading: "Осознанность",
            awarenessDescription: "Замечайте слова вокруг вас в реальном времени",
            breakdownHeading: "Разбор",
            breakdownDescription: "Поймите, как строятся слова",
            progressHeading: "Прогресс",
            progressDescription: "Отслеживайте свой учебный путь",
            readyHeading: "Готовы",
            readyDescription: "Начните учиться сейчас",
            loginOrRegister: "Войти или Зарегистрироваться",
            pageIndicator: "Страница",
            selectLanguageDescription: "Выберите предпочтительный язык",
            whichLanguageDoYouSpeakComfortably: "НА КАКОМ ЯЗЫКЕ ВЫ ГОВОРИТЕ СВОБОДНО?",
            chooseTheLanguageYouWantToMaster: "ВЫБЕРИТЕ ЯЗЫК, КОТОРЫЙ ВЫ ХОТИТЕ ОСВОИТЬ СЕГОДНЯ",
            fromWhereYouStand: "ТАМ, ГДЕ ТЫ\nСТОИШЬ",
            toEveryWord: "К",
            everyWord: "КАЖДОМУ СЛОВУ",
            youNeed: "ТЕБЕ НУЖНО",
            lessonEngine: "МЕХАНИЗМ_УРОКА",
            nodesLive: "УЗЛЫ_АКТИВНЫ",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "ГОЛО_СЕТКА_АКТИВНА",
            adaCr02: "ADA_CR-02",
            your: "ТВОИ",
            places: "МЕСТА,",
            lessons: "УРОКИ.",
            yourPlaces: "ТВОИ МЕСТА,",
            yourLessons: " ТВОИ УРОКИ.",
            nearbyCafes: "Кафе поблизости?",
            unlockOrderFlow: " Разблокировать заказ",
            modules: "модули",
            activeHubs: "Активные хабы?",
            synthesizeGym: " Синтезировать зал",
            vocabulary: "словарный запас",
            locationOpportunity: "Каждое место становится возможностью для обучения",
            module03: "МОДУЛЬ_03",
            notJustMemorization: "НЕ ПРОСТО\nЗАПОМИНАНИЕ",
            philosophy: "ФИЛОСОФИЯ",
            locianTeaches: "Locian не просто учит словам.\nLocian учит тебя ",
            think: "ДУМАТЬ",
            inTargetLanguage: "на изучаемом языке.",
            patternBasedLearning: "ОБУЧЕНИЕ НА ШАБЛОНАХ",
            patternBasedDesc: "Интуитивно распознавай грамматические структуры без сухих правил.",
            situationalIntelligence: "СИТУАЦИОННЫЙ ИНТЕЛЛЕКТ",
            situationalDesc: "Динамические сценарии, адаптирующиеся к твоему окружению и истории.",
            adaptiveDrills: "АДАПТИВНЫЕ УПРАЖНЕНИЯ",
            adaptiveDesc: "Механизм урока выявляет твои слабые места и перестраивается.",
            systemReady: "СИСТЕМА_ГОТОВА",
            quickSetup: "БЫСТРАЯ_НАСТРОЙКА",
            levelB2: "УРОВЕНЬ_B2",
            authorized: "АВТОРИЗОВАНО",
            notificationsPermission: "УВЕДОМЛЕНИЯ",
            notificationsDesc: "Получай обновления в реальном времени о местах для практики и серии занятий.",
            microphonePermission: "МИКРОФОН",
            microphoneDesc: "Необходим для оценки произношения и взаимодействия на уроках в реальных условиях.",
            geolocationPermission: "ГЕОЛОКАЦИЯ",
            geolocationDesc: "Находи ближайшие \"Зоны урока\", такие как кафе или библиотеки, для полного погружения.",
            granted: "ПРЕДОСТАВЛЕНО",
            allow: "РАЗРЕШИТЬ",
            skip: "ПРОПУСТИТЬ",
            letsStart: "НАЧНЕМ",
            continueText: "ПРОДОЛЖИТЬ",
            wordTenses: "Времена:",
            similarWords: "Похожие слова:",
            wordBreakdown: "Разбор слова:",
            consonant: "Согласный",
            vowel: "Гласный",
            past: "Прошлое",
            present: "Настоящее",
            future: "Будущее",
            learnWord: "Учить")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Прогресс",
            current: "Текущая",
            longest: "Самая длинная",
            lastPracticed: "Последняя практика",
            days: "Дней",
            addLanguagePairToSeeProgress: "Добавьте языковую пару, чтобы увидеть прогресс",
            startPracticingMessage: "Начните практиковаться, чтобы создать серию",
            consistencyQuote: "Последовательность — ключ к изучению языков",
            practiceDateSavingDisabled: "Сохранение даты практики отключено",
            editYourStreaks: "Редактировать ваши серии",
            editStreaks: "Редактировать серии",
            selectDatesToAddOrRemove: "Выберите даты для добавления или удаления",
            saving: "Сохранение",
            statusOnFire: "Статус: В Ударе",
            youPracticed: "Вы тренировались ",
            yesterday: " вчера.",
            checkInNow: "Отметиться Сейчас",
            nextGoal: "Следующая Цель",
            reward: "Награда",
            historyLogProgress: "Журнал истории",
            streakStatus: "Статус серии",
            streakLog: "Журнал серии",
            consistency: "Последовательность",
            consistencyHigh: "Ваш журнал активности показывает высокую вовлеченность.",
            consistencyMedium: "Вы набираете хороший темп.",
            consistencyLow: "Последовательность — это ключ. Продолжайте в том же духе.",
            reachMilestone: "Постарайтесь достичь %d дней!",
            nextMilestone: "Следующий рубеж",
            actionRequired: "Требуется действие",
            logActivity: "Записать активность",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "Самая длинная серия",
            streakData: "ДАННЫЕ СЕРИИ",
            activeLabel: "АКТИВНО",
            missedLabel: "ПРОПУЩЕНО",
            saveChanges: "СОХРАНИТЬ",
            discardChanges: "ОТМЕНИТЬ",
            editLabel: "РЕДАКТИРОВАТЬ",
            // Advanced Stats
            skillBalance: "Баланс навыков",
            fluencyVelocity: "Скорость беглости",
            vocabVault: "Хранилище слов",
            chronotype: "Хронотип",
            activityDistribution: "Распределение активности (24ч)",
            studiedTime: "Время обучения",
            currentLabel: "ТЕКУЩАЯ",
            streakLabel: "УДАРНАЯ",
            longestLabel: "САМАЯ ДЛИННАЯ",
            earlyBird: "РАННЯЯ ПТАШКА",
            earlyBirdDesc: "Наиболее активен утром",
            dayWalker: "ДНЕВНОЙ ПУТНИК",
            dayWalkerDesc: "Наиболее активен днем",
            nightOwl: "НОЧНАЯ СОВА",
            nightOwlDesc: "Наиболее активен после наступления темноты",
            timeMastery: "Мастерство времени",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "Загрузка...",
            adaptiveQuiz: "Адаптивный квиз",
            adaptiveQuizDescription: "Сначала показываем неверный перевод, затем правильный.",
            wordCheck: "Проверка слов",
            wordCheckDescription: "Плитки перемешиваются, затем встают на места для проверки.",
            wordCheckExamplePrompt: "Нажимайте на буквы, чтобы составить слово в правильном порядке.",
            quizPrompt: "Выберите правильный перевод для слова.",
            answerConfirmation: "Вы составили правильное слово!",
            tryAgain: "Ой! Попробуйте еще раз.")
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
        case .login: return ui.login
        case .register: return ui.register
        case .settings: return ui.settings
        case .back: return ui.back
        case .done: return ui.done
        case .cancel: return ui.cancel
        case .save: return ui.save
        case .delete: return ui.delete
        case .add: return ui.add
        case .remove: return ui.remove
        case .edit: return ui.edit
        case .learnTab: return ui.learnTab
        case .addTab: return ui.addTab
        case .progressTab: return ui.progressTab
        case .settingsTab: return ui.settingsTab
        case .loading: return ui.loading
        case .user: return settings.user
        case .unknownPlace: return ui.unknownPlace
        case .noLanguageAvailable: return ui.noLanguageAvailable
        case .noInternetConnection: return ui.noInternetConnection
        case .retry: return ui.retry
        case .tapToGetMoments: return ui.tapToGetMoments
        case .startLearningThisMoment: return ui.startLearningThisMoment
        case .daysLabel: return ui.daysLabel
        case .systemLanguage: return settings.systemLanguage
        case .targetLanguages: return settings.targetLanguages
        case .pastLanguagesArchived: return settings.pastLanguagesArchived
        case .theme: return settings.theme
        case .logout: return settings.logout
        case .learnNewLanguage: return settings.learnNewLanguage
        case .profile: return settings.profile
        case .addLanguagePair: return settings.addLanguagePair
        case .deleteAllData: return settings.deleteAllData
        case .deleteAccount: return settings.deleteAccount
        case .selectLevel: return settings.selectLevel
        case .proFeatures: return settings.proFeatures
        case .showSimilarWordsToggle: return settings.showSimilarWordsToggle
        case .cameraLabel: return ui.camera
        case .galleryLabel: return ui.gallery
        case .nextUp: return ui.nextUp
        case .historyLog: return ui.historyLog

        case .moments: return ui.moments
        case .pastMoments: return ui.pastMoments
        case .welcomeLabel: return ui.welcomeLabel
        case .noUpcomingPlaces: return ui.noUpcomingPlaces
        case .noDetailsRecorded: return ui.noDetails

        case .startLearningLabel: return ui.startLearning
        case .continueLearningLabel: return ui.continueLearning
        case .noPastMomentsFor: return ui.noPastMoments
        case .useCameraToStartLearning: return ui.useCamera
        case .previouslyLearning: return ui.previouslyLearning
        case .noHistoryRecorded: return ui.noHistory
        case .tapNextUpToGenerate: return ui.tapNextUpToGenerate
        case .generatingHistory: return ui.generatingHistory
        case .generatingMoments: return ui.generatingMoments
        case .analyzingImage: return ui.analyzingImage
        case .noNewPlace: return ui.noNewPlace
        case .addNewPlaceInstruction: return ui.addNewPlaceInstruction
        case .start: return ui.start
        case .startPracticingMessage: return progress.startPracticingMessage
        case .consistencyQuote: return progress.consistencyQuote
        case .practiceDateSavingDisabled: return progress.practiceDateSavingDisabled
        case .sunShort: return ui.sunShort
        case .monShort: return ui.monShort
        case .tueShort: return ui.tueShort
        case .wedShort: return ui.wedShort
        case .thuShort: return ui.thuShort
        case .friShort: return ui.friShort
        case .satShort: return ui.satShort
        case .noLanguagePairsAdded: return settings.noLanguagePairsAdded
        case .setDefault: return settings.setDefault
        case .defaultText: return settings.defaultText
        case .signOutFromAccount: return settings.signOutFromAccount
        case .permanentlyDeleteAccount: return settings.permanentlyDeleteAccount
        case .currentLevel: return settings.currentLevel
        case .selectPhoto: return settings.selectPhoto
        case .camera: return settings.camera
        case .photoLibrary: return settings.photoLibrary
        case .selectTime: return settings.selectTime
        case .hour: return settings.hour
        case .minute: return settings.minute
        case .addTime: return settings.addTime
        case .areYouSureLogout: return settings.areYouSureLogout
        case .areYouSureDeleteAccount: return settings.areYouSureDeleteAccount
        case .nativeLanguage: return settings.nativeLanguage
        case .selectNativeLanguage: return settings.selectNativeLanguage
        case .targetLanguage: return settings.targetLanguage
        case .selectTargetLanguage: return settings.selectTargetLanguage
        case .targetLanguageDescription: return settings.targetLanguageDescription
        case .beginner: return settings.beginner
        case .intermediate: return settings.intermediate
        case .advanced: return settings.advanced
        case .currentlyLearning: return settings.currentlyLearning
        case .learn: return settings.learn
        case .neonGreen: return settings.neonGreen
        case .neonFuchsia: return settings.neonFuchsia
        case .electricIndigo: return settings.electricIndigo
        case .graphiteBlack: return settings.graphiteBlack
        case .error: return ui.error
        case .ok: return ui.ok
        case .locianHeading: return onboarding.locianHeading
        case .locianDescription: return onboarding.locianDescription
        case .awarenessHeading: return onboarding.awarenessHeading
        case .awarenessDescription: return onboarding.awarenessDescription
        case .breakdownHeading: return onboarding.breakdownHeading
        case .breakdownDescription: return onboarding.breakdownDescription
        case .progressHeading: return onboarding.progressHeading
        case .progressDescription: return onboarding.progressDescription
        case .readyHeading: return onboarding.readyHeading
        case .readyDescription: return onboarding.readyDescription
        case .loginOrRegister: return onboarding.loginOrRegister
        case .pageIndicator: return onboarding.pageIndicator
        case .selectLanguageDescription: return onboarding.selectLanguageDescription
        case .whichLanguageDoYouSpeakComfortably: return onboarding.whichLanguageDoYouSpeakComfortably
        case .chooseTheLanguageYouWantToMaster: return onboarding.chooseTheLanguageYouWantToMaster
        case .wordTenses: return onboarding.wordTenses
        case .similarWords: return onboarding.similarWords
        case .wordBreakdown: return onboarding.wordBreakdown
        case .consonant: return onboarding.consonant
        case .vowel: return onboarding.vowel
        case .adaptiveQuiz: return quiz.adaptiveQuiz
        case .adaptiveQuizDescription: return quiz.adaptiveQuizDescription
        case .wordCheck: return quiz.wordCheck
        case .wordCheckDescription: return quiz.wordCheckDescription
        case .wordCheckExamplePrompt: return quiz.wordCheckExamplePrompt
        case .quizPrompt: return quiz.quizPrompt
        case .answerConfirmation: return quiz.answerConfirmation
        case .tryAgain: return quiz.tryAgain
        case .verify: return login.verify
        case .selectProfession: return login.selectProfession
        case .selectProfessionInstruction: return login.selectProfessionInstruction
        case .showMore: return login.showMore
        case .showLess: return login.showLess
        case .forReview: return login.forReview
        case .username: return login.username
        case .phoneNumber: return login.phoneNumber
        case .guestLogin: return login.guestLogin
        case .authenticatingUser: return login.authenticatingUser
        case .bySigningInYouAgreeToOur: return login.bySigningInYouAgreeToOur
        case .termsOfService: return login.termsOfService
        case .privacyPolicy: return login.privacyPolicy
        case .selectUserProfession: return login.selectUserProfession
        case .editYourStreaks: return progress.editYourStreaks
        case .editStreaks: return progress.editStreaks
        case .selectDatesToAddOrRemove: return progress.selectDatesToAddOrRemove
        case .saving: return progress.saving
        case .student: return settings.student
        case .softwareEngineer: return settings.softwareEngineer
        case .teacher: return settings.teacher
        case .doctor: return settings.doctor
        case .artist: return settings.artist
        case .businessProfessional: return settings.businessProfessional
        case .salesOrMarketing: return settings.salesOrMarketing
        case .traveler: return settings.traveler
        case .activityDistribution: return progress.activityDistribution
        case .studiedTime: return progress.studiedTime
        case .currentLabel: return progress.currentLabel
        case .streakLabel: return progress.streakLabel
        case .longestLabel: return progress.longestLabel
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
        case .otherPlaces: return settings.otherPlaces
        case .speaks: return settings.speaks
        case .neuralEngine: return settings.neuralEngine
        case .currentStreak: return ui.currentStreak
        case .notSet: return ui.notSet
        case .past: return onboarding.past
        case .present: return onboarding.present
        case .future: return onboarding.future
        case .learnWord: return onboarding.learnWord
        case .languageAddedSuccessfully: return settings.languageAddedSuccessfully
        case .failedToAddLanguage: return settings.failedToAddLanguage
        case .pleaseSelectLanguage: return settings.pleaseSelectLanguage
        case .systemConfig: return settings.systemConfig
        case .statusOnFire: return progress.statusOnFire
        case .youPracticed: return progress.youPracticed
        case .yesterday: return progress.yesterday
        case .checkInNow: return progress.checkInNow
        case .nextGoal: return progress.nextGoal
        case .reward: return progress.reward
        case .historyLogProgress: return progress.historyLogProgress
        case .streakStatus: return progress.streakStatus
        case .streakLog: return progress.streakLog
        case .consistency: return progress.consistency
        case .consistencyHigh: return progress.consistencyHigh
        case .consistencyMedium: return progress.consistencyMedium
        case .consistencyLow: return progress.consistencyLow
        case .progress: return progress.progress
        case .current: return progress.current
        case .longest: return progress.longest
        case .days: return progress.days
        case .reachMilestone: return progress.reachMilestone
        case .nextMilestone: return progress.nextMilestone
        case .actionRequired: return progress.actionRequired
        case .logActivity: return progress.logActivity
        case .maintainStreak: return progress.maintainStreak
        case .manualEntry: return progress.manualEntry
        case .longestStreakLabel: return progress.longestStreakLabel
        case .streakData: return progress.streakData
        case .activeLabel: return progress.activeLabel
        case .missedLabel: return progress.missedLabel
        case .saveChanges: return progress.saveChanges
        case .discardChanges: return progress.discardChanges
        case .editLabel: return progress.editLabel
        case .lastPracticed: return progress.lastPracticed
        case .addLanguagePairToSeeProgress: return progress.addLanguagePairToSeeProgress
        case .callingAI: return ui.callingAI
        case .preparingLesson: return ui.preparingLesson
        
        case .module03: return onboarding.module03
        case .notJustMemorization: return onboarding.notJustMemorization
        case .philosophy: return onboarding.philosophy
        case .locianTeaches: return onboarding.locianTeaches
        case .think: return onboarding.think
        case .inTargetLanguage: return onboarding.inTargetLanguage
        case .patternBasedLearning: return onboarding.patternBasedLearning
        case .patternBasedDesc: return onboarding.patternBasedDesc
        case .situationalIntelligence: return onboarding.situationalIntelligence
        case .situationalDesc: return onboarding.situationalDesc
        case .adaptiveDrills: return onboarding.adaptiveDrills
        case .adaptiveDesc: return onboarding.adaptiveDesc
        case .systemReady: return onboarding.systemReady
        case .quickSetup: return onboarding.quickSetup
        case .levelB2: return onboarding.levelB2
        case .authorized: return onboarding.authorized
        case .notificationsPermission: return onboarding.notificationsPermission
        case .notificationsDesc: return onboarding.notificationsDesc
        case .microphonePermission: return onboarding.microphonePermission
        case .microphoneDesc: return onboarding.microphoneDesc
        case .geolocationPermission: return onboarding.geolocationPermission
        case .geolocationDesc: return onboarding.geolocationDesc
        case .granted: return onboarding.granted
        case .allow: return onboarding.allow
        case .skip: return onboarding.skip
        case .letsStart: return onboarding.letsStart
        case .continueText: return onboarding.continueText
        case .fromWhereYouStand: return onboarding.fromWhereYouStand
        case .toEveryWord: return onboarding.toEveryWord
        case .everyWord: return onboarding.everyWord
        case .youNeed: return onboarding.youNeed
        case .lessonEngine: return onboarding.lessonEngine
        case .nodesLive: return onboarding.nodesLive
        case .locEngineVersion: return onboarding.locEngineVersion
        case .holoGridActive: return onboarding.holoGridActive
        case .adaCr02: return onboarding.adaCr02
        case .your: return onboarding.your
        case .places: return onboarding.places
        case .lessons: return onboarding.lessons
        case .yourPlaces: return onboarding.yourPlaces
        case .yourLessons: return onboarding.yourLessons
        case .nearbyCafes: return onboarding.nearbyCafes
        case .unlockOrderFlow: return onboarding.unlockOrderFlow
        case .modules: return onboarding.modules
        case .activeHubs: return onboarding.activeHubs
        case .synthesizeGym: return onboarding.synthesizeGym
        case .vocabulary: return onboarding.vocabulary
        case .locationOpportunity: return onboarding.locationOpportunity
        // Advanced Stats
        case .skillBalance: return progress.skillBalance
        case .fluencyVelocity: return progress.fluencyVelocity
        case .vocabVault: return progress.vocabVault
        case .chronotype: return progress.chronotype
        case .timeMastery: return progress.timeMastery
        case .wordsMastered: return progress.wordsMastered
        case .patternsMastered: return progress.patternsMastered
        case .avgResponseTime: return progress.avgResponseTime
        case .patternGalaxy: return progress.patternGalaxy
        case .typeYourMoment: return ui.typeYourMoment
        case .imagesLabel: return ui.imagesLabel
        case .routinesLabel: return ui.routinesLabel
        case .whatAreYouDoing: return ui.whatAreYouDoing
        case .chooseContext: return ui.chooseContext
        case .typeHere: return ui.typeHere
        case .nearbyLabel: return ui.nearbyLabel
        case .noNearbyPlaces: return ui.noNearbyPlaces
        }
    }
}
