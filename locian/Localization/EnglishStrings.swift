// Placeholder to ensure no action if I was wrong about file. But search needs to happen first.
// I will use list_dir next.
//  locian
//

import Foundation

struct EnglishStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "Camera",
            gallery: "Gallery",
            nextUp: "Next Up",
            historyLog: "History Log",

            moments: "Moments",
            pastMoments: "Past Moments",
            noHistory: "No History",
            generatingHistory: "Generating History",
            generatingMoments: "GENERATING...",
            analyzingImage: "PROCESSING IMAGE...",
            tapNextUpToGenerate: "Tap Next Up to Generate",
            noUpcomingPlaces: "No Upcoming Places",
            noDetails: "No Details",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "Start Learning",
            continueLearning: "Continue Learning",
            noPastMoments: "No Past Moments",
            useCamera: "Use Camera",
            previouslyLearning: "Previously Learning",
            sunShort: "Sun",
            monShort: "Mon",
            tueShort: "Tue",
            wedShort: "Wed",
            thuShort: "Thu",
            friShort: "Fri",
            satShort: "Sat",
            login: "Login",
            register: "Register",
            settings: "Settings",
            back: "Back",
            done: "Done",
            cancel: "Cancel",
            save: "Save",
            delete: "Delete",
            add: "Add",
            remove: "Remove",
            edit: "Edit",
            error: "Error",
            ok: "OK",
            welcomeLabel: "Welcome",
            currentStreak: "CURRENT_STREAK",
            notSet: "Not Set",
            learnTab: "Learn",
            addTab: "Add",
            progressTab: "Progress",
            settingsTab: "Settings",
            loading: "Loading...",
            unknownPlace: "Unknown Place",
            noLanguageAvailable: "No language available",
            noInternetConnection: "No internet connection",
            retry: "Retry",
            tapToGetMoments: "Tap to refresh moments",
            startLearningThisMoment: "Start learning this moment",
            daysLabel: "DAYS",
            noNewPlace: "Add New Place",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "Start",
            typeYourMoment: "Type your moment...",
            imagesLabel: "IMAGES",
            routinesLabel: "ROUTINES",
            whatAreYouDoing: "What are you doing now?",
            chooseContext: "Choose a context to start learning",
            typeHere: "TYPE HERE",
            nearbyLabel: "NEARBY",
            noNearbyPlaces: "No nearby places found",
            addRoutine: "Add Routine",
            tapToSetup: "Tap to Setup",
            tapToStartLearning: "Tap to Start Learning")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "App Interface",
            targetLanguages: "Target Languages",
            pastLanguagesArchived: "Previously Learning",
            theme: "Theme",
            notifications: "Notifications",
            account: "Account",
            profile: "Profile",
            addLanguagePair: "Add Language Pair",
            logout: "Logout",
            deleteAllData: "Delete All Data",
            deleteAccount: "Permanently Delete Account",
            selectLevel: "Select Level",
            proFeatures: "Pro Features",
            showSimilarWordsToggle: "Show Similar Words",
            nativeLanguage: "Native Language",
            selectNativeLanguage: "Select Native Language",
            targetLanguage: "Target Language",
            selectTargetLanguage: "Tap to Change Target Language",
            targetLanguageDescription: "Language you want to learn",
            beginner: "Beginner",
            intermediate: "Intermediate",
            advanced: "Advanced",
            currentlyLearning: "Currently Learning",
            learnNewLanguage: "Learn New Language",
            learn: "Learn",
            neonGreen: "Neon Green",
            neonFuchsia: "Neon Fuchsia",
            electricIndigo: "Electric Indigo",
            graphiteBlack: "Graphite Black",
            student: "Student",
            softwareEngineer: "Software Engineer",
            teacher: "Teacher",
            doctor: "Doctor",
            artist: "Artist",
            businessProfessional: "Business Professional",
            salesOrMarketing: "Sales or Marketing",
            traveler: "Traveler",
            homemaker: "Homemaker",
            chef: "Chef",
            police: "Police",
            bankEmployee: "Bank Employee",
            nurse: "Nurse",
            designer: "Designer",
            engineerManager: "Engineer Manager",
            photographer: "Photographer",
            contentCreator: "Content Creator",
            entrepreneur: "Entrepreneur",
            other: "Other",
            otherPlaces: "OTHER PLACES",
            speaks: "Speaks",
            neuralEngine: "Neural Engine",
            noLanguagePairsAdded: "No Language Pairs Added",
            setDefault: "Set Default",
            defaultText: "Default",
            user: "User",
            signOutFromAccount: "Sign Out from Account",
            permanentlyDeleteAccount: "Permanently Delete Account",
            languageAddedSuccessfully: "Language added successfully",
            failedToAddLanguage: "Failed to add language. Please try again.",
            pleaseSelectLanguage: "Please select a language",
            systemConfig: "SYSTEM // CONFIG",
            currentLevel: "Current Level",
            selectPhoto: "Select Photo",
            camera: "Camera",
            photoLibrary: "Photo Library",
            selectTime: "Select Time",
            hour: "Hour",
            minute: "Minute",
            addTime: "Add Time",
            location: "Location",
            diagnosticBorders: "Diagnostic Borders",
            areYouSureLogout: "Are you sure you want to logout?",
            areYouSureDeleteAccount: "Are you sure you want to delete your account?")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "Login",
            verify: "Verify",
            selectProfession: "Select Profession",
            selectUserProfession: "SELECT USER PROFESSION",
            username: "Username",
            phoneNumber: "Phone Number",
            guestLogin: "Guest Login",
            selectProfessionInstruction: "Select your profession to get started",
            showMore: "Show more",
            showLess: "Show less",
            forReview: "[For Review]",
            authenticatingUser: "AUTHENTICATING USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS OF SERVICE",
            privacyPolicy: "PRIVACY POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "LOCIAN",
            locianDescription: "Next-Gen Language Learning\nEngine v2.0",
            awarenessHeading: "AWARENESS",
            awarenessDescription: "Context-aware lessons based on your environment.",
            breakdownHeading: "BREAKDOWN",
            breakdownDescription: "Understand grammar through pattern recognition.",
            progressHeading: "PROGRESS",
            progressDescription: "Track your fluency with detailed metrics.",
            readyHeading: "READY?",
            readyDescription: "Your journey begins now.",
            loginOrRegister: "Login or Register",
            pageIndicator: "Page",
            selectLanguageDescription: "Select your preferred language",
            whichLanguageDoYouSpeakComfortably: "WHICH LANGUAGE DO YOU SPEAK COMFORTABLY?",
            chooseTheLanguageYouWantToMaster: "CHOOSE THE LANGUAGE YOU WANT TO MASTER TODAY",
            fromWhereYouStand: "FROM WHERE YOU\nSTAND",
            toEveryWord: "T O",
            everyWord: "EVERY WORD",
            youNeed: "YOU NEED",
            lessonEngine: "LESSON_ENGINE",
            nodesLive: "NODES_LIVE",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "HOLO_GRID_ACTIVE",
            adaCr02: "ADA_CR-02",
            your: "YOUR",
            places: "PLACES,",
            lessons: "LESSONS.",
            yourPlaces: "YOUR PLACES,",
            yourLessons: " YOUR LESSONS.",
            nearbyCafes: "Nearby Cafés?",
            unlockOrderFlow: " Unlock order-flow",
            modules: "modules",
            activeHubs: "Active Hubs?",
            synthesizeGym: " Synthesize gym",
            vocabulary: "vocabulary",
            locationOpportunity: "Every location becomes a learning opportunity",
            module03: "MODULE_03",
            notJustMemorization: "NOT JUST\nMEMORIZATION",
            philosophy: "PHILOSOPHY",
            locianTeaches: "Locian doesn't just teach words.\nLocian teaches you to ",
            think: "THINK",
            inTargetLanguage: "in your target language.",
            patternBasedLearning: "PATTERN-BASED LEARNING",
            patternBasedDesc: "Recognize grammatical structures intuitively without dry rules.",
            situationalIntelligence: "SITUATIONAL INTELLIGENCE",
            situationalDesc: "Dynamic scenarios that adapt to your environment and history.",
            adaptiveDrills: "ADAPTIVE DRILLS",
            adaptiveDesc: "The Lesson Engine identifies your weaknesses and recalibrates.",
            systemReady: "SYSTEM_READY",
            quickSetup: "QUICK_SETUP",
            levelB2: "LEVEL_B2",
            authorized: "AUTHORIZED",
            notificationsPermission: "NOTIFICATIONS",
            notificationsDesc: "Get real-time updates on nearby practice opportunities and streak alerts.",
            microphonePermission: "MICROPHONE",
            microphoneDesc: "Essential for pronunciation scoring and lesson interactions in real-world contexts.",
            geolocationPermission: "GEOLOCATION",
            geolocationDesc: "Identify nearby \"Lesson Zones\" like coffee shops or libraries for immersive practice.",
            granted: "GRANTED",
            allow: "ALLOW",
            skip: "SKIP",
            letsStart: "LET'S START",
            continueText: "CONTINUE",
            wordTenses: "Word Tenses:",
            similarWords: "Similar Words:",
            wordBreakdown: "Word Breakdown:",
            consonant: "Consonant",
            vowel: "Vowel",
            past: "Past",
            present: "Present",
            future: "Future",
            learnWord: "Learn")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Progress",
            current: "Current",
            longest: "Longest",
            lastPracticed: "Last Practiced",
            days: "Days",
            addLanguagePairToSeeProgress: "Add a language pair to see your progress",
            startPracticingMessage: "Start practicing to build your streak",
            consistencyQuote: "Consistency is key to language learning",
            practiceDateSavingDisabled: "Practice date saving is disabled",
            editYourStreaks: "Edit Your Streaks",
            editStreaks: "Edit Streaks",
            selectDatesToAddOrRemove: "Select dates to add or remove from your streak",
            saving: "Saving",
            statusOnFire: "Status: On Fire",
            youPracticed: "You practiced ",
            yesterday: " yesterday.",
            checkInNow: "Check In Now",
            nextGoal: "Next Goal",
            reward: "Reward",
            historyLogProgress: "History Log",
            streakStatus: "Streak Status",
            streakLog: "Streak Log",
            consistency: "Consistency",
            consistencyHigh: "Your activity log shows high engagement.",
            consistencyMedium: "You're building good momentum.",
            consistencyLow: "Consistency is key. Keep pushing.",
            reachMilestone: "Try to reach %d days!",
            nextMilestone: "Next Milestone",
            actionRequired: "Action Required",
            logActivity: "Log Activity",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "Longest Streak",
            streakData: "STREAK DATA",
            activeLabel: "ACTIVE",
            missedLabel: "MISSED",
            saveChanges: "SAVE CHANGES",
            discardChanges: "DISCARD CHANGES",
            editLabel: "EDIT",
            
            // Advanced Stats
            skillBalance: "SKILL BALANCE",
            fluencyVelocity: "FLUENCY VELOCITY",
            vocabVault: "VOCAB VAULT",
            chronotype: "CHRONOTYPE",
            activityDistribution: "ACTIVITY DISTRIBUTION (24H)",
            studiedTime: "STUDIED TIME",
            currentLabel: "CURRENT",
            streakLabel: "STREAK",
            longestLabel: "LONGEST",
            
            // Chronotypes
            earlyBird: "EARLY BIRD",
            earlyBirdDesc: "Most active in the morning",
            dayWalker: "DAY WALKER",
            dayWalkerDesc: "Most active in the afternoon",
            nightOwl: "NIGHT OWL",
            nightOwlDesc: "Most active after dark",
            timeMastery: "TIME MASTERY",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "Loading...",
            adaptiveQuiz: "Adaptive Quiz",
            adaptiveQuizDescription: "We flash a wrong translation first, then highlight the correct word.",
            wordCheck: "Word Check",
            wordCheckDescription: "Tiles jumble first, then snap into place to confirm the correct word.",
            wordCheckExamplePrompt: "Tap the letters to arrange the word in the correct order.",
            quizPrompt: "Pick the correct translation for the word.",
            answerConfirmation: "You built the correct word!",
            tryAgain: "Oops! Try again.")
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
        case .callingAI: return ui.callingAI                 // New
        case .preparingLesson: return ui.preparingLesson
        
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
        case .addRoutine: return ui.addRoutine
        case .tapToSetup: return ui.tapToSetup
        case .tapToStartLearning: return ui.tapToStartLearning
        }
    }
}
