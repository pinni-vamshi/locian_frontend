//
//  HindiStrings.swift
//  locian
//

import Foundation

struct HindiStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "कैमरा",
            gallery: "गैलरी",
            nextUp: "आगे",
            historyLog: "इतिहास लॉग",

            moments: "पल",
            pastMoments: "पिछले पल",
            noHistory: "कोई इतिहास नहीं",
            generatingHistory: "इतिहास तैयार हो रहा है",
            generatingMoments: "बना रहा है...",
            analyzingImage: "छवि विश्लेषण...",
            tapNextUpToGenerate: "तैयार करने के लिए आगे टैप करें",
            noUpcomingPlaces: "कोई आने वाले स्थान नहीं",
            noDetails: "कोई विवरण नहीं",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "सीखना शुरू करें",
            continueLearning: "सीखना जारी रखें",
            noPastMoments: "कोई पिछले पल नहीं",
            useCamera: "कैमरा उपयोग करें",
            previouslyLearning: "पहले सीखा",
            sunShort: "रवि",
            monShort: "सोम",
            tueShort: "मंगल",
            wedShort: "बुध",
            thuShort: "गुरु",
            friShort: "शुक्र",
            satShort: "शनि",
            login: "लॉगिन",
            register: "पंजीकरण",
            settings: "सेटिंग्स",
            back: "वापस",
            done: "हो गया",
            cancel: "रद्द करें",
            save: "सहेजें",
            delete: "हटाएं",
            add: "जोड़ें",
            remove: "हटाएं",
            edit: "संपादित करें",
            error: "त्रुटि",
            ok: "ठीक है",
            welcomeLabel: "स्वागत है",
            currentStreak: "वर्तमान स्ट्रैक",
            notSet: "सेट नहीं है",
            learnTab: "सीखें",
            addTab: "जोड़ें",
            progressTab: "प्रगति",
            settingsTab: "सेटिंग्स",
            loading: "लोड हो रहा है...",
            unknownPlace: "अज्ञात स्थान",
            noLanguageAvailable: "कोई भाषा उपलब्ध नहीं",
            noInternetConnection: "इंटरनेट कनेक्शन नहीं है",
            retry: "पुन: प्रयास करें",
            tapToGetMoments: "पल पाने के लिए टैप करें",
            startLearningThisMoment: "इस पल से सीखना शुरू करें",
            daysLabel: "दिन",
            noNewPlace: "नई जगह जोड़ें",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "शुरू",
            typeYourMoment: "अपना पल टाइप करें...",
            imagesLabel: "चित्र",
            routinesLabel: "दिनचर्या",
            whatAreYouDoing: "अब आप क्या कर रहे हैं?",
            chooseContext: "सीखना शुरू करने के लिए एक संदर्भ चुनें",
            typeHere: "यहाँ टाइप करें",
            nearbyLabel: "करीब",
            noNearbyPlaces: "{noNearby}",
            addRoutine: "रूटीन जोड़ें",
            tapToSetup: "सेटअप करने के लिए टैप करें",
            tapToStartLearning: "सीखना शुरू करने के लिए टैप करें")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "ऐप इंटरफ़ेस",
            targetLanguages: "लक्ष्य भाषाएँ",
            pastLanguagesArchived: "पहले सीखी गई भाषाएँ",
            theme: "थीम",
            notifications: "सूचनाएं",
            account: "खाता",
            profile: "प्रोफ़ाइल",
            addLanguagePair: "भाषा जोड़ी जोड़ें",
            logout: "लॉग आउट",
            deleteAllData: "सभी डेटा हटाएं",
            deleteAccount: "खाता स्थायी रूप से हटाएं",
            selectLevel: "स्तर चुनें",
            proFeatures: "प्रो सुविधाएँ",
            showSimilarWordsToggle: "समान शब्द दिखाएं",
            nativeLanguage: "मातृ भाषा",
            selectNativeLanguage: "मातृभाषा चुनें",
            targetLanguage: "लक्ष्य भाषा",
            selectTargetLanguage: "लक्ष्य भाषा चुनें",
            targetLanguageDescription: "वह भाषा जो आप सीखना चाहते हैं",
            beginner: "शुरुआती",
            intermediate: "मध्यवर्ती",
            advanced: "उन्नत",
            currentlyLearning: "वर्तमान में सीख रहे हैं",
            learnNewLanguage: "नई भाषा सीखें",
            learn: "सीखें",
            neonGreen: "नियॉन हरा",
            neonFuchsia: "नियॉन फ्यूशिया",
            electricIndigo: "इलेक्ट्रिक इंडिगो",
            graphiteBlack: "ग्रेफाइट ब्लैक",
            student: "छात्र",
            softwareEngineer: "सॉफ्टवेयर इंजीनियर",
            teacher: "शिक्षक",
            doctor: "डॉक्टर",
            artist: "कलाकार",
            businessProfessional: "बिजनेस पेशेवर",
            salesOrMarketing: "बिक्री या मार्केटिंग",
            traveler: "यात्री",
            homemaker: "गृहिणी/गृहपति",
            chef: "शेफ",
            police: "पुलिस",
            bankEmployee: "बैंक कर्मचारी",
            nurse: "नर्स",
            designer: "डिज़ाइनर",
            engineerManager: "इंजीनियरिंग मैनेजर",
            photographer: "फोटोग्राफर",
            contentCreator: "कंटेंट क्रिएटर",
            entrepreneur: "उद्यमी",
            other: "अन्य",
            otherPlaces: "अन्य स्थान",
            speaks: "बोलते हैं",
            neuralEngine: "न्यूरल इंजन",
            noLanguagePairsAdded: "कोई भाषा जोड़ी नहीं जोड़ी गई",
            setDefault: "डिफ़ॉल्ट सेट करें",
            defaultText: "डिफ़ॉल्ट",
            user: "उपयोगकर्ता",
            signOutFromAccount: "खाते से लॉग आउट",
            permanentlyDeleteAccount: "खाता स्थायी रूप से हटाएं",
            languageAddedSuccessfully: "भाषा सफलतापूर्वक जोड़ी गई",
            failedToAddLanguage: "भाषा जोड़ने में विफल। कृपया पुन: प्रयास करें।",
            pleaseSelectLanguage: "कृपया एक भाषा चुनें",
            systemConfig: "सिस्टम // कॉन्फ़िगर",
            currentLevel: "वर्तमान स्तर",
            selectPhoto: "फोटो चुनें",
            camera: "कैमरा",
            photoLibrary: "फोटो लाइब्रेरी",
            selectTime: "समय चुनें",
            hour: "घंटा",
            minute: "मिनट",
            addTime: "समय जोड़ें",
            location: "स्थान",
            diagnosticBorders: "डायग्नोस्टिक बॉर्डर्स",
            areYouSureLogout: "क्या आप वाकई लॉग आउट करना चाहते?",
            areYouSureDeleteAccount: "क्या आप वाकई अपना खाता स्थायी रूप से हटाना चाहते हैं? यह क्रिया वापस नहीं ली जा सकती।")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "लॉगिन",
            verify: "सत्यापित करें",
            selectProfession: "पेशा चुनें",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "उपयोगकर्ता नाम",
            phoneNumber: "फ़ोन नंबर",
            guestLogin: "अतिथि लॉगिन",
            selectProfessionInstruction: "शुरू करने के लिए अपना पेशा चुनें",
            showMore: "और दिखाएं",
            showLess: "कम दिखाएं",
            forReview: "[समीक्षा के लिए]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "अपनी दैनिक जीवन के माध्यम से स्वाभाविक रूप से भाषाएँ सीखें",
            awarenessHeading: "जागरूकता",
            awarenessDescription: "रियल टाइम में अपने आसपास के शब्दों को नोटिस करें",
            breakdownHeading: "विश्लेषण",
            breakdownDescription: "समझें कि शब्द कैसे बनते हैं",
            progressHeading: "प्रगति",
            progressDescription: "अपनी सीखने की यात्रा को ट्रैक करें",
            readyHeading: "तैयार",
            readyDescription: "अभी सीखना शुरू करें",
            loginOrRegister: "लॉगिन या पंजीकरण",
            pageIndicator: "पृष्ठ",
            selectLanguageDescription: "अपनी पसंदीदा भाषा चुनें",
            whichLanguageDoYouSpeakComfortably: "आप कौन सी भाषा आराम से बोलते हैं?",
            chooseTheLanguageYouWantToMaster: "वह भाषा चुनें जिसे आप आज मास्टर करना चाहते हैं",
            fromWhereYouStand: "तुम जहां\nखड़े हो",
            toEveryWord: "हर शब्द",
            everyWord: "तक",
            youNeed: "तुम्हें चाहिए",
            lessonEngine: "लेसन_इंजन",
            nodesLive: "नोड्स_लाइव",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "होलो_ग्रिड_सक्रिय",
            adaCr02: "ADA_CR-02",
            your: "तुम्हारी",
            places: "जगहें,",
            lessons: "सबक।",
            yourPlaces: "तुम्हारी जगहें,",
            yourLessons: " तुम्हारे सबक।",
            nearbyCafes: "पास के कैफे?",
            unlockOrderFlow: " अनलॉक ऑर्डर",
            modules: "मॉड्यूल",
            activeHubs: "सक्रिय हब?",
            synthesizeGym: " जिम संश्लेषित करें",
            vocabulary: "शब्दावली",
            locationOpportunity: "हर स्थान सीखने का अवसर बन जाता है",
            module03: "मॉड्यूल_03",
            notJustMemorization: "सिर्फ रटना\nनहीं",
            philosophy: "दर्शन",
            locianTeaches: "Locian सिर्फ शब्द नहीं सिखाता।\nLocian आपको सिखाता है ",
            think: "सोचना",
            inTargetLanguage: "अपनी लक्षित भाषा में।",
            patternBasedLearning: "पैटर्न-आधारित शिक्षा",
            patternBasedDesc: "सूखे नियमों के बिना व्याकरणिक संरचनाओं को सहजता से पहचानें।",
            situationalIntelligence: "स्थितिजन्य बुद्धि",
            situationalDesc: "गतिशील परिदृश्य जो आपके वातावरण और इतिहास के अनुकूल होते हैं।",
            adaptiveDrills: "अनुकूलनीय अभ्यास",
            adaptiveDesc: "लेसन इंजन आपकी कमजोरियों की पहचान करता है और पुनर्गणना करता है।",
            systemReady: "सिस्टम_तैयार",
            quickSetup: "त्वरित_सेटअप",
            levelB2: "स्तर_B2",
            authorized: "अधिकृत",
            notificationsPermission: "सूचनाएं",
            notificationsDesc: "आस-पास के अभ्यास के अवसरों और स्ट्रीक अलर्ट पर रीयल-टाइम अपडेट प्राप्त करें।",
            microphonePermission: "माइक्रोफ़ोन",
            microphoneDesc: "वास्तविक दुनिया के संदर्भों में उच्चारण स्कोरिंग और पाठ बातचीत के लिए आवश्यक।",
            geolocationPermission: "जियोलोकेशन",
            geolocationDesc: "विसर्जित अभ्यास के लिए कॉफी शॉप या लाइब्रेरी जैसे नजदीकी \"लेसन ज़ोन\" की पहचान करें।",
            granted: "स्वीकृत",
            allow: "अनुमति दें",
            skip: "छोड़ें",
            letsStart: "चलिए शुरू करते हैं",
            continueText: "जारी रखें",
            wordTenses: "काल:",
            similarWords: "समान शब्द:",
            wordBreakdown: "शब्द विश्लेषण:",
            consonant: "व्यंजन",
            vowel: "स्वर",
            past: "भूतकाल",
            present: "वर्तमान",
            future: "भविष्य",
            learnWord: "सीखें")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "प्रगति",
            current: "वर्तमान",
            longest: "सबसे लंबा",
            lastPracticed: "अंतिम अभ्यास",
            days: "दिन",
            addLanguagePairToSeeProgress: "अपनी प्रगति देखने के लिए भाषा जोड़ी जोड़ें",
            startPracticingMessage: "अपनी स्ट्रीक बनाने के लिए अभ्यास शुरू करें",
            consistencyQuote: "निरंतरता भाषा सीखने की कुंजी है",
            practiceDateSavingDisabled: "अभ्यास तिथि सहेजना अक्षम है",
            editYourStreaks: "अपनी स्ट्रीक संपादित करें",
            editStreaks: "स्ट्रीक संपादित करें",
            selectDatesToAddOrRemove: "जोड़ने या हटाने के लिए तिथियां चुनें",
            saving: "सहेज रहा है",
            statusOnFire: "स्थिति: सक्रिय",
            youPracticed: "आपने अभ्यास किया ",
            yesterday: " कल।",
            checkInNow: "अभी चेक इन करें",
            nextGoal: "अगला लक्ष्य",
            reward: "इनाम",
            historyLogProgress: "इतिहास लॉग",
            streakStatus: "स्ट्रीक स्थिति",
            streakLog: "स्ट्रीक लॉग",
            consistency: "एकाग्रता",
            consistencyHigh: "आपका गतिविधि लॉग उच्च सक्रियता दिखाता है।",
            consistencyMedium: "आप अच्छी गति बना रहे हैं।",
            consistencyLow: "निरंतरता महत्वपूर्ण है। प्रयास करते रहें।",
            reachMilestone: "%d दिनों तक पहुँचने का प्रयास करें!",
            nextMilestone: "अगला माइलस्टोन",
            actionRequired: "कार्रवाई आवश्यक",
            logActivity: "गतिविधि दर्ज करें",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "सबसे लंबी स्ट्रीक",
            streakData: "स्ट्रीक डेटा",
            activeLabel: "सक्रिय",
            missedLabel: "छूटा हुआ",
            saveChanges: "परिवर्तन सहेजें",
            discardChanges: "परिवर्तन छोड़ें",
            editLabel: "संपादित करें",
            // Advanced Stats
            skillBalance: "कौशल संतुलन",
            fluencyVelocity: "प्रवाह वेग",
            vocabVault: "शब्दों का खजाना",
            chronotype: "कालप्रकार",
            activityDistribution: "गतिविधि वितरण (24 घंटे)",
            studiedTime: "अध्ययन समय",
            currentLabel: "वर्तमान",
            streakLabel: "स्ट्रीक",
            longestLabel: "लंबी",
            earlyBird: "सुबह का पंछी",
            earlyBirdDesc: "सुबह के समय सबसे सक्रिय",
            dayWalker: "दिन का राही",
            dayWalkerDesc: "दोपहर के समय सबसे सक्रिय",
            nightOwl: "रात का उल्लू",
            nightOwlDesc: "अंधेरा होने के बाद सबसे सक्रिय",
            timeMastery: "समय महारत",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "लोड हो रहा है...",
            adaptiveQuiz: "अनुकूल प्रश्नोत्तरी",
            adaptiveQuizDescription: "हम पहले गलत अनुवाद दिखाते हैं, फिर सही शब्द।",
            wordCheck: "शब्द जाँच",
            wordCheckDescription: "टाइल्स पहले मिलती हैं, फिर सही शब्द की पुष्टि के लिए सेट होती हैं।",
            wordCheckExamplePrompt: "शब्द को सही क्रम में व्यवस्थित करने के लिए अक्षरों को टैप करें।",
            quizPrompt: "शब्द के लिए सही अनुवाद चुनें।",
            answerConfirmation: "आपने सही शब्द बनाया है!",
            tryAgain: "ओह! फिर से प्रयास करें।")
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
        case .addRoutine: return ui.addRoutine
        case .tapToSetup: return ui.tapToSetup
        case .tapToStartLearning: return ui.tapToStartLearning
        }
    }
}
