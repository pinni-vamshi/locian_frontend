//
//  TeluguStrings.swift
//  locian
//

import Foundation

struct TeluguStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "కెమెరా",
            gallery: "గ్యాలరీ",
            nextUp: "తదుపరి",
            historyLog: "చరిత్ర లాగ్",

            moments: "క్షణాలు",
            pastMoments: "గత క్షణాలు",
            noHistory: "చరిత్ర లేదు",
            generatingHistory: "చరిత్ర రూపొందిస్తోంది",
            generatingMoments: "సృష్టిస్తోంది...",
            analyzingImage: "చిత్ర విశ్లేషణ...",
            tapNextUpToGenerate: "రూపొందించడానికి తదుపరి ట్యాప్ చేయండి",
            noUpcomingPlaces: "రాబోయే ప్రదేశాలు లేవు",
            noDetails: "వివరాలు లేవు",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "నేర్చుకోవడం ప్రారంభించండి",
            continueLearning: "నేర్చుకోవడం కొనసాగించండి",
            noPastMoments: "గత క్షణాలు లేవు",
            useCamera: "కెమెరా ఉపయోగించండి",
            previouslyLearning: "గతంలో నేర్చుకున్నారు",
            sunShort: "ఆది",
            monShort: "సోమ",
            tueShort: "మంగళ",
            wedShort: "బుధ",
            thuShort: "గురు",
            friShort: "శుక్ర",
            satShort: "శని",
            login: "లాగిన్",
            register: "నోందణి",
            settings: "సెట్టింగులు",
            back: "వెనుకకు",
            done: "పూర్తయింది",
            cancel: "రద్దు చేయండి",
            save: "సేవ్ చేయండి",
            delete: "తొలగించండి",
            add: "జోడించండి",
            remove: "తొలగించండి",
            edit: "సవరించు",
            error: "లోపం",
            ok: "సరే",
            welcomeLabel: "స్వాగతం",
            currentStreak: "ప్రస్తుత స్ట్రీక్",
            notSet: "సెట్ చేయబడలేదు",
            learnTab: "నేర్చుకోండి",
            addTab: "జోడించండి",
            progressTab: "ప్రగతి",
            settingsTab: "సెట్టింగులు",
            loading: "లోడ్ అవుతోంది...",
            unknownPlace: "తెలియని ప్రదేశం",
            noLanguageAvailable: "భాష అందుబాటులో లేదు",
            noInternetConnection: "ఇంటర్‌నెట్ కనెక్షన్ లేదు",
            retry: "మళ్ళీ ప్రయత్నించండి",
            tapToGetMoments: "క్షణాలు పొందడానికి ట్యాప్ చేయండి",
            startLearningThisMoment: "ఈ క్షణం నుండి నేర్చుకోవడం ప్రారంభించండి",
            daysLabel: "రోజులు",
            noNewPlace: "కొత్త స్థలాన్ని జోడించండి",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "ప్రారంభించు",
            typeYourMoment: "మీ క్షణాన్ని టైప్ చేయండి...",
            imagesLabel: "చిత్రాలు",
            routinesLabel: "దినచర్యలు",
            whatAreYouDoing: "మీరు ఇప్పుడు ఏం చేస్తున్నారు?",
            chooseContext: "నేర్చుకోవడం ప్రారంభించడానికి సందర్భాన్ని ఎంచుకోండి",
            typeHere: "ఇక్కడ టైప్ చేయండి",
            nearbyLabel: "దగ్గరలో",
            noNearbyPlaces: "{noNearby}",
            addRoutine: "రొటీన్ జోడించండి",
            tapToSetup: "సెటప్ చేయడానికి ట్యాప్ చేయండి",
            tapToStartLearning: "నేర్చుకోవడం ప్రారంభించడానికి ట్యాప్ చేయండి")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "యాప్ ఇంటర్‌ఫేస్",
            targetLanguages: "లక్ష్య భాషలు",
            pastLanguagesArchived: "గతంలో నేర్చుకున్న భాషలు",
            theme: "థీమ్",
            notifications: "నోటిఫికేషన్లు",
            account: "ఖాతా",
            profile: "ప్రొఫైల్",
            addLanguagePair: "భాషా జంటను జోడించండి",
            logout: "లాగ్ అవుట్",
            deleteAllData: "అన్ని డేటాను తొలగించండి",
            deleteAccount: "ఖాతాను శాశ్వతంగా తొలగించండి",
            selectLevel: "స్థాయిని ఎంచుకోండి",
            proFeatures: "ప్రో ఫీచర్లు",
            showSimilarWordsToggle: "సారూప్య పదాలను చూపించు",
            nativeLanguage: "మాతృ భాష",
            selectNativeLanguage: "మాతృభాషను ఎంచుకోండి",
            targetLanguage: "లక్ష్య భాష",
            selectTargetLanguage: "లక్ష్య భాషను ఎంచుకోండి",
            targetLanguageDescription: "మీరు నేర్చుకోవాలనుకునే భాష",
            beginner: "ప్రారంభ స్థాయి",
            intermediate: "మధ్యస్థ స్థాయి",
            advanced: "ఉన్నత స్థాయి",
            currentlyLearning: "ప్రస్తుతం నేర్చుకుంటున్నారు",
            learnNewLanguage: "కొత్త భాష నేర్చుకోండి",
            learn: "నేర్చుకోండి",
            neonGreen: "నియాన్ ఆకుపచ్చ",
            neonFuchsia: "నియాన్ ఫ్యూషియా",
            electricIndigo: "ఎలక్ట్రిక్ ఇండిగో",
            graphiteBlack: "గ్రాఫైట్ బ్లాక్",
            student: "విద్యార్థి",
            softwareEngineer: "సాఫ్ట్‌వేర్ ఇంజనీర్",
            teacher: "ఉపాధ్యాయుడు",
            doctor: "వైద్యుడు",
            artist: "కళాకారుడు",
            businessProfessional: "వ్యాపార నిపుణుడు",
            salesOrMarketing: "అమ్మకాలు లేదా మార్కెటింగ్",
            traveler: "ప్రయాణికుడు",
            homemaker: "గృహిణి/గృహస్థుడు",
            chef: "షెఫ్",
            police: "పోలీసు",
            bankEmployee: "బ్యాంక్ ఉద్యోగి",
            nurse: "నర్స్",
            designer: "డిజైనర్",
            engineerManager: "ఇంజనీరింగ్ మేనేజర్",
            photographer: "ఫోటోగ్రాఫర్",
            contentCreator: "కంటెంట్ క్రియేటర్",
            entrepreneur: "పారిశ్రామికవేత్త",
            other: "ఇతర",
            otherPlaces: "ఇతర ప్రదేశాలు",
            speaks: "మాట్లాడతారు",
            neuralEngine: "న్యూరల్ ఇంజిన్",
            noLanguagePairsAdded: "భాషా జంటలు జోడించలేదు",
            setDefault: "డీఫాల్ట్‌గా సెట్ చేయండి",
            defaultText: "డీఫాల్ట్",
            user: "వినియోగదారుడు",
            signOutFromAccount: "ఖాతా నుండి లాగ్ అవుట్ అవండి",
            permanentlyDeleteAccount: "ఖాతాను శాశ్వతంగా తొలగించండి",
            languageAddedSuccessfully: "భాష విజయవంతంగా జోడించబడింది",
            failedToAddLanguage: "భాషను జోడించడంలో విఫలమైంది. దయచేసి మళ్ళీ ప్రయత్నించండి.",
            pleaseSelectLanguage: "దయచేసి ఒక భాషను ఎంచుకోండి",
            systemConfig: "సిస్టమ్ // కాన్ఫిగ్",
            currentLevel: "ప్రస్తుత స్థాయి",
            selectPhoto: "ఫోటో ఎంచుకోండి",
            camera: "కెమెరా",
            photoLibrary: "ఫోటో లైబ్రరీ",
            selectTime: "సమయం ఎంచుకోండి",
            hour: "గంట",
            minute: "నిమిషం",
            addTime: "సమయం జోడించండి",
            location: "స్థానం",
            diagnosticBorders: "డయాగ్నోస్టిక్ బోర్డర్స్",
            areYouSureLogout: "మీరు ఖచ్చితంగా లాగ్ అవుట్ అవ్వాలనుకుంటున్నారా?",
            areYouSureDeleteAccount: "మీరు మీ ఖాతాను శాశ్వతంగా తొలగించాలనుకుంటున్నారా? ఈ చర్యను తిరిగి పొందలేము.",
            
            // Personalization Refresh
            refreshHeading: "రిఫ్రెష్",
            refreshSubheading: "వినియోగదారు సందర్భం // పరిణామం",
            refreshDescription: "మీ ఆచరణ ఆధారంగా మీ క్షణాలు కాలక్రమేణా మరింత వ్యక్తిగతీకరించబడతాయి.",
            refreshButton: "వ్యక్తిగతీకరణను నవీకరించండి")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "లాగిన్",
            verify: "ధృవీకరించండి",
            selectProfession: "వృత్తిని ఎంచుకోండి",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "వినియోగదారు పేరు",
            phoneNumber: "ఫోన్ నంబర్",
            guestLogin: "అతిథి లాగిన్",
            selectProfessionInstruction: "ప్రారంభించడానికి మీ వృత్తిని ఎంచుకోండి",
            showMore: "మరిన్ని చూపించు",
            showLess: "తక్కువ చూపించు",
            forReview: "[సమీక్ష కోసం]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "మీ రోజువారీ జీవితం ద్వారా సహజంగా భాషలు నేర్చుకోండి",
            awarenessHeading: "అవగాహన",
            awarenessDescription: "రియల్ టైమ్‌లో మీ చుట్టూ ఉన్న పదాలను గమనించండి",
            breakdownHeading: "విశ్లేషణ",
            breakdownDescription: "పదాలు ఎలా నిర్మించబడతాయో అర్థం చేసుకోండి",
            progressHeading: "ప్రగతి",
            progressDescription: "మీ నేర్చుకున్న ప్రయాణాన్ని ట్రాక్ చేయండి",
            readyHeading: "సిద్ధం",
            readyDescription: "ఇప్పుడు నేర్చుకోవడం ప్రారంభించండి",
            loginOrRegister: "లాగిన్ లేదా నోందణి",
            pageIndicator: "పేజీ",
            selectLanguageDescription: "మీ ఇష్టమైన భాషను ఎంచుకోండి",
            whichLanguageDoYouSpeakComfortably: "మీరు ఏ భాష ను సుఖంగా మాట్లాడుతారు?",
            chooseTheLanguageYouWantToMaster: "ఈ రోజు మీరు నేర్చుకోవాలనుకునే భాషను ఎంచుకోండి",
            fromWhereYouStand: "మీరు నిలబడిన\nచోటి నుండి",
            toEveryWord: "ప్రతి",
            everyWord: "పదానికి",
            youNeed: "మీకు కావాలి",
            lessonEngine: "పాఠం_ఇంజిన్",
            nodesLive: "నోడ్స్_లైవ్",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "హోలో_గ్రిడ్_యాక్టివ్",
            adaCr02: "ADA_CR-02",
            your: "మీ",
            places: "ప్రదేశాలు,",
            lessons: "పాఠాలు.",
            yourPlaces: "మీ ప్రదేశాలు,",
            yourLessons: " మీ పాఠాలు.",
            nearbyCafes: "సమీపంలోని కేఫ్‌లు?",
            unlockOrderFlow: " ఆర్డర్-ఫ్లో అన్‌లాక్ చేయండి",
            modules: "మాడ్యూల్స్",
            activeHubs: "యాక్టివ్ హబ్‌లు?",
            synthesizeGym: " జిమ్ సంశ్లేషణ",
            vocabulary: "పదజాలం",
            locationOpportunity: "ప్రతి ప్రదేశం నేర్చుకునే అవకాశంగా మారుతుంది",
            module03: "మాడ్యూల్_03",
            notJustMemorization: "కేవలం కంఠస్థం\nకాదు",
            philosophy: "తత్వం",
            locianTeaches: "లోసియన్ కేవలం పదాలను మాత్రమే నేర్పించదు.\nలోసియన్ మీకు బోధిస్తుంది ",
            think: "ఆలోచించడం",
            inTargetLanguage: "మీ లక్ష్య భాషలో.",
            patternBasedLearning: "నమూనా-ఆధారిత అభ్యాసం",
            patternBasedDesc: "పొడి నియమాలు లేకుండా వ్యాకరణ నిర్మాణాలను అకారణంగా గుర్తించండి.",
            situationalIntelligence: "సందర్భోచిత మేధస్సు",
            situationalDesc: "మీ వాతావరణం మరియు చరిత్రకు అనుగుణంగా ఉండే డైనమిక్ దృశ్యాలు.",
            adaptiveDrills: "అనుకూల కసరత్తులు",
            adaptiveDesc: "లెసన్ ఇంజిన్ మీ బలహీనతలను గుర్తిస్తుంది మరియు రీకాలిబ్రేట్ చేస్తుంది.",
            systemReady: "సిస్టమ్_రెడీ",
            quickSetup: "త్వరిత_సెటప్",
            levelB2: "స్థాయి_B2",
            authorized: "అధికారం",
            notificationsPermission: "నోటిఫికేషన్‌లు",
            notificationsDesc: "సమీపంలోని అభ్యాస అవకాశాలు మరియు స్ట్రీక్ అలర్ట్‌ల గురించి నిజ-సమయ నవీకరణలను పొందండి.",
            microphonePermission: "మైక్రోఫోన్",
            microphoneDesc: "వాస్తవ ప్రపంచ సందర్భాలలో ఉచ్చారణ స్కోరింగ్ మరియు పాఠ్య పరస్పర చర్యలకు అవసరం.",
            geolocationPermission: "జియోలొకేషన్",
            geolocationDesc: "లీనమయ్యే అభ్యాసం కోసం కాఫీ షాప్‌లు లేదా లైబ్రరీల వంటి సమీపంలోని \"లెసన్ జోన్‌ల\"ను గుర్తించండి.",
            granted: "మంజూరు చేయబడింది",
            allow: "అనుమతించు",
            skip: "దాటవేయి",
            letsStart: "ప్రారంభిద్దాం",
            continueText: "కొనసాగించు",
            wordTenses: "పద కాలాలు:",
            similarWords: "సమాన పదాలు:",
            wordBreakdown: "పద విశ్లేషణ:",
            consonant: "హల్లు",
            vowel: "అచ్చు",
            past: "గతం",
            present: "వర్తమానం",
            future: "భవిష్యత్తు",
            learnWord: "నేర్చుకోండి")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "ప్రగతి",
            current: "ప్రస్తుత",
            longest: "అత్యంత పొడవైన",
            lastPracticed: "చివరి సాధన",
            days: "రోజులు",
            addLanguagePairToSeeProgress: "మీ ప్రగతిని చూడటానికి భాషా జంటను జోడించండి",
            startPracticingMessage: "మీ స్ట్రీక్ నిర్మించడానికి సాధన ప్రారంభించండి",
            consistencyQuote: "స్థిరత్వం భాషా అభ్యాసానికి కీలకం",
            practiceDateSavingDisabled: "సాధన తేదీ సేవింగ్ నిలిపివేయబడింది",
            editYourStreaks: "మీ స్ట్రీక్‌లను సవరించండి",
            editStreaks: "స్ట్రీక్‌లను సవరించండి",
            selectDatesToAddOrRemove: "జోడించడానికి లేదా తీసివేయడానికి తేదీలను ఎంచుకోండి",
            saving: "సేవ్ చేస్తోంది",
            statusOnFire: "స్థితి: ఆన్ ఫైర్",
            youPracticed: "మీరు సాధన చేశారు ",
            yesterday: " నిన్న.",
            checkInNow: "ఇప్పుడే చెక్ ఇన్ చేయండి",
            nextGoal: "తదుపరి లక్ష్యం",
            reward: "బహుమతి",
            historyLogProgress: "చరిత్ర లాగ్",
            streakStatus: "స్ట్రీక్ స్థితి",
            streakLog: "స్ట్రీక్ లాగ్",
            consistency: "స్థిరత్వం",
            consistencyHigh: "మీ కార్యాచరణ లాగ్ అధిక ఆసక్తిని చూపుతుంది.",
            consistencyMedium: "మీరు మంచి వేగాన్ని అందుకుంటున్నారు.",
            consistencyLow: "స్థిరత్వం ముఖ్యం. ప్రయత్నిస్తూనే ఉండండి.",
            reachMilestone: "%d రోజులు చేరుకోవడానికి ప్రయత్నించండి!",
            nextMilestone: "తదుపరి మైలురాయి",
            actionRequired: "చర్య అవసరం",
            logActivity: "కార్యాచరణను నమోదు చేయండి",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "అత్యధిక స్కోరు",
            streakData: "స్ట్రీక్ డేటా",
            activeLabel: "యాక్టివ్",
            missedLabel: "మిస్డ్",
            saveChanges: "మార్పులను సేవ్ చేయి",
            discardChanges: "మార్పులను రద్దు చేయి",
            editLabel: "ఎడిట్",
            // Advanced Stats
            skillBalance: "నైపుణ్య సమతుల్యత",
            fluencyVelocity: "ధారాళత వేగం",
            vocabVault: "పదజాల భాండాగారం",
            chronotype: "కాలప్రకృతి",
            activityDistribution: "కార్యకలాప పంపిణీ (24 గం)",
            studiedTime: "అధ్యయన సమయం",
            currentLabel: "ప్రస్తుత",
            streakLabel: "స్ట్రీక్",
            longestLabel: "సుదీర్ఘ",
            earlyBird: "తెల్లవారుజాము పక్షి",
            earlyBirdDesc: "ఉదయాన్నే చురుకుగా ఉంటారు",
            dayWalker: "పగలు తిరిగే వారు",
            dayWalkerDesc: "మధ్యాహ్నం చురుకుగా ఉంటారు",
            nightOwl: "రాత్రి గుడ్లగూబ",
            nightOwlDesc: "చీకటి పడ్డాక చురుకుగా ఉంటారు",
            timeMastery: "TIME MASTERY",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "లోడ్ అవుతోంది...",
            adaptiveQuiz: "అడాప్టివ్ క్విజ్",
            adaptiveQuizDescription: "మేము మొదట తప్పు అనువాదాన్ని చూపిస్తాం, తర్వాత సరైన పదాన్ని హైలైట్ చేస్తాం.",
            wordCheck: "పద తనిఖీ",
            wordCheckDescription: "టైల్స్ ముందుగా కలిసిపోయి, తర్వాత సరైన పదాన్ని నిర్ధారించడానికి అమర్చబడతాయి.",
            wordCheckExamplePrompt: "పదాన్ని సరైన క్రమంలో అమర్చడానికి అక్షరాలను ట్యాప్ చేయండి.",
            quizPrompt: "పదం కోసం సరైన అనువాదాన్ని ఎంచుకోండి.",
            answerConfirmation: "మీరు సరైన పదాన్ని నిర్మించారు!",
            tryAgain: "అయ్యో! మళ్ళీ ప్రయత్నించండి.")
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

        // Personalization Refresh
        case .refreshHeading: return settings.refreshHeading
        case .refreshSubheading: return settings.refreshSubheading
        case .refreshDescription: return settings.refreshDescription
        case .refreshButton: return settings.refreshButton
        case .routinesLabel: return ui.routinesLabel
        case .whatAreYouDoing: return ui.whatAreYouDoing
        case .chooseContext: return ui.chooseContext
        case .typeHere: return ui.typeHere
        case .nearbyLabel: return ui.nearbyLabel
        case .noNearbyPlaces: return ui.noNearbyPlaces
        case .addRoutine: return ui.addRoutine
        case .tapToSetup: return ui.tapToSetup
        case .tapToStartLearning: return ui.tapToStartLearning
        case .smartNotificationExactPlace: return "మీరు %@ వద్ద ఉంటే, ఈ స్థలం గురించి చదవండి!"
        }
    }
}
