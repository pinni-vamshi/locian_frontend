//
//  EnglishStrings.swift
//  locian
//
//  English localization strings
//

import Foundation

struct EnglishStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "Quiz Completed!",
            masteredEnvironment: "You have mastered your environment!",
            learnMoreAbout: "Learn more about",
            backToHome: "Back to Home",
            next: "Next",
            previous: "Previous",
            check: "Check",
            tryAgain: "Try again",
            shuffled: "Shuffled",
            noQuizAvailable: "No quiz available",
            question: "Question",
            correct: "Correct",
            incorrect: "Incorrect",
            notAttempted: "Not Attempted"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "My Languages",
            notifications: "Notifications",
            appearance: "Aesthetics",
            account: "Account",
            profile: "Profile",
            addLanguagePair: "Add Language Pair",
            enableNotifications: "Enable Notifications",
            logout: "Logout",
            deleteAllData: "Delete All Data",
            deleteAccount: "Delete Account",
            selectLevel: "Select Level",
            selectAppLanguage: "App Interface",
            proFeatures: "Power Tools",
            showSimilarWordsToggle: "Show Similar Words",
            showWordTensesToggle: "Show Word Tenses",
            nativeLanguage: "Native Language:",
            selectNativeLanguage: "Select your native language",
            targetLanguage: "Target Language:",
            selectTargetLanguage: "Select the language you want to learn",
            nativeLanguageDescription: "Your native language is the language you can read, write, and speak fluently. This is the language you are most comfortable with.",
            targetLanguageDescription: "Your target language is the language you want to learn and practice. Choose the language you wish to improve your skills in.",
            addPair: "Add Pair",
            adding: "Adding...",
            failedToAddLanguagePair: "Failed to add language pair. Please try again.",
            settingAsDefault: "Setting as default...",
            beginner: "Beginner",
            intermediate: "Intermediate",
            advanced: "Advanced",
            currentlyLearning: "Learning",
            otherLanguages: "Other Languages",
            learnNewLanguage: "Learn new language",
            learn: "Learn",
            tapToSelectNativeLanguage: "Tap to select your native language",
            neonGreen: "Neon Green",
            cyanMist: "Cyan Mist",
            violetHaze: "Violet Haze",
            softPink: "Pink",
            pureWhite: "Pure White"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "Explore categories",
            testYourself: "Test yourself",
            slideToStartQuiz: "Slide to start the quiz",
            similarWords: "Similar Words",
            wordTenses: "Word Tenses",
            wordBreakdown: "Word Breakdown",
            tapToSeeBreakdown: "Tap the word to see its breakdown",
            tapToHideBreakdown: "Tap the word to hide the breakdown",
            tapWordsToExplore: "Tap the words to read their translations and explore",
            loading: "Loading...",
            learnTheWord: "Learn the word",
            tryFromMemory: "Try from memory",
            adjustingTo: "Adjusting",
            settingPlace: "Setting",
            settingTime: "Setting",
            generatingVocabulary: "Generating",
            analyzingVocabulary: "Analyzing",
            analyzingCategories: "Analyzing",
            analyzingWords: "Analyzing",
            creatingQuiz: "Creating",
            organizingContent: "Organizing",
            to: "to",
            place: "place",
            time: "time",
            vocabulary: "vocabulary",
            your: "your",
            interested: "interested",
            categories: "categories",
            words: "words",
            quiz: "quiz",
            content: "content"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "Hi,",
            learnFromSurroundings: "Learn from your surroundings",
            learnFromSurroundingsDescription: "Capture your environment and learn vocabulary from real-world contexts",
            locianChoosing: "choosing...",
            chooseLanguages: "Choose languages",
            continueWith: "Continue with what Locian chose",
            slideToLearn: "Slide to learn",
            recommended: "Recommended",
            intoYourLearningFlow: "Into your learning flow",
            intoYourLearningFlowDescription: "Recommended places to practice based on your learning history",
            customSituations: "Your custom situations",
            customSituationsDescription: "Create and practice with your own personalized learning scenarios",
            max: "Max",
            recentPlacesTitle: "Your recent places",
            allPlacesTitle: "All places",
            recentPlacesEmpty: "Generate vocabulary to see suggestions here.",
            showMore: "Show more",
            showLess: "Show less",
            takePhoto: "Take Photo",
            chooseFromGallery: "Choose from Gallery",
            letLocianChoose: "LET LOCIAN CHOOSE",
            lociansChoice: "By Locian",
            cameraTileDescription: "This photo analyzes your environment and shows you moments to learn from.",
            airport: "Airport",
            aquarium: "Aquarium",
            bakery: "Bakery",
            beach: "Beach",
            bookstore: "Bookstore",
            cafe: "Cafe",
            cinema: "Cinema",
            gym: "Gym",
            hospital: "Hospital",
            hotel: "Hotel",
            home: "Home",
            library: "Library",
            market: "Market",
            museum: "Museum",
            office: "Office",
            park: "Park",
            restaurant: "Restaurant",
            shoppingMall: "Shopping Mall",
            stadium: "Stadium",
            supermarket: "Supermarket",
            temple: "Temple",
            travelling: "Travelling",
            university: "University",
            addCustomPlace: "Add Custom Place",
            addPlace: "Add place",
            enterCustomPlaceName: "Enter a custom place name (30 characters max)",
            maximumCustomPlaces: "Maximum 10 custom places",
            welcome: "Welcome",
            user: "User",
            tapToCaptureContext: "Tap to capture your context and start learning",
            customSection: "Custom",
            examples: "Examples:",
            customPlacePlaceholder: "e.g., travelling to office",
            exampleTravellingToOffice: "travelling to office",
            exampleTravellingToHome: "travelling to home",
            exampleExploringParis: "exploring paris",
            exampleVisitingMuseum: "visiting museum",
            exampleCoffeeShop: "coffee shop",
            characterCount: "characters",
            situationExample1: "Ordering coffee at a busy cafe",
            situationExample2: "Asking for directions in a new city",
            situationExample3: "Shopping for groceries at the market",
            situationExample4: "Making a doctor's appointment",
            situationExample5: "Checking into a hotel"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "Login",
            verify: "Verify",
            selectProfession: "Select Profession",
            username: "Username",
            phoneNumber: "Phone Number",
            guestLogin: "Guest Login",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "From where you stand to every tense you need",
            awarenessHeading: "Awareness",
            awarenessDescription: "AI learns from your surroundings",
            inputsHeading: "Inputs",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "Breakdown",
            breakdownDescription: "Locian breaks down sentences into tenses, provides word-by-word translations",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "Ready",
            readyDescription: "",
            loginOrRegister: "Login / Register",
            pageIndicator: " / 6",
            tapToNavigate: "Tap left or right side to navigate",
            selectAppLanguage: "Select App Language",
            selectLanguageDescription: "This language will make the app user interface, headings, descriptions, buttons, names, and all things into the selected language"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "Cancel",
            save: "Save",
            done: "Done",
            ok: "OK",
            back: "Back",
            next: "Next",
            continueText: "Continue"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "Custom",
            hint: "Hint",
            practiceDescription: "Tap any word to translate it into your target language. If you need help, use the hint button to get suggestions.",
            practiceTitle: "Practice",
            practiceFollowUp: "Practice follow up",
            camera: "Camera",
            cameraDescription: "Locian will generate a conversation in {native} and you can practice converting to {target}.",
            useCamera: "Use camera",
            cameraButtonDescription: "Generate moments from photo",
            typeConversation: "Type of conversation",
            typeConversationDescription: "Locian will generate a conversation in {native} and you can practice converting to {target}.",
            conversationPlaceholder: "e.g. Ordering coffee at a busy cafe",
            submit: "Submit",
            fullCustomText: "Full custom text",
            examples: "Examples:",
            conversationExample1: "Asking for directions in the rain",
            conversationExample2: "Buying vegetables late at night",
            conversationExample3: "Working in a crowded office",
            describeConversation: "Describe the conversation you want Locian to build.",
            fullTextPlaceholder: "Type the full text or dialogue here...",
            startCustomPractice: "Start custom practice"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Progress",
            edit: "Edit",
            current: "Current",
            longest: "Longest",
            lastPracticed: "Last practiced",
            days: "days",
            addLanguagePairToSeeProgress: "Add a language pair to see your progress."
        )
    }
    
    func getString(_ key: String) -> String {
        // Fallback to English if key not found
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "My Languages"
        case .notifications: return "Notifications"
        case .aesthetics: return "Aesthetics"
        case .account: return "Account"
        case .appLanguage: return "App Interface"
        
        // Common
        case .login: return "Login /"
        case .register: return "Register"
        case .settings: return "Settings"
        case .home: return "Home"
        case .back: return "Back"
        case .next: return "Next"
        case .previous: return "Previous"
        case .done: return "Done"
        case .cancel: return "Cancel"
        case .save: return "Save"
        case .delete: return "Delete"
        case .add: return "Add"
        case .remove: return "Remove"
        case .edit: return "Edit"
        case .continueText: return "Continue"
        
        // Quiz
        case .quizCompleted: return "Quiz Completed!"
        case .sessionCompleted: return "Session Completed!"
        case .masteredEnvironment: return "You have mastered your environment!"
        case .learnMoreAbout: return "Learn more about"
        case .backToHome: return "Back to Home"
        case .tryAgain: return "Try again"
        case .shuffled: return "Shuffled"
        case .check: return "Check"
        
        // Vocabulary
        case .exploreCategories: return "Explore categories"
        case .testYourself: return "Test yourself"
        case .similarWords: return "Similar Words:"
        case .wordTenses: return "Word Tenses:"
        case .tapWordsToExplore: return "Tap the words to read their translations and explore"
        case .wordBreakdown: return "Word Breakdown:"
        
        // Scene
        case .analyzingImage: return "Analyzing image..."
        case .imageAnalysisCompleted: return "Image analysis completed"
        case .imageSelected: return "Image selected"
        case .placeNotSelected: return "Place not selected"
        case .locianChoose: return "Locian choose"
        case .chooseLanguages: return "Choose languages"
        
        // Settings
        case .enableNotifications: return "Enable Notifications"
        case .thisPlace: return "this place"
        case .tapOnAnySection: return "Tap on any section above to view and manage settings"
        case .addNewLanguagePair: return "Add New Language Pair"
        case .noLanguagePairsAdded: return "No language pairs added yet"
        case .setDefault: return "Set Default"
        case .defaultText: return "Default"
        case .user: return "User"
        case .noPhone: return "No phone"
        case .signOutFromAccount: return "Sign out from your account"
        case .removeAllPracticeData: return "Remove all your practice data"
        case .permanentlyDeleteAccount: return "Permanently delete your account and all data"
        case .currentLevel: return "Current Level"
        case .selectPhoto: return "Select Photo"
        case .camera: return "Camera"
        case .photoLibrary: return "Photo Library"
        case .selectTime: return "Select Time"
        case .hour: return "Hour"
        case .minute: return "Minute"
        case .addTime: return "Add Time"
        case .areYouSureLogout: return "Are you sure you want to logout?"
        case .areYouSureDeleteAccount: return "Are you sure you want to delete your account? This action cannot be undone."
        
        // Quiz
        case .goBack: return "Go Back"
        case .fillInTheBlank: return "Fill in the blank:"
        case .arrangeWordsInOrder: return "Arrange the words in correct order:"
        case .tapWordsBelowToAdd: return "Tap words below to add them here"
        case .availableWords: return "Available words:"
        case .correctAnswer: return "Correct Answer:"
        
        // Common
        case .error: return "Error"
        case .ok: return "OK"
        case .close: return "Close"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "From where you stand to every time you need"
        case .awarenessHeading: return "Awareness"
        case .awarenessDescription: return "AI learns from your environment"
        case .inputsHeading: return "Inputs"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "Breakdown"
        case .breakdownDescription: return "Locian breaks down sentences into tenses, provides word-by-word translations"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "Ready"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "Login / Register"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "Tap left or right side to navigate"
        case .selectAppLanguage: return "Select App Language"
        case .selectLanguageDescription: return "This language will make the app user interface, headings, descriptions, buttons, names, and all things into the selected language"
        
        // Login
        case .username: return "Username"
        case .phoneNumber: return "Phone Number"
        case .guestLogin: return "Guest Login"
        case .guestLoginDescription: return "Guest Login is for verification and will let guest access all app features. Will be removed after verification."
        
        // Professions
        case .student: return "Student"
        case .softwareEngineer: return "Software Engineer"
        case .teacher: return "Teacher"
        case .doctor: return "Doctor"
        case .artist: return "Artist"
        case .businessProfessional: return "Business Professional"
        case .salesOrMarketing: return "Sales or Marketing"
        case .traveler: return "Traveler"
        case .homemaker: return "Homemaker"
        case .chef: return "Chef"
        case .police: return "Police"
        case .bankEmployee: return "Bank Employee"
        case .nurse: return "Nurse"
        case .designer: return "Designer"
        case .engineerManager: return "Engineer Manager"
        case .photographer: return "Photographer"
        case .contentCreator: return "Content Creator"
        case .other: return "Other"
        
        // Scene Places
        case .lociansChoice: return "Locian's choice"
        case .airport: return "Airport"
        case .cafe: return "Cafe"
        case .gym: return "Gym"
        case .library: return "Library"
        case .office: return "Office"
        case .park: return "Park"
        case .restaurant: return "Restaurant"
        case .shoppingMall: return "Shopping Mall"
        case .travelling: return "Travelling"
        case .university: return "University"
        case .addCustomPlace: return "Add Custom Place"
        case .enterCustomPlaceName: return "Enter a custom place name (30 characters max)"
        case .maximumCustomPlaces: return "Maximum 10 custom places"
        case .welcome: return "Welcome"
        case .tapToCaptureContext: return "Tap to capture your context and start learning"
        case .customSection: return "Custom"
        case .examples: return "Examples:"
        case .customPlacePlaceholder: return "e.g., travelling to office"
        case .exampleTravellingToOffice: return "travelling to office"
        case .exampleTravellingToHome: return "travelling to home"
        case .exampleExploringParis: return "exploring paris"
        case .exampleVisitingMuseum: return "visiting museum"
        case .exampleCoffeeShop: return "coffee shop"
        case .characterCount: return "characters"
        
        // Settings Modal Strings
        case .nativeLanguage: return "Native Language:"
        case .selectNativeLanguage: return "Select your native language"
        case .targetLanguage: return "Target Language:"
        case .selectTargetLanguage: return "Select the language you want to learn"
        case .nativeLanguageDescription: return "Your native language is the language you can read, write, and speak fluently. This is the language you are most comfortable with."
        case .targetLanguageDescription: return "Your target language is the language you want to learn and practice. Choose the language you wish to improve your skills in."
        case .addPair: return "Add Pair"
        case .adding: return "Adding..."
        case .failedToAddLanguagePair: return "Failed to add language pair. Please try again."
        case .settingAsDefault: return "Setting as default..."
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .currentlyLearning: return "Learning"
        case .otherLanguages: return "Other Languages"
        case .learnNewLanguage: return "Learn new language"
        case .learn: return "Learn"
        case .tapToSelectNativeLanguage: return "Tap to select your native language"
        
        // Theme color names
        case .neonGreen: return "Neon Green"
        case .cyanMist: return "Cyan Mist"
        case .violetHaze: return "Violet Haze"
        case .softPink: return "Soft Pink"
        case .pureWhite: return "Pure White"
        
        // Quick Look
        case .quickRecall: return "Quick recall"
        case .startQuickPuzzle: return "Start Quick Puzzle"
        case .stopPuzzle: return "Stop Puzzle"
        
        // Streak
        case .streak: return "Streak"
        case .dayStreak: return "day streak"
        case .daysStreak: return "days streak"
        case .editYourStreaks: return "Edit your streaks"
        case .editStreaks: return "Edit Streaks"
        case .selectDatesToAddOrRemove: return "Select dates to add or remove practice days"
        case .saving: return "Saving..."
        }
    }
}

