//
//  HindiStrings.swift
//  locian
//
//  Hindi localization strings
//

import Foundation

struct HindiStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "क्विज़ पूर्ण!",
            masteredEnvironment: "आपने अपने वातावरण में महारत हासिल कर ली है!",
            learnMoreAbout: "के बारे में और जानें",
            backToHome: "होम पर वापस",
            next: "अगला",
            previous: "पिछला",
            check: "जांचें",
            tryAgain: "फिर से कोशिश करें",
            shuffled: "शफल किया गया",
            noQuizAvailable: "कोई क्विज़ उपलब्ध नहीं",
            question: "प्रश्न",
            correct: "सही",
            incorrect: "गलत",
            notAttempted: "अप्रयासित"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "मेरी भाषाएं",
            notifications: "सूचनाएं",
            appearance: "सौंदर्य",
            account: "खाता",
            profile: "प्रोफ़ाइल",
            addLanguagePair: "भाषा युग्म जोड़ें",
            enableNotifications: "सूचनाएं सक्षम करें",
            logout: "लॉगआउट",
            deleteAllData: "सभी डेटा हटाएं",
            deleteAccount: "खाता हटाएं",
            selectLevel: "स्तर चुनें",
            selectAppLanguage: "ऐप इंटरफ़ेस",
            proFeatures: "प्रो सुविधाएँ",
            showSimilarWordsToggle: "समान शब्द दिखाएँ",
            showWordTensesToggle: "शब्दों के काल दिखाएँ",
            nativeLanguage: "मूल भाषा:",
            selectNativeLanguage: "अपनी मूल भाषा चुनें",
            targetLanguage: "लक्ष्य भाषा:",
            selectTargetLanguage: "वह भाषा चुनें जो आप सीखना चाहते हैं",
            nativeLanguageDescription: "आपकी मूल भाषा वह भाषा है जिसे आप पढ़, लिख और धाराप्रवाह बोल सकते हैं। यह वह भाषा है जिसमें आप सबसे अधिक सहज हैं।",
            targetLanguageDescription: "आपकी लक्ष्य भाषा वह भाषा है जिसे आप सीखना और अभ्यास करना चाहते हैं। वह भाषा चुनें जिसमें आप अपने कौशल में सुधार करना चाहते हैं।",
            addPair: "जोड़ी जोड़ें",
            adding: "जोड़ रहे हैं...",
            failedToAddLanguagePair: "भाषा जोड़ी जोड़ने में विफल। कृपया पुनः प्रयास करें।",
            settingAsDefault: "डिफ़ॉल्ट के रूप में सेट कर रहे हैं...",
            beginner: "शुरुआती",
            intermediate: "मध्यम",
            advanced: "उन्नत",
            currentlyLearning: "सीख रहे हैं",
            otherLanguages: "अन्य भाषाएं",
            learnNewLanguage: "नई भाषा सीखें",
            learn: "सीखें",
            tapToSelectNativeLanguage: "अपनी मूल भाषा चुनने के लिए टैप करें",
            neonGreen: "नीयन ग्रीन",
            cyanMist: "सियान मिस्ट",
            violetHaze: "वायलेट हेज़",
            softPink: "सॉफ्ट पिंक",
            pureWhite: "शुद्ध सफेद"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "श्रेणियां खोजें",
            testYourself: "अपना परीक्षण करें",
            slideToStartQuiz: "Slide to start the quiz",
            similarWords: "समान शब्द",
            wordTenses: "शब्द काल",
            wordBreakdown: "शब्द विभाजन",
            tapToSeeBreakdown: "शब्द का विभाजन देखने के लिए टैप करें",
            tapToHideBreakdown: "शब्द का विभाजन छुपाने के लिए टैप करें",
            tapWordsToExplore: "उनके अनुवाद पढ़ने और अन्वेषण करने के लिए शब्दों पर टैप करें",
            loading: "लोड हो रहा है...",
            learnTheWord: "शब्द सीखें",
            tryFromMemory: "याद से कोशिश करें",
            adjustingTo: "समायोजन",
            settingPlace: "सेट करना",
            settingTime: "सेट करना",
            generatingVocabulary: "उत्पन्न करना",
            analyzingVocabulary: "विश्लेषण",
            analyzingCategories: "विश्लेषण",
            analyzingWords: "विश्लेषण",
            creatingQuiz: "बनाना",
            organizingContent: "व्यवस्थित करना",
            to: "को",
            place: "स्थान",
            time: "समय",
            vocabulary: "शब्दावली",
            your: "आपका",
            interested: "रुचि",
            categories: "श्रेणियां",
            words: "शब्द",
            quiz: "क्विज़",
            content: "सामग्री"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "नमस्ते,",
            learnFromSurroundings: "अपने आसपास से सीखें",
            learnFromSurroundingsDescription: "अपने वातावरण को कैप्चर करें और वास्तविक दुनिया के संदर्भों से शब्दावली सीखें",
            locianChoosing: "चुन रहा है...",
            chooseLanguages: "भाषाएँ चुनें",
            continueWith: "Locian ने जो चुना उससे जारी रखें",
            slideToLearn: "Slide to learn",
            recommended: "अनुशंसित",
            intoYourLearningFlow: "आपकी सीखने की धारा में",
            intoYourLearningFlowDescription: "आपके सीखने के इतिहास के आधार पर अभ्यास करने के लिए अनुशंसित स्थान",
            customSituations: "आपकी कस्टम स्थितियाँ",
            customSituationsDescription: "अपने स्वयं के व्यक्तिगत सीखने के परिदृश्यों के साथ बनाएं और अभ्यास करें",
            max: "अधिकतम",
            recentPlacesTitle: "आपके हाल के स्थान",
            allPlacesTitle: "सभी स्थान",
            recentPlacesEmpty: "सुझाव देखने के लिए शब्दावली जनरेट करें।",
            showMore: "और दिखाएं",
            showLess: "कम दिखाएं",
            takePhoto: "फोटो लें",
            chooseFromGallery: "गैलरी से चुनें",
            letLocianChoose: "Locian को चुनने दें",
            lociansChoice: "Locian द्वारा",
            cameraTileDescription: "यह फोटो आपके वातावरण का विश्लेषण करता है और सीखने के लिए क्षण दिखाता है।",
            airport: "हवाई अड्डा",
            aquarium: "जलजीवालय",
            bakery: "बेकरी",
            beach: "समुद्र तट",
            bookstore: "पुस्तक दुकान",
            cafe: "कैफे",
            cinema: "सिनेमा",
            gym: "जिम",
            hospital: "अस्पताल",
            hotel: "होटल",
            home: "घर",
            library: "पुस्तकालय",
            market: "बाज़ार",
            museum: "संग्रहालय",
            office: "ऑफ़िस",
            park: "पार्क",
            restaurant: "रेस्तरां",
            shoppingMall: "शॉपिंग मॉल",
            stadium: "स्टेडियम",
            supermarket: "सुपरमार्केट",
            temple: "मंदिर",
            travelling: "यात्रा",
            university: "विश्वविद्यालय",
            addCustomPlace: "कस्टम स्थान जोड़ें",
            addPlace: "स्थान जोड़ें",
            enterCustomPlaceName: "कस्टम स्थान का नाम दर्ज करें (अधिकतम 30 अक्षर)",
            maximumCustomPlaces: "अधिकतम 10 कस्टम स्थान",
            welcome: "स्वागत है",
            user: "उपयोगकर्ता",
            tapToCaptureContext: "अपने संदर्भ को कैप्चर करने और सीखना शुरू करने के लिए टैप करें",
            customSection: "कस्टम",
            examples: "उदाहरण:",
            customPlacePlaceholder: "उदा., कार्यालय की यात्रा",
            exampleTravellingToOffice: "कार्यालय की यात्रा",
            exampleTravellingToHome: "घर की यात्रा",
            exampleExploringParis: "पेरिस की खोज",
            exampleVisitingMuseum: "संग्रहालय का दौरा",
            exampleCoffeeShop: "कॉफी की दुकान",
            characterCount: "अक्षर",
            situationExample1: "एक व्यस्त कैफे में कॉफी ऑर्डर करना",
            situationExample2: "एक नए शहर में रास्ता पूछना",
            situationExample3: "बाजार में किराने का सामान खरीदना",
            situationExample4: "डॉक्टर की अपॉइंटमेंट लेना",
            situationExample5: "होटल में चेक-इन करना"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "लॉगिन",
            verify: "सत्यापित करें",
            selectProfession: "पेशा चुनें",
            username: "उपयोगकर्ता नाम",
            phoneNumber: "फोन नंबर",
            guestLogin: "अतिथि लॉगिन",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "जहाँ आप खड़े हैं से लेकर हर tense जो आपको चाहिए",
            awarenessHeading: "जागरूकता",
            awarenessDescription: "AI आपके आसपास से सीखता है",
            inputsHeading: "इनपुट",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "विभाजन",
            breakdownDescription: "Locian वाक्यों को tenses में विभाजित करता है, शब्द-दर-शब्द अनुवाद प्रदान करता है",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "तैयार",
            readyDescription: "",
            loginOrRegister: "लॉगिन / पंजीकरण",
            pageIndicator: " / 6",
            tapToNavigate: "नेविगेट करने के लिए बाएं या दाएं टैप करें",
            selectAppLanguage: "ऐप भाषा चुनें",
            selectLanguageDescription: "यह भाषा ऐप यूजर इंटरफ़ेस, हेडिंग, विवरण, बटन, नाम और सभी चीजों को चयनित भाषा में बदल देगी"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "रद्द करें",
            save: "सहेजें",
            done: "पूर्ण",
            ok: "ठीक",
            back: "वापस",
            next: "अगला",
            continueText: "जारी रखें"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "कस्टम",
            hint: "संकेत",
            practiceDescription: "किसी भी शब्द पर टैप करें इसे अपनी लक्ष्य भाषा में अनुवाद करने के लिए। यदि आपको मदद चाहिए, तो सुझाव प्राप्त करने के लिए संकेत बटन का उपयोग करें।",
            practiceTitle: "अभ्यास",
            practiceFollowUp: "अगला अभ्यास",
            camera: "कैमरा",
            cameraDescription: "Locian {native} में एक बातचीत उत्पन्न करेगा और आप {target} में परिवर्तित करने का अभ्यास कर सकते हैं।",
            useCamera: "कैमरा उपयोग करें",
            cameraButtonDescription: "फोटो से क्षण उत्पन्न करें",
            typeConversation: "एक बातचीत टाइप करें",
            typeConversationDescription: "Locian {native} में एक बातचीत उत्पन्न करेगा और आप {target} में परिवर्तित करने का अभ्यास कर सकते हैं।",
            conversationPlaceholder: "उदा. एक व्यस्त कैफे में कॉफी ऑर्डर करना",
            submit: "सबमिट करें",
            fullCustomText: "पूर्ण कस्टम पाठ",
            examples: "उदाहरण:",
            conversationExample1: "बारिश में रास्ता पूछना",
            conversationExample2: "रात में देर से सब्जियां खरीदना",
            conversationExample3: "भीड़भाड़ वाले कार्यालय में काम करना",
            describeConversation: "वह बातचीत वर्णन करें जिसे आप Locian से बनाना चाहते हैं।",
            fullTextPlaceholder: "पूर्ण पाठ या संवाद यहाँ टाइप करें...",
            startCustomPractice: "कस्टम अभ्यास शुरू करें"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "प्रगति",
            edit: "संपादित करें",
            current: "वर्तमान",
            longest: "सबसे लंबा",
            lastPracticed: "अंतिम अभ्यास",
            days: "दिन",
            addLanguagePairToSeeProgress: "अपनी प्रगति देखने के लिए एक भाषा युग्म जोड़ें।"
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "मेरी भाषाएं"
        case .notifications: return "सूचनाएं"
        case .aesthetics: return "सौंदर्य"
        case .account: return "खाता"
        case .appLanguage: return "ऐप इंटरफ़ेस"
        
        // Common
        case .login: return "लॉगिन /"
        case .register: return "पंजीकरण"
        case .settings: return "सेटिंग्स"
        case .home: return "होम"
        case .back: return "वापस"
        case .next: return "अगला"
        case .previous: return "पिछला"
        case .done: return "पूर्ण"
        case .cancel: return "रद्द करें"
        case .save: return "सहेजें"
        case .delete: return "हटाएं"
        case .add: return "जोड़ें"
        case .remove: return "हटाएं"
        case .edit: return "संपादित करें"
        case .continueText: return "जारी रखें"
        
        // Quiz
        case .quizCompleted: return "क्विज़ पूर्ण!"
        case .sessionCompleted: return "सत्र पूर्ण!"
        case .masteredEnvironment: return "आपने अपने वातावरण में महारत हासिल कर ली है!"
        case .learnMoreAbout: return "के बारे में और जानें"
        case .backToHome: return "होम पर वापस जाएं"
        case .tryAgain: return "फिर से कोशिश करें"
        case .shuffled: return "शफल किया गया"
        case .check: return "जांचें"
        
        // Vocabulary
        case .exploreCategories: return "श्रेणियां खोजें"
        case .testYourself: return "अपना परीक्षण करें"
        case .similarWords: return "समान शब्द:"
        case .wordTenses: return "शब्द काल:"
        case .tapWordsToExplore: return "उनके अनुवाद पढ़ने और अन्वेषण करने के लिए शब्दों पर टैप करें"
        case .wordBreakdown: return "शब्द विभाजन:"
        
        // Scene
        case .analyzingImage: return "छवि का विश्लेषण कर रहे हैं..."
        case .imageAnalysisCompleted: return "छवि विश्लेषण पूर्ण"
        case .imageSelected: return "छवि चुनी गई"
        case .placeNotSelected: return "स्थान चयनित नहीं"
        case .locianChoose: return "Locian चुनता है"
        case .chooseLanguages: return "भाषाएँ चुनें"
        
        // Settings
        case .enableNotifications: return "सूचनाएं सक्षम करें"
        case .thisPlace: return "यह स्थान"
        case .tapOnAnySection: return "सेटिंग्स देखने और प्रबंधित करने के लिए ऊपर किसी भी सेक्शन पर टैप करें"
        case .addNewLanguagePair: return "नया भाषा युग्म जोड़ें"
        case .noLanguagePairsAdded: return "अभी तक कोई भाषा युग्म जोड़ा नहीं गया"
        case .setDefault: return "डिफ़ॉल्ट सेट करें"
        case .defaultText: return "डिफ़ॉल्ट"
        case .user: return "उपयोगकर्ता"
        case .noPhone: return "कोई फोन नहीं"
        case .signOutFromAccount: return "अपने खाते से साइन आउट करें"
        case .removeAllPracticeData: return "अपना सभी अभ्यास डेटा हटाएं"
        case .permanentlyDeleteAccount: return "अपने खाते और सभी डेटा को स्थायी रूप से हटाएं"
        case .currentLevel: return "वर्तमान स्तर"
        case .selectPhoto: return "फोटो चुनें"
        case .camera: return "कैमरा"
        case .photoLibrary: return "फोटो लाइब्रेरी"
        case .selectTime: return "समय चुनें"
        case .hour: return "घंटा"
        case .minute: return "मिनट"
        case .addTime: return "समय जोड़ें"
        case .areYouSureLogout: return "क्या आप वाकई लॉगआउट करना चाहते हैं?"
        case .areYouSureDeleteAccount: return "क्या आप वाकई अपना खाता हटाना चाहते हैं? यह कार्रवाई पूर्ववत नहीं की जा सकती।"
        
        // Quiz
        case .goBack: return "वापस जाएं"
        case .fillInTheBlank: return "रिक्त स्थान भरें:"
        case .arrangeWordsInOrder: return "शब्दों को सही क्रम में व्यवस्थित करें:"
        case .tapWordsBelowToAdd: return "उन्हें यहाँ जोड़ने के लिए नीचे के शब्दों पर टैप करें"
        case .availableWords: return "उपलब्ध शब्द:"
        case .correctAnswer: return "सही उत्तर:"
        
        // Common
        case .error: return "त्रुटि"
        case .ok: return "ठीक"
        case .close: return "बंद करें"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "जहाँ आप खड़े हैं से लेकर हर tense जो आपको चाहिए"
        case .awarenessHeading: return "जागरूकता"
        case .awarenessDescription: return "AI आपके आसपास से सीखता है"
        case .inputsHeading: return "इनपुट"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "विभाजन"
        case .breakdownDescription: return "Locian वाक्यों को tenses में विभाजित करता है, शब्द-दर-शब्द अनुवाद प्रदान करता है"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "तैयार"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "लॉगिन / पंजीकरण"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "नेविगेट करने के लिए बाएं या दाएं टैप करें"
        case .selectAppLanguage: return "ऐप भाषा चुनें"
        case .selectLanguageDescription: return "यह भाषा ऐप यूजर इंटरफ़ेस, हेडिंग, विवरण, बटन, नाम और सभी चीजों को चयनित भाषा में बदल देगी"
        
        // Login
        case .username: return "उपयोगकर्ता नाम"
        case .phoneNumber: return "फोन नंबर"
        case .guestLogin: return "अतिथि लॉगिन"
        case .guestLoginDescription: return "अतिथि लॉगिन सत्यापन के लिए है और अतिथि को सभी ऐप सुविधाओं तक पहुंच देगा। सत्यापन के बाद हटा दिया जाएगा।"
        
        // Professions
        case .student: return "छात्र"
        case .softwareEngineer: return "सॉफ्टवेयर इंजीनियर"
        case .teacher: return "शिक्षक"
        case .doctor: return "डॉक्टर"
        case .artist: return "कलाकार"
        case .businessProfessional: return "व्यापार पेशेवर"
        case .salesOrMarketing: return "बिक्री या विपणन"
        case .traveler: return "यात्री"
        case .homemaker: return "गृहिणी"
        case .chef: return "शेफ"
        case .police: return "पुलिस"
        case .bankEmployee: return "बैंक कर्मचारी"
        case .nurse: return "नर्स"
        case .designer: return "डिज़ाइनर"
        case .engineerManager: return "इंजीनियर मैनेजर"
        case .photographer: return "फोटोग्राफर"
        case .contentCreator: return "कंटेंट क्रिएटर"
        case .other: return "अन्य"
        
        // Scene Places
        case .lociansChoice: return "Locian की पसंद"
        case .airport: return "हवाई अड्डा"
        case .cafe: return "कैफे"
        case .gym: return "जिम"
        case .library: return "पुस्तकालय"
        case .office: return "ऑफ़िस"
        case .park: return "पार्क"
        case .restaurant: return "रेस्तरां"
        case .shoppingMall: return "शॉपिंग मॉल"
        case .travelling: return "यात्रा"
        case .university: return "विश्वविद्यालय"
        case .addCustomPlace: return "कस्टम स्थान जोड़ें"
        case .enterCustomPlaceName: return "कस्टम स्थान का नाम दर्ज करें (अधिकतम 30 अक्षर)"
        case .maximumCustomPlaces: return "अधिकतम 10 कस्टम स्थान"
        case .welcome: return "स्वागत है"
        case .tapToCaptureContext: return "अपने संदर्भ को कैप्चर करने और सीखना शुरू करने के लिए टैप करें"
        case .customSection: return "कस्टम"
        case .examples: return "उदाहरण:"
        case .customPlacePlaceholder: return "उदा., कार्यालय की यात्रा"
        case .exampleTravellingToOffice: return "कार्यालय की यात्रा"
        case .exampleTravellingToHome: return "घर की यात्रा"
        case .exampleExploringParis: return "पेरिस की खोज"
        case .exampleVisitingMuseum: return "संग्रहालय का दौरा"
        case .exampleCoffeeShop: return "कॉफी की दुकान"
        case .characterCount: return "अक्षर"
        
        // Settings Modal Strings
        case .nativeLanguage: return "मूल भाषा:"
        case .selectNativeLanguage: return "अपनी मूल भाषा चुनें"
        case .targetLanguage: return "लक्ष्य भाषा:"
        case .selectTargetLanguage: return "वह भाषा चुनें जो आप सीखना चाहते हैं"
        case .nativeLanguageDescription: return "आपकी मूल भाषा वह भाषा है जिसे आप पढ़, लिख और धाराप्रवाह बोल सकते हैं। यह वह भाषा है जिसमें आप सबसे अधिक सहज हैं।"
        case .targetLanguageDescription: return "आपकी लक्ष्य भाषा वह भाषा है जिसे आप सीखना और अभ्यास करना चाहते हैं। वह भाषा चुनें जिसमें आप अपने कौशल में सुधार करना चाहते हैं।"
        case .addPair: return "जोड़ी जोड़ें"
        case .adding: return "जोड़ रहे हैं..."
        case .failedToAddLanguagePair: return "भाषा जोड़ी जोड़ने में विफल। कृपया पुनः प्रयास करें।"
        case .settingAsDefault: return "डिफ़ॉल्ट के रूप में सेट कर रहे हैं..."
        case .beginner: return "शुरुआती"
        case .intermediate: return "मध्यम"
        case .advanced: return "उन्नत"
        case .currentlyLearning: return "सीख रहे हैं"
        case .otherLanguages: return "अन्य भाषाएं"
        case .learnNewLanguage: return "नई भाषा सीखें"
        case .learn: return "सीखें"
        case .tapToSelectNativeLanguage: return "अपनी मूल भाषा चुनने के लिए टैप करें"
        case .neonGreen: return "नीयन ग्रीन"
        
        // Theme color names
        case .cyanMist: return "सियान मिस्ट"
        case .violetHaze: return "वायलेट हेज़"
        case .softPink: return "सॉफ्ट पिंक"
        case .pureWhite: return "शुद्ध सफेद"
        
        // Quick Look
        case .quickRecall: return "त्वरित याद"
        case .startQuickPuzzle: return "त्वरित पहेली शुरू करें"
        case .stopPuzzle: return "पहेली रोकें"
        
        // Streak
        case .streak: return "स्ट्रीक"
        case .dayStreak: return "दिन की स्ट्रीक"
        case .daysStreak: return "दिनों की स्ट्रीक"
        case .editYourStreaks: return "अपनी स्ट्रीक संपादित करें"
        case .editStreaks: return "स्ट्रीक संपादित करें"
        case .selectDatesToAddOrRemove: return "अभ्यास दिनों को जोड़ने या हटाने के लिए तारीखें चुनें"
        case .saving: return "सहेजा जा रहा है..."
        }
    }
}

