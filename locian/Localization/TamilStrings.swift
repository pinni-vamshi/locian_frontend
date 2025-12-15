//
//  TamilStrings.swift
//  locian
//
//  Tamil localization strings
//

import Foundation

struct TamilStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "வினாடி வினா முடிந்தது!",
            masteredEnvironment: "நீங்கள் உங்கள் சூழலை மாஸ்டர் செய்துள்ளீர்கள்!",
            learnMoreAbout: "பற்றி மேலும் அறிய",
            backToHome: "வீட்டிற்கு திரும்ப",
            next: "அடுத்து",
            previous: "முந்தைய",
            check: "சரிபார்",
            tryAgain: "மீண்டும் முயற்சிக்கவும்",
            shuffled: "கலக்கப்பட்டது",
            noQuizAvailable: "வினாடி வினா இல்லை",
            question: "கேள்வி",
            correct: "சரியானது",
            incorrect: "தவறானது",
            notAttempted: "முயற்சிக்கப்படவில்லை"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "எனது மொழிகள்",
            notifications: "அறிவிப்புகள்",
            appearance: "அழகியல்",
            account: "கணக்கு",
            profile: "சுயவிவரம்",
            addLanguagePair: "மொழி இணை சேர்",
            enableNotifications: "அறிவிப்புகளை இயக்கு",
            logout: "வெளியேறு",
            deleteAllData: "அனைத்து தரவையும் நீக்கு",
            deleteAccount: "கணக்கை நீக்கு",
            selectLevel: "நிலை தேர்ந்தெடு",
            selectAppLanguage: "பயன்பாட்டு இடைமுகம்",
            proFeatures: "ப்ரோ அம்சங்கள்",
            showSimilarWordsToggle: "ஒத்த சொற்களை காண்பி",
            showWordTensesToggle: "சொல் காலங்களை காண்பி",
            nativeLanguage: "முதன்மை மொழி:",
            selectNativeLanguage: "உங்கள் முதன்மை மொழியைத் தேர்ந்தெடுக்கவும்",
            targetLanguage: "இலக்கு மொழி:",
            selectTargetLanguage: "நீங்கள் கற்றுக்கொள்ள விரும்பும் மொழியைத் தேர்ந்தெடுக்கவும்",
            nativeLanguageDescription: "உங்கள் முதன்மை மொழி என்பது நீங்கள் படிக்க, எழுத மற்றும் சரளமாக பேசக்கூடிய மொழியாகும். இது நீங்கள் மிகவும் வசதியாக உள்ள மொழியாகும்.",
            targetLanguageDescription: "உங்கள் இலக்கு மொழி என்பது நீங்கள் கற்றுக்கொள்ளவும் பயிற்சி செய்யவும் விரும்பும் மொழியாகும். உங்கள் திறன்களை மேம்படுத்த விரும்பும் மொழியைத் தேர்ந்தெடுக்கவும்.",
            addPair: "இணை சேர்",
            adding: "சேர்க்கிறது...",
            failedToAddLanguagePair: "மொழி இணையை சேர்க்க முடியவில்லை. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.",
            settingAsDefault: "இயல்புநிலையாக அமைக்கிறது...",
            beginner: "தொடக்க",
            intermediate: "இடைநிலை",
            advanced: "மேம்பட்ட",
            currentlyLearning: "கற்றுக்கொள்கிறேன்",
            otherLanguages: "மற்ற மொழிகள்",
            learnNewLanguage: "புதிய மொழி கற்றுக்கொள்ள",
            learn: "கற்றுக்கொள்",
            tapToSelectNativeLanguage: "உங்கள் முதன்மை மொழியைத் தேர்ந்தெடுக்க தட்டவும்",
            neonGreen: "நியான் பச்சை",
            cyanMist: "சையான் மிஸ்ட்",
            violetHaze: "வயலட் ஹேஸ்",
            softPink: "சாஃப்ட் பிங்க்",
            pureWhite: "தூய வெள்ளை"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "வகைகளை ஆராயுங்கள்",
            testYourself: "நீங்களே சோதிக்கவும்",
            slideToStartQuiz: "வினாடி வினாவை தொடங்க ஸ்லைடு செய்யவும்",
            similarWords: "ஒத்த வார்த்தைகள்",
            wordTenses: "வார்த்தை காலங்கள்",
            wordBreakdown: "வார்த்தை பிரித்தல்",
            tapToSeeBreakdown: "சொல் பிரித்தலைப் பார்க்க தட்டவும்",
            tapToHideBreakdown: "சொல் பிரித்தலை மறைக்க தட்டவும்",
            tapWordsToExplore: "அவற்றின் மொழிபெயர்ப்புகளைப் படிக்கவும் மற்றும் ஆராயவும் சொற்களைத் தொடவும்",
            loading: "லோட் செய்கிறது...",
            learnTheWord: "சொல்லைக் கற்றுக்கொள்ளுங்கள்",
            tryFromMemory: "நினைவிலிருந்து முயற்சிக்கவும்",
            adjustingTo: "சரிசெய்தல்",
            settingPlace: "அமைத்தல்",
            settingTime: "அமைத்தல்",
            generatingVocabulary: "உருவாக்குதல்",
            analyzingVocabulary: "பகுப்பாய்வு",
            analyzingCategories: "பகுப்பாய்வு",
            analyzingWords: "பகுப்பாய்வு",
            creatingQuiz: "உருவாக்குதல்",
            organizingContent: "ஒழுங்கமைத்தல்",
            to: "க்கு",
            place: "இடம்",
            time: "நேரம்",
            vocabulary: "சொற்களஞ்சியம்",
            your: "உங்கள்",
            interested: "ஆர்வம்",
            categories: "வகைகள்",
            words: "வார்த்தைகள்",
            quiz: "வினாடி",
            content: "உள்ளடக்கம்"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "வணக்கம்,",
            learnFromSurroundings: "உங்கள் சூழலிலிருந்து கற்றுக்கொள்ளுங்கள்",
            learnFromSurroundingsDescription: "உங்கள் சூழலைப் பிடித்து உண்மையான உலக சூழல்களிலிருந்து சொற்களஞ்சியத்தைக் கற்றுக்கொள்ளுங்கள்",
            locianChoosing: "தேர்ந்தெடுக்கிறது...",
            chooseLanguages: "மொழிகளைத் தேர்ந்தெடுக்கவும்",
            continueWith: "Locian தேர்ந்தெடுத்ததைத் தொடரவும்",
            slideToLearn: "கற்க ஸ்லைட் செய்யவும்",
            recommended: "பரிந்துரைகள்",
            intoYourLearningFlow: "உங்கள் கற்றல் ஓட்டத்தில்",
            intoYourLearningFlowDescription: "உங்கள் கற்றல் வரலாற்றின் அடிப்படையில் பயிற்சி செய்வதற்கான பரிந்துரைக்கப்பட்ட இடங்கள்",
            customSituations: "உங்கள் தனிப்பயன் சூழ்நிலைகள்",
            customSituationsDescription: "உங்கள் சொந்த தனிப்பயனாக்கப்பட்ட கற்றல் காட்சிகளுடன் உருவாக்கி பயிற்சி செய்யுங்கள்",
            max: "அதிகபட்சம்",
            recentPlacesTitle: "உங்கள் சமீபத்திய இடங்கள்",
            allPlacesTitle: "அனைத்து இடங்கள்",
            recentPlacesEmpty: "இங்கே பரிந்துரைகளை பார்க்க சொற்களை உருவாக்கவும்.",
            showMore: "மேலும் காட்டு",
            showLess: "குறைவாக காட்டு",
            takePhoto: "படம் எடுக்க",
            chooseFromGallery: "கேலரியிலிருந்து தேர்ந்தெடுக்க",
            letLocianChoose: "Locian தேர்ந்தெடுக்க விடுங்கள்",
            lociansChoice: "Locian மூலம்",
            cameraTileDescription: "இந்த படம் உங்கள் சூழலை பகுப்பாய்வு செய்து கற்றுக்கொள்ளக்கூடிய தருணங்களைக் காட்டுகிறது।",
            airport: "விமான நிலையம்",
            aquarium: "ஆக்வேரியம்",
            bakery: "பேக்கரி",
            beach: "கடற்கரை",
            bookstore: "நூல் கடை",
            cafe: "காபி",
            cinema: "திரையரங்கம்",
            gym: "விளையாட்டு அரங்கம்",
            hospital: "மருத்துவமனை",
            hotel: "ஹோட்டல்",
            home: "வீடு",
            library: "நூலகம்",
            market: "சந்தை",
            museum: "அருங்காட்சியகம்",
            office: "அலுவலகம்",
            park: "பூங்கா",
            restaurant: "உணவகம்",
            shoppingMall: "வணிக மையம்",
            stadium: "விளையாட்டரங்கம்",
            supermarket: "சூப்பர் மார்க்கெட்",
            temple: "கோவில்",
            travelling: "பயணம்",
            university: "பல்கலைக்கழகம்",
            addCustomPlace: "தனிப்பயன் இடத்தைச் சேர்",
            addPlace: "இடத்தைச் சேர்",
            enterCustomPlaceName: "தனிப்பயன் இடத்தின் பெயரை உள்ளிடவும் (அதிகபட்சம் 30 எழுத்துக்கள்)",
            maximumCustomPlaces: "அதிகபட்சம் 10 தனிப்பயன் இடங்கள்",
            welcome: "வரவேற்கிறோம்",
            user: "பயனர்",
            tapToCaptureContext: "உங்கள் சூழலை பிடிக்கவும் மற்றும் கற்றலைத் தொடங்கவும் தட்டவும்",
            customSection: "தனிப்பயன்",
            examples: "எடுத்துக்காட்டுகள்:",
            customPlacePlaceholder: "எ.கா., அலுவலகத்திற்கு பயணம்",
            exampleTravellingToOffice: "அலுவலகத்திற்கு பயணம்",
            exampleTravellingToHome: "வீட்டிற்கு பயணம்",
            exampleExploringParis: "பாரிஸை ஆராய்தல்",
            exampleVisitingMuseum: "அருங்காட்சியகத்தை பார்வையிடுதல்",
            exampleCoffeeShop: "காபி கடை",
            characterCount: "எழுத்துக்கள்",
            situationExample1: "நிறைந்த காபி கடையில் காபி ஆர்டர் செய்தல்",
            situationExample2: "புதிய நகரத்தில் திசை கேட்டல்",
            situationExample3: "சந்தையில் மளிகை பொருட்கள் வாங்குதல்",
            situationExample4: "மருத்துவர் நேரம் எடுத்தல்",
            situationExample5: "ஹோட்டலில் சேர்க்கை செய்தல்"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "உள்நுழை",
            verify: "சரிபார்க்க",
            selectProfession: "தொழிலைத் தேர்ந்தெடுக்கவும்",
            username: "பயனர் பெயர்",
            phoneNumber: "தொலைபேசி எண்",
            guestLogin: "விருந்தினர் உள்நுழைவு",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "நீங்கள் நிற்கும் இடத்திலிருந்து நீங்கள் தேவையான ஒவ்வொரு காலமும்",
            awarenessHeading: "விழிப்புணர்வு",
            awarenessDescription: "AI உங்கள் சூழலிலிருந்து கற்றுக்கொள்கிறது",
            inputsHeading: "உள்ளீடுகள்",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "பிரிவு",
            breakdownDescription: "Locian வாக்கியங்களை காலங்களாக பிரிக்கிறது, சொல்-படி-சொல் மொழிபெயர்ப்புகளை வழங்குகிறது",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "தயார்",
            readyDescription: "",
            loginOrRegister: "உள்நுழை / பதிவு",
            pageIndicator: " / 6",
            tapToNavigate: "வழிசெல்ல இடது அல்லது வலது பக்கத்தைத் தட்டவும்",
            selectAppLanguage: "பயன்பாட்டு மொழியைத் தேர்ந்தெடுக்கவும்",
            selectLanguageDescription: "இந்த மொழி பயன்பாட்டு பயனர் இடைமுகம், தலைப்புகள், விளக்கங்கள், பொத்தான்கள், பெயர்கள் மற்றும் அனைத்தையும் தேர்ந்தெடுக்கப்பட்ட மொழியாக மாற்றும்"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "ரத்துசெய்",
            save: "சேமி",
            done: "முடிந்தது",
            ok: "சரி",
            back: "பின்",
            next: "அடுத்து",
            continueText: "தொடர்க"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "தனிப்பயன்",
            hint: "குறிப்பு",
            practiceDescription: "எந்த வார்த்தையையும் தட்டவும் அதை உங்கள் இலக்கு மொழியில் மொழிபெயர்க்க. உதவி தேவைப்பட்டால், குறிப்பு பொத்தானைப் பயன்படுத்தி பரிந்துரைகளைப் பெறுங்கள்।",
            practiceTitle: "பயிற்சி",
            practiceFollowUp: "அடுத்த பயிற்சிக்குச் செல்",
            camera: "கேமரா",
            cameraDescription: "Locian {native} இல் ஒரு உரையாடலை உருவாக்கும், மேலும் நீங்கள் {target} க்கு மாற்றுவதை பயிற்சி செய்யலாம்.",
            useCamera: "கேமராவைப் பயன்படுத்த",
            cameraButtonDescription: "படத்திலிருந்து தருணங்களை உருவாக்க",
            typeConversation: "ஒரு உரையாடலை தட்டச்சு செய்ய",
            typeConversationDescription: "Locian {native} இல் ஒரு உரையாடலை உருவாக்கும், மேலும் நீங்கள் {target} க்கு மாற்றுவதை பயிற்சி செய்யலாம்.",
            conversationPlaceholder: "எ.கா. ஒரு நிறைந்த காபி கடையில் காபி ஆர்டர் செய்தல்",
            submit: "சமர்ப்பி",
            fullCustomText: "முழு தனிப்பயன் உரை",
            examples: "எடுத்துக்காட்டுகள்:",
            conversationExample1: "மழையில் திசை கேட்டல்",
            conversationExample2: "இரவு நேரத்தில் காய்கறிகள் வாங்குதல்",
            conversationExample3: "நிறைந்த அலுவலகத்தில் பணிபுரிதல்",
            describeConversation: "Locian உருவாக்க விரும்பும் உரையாடலை விவரிக்கவும்.",
            fullTextPlaceholder: "முழு உரை அல்லது உரையாடலை இங்கே தட்டச்சு செய்ய...",
            startCustomPractice: "தனிப்பயன் பயிற்சியைத் தொடங்க"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "முன்னேற்றம்",
            edit: "திருத்து",
            current: "தற்போதைய",
            longest: "நீளமான",
            lastPracticed: "கடைசியாக பயிற்சி செய்தது",
            days: "நாட்கள்",
            addLanguagePairToSeeProgress: "உங்கள் முன்னேற்றத்தைக் காண ஒரு மொழி இணையைச் சேர்க்கவும்."
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "எனது மொழிகள்"
        case .notifications: return "அறிவிப்புகள்"
        case .aesthetics: return "அழகியல்"
        case .account: return "கணக்கு"
        case .appLanguage: return "பயன்பாட்டு இடைமுகம்"
        
        // Common
        case .login: return "உள்நுழை /"
        case .register: return "பதிவு"
        case .settings: return "அமைப்புகள்"
        case .home: return "வீடு"
        case .back: return "பின்"
        case .next: return "அடுத்து"
        case .previous: return "முந்தைய"
        case .done: return "முடிந்தது"
        case .cancel: return "ரத்து"
        case .save: return "சேமி"
        case .delete: return "நீக்கு"
        case .add: return "சேர்"
        case .remove: return "அகற்று"
        case .edit: return "திருத்து"
        case .continueText: return "தொடர்க"
        
        // Quiz
        case .quizCompleted: return "வினாடி வினா முடிந்தது!"
        case .sessionCompleted: return "அமர்வு முடிந்தது!"
        case .masteredEnvironment: return "நீங்கள் உங்கள் சூழலை தேர்ச்சி பெற்றீர்கள்!"
        case .learnMoreAbout: return "பற்றி மேலும் அறிய"
        case .backToHome: return "வீட்டுக்கு திரும்பு"
        case .tryAgain: return "மீண்டும் முயற்சி"
        case .shuffled: return "கலக்கப்பட்டது"
        case .check: return "சரிபார்"
        
        // Vocabulary
        case .exploreCategories: return "வகைகளை ஆராய்க"
        case .testYourself: return "உங்களை சோதிக்கவும்"
        case .similarWords: return "ஒத்த சொற்கள்:"
        case .wordTenses: return "சொல் காலங்கள்:"
        case .tapWordsToExplore: return "அவற்றின் மொழிபெயர்ப்புகளைப் படிக்கவும் மற்றும் ஆராயவும் சொற்களைத் தொடவும்"
        case .wordBreakdown: return "சொல் பிரிவு:"
        
        // Scene
        case .analyzingImage: return "படத்தை பகுப்பாய்வு செய்கிறது..."
        case .imageAnalysisCompleted: return "பட பகுப்பாய்வு முடிந்தது"
        case .imageSelected: return "படம் தேர்ந்தெடுக்கப்பட்டது"
        case .placeNotSelected: return "இடம் தேர்ந்தெடுக்கப்படவில்லை"
        case .chooseLanguages: return "மொழிகளைத் தேர்ந்தெடுக்கவும்"
        case .locianChoose: return "Locian தேர்ந்தெடுக்கிறது"
        
        // Settings
        case .enableNotifications: return "அறிவிப்புகளை இயக்கு"
        case .thisPlace: return "இந்த இடம்"
        case .tapOnAnySection: return "அமைப்புகளைக் காணவும் நிர்வகிக்கவும் மேலே உள்ள எந்தப் பிரிவையும் தொடவும்"
        case .addNewLanguagePair: return "புதிய மொழி இணையைச் சேர்க்க"
        case .noLanguagePairsAdded: return "இன்னும் மொழி இணைகள் சேர்க்கப்படவில்லை"
        case .setDefault: return "இயல்புநிலையாக அமை"
        case .defaultText: return "இயல்புநிலை"
        case .user: return "பயனர்"
        case .noPhone: return "தொலைபேசி இல்லை"
        case .signOutFromAccount: return "உங்கள் கணக்கிலிருந்து வெளியேறவும்"
        case .removeAllPracticeData: return "உங்கள் அனைத்து பயிற்சி தரவையும் நீக்கவும்"
        case .permanentlyDeleteAccount: return "உங்கள் கணக்கு மற்றும் அனைத்து தரவையும் நிரந்தரமாக நீக்கவும்"
        case .currentLevel: return "தற்போதைய நிலை"
        case .selectPhoto: return "படத்தைத் தேர்ந்தெடுக்கவும்"
        case .camera: return "கேமரா"
        case .photoLibrary: return "பட நூலகம்"
        case .selectTime: return "நேரத்தைத் தேர்ந்தெடுக்கவும்"
        case .hour: return "மணி"
        case .minute: return "நிமிடம்"
        case .addTime: return "நேரத்தைச் சேர்க்க"
        case .areYouSureLogout: return "நீங்கள் உறுதியாக வெளியேற விரும்புகிறீர்களா?"
        case .areYouSureDeleteAccount: return "நீங்கள் உறுதியாக உங்கள் கணக்கை நீக்க விரும்புகிறீர்களா? இந்த செயலை மீண்டும் செய்ய முடியாது."
        
        // Quiz
        case .goBack: return "பின் செல்ல"
        case .fillInTheBlank: return "வெற்று இடத்தை நிரப்பவும்:"
        case .arrangeWordsInOrder: return "சொற்களை சரியான வரிசையில் அமைக்கவும்:"
        case .tapWordsBelowToAdd: return "அவற்றை இங்கே சேர்க்க கீழே உள்ள சொற்களைத் தொடவும்"
        case .availableWords: return "கிடைக்கும் சொற்கள்:"
        case .correctAnswer: return "சரியான பதில்:"
        
        // Common
        case .error: return "பிழை"
        case .ok: return "சரி"
        case .close: return "மூடு"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "நீங்கள் நிற்கும் இடத்திலிருந்து நீங்கள் தேவையான ஒவ்வொரு காலமும்"
        case .awarenessHeading: return "விழிப்புணர்வு"
        case .awarenessDescription: return "AI உங்கள் சூழலிலிருந்து கற்றுக்கொள்கிறது"
        case .inputsHeading: return "உள்ளீடுகள்"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "பிரிவு"
        case .breakdownDescription: return "Locian வாக்கியங்களை காலங்களாக பிரிக்கிறது, சொல்-படி-சொல் மொழிபெயர்ப்புகளை வழங்குகிறது"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "தயார்"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "உள்நுழை / பதிவு"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "வழிசெல்ல இடது அல்லது வலது பக்கத்தைத் தட்டவும்"
        case .selectAppLanguage: return "பயன்பாட்டு மொழியைத் தேர்ந்தெடுக்கவும்"
        case .selectLanguageDescription: return "இந்த மொழி பயன்பாட்டு பயனர் இடைமுகம், தலைப்புகள், விளக்கங்கள், பொத்தான்கள், பெயர்கள் மற்றும் அனைத்தையும் தேர்ந்தெடுக்கப்பட்ட மொழியாக மாற்றும்"
        
        // Login
        case .username: return "பயனர் பெயர்"
        case .phoneNumber: return "தொலைபேசி எண்"
        case .guestLogin: return "விருந்தினர் உள்நுழைவு"
        case .guestLoginDescription: return "விருந்தினர் உள்நுழைவு சரிபார்ப்புக்காக மற்றும் விருந்தினருக்கு அனைத்து பயன்பாட்டு அம்சங்களுக்கும் அணுகலை அனுமதிக்கும். சரிபார்ப்புக்குப் பிறகு அகற்றப்படும்."
        
        // Professions
        case .student: return "மாணவர்"
        case .softwareEngineer: return "மென்பொருள் பொறியாளர்"
        case .teacher: return "ஆசிரியர்"
        case .doctor: return "மருத்துவர்"
        case .artist: return "கலைஞர்"
        case .businessProfessional: return "வணிக நிபுணர்"
        case .salesOrMarketing: return "விற்பனை அல்லது சந்தைப்படுத்தல்"
        case .traveler: return "பயணி"
        case .homemaker: return "வீட்டு உழைப்பாளி"
        case .chef: return "செஃப்"
        case .police: return "போலீஸ்"
        case .bankEmployee: return "வங்கி ஊழியர்"
        case .nurse: return "நர்ஸ்"
        case .designer: return "வடிவமைப்பாளர்"
        case .engineerManager: return "பொறியாளர் மேலாளர்"
        case .photographer: return "புகைப்படக்காரர்"
        case .contentCreator: return "உள்ளடக்க படைப்பாளர்"
        case .other: return "மற்றவை"
        
        // Scene Places
        case .lociansChoice: return "Locian இன் தேர்வு"
        case .airport: return "விமான நிலையம்"
        case .cafe: return "காபி"
        case .gym: return "விளையாட்டு அரங்கம்"
        case .library: return "நூலகம்"
        case .office: return "அலுவலகம்"
        case .park: return "பூங்கா"
        case .restaurant: return "உணவகம்"
        case .shoppingMall: return "வணிக மையம்"
        case .travelling: return "பயணம்"
        case .university: return "பல்கலைக்கழகம்"
        case .addCustomPlace: return "தனிப்பயன் இடத்தைச் சேர்"
        case .enterCustomPlaceName: return "தனிப்பயன் இடத்தின் பெயரை உள்ளிடவும் (அதிகபட்சம் 30 எழுத்துக்கள்)"
        case .maximumCustomPlaces: return "அதிகபட்சம் 10 தனிப்பயன் இடங்கள்"
        case .welcome: return "வரவேற்கிறோம்"
        case .tapToCaptureContext: return "உங்கள் சூழலை பிடிக்கவும் மற்றும் கற்றலைத் தொடங்கவும் தட்டவும்"
        case .customSection: return "தனிப்பயன்"
        case .examples: return "எடுத்துக்காட்டுகள்:"
        case .customPlacePlaceholder: return "எ.கா., அலுவலகத்திற்கு பயணம்"
        case .exampleTravellingToOffice: return "அலுவலகத்திற்கு பயணம்"
        case .exampleTravellingToHome: return "வீட்டிற்கு பயணம்"
        case .exampleExploringParis: return "பாரிஸை ஆராய்தல்"
        case .exampleVisitingMuseum: return "அருங்காட்சியகத்தை பார்வையிடுதல்"
        case .exampleCoffeeShop: return "காபி கடை"
        case .characterCount: return "எழுத்துக்கள்"
        
        // Settings Modal Strings
        case .nativeLanguage: return "முதன்மை மொழி:"
        case .selectNativeLanguage: return "உங்கள் முதன்மை மொழியைத் தேர்ந்தெடுக்கவும்"
        case .targetLanguage: return "இலக்கு மொழி:"
        case .selectTargetLanguage: return "நீங்கள் கற்றுக்கொள்ள விரும்பும் மொழியைத் தேர்ந்தெடுக்கவும்"
        case .nativeLanguageDescription: return "உங்கள் முதன்மை மொழி என்பது நீங்கள் படிக்க, எழுத மற்றும் சரளமாக பேசக்கூடிய மொழியாகும். இது நீங்கள் மிகவும் வசதியாக உள்ள மொழியாகும்."
        case .targetLanguageDescription: return "உங்கள் இலக்கு மொழி என்பது நீங்கள் கற்றுக்கொள்ளவும் பயிற்சி செய்யவும் விரும்பும் மொழியாகும். உங்கள் திறன்களை மேம்படுத்த விரும்பும் மொழியைத் தேர்ந்தெடுக்கவும்."
        case .addPair: return "இணை சேர்"
        case .adding: return "சேர்க்கிறது..."
        case .failedToAddLanguagePair: return "மொழி இணையை சேர்க்க முடியவில்லை. தயவுசெய்து மீண்டும் முயற்சிக்கவும்."
        case .settingAsDefault: return "இயல்புநிலையாக அமைக்கிறது..."
        case .beginner: return "தொடக்க"
        case .intermediate: return "இடைநிலை"
        case .advanced: return "மேம்பட்ட"
        case .currentlyLearning: return "கற்றுக்கொள்கிறேன்"
        case .otherLanguages: return "மற்ற மொழிகள்"
        case .learnNewLanguage: return "புதிய மொழி கற்றுக்கொள்ள"
        case .learn: return "கற்றுக்கொள்"
        case .tapToSelectNativeLanguage: return "உங்கள் முதன்மை மொழியைத் தேர்ந்தெடுக்க தட்டவும்"
        case .neonGreen: return "நியான் பச்சை"
        
        // Theme color names
        case .cyanMist: return "சையான் மிஸ்ட்"
        case .violetHaze: return "வயலட் ஹேஸ்"
        case .softPink: return "சாஃப்ட் பிங்க்"
        case .pureWhite: return "தூய வெள்ளை"
        
        // Quick Look
        case .quickRecall: return "விரைவு நினைவு"
        case .startQuickPuzzle: return "விரைவு புதிரைத் தொடங்க"
        case .stopPuzzle: return "புதிரை நிறுத்த"
        
        // Streak
        case .streak: return "தொடர்"
        case .dayStreak: return "நாள் தொடர்"
        case .daysStreak: return "நாட்கள் தொடர்"
        case .editYourStreaks: return "உங்கள் தொடர்களை திருத்த"
        case .editStreaks: return "தொடர்களை திருத்த"
        case .selectDatesToAddOrRemove: return "பயிற்சி நாட்களைச் சேர்க்க அல்லது நீக்க தேதிகளைத் தேர்ந்தெடுக்கவும்"
        case .saving: return "சேமிக்கிறது..."
        }
    }
}

