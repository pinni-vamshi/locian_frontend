//
//  RussianStrings.swift
//  locian
//
//  Russian localization strings
//

import Foundation

struct RussianStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "Викторина завершена!",
            masteredEnvironment: "Вы освоили свое окружение!",
            learnMoreAbout: "Узнать больше о",
            backToHome: "Вернуться на главную",
            next: "Далее",
            previous: "Назад",
            check: "Проверить",
            tryAgain: "Попробовать снова",
            shuffled: "Перемешано",
            noQuizAvailable: "Викторина недоступна",
            question: "Вопрос",
            correct: "Правильно",
            incorrect: "Неправильно",
            notAttempted: "Не предпринято"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "Мои языки",
            notifications: "Уведомления",
            appearance: "Эстетика",
            account: "Аккаунт",
            profile: "Профиль",
            addLanguagePair: "Добавить языковую пару",
            enableNotifications: "Включить уведомления",
            logout: "Выйти",
            deleteAllData: "Удалить все данные",
            deleteAccount: "Удалить аккаунт",
            selectLevel: "Выбрать уровень",
            selectAppLanguage: "Интерфейс приложения",
            proFeatures: "Инструменты профи",
            showSimilarWordsToggle: "Показывать похожие слова",
            showWordTensesToggle: "Показывать времена слов",
            nativeLanguage: "Родной язык:",
            selectNativeLanguage: "Выберите ваш родной язык",
            targetLanguage: "Целевой язык:",
            selectTargetLanguage: "Выберите язык, который вы хотите изучить",
            nativeLanguageDescription: "Ваш родной язык - это язык, на котором вы можете свободно читать, писать и говорить. Это язык, с которым вы чувствуете себя наиболее комфортно.",
            targetLanguageDescription: "Ваш целевой язык - это язык, который вы хотите изучать и практиковать. Выберите язык, в котором вы хотите улучшить свои навыки.",
            addPair: "Добавить пару",
            adding: "Добавление...",
            failedToAddLanguagePair: "Не удалось добавить языковую пару. Пожалуйста, попробуйте снова.",
            settingAsDefault: "Установка по умолчанию...",
            beginner: "Начинающий",
            intermediate: "Средний",
            advanced: "Продвинутый",
            currentlyLearning: "Изучаю",
            otherLanguages: "Другие языки",
            learnNewLanguage: "Изучить новый язык",
            learn: "Изучить",
            tapToSelectNativeLanguage: "Нажмите, чтобы выбрать ваш родной язык",
            neonGreen: "Неоновый Зелёный",
            cyanMist: "Голубая Дымка",
            violetHaze: "Фиолетовая Дымка",
            softPink: "Мягкий Розовый",
            pureWhite: "Чисто белый"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "Исследовать категории",
            testYourself: "Проверьте себя",
            slideToStartQuiz: "Проведите, чтобы начать викторину",
            similarWords: "Похожие слова",
            wordTenses: "Времена слов",
            wordBreakdown: "Разбор слова",
            tapToSeeBreakdown: "Нажмите на слово, чтобы увидеть разбор",
            tapToHideBreakdown: "Нажмите на слово, чтобы скрыть разбор",
            tapWordsToExplore: "Нажмите на слова, чтобы прочитать их переводы и изучить",
            loading: "Загрузка...",
            learnTheWord: "Изучить слово",
            tryFromMemory: "Попробовать по памяти",
            adjustingTo: "Настройка",
            settingPlace: "Установка",
            settingTime: "Установка",
            generatingVocabulary: "Генерация",
            analyzingVocabulary: "Анализ",
            analyzingCategories: "Анализ",
            analyzingWords: "Анализ",
            creatingQuiz: "Создание",
            organizingContent: "Организация",
            to: "к",
            place: "место",
            time: "время",
            vocabulary: "словарь",
            your: "ваш",
            interested: "заинтересованный",
            categories: "категории",
            words: "слова",
            quiz: "викторина",
            content: "содержание"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "Привет,",
            learnFromSurroundings: "Учитесь из своего окружения",
            learnFromSurroundingsDescription: "Захватите свое окружение и изучайте словарь из реальных контекстов",
            locianChoosing: "выбирает...",
            chooseLanguages: "Выберите языки",
            continueWith: "Продолжить с тем, что выбрал Locian",
            slideToLearn: "Проведите, чтобы учиться",
            recommended: "Рекомендуемое",
            intoYourLearningFlow: "В ваш поток обучения",
            intoYourLearningFlowDescription: "Рекомендуемые места для практики на основе вашей истории обучения",
            customSituations: "Ваши пользовательские ситуации",
            customSituationsDescription: "Создавайте и практикуйтесь с вашими собственными персонализированными сценариями обучения",
            max: "Макс",
            recentPlacesTitle: "Ваши недавние места",
            allPlacesTitle: "Все места",
            recentPlacesEmpty: "Создайте словарь, чтобы увидеть рекомендации здесь.",
            showMore: "Показать больше",
            showLess: "Показать меньше",
            takePhoto: "Сделать фото",
            chooseFromGallery: "Выбрать из галереи",
            letLocianChoose: "ПОЗВОЛИТЬ LOCIAN ВЫБРАТЬ",
            lociansChoice: "От Locian",
            cameraTileDescription: "Это фото анализирует ваше окружение и показывает моменты для обучения.",
            airport: "Аэропорт",
            aquarium: "Аквариум",
            bakery: "Пекарня",
            beach: "Пляж",
            bookstore: "Книжный магазин",
            cafe: "Кафе",
            cinema: "Кинотеатр",
            gym: "Спортзал",
            hospital: "Больница",
            hotel: "Отель",
            home: "Дом",
            library: "Библиотека",
            market: "Рынок",
            museum: "Музей",
            office: "Офис",
            park: "Парк",
            restaurant: "Ресторан",
            shoppingMall: "Торговый центр",
            stadium: "Стадион",
            supermarket: "Супермаркет",
            temple: "Храм",
            travelling: "Путешествие",
            university: "Университет",
            addCustomPlace: "Добавить пользовательское место",
            addPlace: "Добавить место",
            enterCustomPlaceName: "Введите название пользовательского места (максимум 30 символов)",
            maximumCustomPlaces: "Максимум 10 пользовательских мест",
            welcome: "Добро пожаловать",
            user: "Пользователь",
            tapToCaptureContext: "Нажмите, чтобы захватить ваш контекст и начать обучение",
            customSection: "Пользовательское",
            examples: "Примеры:",
            customPlacePlaceholder: "например, поездка в офис",
            exampleTravellingToOffice: "поездка в офис",
            exampleTravellingToHome: "поездка домой",
            exampleExploringParis: "исследование парижа",
            exampleVisitingMuseum: "посещение музея",
            exampleCoffeeShop: "кофейня",
            characterCount: "символов",
            situationExample1: "Заказ кофе в оживленном кафе",
            situationExample2: "Спросить дорогу в новом городе",
            situationExample3: "Покупка продуктов на рынке",
            situationExample4: "Запись на прием к врачу",
            situationExample5: "Регистрация в отеле"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "Войти",
            verify: "Проверить",
            selectProfession: "Выбрать профессию",
            username: "Имя пользователя",
            phoneNumber: "Номер телефона",
            guestLogin: "Гостевой вход",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "От того места, где вы стоите, до каждого времени, которое вам нужно",
            awarenessHeading: "Осознание",
            awarenessDescription: "ИИ учится из вашего окружения",
            inputsHeading: "Входы",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "Разбор",
            breakdownDescription: "Locian разбирает предложения на времена, предоставляет переводы слово за словом",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "Готов",
            readyDescription: "",
            loginOrRegister: "Войти / Зарегистрироваться",
            pageIndicator: " / 6",
            tapToNavigate: "Нажмите слева или справа для навигации",
            selectAppLanguage: "Выбрать язык приложения",
            selectLanguageDescription: "Этот язык изменит пользовательский интерфейс приложения, заголовки, описания, кнопки, имена и все на выбранный язык"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "Отмена",
            save: "Сохранить",
            done: "Готово",
            ok: "ОК",
            back: "Назад",
            next: "Далее",
            continueText: "Продолжить"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "Пользовательское",
            hint: "Подсказка",
            practiceDescription: "Нажмите на любое слово, чтобы перевести его на целевой язык. Если нужна помощь, используйте кнопку подсказки для получения предложений.",
            practiceTitle: "Практика",
            practiceFollowUp: "Следующая практика",
            camera: "Камера",
            cameraDescription: "Locian создаст разговор на {native}, и вы сможете практиковать перевод на {target}.",
            useCamera: "Использовать камеру",
            cameraButtonDescription: "Создать моменты из фото",
            typeConversation: "Введите разговор",
            typeConversationDescription: "Locian создаст разговор на {native}, и вы сможете практиковать перевод на {target}.",
            conversationPlaceholder: "например, заказ кофе в оживленном кафе",
            submit: "Отправить",
            fullCustomText: "Полный пользовательский текст",
            examples: "Примеры:",
            conversationExample1: "Спросить дорогу под дождем",
            conversationExample2: "Покупка овощей поздно вечером",
            conversationExample3: "Работа в переполненном офисе",
            describeConversation: "Опишите разговор, который вы хотите, чтобы Locian создал.",
            fullTextPlaceholder: "Введите полный текст или диалог здесь...",
            startCustomPractice: "Начать пользовательскую практику"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Прогресс",
            edit: "Редактировать",
            current: "Текущий",
            longest: "Самый длинный",
            lastPracticed: "Последняя практика",
            days: "дней",
            addLanguagePairToSeeProgress: "Добавьте языковую пару, чтобы увидеть ваш прогресс."
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "Мои языки"
        case .notifications: return "Уведомления"
        case .aesthetics: return "Эстетика"
        case .account: return "Аккаунт"
        case .appLanguage: return "Интерфейс приложения"
        
        // Common
        case .login: return "Вход /"
        case .register: return "Регистрация"
        case .settings: return "Настройки"
        case .home: return "Главная"
        case .back: return "Назад"
        case .next: return "Далее"
        case .previous: return "Предыдущий"
        case .done: return "Готово"
        case .cancel: return "Отмена"
        case .save: return "Сохранить"
        case .delete: return "Удалить"
        case .add: return "Добавить"
        case .remove: return "Удалить"
        case .edit: return "Редактировать"
        case .continueText: return "Продолжить"
        
        // Quiz
        case .quizCompleted: return "Викторина завершена!"
        case .sessionCompleted: return "Сеанс завершен!"
        case .masteredEnvironment: return "Вы освоили свою среду!"
        case .learnMoreAbout: return "Узнать больше о"
        case .backToHome: return "Вернуться на главную"
        case .tryAgain: return "Попробовать снова"
        case .shuffled: return "Перемешано"
        case .check: return "Проверить"
        
        // Vocabulary
        case .exploreCategories: return "Исследовать категории"
        case .testYourself: return "Проверьте себя"
        case .similarWords: return "Похожие слова:"
        case .wordTenses: return "Времена слов:"
        case .tapWordsToExplore: return "Нажмите на слова, чтобы прочитать их переводы и изучить"
        case .wordBreakdown: return "Разбор слов:"
        
        // Scene
        case .analyzingImage: return "Анализ изображения..."
        case .imageAnalysisCompleted: return "Анализ изображения завершен"
        case .imageSelected: return "Изображение выбрано"
        case .placeNotSelected: return "Место не выбрано"
        case .locianChoose: return "Locian выбирает"
        case .chooseLanguages: return "Выберите языки"
        
        // Settings
        case .enableNotifications: return "Включить уведомления"
        case .thisPlace: return "это место"
        case .tapOnAnySection: return "Нажмите на любой раздел выше, чтобы просмотреть и управлять настройками"
        case .addNewLanguagePair: return "Добавить новую языковую пару"
        case .noLanguagePairsAdded: return "Языковые пары еще не добавлены"
        case .setDefault: return "Установить по умолчанию"
        case .defaultText: return "По умолчанию"
        case .user: return "Пользователь"
        case .noPhone: return "Нет телефона"
        case .signOutFromAccount: return "Выйти из вашего аккаунта"
        case .removeAllPracticeData: return "Удалить все ваши данные для практики"
        case .permanentlyDeleteAccount: return "Навсегда удалить ваш аккаунт и все данные"
        case .currentLevel: return "Текущий уровень"
        case .selectPhoto: return "Выбрать фото"
        case .camera: return "Камера"
        case .photoLibrary: return "Фототека"
        case .selectTime: return "Выбрать время"
        case .hour: return "Час"
        case .minute: return "Минута"
        case .addTime: return "Добавить время"
        case .areYouSureLogout: return "Вы уверены, что хотите выйти?"
        case .areYouSureDeleteAccount: return "Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить."
        
        // Quiz
        case .goBack: return "Назад"
        case .fillInTheBlank: return "Заполните пробел:"
        case .arrangeWordsInOrder: return "Расположите слова в правильном порядке:"
        case .tapWordsBelowToAdd: return "Нажмите на слова ниже, чтобы добавить их сюда"
        case .availableWords: return "Доступные слова:"
        case .correctAnswer: return "Правильный ответ:"
        
        // Common
        case .error: return "Ошибка"
        case .ok: return "ОК"
        case .close: return "Закрыть"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "От того места, где вы стоите, до каждого времени, которое вам нужно"
        case .awarenessHeading: return "Осознание"
        case .awarenessDescription: return "ИИ учится из вашего окружения"
        case .inputsHeading: return "Входы"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "Разбор"
        case .breakdownDescription: return "Locian разбирает предложения на времена, предоставляет переводы слово за словом"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "Готов"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "Войти / Зарегистрироваться"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "Нажмите слева или справа для навигации"
        case .selectAppLanguage: return "Выбрать язык приложения"
        case .selectLanguageDescription: return "Этот язык изменит пользовательский интерфейс приложения, заголовки, описания, кнопки, имена и все на выбранный язык"
        
        // Login
        case .username: return "Имя пользователя"
        case .phoneNumber: return "Номер телефона"
        case .guestLogin: return "Гостевой вход"
        case .guestLoginDescription: return "Гостевой вход предназначен для проверки и позволит гостю получить доступ ко всем функциям приложения. Будет удалено после проверки."
        
        // Professions
        case .student: return "Студент"
        case .softwareEngineer: return "Инженер-программист"
        case .teacher: return "Учитель"
        case .doctor: return "Врач"
        case .artist: return "Художник"
        case .businessProfessional: return "Бизнес-профессионал"
        case .salesOrMarketing: return "Продажи или маркетинг"
        case .traveler: return "Путешественник"
        case .homemaker: return "Домохозяйка"
        case .chef: return "Шеф-повар"
        case .police: return "Полиция"
        case .bankEmployee: return "Банковский служащий"
        case .nurse: return "Медсестра"
        case .designer: return "Дизайнер"
        case .engineerManager: return "Инженер-менеджер"
        case .photographer: return "Фотограф"
        case .contentCreator: return "Создатель контента"
        case .other: return "Другое"
        
        // Scene Places
        case .lociansChoice: return "Выбор Locian"
        case .airport: return "Аэропорт"
        case .cafe: return "Кафе"
        case .gym: return "Спортзал"
        case .library: return "Библиотека"
        case .office: return "Офис"
        case .park: return "Парк"
        case .restaurant: return "Ресторан"
        case .shoppingMall: return "Торговый центр"
        case .travelling: return "Путешествие"
        case .university: return "Университет"
        case .addCustomPlace: return "Добавить пользовательское место"
        case .enterCustomPlaceName: return "Введите название пользовательского места (максимум 30 символов)"
        case .maximumCustomPlaces: return "Максимум 10 пользовательских мест"
        case .welcome: return "Добро пожаловать"
        case .tapToCaptureContext: return "Нажмите, чтобы захватить ваш контекст и начать обучение"
        case .customSection: return "Пользовательское"
        case .examples: return "Примеры:"
        case .customPlacePlaceholder: return "например, поездка в офис"
        case .exampleTravellingToOffice: return "поездка в офис"
        case .exampleTravellingToHome: return "поездка домой"
        case .exampleExploringParis: return "исследование парижа"
        case .exampleVisitingMuseum: return "посещение музея"
        case .exampleCoffeeShop: return "кофейня"
        case .characterCount: return "символов"
        
        // Settings Modal Strings
        case .nativeLanguage: return "Родной язык:"
        case .selectNativeLanguage: return "Выберите ваш родной язык"
        case .targetLanguage: return "Целевой язык:"
        case .selectTargetLanguage: return "Выберите язык, который вы хотите изучить"
        case .nativeLanguageDescription: return "Ваш родной язык - это язык, на котором вы можете свободно читать, писать и говорить. Это язык, с которым вы чувствуете себя наиболее комфортно."
        case .targetLanguageDescription: return "Ваш целевой язык - это язык, который вы хотите изучать и практиковать. Выберите язык, в котором вы хотите улучшить свои навыки."
        case .addPair: return "Добавить пару"
        case .adding: return "Добавление..."
        case .failedToAddLanguagePair: return "Не удалось добавить языковую пару. Пожалуйста, попробуйте снова."
        case .settingAsDefault: return "Установка по умолчанию..."
        case .beginner: return "Начинающий"
        case .intermediate: return "Средний"
        case .advanced: return "Продвинутый"
        case .currentlyLearning: return "Изучаю"
        case .otherLanguages: return "Другие языки"
        case .learnNewLanguage: return "Изучить новый язык"
        case .learn: return "Изучить"
        case .tapToSelectNativeLanguage: return "Нажмите, чтобы выбрать ваш родной язык"
        
        // Theme color names
        case .neonGreen: return "Неоновый Зелёный"
        case .cyanMist: return "Голубая Дымка"
        case .violetHaze: return "Фиолетовая Дымка"
        case .softPink: return "Мягкий Розовый"
        case .pureWhite: return "Чисто белый"
        
        // Quick Look
        case .quickRecall: return "Быстрое вспоминание"
        case .startQuickPuzzle: return "Начать быструю головоломку"
        case .stopPuzzle: return "Остановить головоломку"
        
        // Streak
        case .streak: return "Серия"
        case .dayStreak: return "день серии"
        case .daysStreak: return "дней серии"
        case .editYourStreaks: return "Редактировать ваши серии"
        case .editStreaks: return "Редактировать серии"
        case .selectDatesToAddOrRemove: return "Выберите даты для добавления или удаления дней практики"
        case .saving: return "Сохранение..."
        }
    }
}

