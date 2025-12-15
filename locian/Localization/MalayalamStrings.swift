//
//  MalayalamStrings.swift
//  locian
//
//  Malayalam localization strings
//

import Foundation

struct MalayalamStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "ക്വിസ് പൂർത്തിയായി!",
            masteredEnvironment: "നിങ്ങൾ നിങ്ങളുടെ പരിസ്ഥിതി മാസ്റ്റർ ചെയ്തു!",
            learnMoreAbout: "കുറിച്ച് കൂടുതൽ അറിയുക",
            backToHome: "ഹോമിലേക്ക് മടങ്ങുക",
            next: "അടുത്തത്",
            previous: "മുമ്പത്തെ",
            check: "പരിശോധിക്കുക",
            tryAgain: "വീണ്ടും ശ്രമിക്കുക",
            shuffled: "കലക്കി",
            noQuizAvailable: "ക്വിസ് ലഭ്യമല്ല",
            question: "ചോദ്യം",
            correct: "ശരിയാണ്",
            incorrect: "തെറ്റാണ്",
            notAttempted: "ശ്രമിച്ചിട്ടില്ല"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "എന്റെ ഭാഷകൾ",
            notifications: "അറിയിപ്പുകൾ",
            appearance: "സൗന്ദര്യം",
            account: "അക്കൗണ്ട്",
            profile: "പ്രോഫൈൽ",
            addLanguagePair: "ഭാഷാ ജോഡി ചേർക്കുക",
            enableNotifications: "അറിയിപ്പുകൾ പ്രവർത്തനക്ഷമമാക്കുക",
            logout: "ലോഗൗട്ട്",
            deleteAllData: "എല്ലാ ഡാറ്റയും ഇല്ലാതാക്കുക",
            deleteAccount: "അക്കൗണ്ട് ഇല്ലാതാക്കുക",
            selectLevel: "ലെവൽ തിരഞ്ഞെടുക്കുക",
            selectAppLanguage: "ആപ്പ് ഇന്റർഫേസ്",
            proFeatures: "പ്രോ സവിശേഷതകൾ",
            showSimilarWordsToggle: "സമാനമായ വാക്കുകൾ കാണിക്കുക",
            showWordTensesToggle: "വാക്കുകളുടെ കാലങ്ങൾ കാണിക്കുക",
            nativeLanguage: "മാതൃഭാഷ:",
            selectNativeLanguage: "നിങ്ങളുടെ മാതൃഭാഷ തിരഞ്ഞെടുക്കുക",
            targetLanguage: "ലക്ഷ്യ ഭാഷ:",
            selectTargetLanguage: "നിങ്ങൾ പഠിക്കാൻ ആഗ്രഹിക്കുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക",
            nativeLanguageDescription: "നിങ്ങളുടെ മാതൃഭാഷ എന്നത് നിങ്ങൾക്ക് വായിക്കാനും എഴുതാനും സംസാരിക്കാനും കഴിയുന്ന ഭാഷയാണ്. ഇത് നിങ്ങൾക്ക് ഏറ്റവും സുഖകരമായ ഭാഷയാണ്.",
            targetLanguageDescription: "നിങ്ങളുടെ ലക്ഷ്യ ഭാഷ എന്നത് നിങ്ങൾ പഠിക്കാനും പരിശീലിക്കാനും ആഗ്രഹിക്കുന്ന ഭാഷയാണ്. നിങ്ങളുടെ കഴിവുകൾ മെച്ചപ്പെടുത്താൻ ആഗ്രഹിക്കുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക.",
            addPair: "ജോഡി ചേർക്കുക",
            adding: "ചേർക്കുന്നു...",
            failedToAddLanguagePair: "ഭാഷാ ജോഡി ചേർക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.",
            settingAsDefault: "സ്ഥിരസ്ഥിതിയായി സജ്ജമാക്കുന്നു...",
            beginner: "ആരംഭകൻ",
            intermediate: "മധ്യവർത്തി",
            advanced: "മുകളിലെ",
            currentlyLearning: "പഠിക്കുന്നു",
            otherLanguages: "മറ്റ് ഭാഷകൾ",
            learnNewLanguage: "പുതിയ ഭാഷ പഠിക്കുക",
            learn: "പഠിക്കുക",
            tapToSelectNativeLanguage: "നിങ്ങളുടെ മാതൃഭാഷ തിരഞ്ഞെടുക്കാൻ ടാപ്പ് ചെയ്യുക",
            neonGreen: "നിയോൺ ഗ്രീൻ",
            cyanMist: "സിയാൻ മിസ്റ്റ്",
            violetHaze: "വയലറ്റ് ഹേസ്",
            softPink: "സോഫ്റ്റ് പിങ്ക്",
            pureWhite: "ശുദ്ധ വെള്ള"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "വിഭാഗങ്ങൾ പര്യവേക്ഷണം ചെയ്യുക",
            testYourself: "സ്വയം പരീക്ഷിക്കുക",
            slideToStartQuiz: "Slide to start the quiz",
            similarWords: "സമാനമായ വാക്കുകൾ",
            wordTenses: "വാക്ക് കാലങ്ങൾ",
            wordBreakdown: "വാക്ക് വിഘടനം",
            tapToSeeBreakdown: "വാക്കിന്റെ വിഘടനം കാണാൻ ടാപ്പ് ചെയ്യുക",
            tapToHideBreakdown: "വാക്കിന്റെ വിഘടനം മറയ്ക്കാൻ ടാപ്പ് ചെയ്യുക",
            tapWordsToExplore: "അവയുടെ വിവർത്തനങ്ങൾ വായിക്കാനും പര്യവേക്ഷണം ചെയ്യാനും വാക്കുകൾ ടാപ്പ് ചെയ്യുക",
            loading: "ലോഡ് ചെയ്യുന്നു...",
            learnTheWord: "വാക്ക് പഠിക്കുക",
            tryFromMemory: "മെമ്മറിയിൽ നിന്ന് ശ്രമിക്കുക",
            adjustingTo: "സര്ദ്ദുബാട്",
            settingPlace: "സെറ്റ് ചെയ്യുന്നു",
            settingTime: "സെറ്റ് ചെയ്യുന്നു",
            generatingVocabulary: "ഉത്പാദിപ്പിക്കുന്നു",
            analyzingVocabulary: "വിശ്ലേഷിക്കുന്നു",
            analyzingCategories: "വിശ്ലേഷിക്കുന്നു",
            analyzingWords: "വിശ്ലേഷിക്കുന്നു",
            creatingQuiz: "സൃഷ്ടിക്കുന്നു",
            organizingContent: "ആയോജിക്കുന്നു",
            to: "ലേക്ക്",
            place: "സ്ഥലം",
            time: "സമയം",
            vocabulary: "പദാവലി",
            your: "നിങ്ങളുടെ",
            interested: "താൽപ്പര്യമുള്ള",
            categories: "വിഭാഗങ്ങൾ",
            words: "വാക്കുകൾ",
            quiz: "ക്വിസ്",
            content: "ഉള്ളടക്കം"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "ഹായ്,",
            learnFromSurroundings: "നിങ്ങളുടെ ചുറ്റുപാടുകളിൽ നിന്ന് പഠിക്കുക",
            learnFromSurroundingsDescription: "നിങ്ങളുടെ പരിസ്ഥിതി പിടിച്ചെടുത്ത് യഥാർത്ഥ ലോക സന്ദർഭങ്ങളിൽ നിന്ന് പദാവലി പഠിക്കുക",
            locianChoosing: "തിരഞ്ഞെടുക്കുന്നു...",
            chooseLanguages: "ഭാഷകൾ തിരഞ്ഞെടുക്കുക",
            continueWith: "Locian തിരഞ്ഞെടുത്തത് തുടരുക",
            slideToLearn: "Slide to learn",
            recommended: "ശുപാർശ ചെയ്തത്",
            intoYourLearningFlow: "നിങ്ങളുടെ പഠന പ്രവാഹത്തിലേക്ക്",
            intoYourLearningFlowDescription: "നിങ്ങളുടെ പഠന ചരിത്രത്തെ അടിസ്ഥാനമാക്കി പരിശീലനത്തിനായി ശുപാർശ ചെയ്യുന്ന സ്ഥലങ്ങൾ",
            customSituations: "നിങ്ങളുടെ കസ്റ്റം സാഹചര്യങ്ങൾ",
            customSituationsDescription: "നിങ്ങളുടെ സ്വന്തം വ്യക്തിഗത പഠന രംഗങ്ങളുമായി സൃഷ്ടിക്കുകയും പരിശീലിക്കുകയും ചെയ്യുക",
            max: "പരമാവധി",
            recentPlacesTitle: "നിങ്ങളുടെ പുതിയ സ്ഥലങ്ങൾ",
            allPlacesTitle: "എല്ലാ സ്ഥലങ്ങളും",
            recentPlacesEmpty: "ഇവിടെ നിർദേശങ്ങൾ കാണാൻ വാക്കുകൾ സൃഷ്ടിക്കുക.",
            showMore: "കൂടുതൽ കാണിക്കുക",
            showLess: "കുറച്ച് കാണിക്കുക",
            takePhoto: "ഫോട്ടോ എടുക്കുക",
            chooseFromGallery: "ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക",
            letLocianChoose: "Locian തിരഞ്ഞെടുക്കാൻ അനുവദിക്കുക",
            lociansChoice: "Locian ഒരുക്കിയത്",
            cameraTileDescription: "ഈ ഫോട്ടോ നിങ്ങളുടെ പരിസ്ഥിതി വിശ്ലേഷണം ചെയ്ത് പഠിക്കാനുള്ള നിമിഷങ്ങൾ കാണിക്കുന്നു.",
            airport: "വിമാനത്താവളം",
            aquarium: "ജലജീവാലയം",
            bakery: "ബേക്കറി",
            beach: "കടൽത്തീരം",
            bookstore: "പുസ്തകശാല",
            cafe: "കാഫേ",
            cinema: "സിനിമാഹാൾ",
            gym: "ജിമ്",
            hospital: "ആശുപത്രി",
            hotel: "ഹോട്ടൽ",
            home: "വീട്",
            library: "ലൈബ്രറി",
            market: "മാർക്കറ്റ്",
            museum: "മ്യൂസിയം",
            office: "ഓഫീസ്",
            park: "പാർക്ക്",
            restaurant: "റെസ്റ്റോറന്റ്",
            shoppingMall: "ഷോപ്പിംഗ് മാള്",
            stadium: "സ്റ്റേഡിയം",
            supermarket: "സൂപർമാർക്കറ്റ്",
            temple: "ക്ഷേത്രം",
            travelling: "യാത്ര",
            university: "യൂണിവേഴ്സിറ്റി",
            addCustomPlace: "ഇഷ്ടാനുസൃത സ്ഥലം ചേർക്കുക",
            addPlace: "സ്ഥലം ചേർക്കുക",
            enterCustomPlaceName: "ഇഷ്ടാനുസൃത സ്ഥലത്തിന്റെ പേര് നൽകുക (പരമാവധി 30 അക്ഷരങ്ങൾ)",
            maximumCustomPlaces: "പരമാവധി 10 ഇഷ്ടാനുസൃത സ്ഥലങ്ങൾ",
            welcome: "സ്വാഗതം",
            user: "ഉപയോക്താവ്",
            tapToCaptureContext: "നിങ്ങളുടെ സന്ദർഭം പിടിക്കാനും പഠനം ആരംഭിക്കാനും ടാപ്പ് ചെയ്യുക",
            customSection: "ഇഷ്ടാനുസൃതം",
            examples: "ഉദാഹരണങ്ങൾ:",
            customPlacePlaceholder: "ഉദാ., ഓഫീസിലേക്ക് യാത്ര",
            exampleTravellingToOffice: "ഓഫീസിലേക്ക് യാത്ര",
            exampleTravellingToHome: "വീട്ടിലേക്ക് യാത്ര",
            exampleExploringParis: "പാരീസ് പര്യവേക്ഷണം",
            exampleVisitingMuseum: "മ്യൂസിയം സന്ദർശനം",
            exampleCoffeeShop: "കാപ്പി ഷോപ്പ്",
            characterCount: "അക്ഷരങ്ങൾ",
            situationExample1: "തിരക്കേറിയ കാഫിയിൽ കാപ്പി ഓർഡർ ചെയ്യുന്നു",
            situationExample2: "പുതിയ നഗരത്തിൽ വഴി ചോദിക്കുന്നു",
            situationExample3: "മാർക്കറ്റിൽ പലചരക്ക് വാങ്ങുന്നു",
            situationExample4: "ഡോക്ടറുടെ അപ്പോയിന്റ്‌മെന്റ് എടുക്കുന്നു",
            situationExample5: "ഹോട്ടലിൽ ചെക്ക്-ഇൻ ചെയ്യുന്നു"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "ലോഗിൻ",
            verify: "സ്ഥിരീകരിക്കുക",
            selectProfession: "തൊഴിൽ തിരഞ്ഞെടുക്കുക",
            username: "ഉപയോക്തൃനാമം",
            phoneNumber: "ഫോൺ നമ്പർ",
            guestLogin: "ഗസ്റ്റ് ലോഗിൻ",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "നിങ്ങൾ നിൽക്കുന്നിടത്ത് നിന്ന് നിങ്ങൾക്ക് ആവശ്യമായ എല്ലാ കാലവും",
            awarenessHeading: "അവബോധം",
            awarenessDescription: "AI നിങ്ങളുടെ ചുറ്റുപാടുകളിൽ നിന്ന് പഠിക്കുന്നു",
            inputsHeading: "ഇൻപുട്ടുകൾ",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "വിഭജനം",
            breakdownDescription: "Locian വാക്യങ്ങളെ കാലങ്ങളായി വിഭജിക്കുന്നു, പദം-പദം വിവർത്തനങ്ങൾ നൽകുന്നു",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "തയ്യാറാണ്",
            readyDescription: "",
            loginOrRegister: "ലോഗിൻ / രജിസ്റ്റർ",
            pageIndicator: " / 6",
            tapToNavigate: "നാവിഗേറ്റ് ചെയ്യാൻ ഇടത് അല്ലെങ്കിൽ വലത് വശം ടാപ്പ് ചെയ്യുക",
            selectAppLanguage: "ആപ്പ് ഭാഷ തിരഞ്ഞെടുക്കുക",
            selectLanguageDescription: "ഈ ഭാഷ ആപ്പ് ഉപയോക്തൃ ഇന്റർഫേസ്, ഹെഡിംഗുകൾ, വിവരണങ്ങൾ, ബട്ടണുകൾ, പേരുകൾ, എല്ലാം തിരഞ്ഞെടുത്ത ഭാഷയിലേക്ക് മാറ്റും"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "റദ്ദാക്കുക",
            save: "സംരക്ഷിക്കുക",
            done: "പൂർത്തിയായി",
            ok: "ശരി",
            back: "പുറകോട്ട്",
            next: "അടുത്തത്",
            continueText: "തുടരുക"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "ഇഷ്ടാനുസൃതം",
            hint: "സൂചന",
            practiceDescription: "ഏത് വാക്കും ടാപ്പ് ചെയ്ത് അത് നിങ്ങളുടെ ലക്ഷ്യ ഭാഷയിലേക്ക് വിവർത്തനം ചെയ്യുക. സഹായം ആവശ്യമെങ്കിൽ, സൂചനകൾ ലഭിക്കാൻ സൂചന ബട്ടൺ ഉപയോഗിക്കുക.",
            practiceTitle: "പരിശീലനം",
            practiceFollowUp: "അടുത്ത പരിശീലനം",
            camera: "ക്യാമറ",
            cameraDescription: "Locian {native} ൽ ഒരു സംഭാഷണം സൃഷ്ടിക്കും, നിങ്ങൾക്ക് {target} ലേക്ക് പരിവർത്തനം ചെയ്യാനുള്ള പരിശീലനം നടത്താം.",
            useCamera: "ക്യാമറ ഉപയോഗിക്കുക",
            cameraButtonDescription: "ഫോട്ടോയിൽ നിന്ന് നിമിഷങ്ങൾ സൃഷ്ടിക്കുക",
            typeConversation: "ഒരു സംഭാഷണം ടൈപ്പ് ചെയ്യുക",
            typeConversationDescription: "Locian {native} ൽ ഒരു സംഭാഷണം സൃഷ്ടിക്കും, നിങ്ങൾക്ക് {target} ലേക്ക് പരിവർത്തനം ചെയ്യാനുള്ള പരിശീലനം നടത്താം.",
            conversationPlaceholder: "ഉദാ. തിരക്കേറിയ കാഫിയിൽ കാപ്പി ഓർഡർ ചെയ്യുന്നു",
            submit: "സമർപ്പിക്കുക",
            fullCustomText: "പൂർണ്ണ ഇഷ്ടാനുസൃത ടെക്സ്റ്റ്",
            examples: "ഉദാഹരണങ്ങൾ:",
            conversationExample1: "മഴയിൽ വഴി ചോദിക്കുന്നു",
            conversationExample2: "രാത്രി വൈകി പച്ചക്കറികൾ വാങ്ങുന്നു",
            conversationExample3: "കൂട്ടം നിറഞ്ഞ ഓഫീസിൽ പണിയെടുക്കുന്നു",
            describeConversation: "Locian നിർമ്മിക്കേണ്ട സംഭാഷണം വിവരിക്കുക.",
            fullTextPlaceholder: "പൂർണ്ണ ടെക്സ്റ്റ് അല്ലെങ്കിൽ സംഭാഷണം ഇവിടെ ടൈപ്പ് ചെയ്യുക...",
            startCustomPractice: "ഇഷ്ടാനുസൃത പരിശീലനം ആരംഭിക്കുക"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "പുരോഗതി",
            edit: "എഡിറ്റ് ചെയ്യുക",
            current: "നിലവിലുള്ള",
            longest: "ഏറ്റവും നീളമുള്ള",
            lastPracticed: "അവസാന പരിശീലനം",
            days: "ദിവസങ്ങൾ",
            addLanguagePairToSeeProgress: "നിങ്ങളുടെ പുരോഗതി കാണാൻ ഒരു ഭാഷാ ജോഡി ചേർക്കുക."
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "എന്റെ ഭാഷകൾ"
        case .notifications: return "അറിയിപ്പുകൾ"
        case .aesthetics: return "സൗന്ദര്യം"
        case .account: return "അക്കൗണ്ട്"
        case .appLanguage: return "ആപ്പ് ഇന്റർഫേസ്"
        
        // Common
        case .login: return "ലോഗിൻ /"
        case .register: return "രജിസ്റ്റർ"
        case .settings: return "ക്രമീകരണങ്ങൾ"
        case .home: return "ഹോം"
        case .back: return "പിന്നോട്ട്"
        case .next: return "അടുത്തത്"
        case .previous: return "മുമ്പത്തെ"
        case .done: return "പൂർത്തിയായി"
        case .cancel: return "റദ്ദാക്കുക"
        case .save: return "സംരക്ഷിക്കുക"
        case .delete: return "ഇല്ലാതാക്കുക"
        case .add: return "ചേർക്കുക"
        case .remove: return "നീക്കം ചെയ്യുക"
        case .edit: return "എഡിറ്റ് ചെയ്യുക"
        case .continueText: return "തുടരുക"
        
        // Quiz
        case .quizCompleted: return "ക്വിസ് പൂർത്തിയായി!"
        case .sessionCompleted: return "സെഷൻ പൂർത്തിയായി!"
        case .masteredEnvironment: return "നിങ്ങൾ നിങ്ങളുടെ പരിസ്ഥിതി മാസ്റ്റർ ചെയ്തു!"
        case .learnMoreAbout: return "കുറിച്ച് കൂടുതൽ അറിയുക"
        case .backToHome: return "ഹോമിലേക്ക് മടങ്ങുക"
        case .tryAgain: return "വീണ്ടും ശ്രമിക്കുക"
        case .shuffled: return "കലക്കി"
        case .check: return "പരിശോധിക്കുക"
        
        // Vocabulary
        case .exploreCategories: return "വിഭാഗങ്ങൾ പര്യവേക്ഷണം ചെയ്യുക"
        case .testYourself: return "നിങ്ങളെ പരീക്ഷിക്കുക"
        case .similarWords: return "സമാന വാക്കുകൾ:"
        case .wordTenses: return "വാക്ക് കാലങ്ങൾ:"
        case .tapWordsToExplore: return "അവയുടെ വിവർത്തനങ്ങൾ വായിക്കാനും പര്യവേക്ഷണം ചെയ്യാനും വാക്കുകൾ ടാപ്പ് ചെയ്യുക"
        case .wordBreakdown: return "വാക്ക് വിഭജനം:"
        
        // Scene
        case .analyzingImage: return "ചിത്രം വിശ്ലേഷിക്കുന്നു..."
        case .imageAnalysisCompleted: return "ചിത്ര വിശ്ലേഷണം പൂർത്തിയായി"
        case .imageSelected: return "ചിത്രം തിരഞ്ഞെടുത്തു"
        case .placeNotSelected: return "സ്ഥലം തിരഞ്ഞെടുത്തിട്ടില്ല"
        case .locianChoose: return "Locian തിരഞ്ഞെടുക്കുന്നു"
        case .chooseLanguages: return "ഭാഷകൾ തിരഞ്ഞെടുക്കുക"
        
        // Settings
        case .enableNotifications: return "അറിയിപ്പുകൾ പ്രവർത്തനക്ഷമമാക്കുക"
        case .thisPlace: return "ഈ സ്ഥലം"
        case .tapOnAnySection: return "സെറ്റിംഗുകൾ കാണാനും നിയന്ത്രിക്കാനും മുകളിലെ ഏതെങ്കിലും സെക്ഷൻ ടാപ്പ് ചെയ്യുക"
        case .addNewLanguagePair: return "പുതിയ ഭാഷാ ജോഡി ചേർക്കുക"
        case .noLanguagePairsAdded: return "ഇതുവരെ ഭാഷാ ജോഡികൾ ചേർത്തിട്ടില്ല"
        case .setDefault: return "ഡിഫോൾട്ടായി സജ്ജമാക്കുക"
        case .defaultText: return "ഡിഫോൾട്ട്"
        case .user: return "ഉപയോക്താവ്"
        case .noPhone: return "ഫോൺ ഇല്ല"
        case .signOutFromAccount: return "നിങ്ങളുടെ അക്കൗണ്ടിൽ നിന്ന് സൈൻ ഔട്ട് ചെയ്യുക"
        case .removeAllPracticeData: return "നിങ്ങളുടെ എല്ലാ പരിശീലന ഡാറ്റയും നീക്കം ചെയ്യുക"
        case .permanentlyDeleteAccount: return "നിങ്ങളുടെ അക്കൗണ്ടും എല്ലാ ഡാറ്റയും സ്ഥിരമായി ഇല്ലാതാക്കുക"
        case .currentLevel: return "നിലവിലെ ലെവൽ"
        case .selectPhoto: return "ഫോട്ടോ തിരഞ്ഞെടുക്കുക"
        case .camera: return "ക്യാമറ"
        case .photoLibrary: return "ഫോട്ടോ ലൈബ്രറി"
        case .selectTime: return "സമയം തിരഞ്ഞെടുക്കുക"
        case .hour: return "മണിക്കൂർ"
        case .minute: return "മിനിറ്റ്"
        case .addTime: return "സമയം ചേർക്കുക"
        case .areYouSureLogout: return "നിങ്ങൾക്ക് ഉറപ്പാണോ ലോഗ്‌ഔട്ട് ചെയ്യാൻ?"
        case .areYouSureDeleteAccount: return "നിങ്ങൾക്ക് ഉറപ്പാണോ നിങ്ങളുടെ അക്കൗണ്ട് ഇല്ലാതാക്കാൻ? ഈ പ്രവർത്തനം പൂർവ്വസ്ഥതയിലാക്കാൻ കഴിയില്ല."
        
        // Quiz
        case .goBack: return "തിരികെ പോകുക"
        case .fillInTheBlank: return "വിട്ടുകളഞ്ഞ സ്ഥലം പൂരിപ്പിക്കുക:"
        case .arrangeWordsInOrder: return "വാക്കുകൾ ശരിയായ ക്രമത്തിൽ ക്രമീകരിക്കുക:"
        case .tapWordsBelowToAdd: return "ഇവിടെ ചേർക്കാൻ ചുവടെയുള്ള വാക്കുകൾ ടാപ്പ് ചെയ്യുക"
        case .availableWords: return "ലഭ്യമായ വാക്കുകൾ:"
        case .correctAnswer: return "ശരിയായ ഉത്തരം:"
        
        // Common
        case .error: return "പിശക്"
        case .ok: return "ശരി"
        case .close: return "അടയ്ക്കുക"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "നിങ്ങൾ നിൽക്കുന്നിടത്ത് നിന്ന് നിങ്ങൾക്ക് ആവശ്യമായ എല്ലാ കാലവും"
        case .awarenessHeading: return "അവബോധം"
        case .awarenessDescription: return "AI നിങ്ങളുടെ ചുറ്റുപാടുകളിൽ നിന്ന് പഠിക്കുന്നു"
        case .inputsHeading: return "ഇൻപുട്ടുകൾ"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "വിഭജനം"
        case .breakdownDescription: return "Locian വാക്യങ്ങളെ കാലങ്ങളായി വിഭജിക്കുന്നു, പദം-പദം വിവർത്തനങ്ങൾ നൽകുന്നു"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "തയ്യാറാണ്"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "ലോഗിൻ / രജിസ്റ്റർ"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "നാവിഗേറ്റ് ചെയ്യാൻ ഇടത് അല്ലെങ്കിൽ വലത് വശം ടാപ്പ് ചെയ്യുക"
        case .selectAppLanguage: return "ആപ്പ് ഭാഷ തിരഞ്ഞെടുക്കുക"
        case .selectLanguageDescription: return "ഈ ഭാഷ ആപ്പ് ഉപയോക്തൃ ഇന്റർഫേസ്, ഹെഡിംഗുകൾ, വിവരണങ്ങൾ, ബട്ടണുകൾ, പേരുകൾ, എല്ലാം തിരഞ്ഞെടുത്ത ഭാഷയിലേക്ക് മാറ്റും"
        
        // Login
        case .username: return "ഉപയോക്തൃനാമം"
        case .phoneNumber: return "ഫോൺ നമ്പർ"
        case .guestLogin: return "ഗസ്റ്റ് ലോഗിൻ"
        case .guestLoginDescription: return "ഗസ്റ്റ് ലോഗിൻ പരിശോധനയ്ക്കാണ്, ഗസ്റ്റിന് എല്ലാ ആപ്പ് സവിശേഷതകളിലേക്കും പ്രവേശനം അനുവദിക്കും. പരിശോധനയ്ക്ക് ശേഷം നീക്കംചെയ്യും."
        
        // Professions
        case .student: return "വിദ്യാർത്ഥി"
        case .softwareEngineer: return "സോഫ്റ്റ്വെയർ എഞ്ചിനീയർ"
        case .teacher: return "അധ്യാപകൻ"
        case .doctor: return "വൈദ്യൻ"
        case .artist: return "കലാകാരൻ"
        case .businessProfessional: return "ബിസിനസ് പ്രൊഫഷണൽ"
        case .salesOrMarketing: return "വിൽപ്പന അല്ലെങ്കിൽ മാർക്കറ്റിംഗ്"
        case .traveler: return "യാത്രക്കാരൻ"
        case .homemaker: return "ഗൃഹിണി"
        case .chef: return "ചെഫ്"
        case .police: return "പോലീസ്"
        case .bankEmployee: return "ബാങ്ക് ജീവനക്കാരൻ"
        case .nurse: return "നഴ്സ്"
        case .designer: return "ഡിസൈനർ"
        case .engineerManager: return "എഞ്ചിനീയർ മാനേജർ"
        case .photographer: return "ഫോട്ടോഗ്രാഫർ"
        case .contentCreator: return "ഉള്ളടക്ക സ്രഷ്ടാവ്"
        case .other: return "മറ്റുള്ളവ"
        
        // Scene Places
        case .lociansChoice: return "Locian ന്റെ തിരഞ്ഞെടുപ്പ്"
        case .airport: return "വിമാനത്താവളം"
        case .cafe: return "കാഫേ"
        case .gym: return "ജിമ്"
        case .library: return "ലൈബ്രറി"
        case .office: return "ഓഫീസ്"
        case .park: return "പാർക്ക്"
        case .restaurant: return "റെസ്റ്റോറന്റ്"
        case .shoppingMall: return "ഷോപ്പിംഗ് മാള്"
        case .travelling: return "യാത്ര"
        case .university: return "യൂണിവേഴ്സിറ്റി"
        case .addCustomPlace: return "ഇഷ്ടാനുസൃത സ്ഥലം ചേർക്കുക"
        case .enterCustomPlaceName: return "ഇഷ്ടാനുസൃത സ്ഥലത്തിന്റെ പേര് നൽകുക (പരമാവധി 30 അക്ഷരങ്ങൾ)"
        case .maximumCustomPlaces: return "പരമാവധി 10 ഇഷ്ടാനുസൃത സ്ഥലങ്ങൾ"
        case .welcome: return "സ്വാഗതം"
        case .tapToCaptureContext: return "നിങ്ങളുടെ സന്ദർഭം പിടിക്കാനും പഠനം ആരംഭിക്കാനും ടാപ്പ് ചെയ്യുക"
        case .customSection: return "ഇഷ്ടാനുസൃതം"
        case .examples: return "ഉദാഹരണങ്ങൾ:"
        case .customPlacePlaceholder: return "ഉദാ., ഓഫീസിലേക്ക് യാത്ര"
        case .exampleTravellingToOffice: return "ഓഫീസിലേക്ക് യാത്ര"
        case .exampleTravellingToHome: return "വീട്ടിലേക്ക് യാത്ര"
        case .exampleExploringParis: return "പാരീസ് പര്യവേക്ഷണം"
        case .exampleVisitingMuseum: return "മ്യൂസിയം സന്ദർശനം"
        case .exampleCoffeeShop: return "കാപ്പി ഷോപ്പ്"
        case .characterCount: return "അക്ഷരങ്ങൾ"
        
        // Settings Modal Strings
        case .nativeLanguage: return "മാതൃഭാഷ:"
        case .selectNativeLanguage: return "നിങ്ങളുടെ മാതൃഭാഷ തിരഞ്ഞെടുക്കുക"
        case .targetLanguage: return "ലക്ഷ്യ ഭാഷ:"
        case .selectTargetLanguage: return "നിങ്ങൾ പഠിക്കാൻ ആഗ്രഹിക്കുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക"
        case .nativeLanguageDescription: return "നിങ്ങളുടെ മാതൃഭാഷ എന്നത് നിങ്ങൾക്ക് വായിക്കാനും എഴുതാനും സംസാരിക്കാനും കഴിയുന്ന ഭാഷയാണ്. ഇത് നിങ്ങൾക്ക് ഏറ്റവും സുഖകരമായ ഭാഷയാണ്."
        case .targetLanguageDescription: return "നിങ്ങളുടെ ലക്ഷ്യ ഭാഷ എന്നത് നിങ്ങൾ പഠിക്കാനും പരിശീലിക്കാനും ആഗ്രഹിക്കുന്ന ഭാഷയാണ്. നിങ്ങളുടെ കഴിവുകൾ മെച്ചപ്പെടുത്താൻ ആഗ്രഹിക്കുന്ന ഭാഷ തിരഞ്ഞെടുക്കുക."
        case .addPair: return "ജോഡി ചേർക്കുക"
        case .adding: return "ചേർക്കുന്നു..."
        case .failedToAddLanguagePair: return "ഭാഷാ ജോഡി ചേർക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക."
        case .settingAsDefault: return "സ്ഥിരസ്ഥിതിയായി സജ്ജമാക്കുന്നു..."
        case .beginner: return "ആരംഭകൻ"
        case .intermediate: return "മധ്യവർത്തി"
        case .advanced: return "മുകളിലെ"
        case .currentlyLearning: return "പഠിക്കുന്നു"
        case .otherLanguages: return "മറ്റ് ഭാഷകൾ"
        case .learnNewLanguage: return "പുതിയ ഭാഷ പഠിക്കുക"
        case .learn: return "പഠിക്കുക"
        case .tapToSelectNativeLanguage: return "നിങ്ങളുടെ മാതൃഭാഷ തിരഞ്ഞെടുക്കാൻ ടാപ്പ് ചെയ്യുക"
        case .neonGreen: return "നിയോൺ ഗ്രീൻ"
        
        // Theme color names
        case .cyanMist: return "സിയാൻ മിസ്റ്റ്"
        case .violetHaze: return "വയലറ്റ് ഹേസ്"
        case .softPink: return "സോഫ്റ്റ് പിങ്ക്"
        case .pureWhite: return "ശുദ്ധ വെള്ള"
        
        // Quick Look
        case .quickRecall: return "ദ്രുത ഓർമ്മ"
        case .startQuickPuzzle: return "ദ്രുത പസിൽ ആരംഭിക്കുക"
        case .stopPuzzle: return "പസിൽ നിർത്തുക"
        
        // Streak
        case .streak: return "സ്ട്രീക്ക്"
        case .dayStreak: return "ദിവസം സ്ട്രീക്ക്"
        case .daysStreak: return "ദിവസങ്ങൾ സ്ട്രീക്ക്"
        case .editYourStreaks: return "നിങ്ങളുടെ സ്ട്രീക്കുകൾ എഡിറ്റ് ചെയ്യുക"
        case .editStreaks: return "സ്ട്രീക്കുകൾ എഡിറ്റ് ചെയ്യുക"
        case .selectDatesToAddOrRemove: return "പരിശീലന ദിവസങ്ങൾ ചേർക്കാനോ നീക്കംചെയ്യാനോ തീയതികൾ തിരഞ്ഞെടുക്കുക"
        case .saving: return "സേവ് ചെയ്യുന്നു..."
        }
    }
}

