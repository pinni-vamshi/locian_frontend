//
//  GermanStrings.swift
//  locian
//

import Foundation

struct GermanStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "Kamera",
            gallery: "Galerie",
            nextUp: "Als Nächstes",
            historyLog: "Verlaufsprotokoll",

            moments: "Momente",
            pastMoments: "Vergangene Momente",
            noHistory: "Kein Verlauf",
            generatingHistory: "Verlauf wird Generiert",
            generatingMoments: "GENERIEREN...",
            analyzingImage: "BILDANALYSE...",
            tapNextUpToGenerate: "Tippen Sie auf Als Nächstes zum Generieren",
            noUpcomingPlaces: "Keine Bevorstehenden Orte",
            noDetails: "Keine Details",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "Lernen Beginnen",
            continueLearning: "Weiter Lernen",
            noPastMoments: "Keine Vergangenen Momente",
            useCamera: "Kamera Verwenden",
            previouslyLearning: "Zuvor Gelernt",
            sunShort: "So",
            monShort: "Mo",
            tueShort: "Di",
            wedShort: "Mi",
            thuShort: "Do",
            friShort: "Fr",
            satShort: "Sa",
            login: "Anmelden",
            register: "Registrieren",
            settings: "Einstellungen",
            back: "Zurück",
            done: "Fertig",
            cancel: "Abbrechen",
            save: "Speichern",
            delete: "Löschen",
            add: "Hinzufügen",
            remove: "Entfernen",
            edit: "Bearbeiten",
            error: "Fehler",
            ok: "OK",
            welcomeLabel: "Willkommen",
            currentStreak: "AKTUELLER_STREAK",
            notSet: "Nicht festgelegt",
            learnTab: "Lernen",
            addTab: "Hinzufügen",
            progressTab: "Fortschritt",
            settingsTab: "Einstellungen",
            loading: "Laden...",
            unknownPlace: "Unbekannter Ort",
            noLanguageAvailable: "Keine Sprache verfügbar",
            noInternetConnection: "Keine Internetverbindung",
            retry: "Wiederholen",
            tapToGetMoments: "Tippen für Momente",
            startLearningThisMoment: "Jetzt lernen",
            daysLabel: "TAGE",
            noNewPlace: "Neuen Ort hinzufügen",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "Start",
            typeYourMoment: "Schreibe deinen Moment...",
            imagesLabel: "BILDER",
            routinesLabel: "ROUTINEN",
            whatAreYouDoing: "Was machst du gerade?",
            chooseContext: "Wähle einen Kontext zum Lernen",
            typeHere: "HIER TIPPEN",
            nearbyLabel: "IN DER NÄHE",
            noNearbyPlaces: "Keine Orte in der Nähe gefunden")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "App-Oberfläche",
            targetLanguages: "Zielsprachen",
            pastLanguagesArchived: "Zuvor Gelernt",
            theme: "Thema",
            notifications: "Benachrichtigungen",
            account: "Konto",
            profile: "Profil",
            addLanguagePair: "Sprachpaar Hinzufügen",
            logout: "Abmelden",
            deleteAllData: "Alle Daten Löschen",
            deleteAccount: "Konto Dauerhaft Löschen",
            selectLevel: "Niveau Auswählen",
            proFeatures: "Pro-Funktionen",
            showSimilarWordsToggle: "Ähnliche Wörter Anzeigen",
            nativeLanguage: "Mutter Sprache",
            selectNativeLanguage: "Muttersprache Auswählen",
            targetLanguage: "Zielsprache",
            selectTargetLanguage: "Zielsprache Auswählen",
            targetLanguageDescription: "Sprache, die Sie lernen möchten",
            beginner: "Anfänger",
            intermediate: "Fortgeschritten",
            advanced: "Experte",
            currentlyLearning: "Derzeit Lernen",
            learnNewLanguage: "Neue Sprache Lernen",
            learn: "Lernen",
            neonGreen: "Neongrün",
            neonFuchsia: "Neon-Fuchsia",
            electricIndigo: "Elektrisches Indigo",
            graphiteBlack: "Graphitschwarz",
            student: "Student",
            softwareEngineer: "Software-Ingenieur",
            teacher: "Lehrer",
            doctor: "Arzt",
            artist: "Künstler",
            businessProfessional: "Geschäftsmann",
            salesOrMarketing: "Vertrieb oder Marketing",
            traveler: "Reisender",
            homemaker: "Hausmann/Hausfrau",
            chef: "Koch",
            police: "Polizei",
            bankEmployee: "Bankangestellter",
            nurse: "Krankenschwester/Krankenpfleger",
            designer: "Designer",
            engineerManager: "Ingenieur-Manager",
            photographer: "Fotograf",
            contentCreator: "Content-Ersteller",
            entrepreneur: "Unternehmer",
            other: "Andere",
            otherPlaces: "Andere Orte",
            speaks: "Spricht",
            neuralEngine: "Neuronale Engine",
            noLanguagePairsAdded: "Keine Sprachpaare Hinzugefügt",
            setDefault: "Als Standard Festlegen",
            defaultText: "Standard",
            user: "Benutzer",
            signOutFromAccount: "Vom Konto Abmelden",
            permanentlyDeleteAccount: "Konto Dauerhaft Löschen",
            languageAddedSuccessfully: "Sprache erfolgreich hinzugefügt",
            failedToAddLanguage: "Sprache konnte nicht hinzugefügt werden. Bitte erneut versuchen.",
            pleaseSelectLanguage: "Bitte wählen Sie eine Sprache",
            systemConfig: "SYSTEM // KONFIG",
            currentLevel: "Aktuelles Niveau",
            selectPhoto: "Foto Auswählen",
            camera: "Kamera",
            photoLibrary: "Fotobibliothek",
            selectTime: "Zeit Auswählen",
            hour: "Stunde",
            minute: "Minute",
            addTime: "Zeit Hinzufügen",
            location: "Standort",
            diagnosticBorders: "Diagnose-Ränder",
            areYouSureLogout: "Sind Sie sicher, dass Sie sich abmelden möchten?",
            areYouSureDeleteAccount: "Sind Sie sicher, dass Sie Ihr Konto dauerhaft löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden?")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "Anmelden",
            verify: "Überprüfen",
            selectProfession: "Beruf Auswählen",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "Benutzername",
            phoneNumber: "Telefonnummer",
            guestLogin: "Gast-Anmeldung",
            selectProfessionInstruction: "Wählen Sie Ihren Beruf",
            showMore: "Mehr anzeigen",
            showLess: "Weniger anzeigen",
            forReview: "[Zur Überprüfung]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "Lernen Sie Sprachen natürlich durch Ihren Alltag",
            awarenessHeading: "Bewusstsein",
            awarenessDescription: "Bemerken Sie Wörter um Sie herum in Echtzeit",
            breakdownHeading: "Aufschlüsselung",
            breakdownDescription: "Verstehen Sie, wie Wörter aufgebaut sind",
            progressHeading: "Fortschritt",
            progressDescription: "Verfolgen Sie Ihre Lernreise",
            readyHeading: "Bereit",
            readyDescription: "Jetzt mit dem Lernen beginnen",
            loginOrRegister: "Anmelden oder Registrieren",
            pageIndicator: "Seite",
            selectLanguageDescription: "Wählen Sie Ihre bevorzugte Sprache",
            whichLanguageDoYouSpeakComfortably: "WELCHE SPRACHE SPRECHEN SIE BEQUEM?",
            chooseTheLanguageYouWantToMaster: "WÄHLEN SIE DIE SPRACHE, DIE SIE HEUTE MEISTERN MÖCHTEN",

            fromWhereYouStand: "VON WO SIE\nSTEHEN",
            toEveryWord: "Z U",
            everyWord: "JEDEM WORT",
            youNeed: "SIE BRAUCHEN",
            lessonEngine: "LEKTION_ENGINE",
            nodesLive: "NODES_LIVE",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "HOLO_GRID_AKTIV",
            adaCr02: "ADA_CR-02",
            your: "IHRE",
            places: "ORTE,",
            lessons: "LEKTIONEN.",
            yourPlaces: "IHRE ORTE,",
            yourLessons: " IHRE LEKTIONEN.",
            nearbyCafes: "Cafés in der Nähe?",
            unlockOrderFlow: " Bestellablauf freischalten",
            modules: "Module",
            activeHubs: "Aktive Hubs?",
            synthesizeGym: " Synthese-Gym",
            vocabulary: "Wortschatz",
            locationOpportunity: "Jeder Ort wird zur Lerngelegenheit",
            module03: "MODUL_03",
            notJustMemorization: "NICHT NUR\nAUSWENDIGLERNEN",
            philosophy: "PHILOSOPHIE",
            locianTeaches: "Locian lehrt nicht nur Wörter.\nLocian lehrt Sie zu ",
            think: "DENKEN",
            inTargetLanguage: "in Ihrer Zielsprache.",
            patternBasedLearning: "MUSTERBASIERTES LERNEN",
            patternBasedDesc: "Erkennen Sie grammatikalische Strukturen intuitiv ohne trockene Regeln.",
            situationalIntelligence: "SITUATIVE INTELLIGENZ",
            situationalDesc: "Dynamische Szenarien, die sich an Ihre Umgebung und Ihren Verlauf anpassen.",
            adaptiveDrills: "ADAPTIVE ÜBUNGEN",
            adaptiveDesc: "Die Lektions-Engine erkennt Ihre Schwächen und kalibriert sich neu.",
            systemReady: "SYSTEM_BEREIT",
            quickSetup: "SCHNELLSTART",
            levelB2: "GER_B2",
            authorized: "AUTORISIERT",
            notificationsPermission: "BENACHRICHTIGUNGEN",
            notificationsDesc: "Erhalten Sie Echtzeit-Updates zu Übungsmöglichkeiten in der Nähe und Streak-Warnungen.",
            microphonePermission: "MIKROFON",
            microphoneDesc: "Unverzichtbar für die Aussprachebewertung und Lektionsinteraktionen in realen Kontexten.",
            geolocationPermission: "STANDORT",
            geolocationDesc: "Identifizieren Sie nahegelegene \"Lernzonen\" wie Cafés oder Bibliotheken für immersives Üben.",
            granted: "GEWÄHRT",
            allow: "ERLAUBEN",
            skip: "ÜBERSPRINGEN",
            letsStart: "LOS GEHT'S",
            continueText: "WEITER",
            wordTenses: "Zeitformen:",
            similarWords: "Ähnliche Wörter:",
            wordBreakdown: "Wortanalyse:",
            consonant: "Konsonant",
            vowel: "Vokal",
            past: "Vergangenheit",
            present: "Gegenwart",
            future: "Zukunft",
            learnWord: "Lernen")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Fortschritt",
            current: "Aktuell",
            longest: "Längste",
            lastPracticed: "Zuletzt Geübt",
            days: "Tage",
            addLanguagePairToSeeProgress: "Fügen Sie ein Sprachpaar hinzu, um Ihren Fortschritt zu sehen",
            startPracticingMessage: "Beginnen Sie zu üben, um Ihre Serie aufzubauen",
            consistencyQuote: "Beständigkeit ist der Schlüssel zum Sprachenlernen",
            practiceDateSavingDisabled: "Das Speichern von Übungsdaten ist deaktiviert",
            editYourStreaks: "Ihre Serien Bearbeiten",
            editStreaks: "Serien Bearbeiten",
            selectDatesToAddOrRemove: "Wählen Sie Daten aus, die Sie Ihrer Serie hinzufügen oder entfernen möchten",
            saving: "Speichern",
            statusOnFire: "Status: In Flammen",
            youPracticed: "Sie haben geübt ",
            yesterday: " gestern.",
            checkInNow: "Jetzt Einchecken",
            nextGoal: "Nächstes Ziel",
            reward: "Belohnung",
            historyLogProgress: "Verlaufsprotokoll",
            streakStatus: "Strähnenstatus",
            streakLog: "Strähnenprotokoll",
            consistency: "Konsistenz",
            consistencyHigh: "Ihr Aktivitätsprotokoll zeigt hohes Engagement.",
            consistencyMedium: "Sie bauen guten Schwung auf.",
            consistencyLow: "Konsistenz ist der Schlüssel. Weiter so.",
            reachMilestone: "Versuchen Sie %d Tage zu erreichen!",
            nextMilestone: "Nächster Meilenstein",
            actionRequired: "Handlung erforderlich",
            logActivity: "Aktivität protokollieren",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "Längste Strähne",
            streakData: "STREAK-DATEN",
            activeLabel: "AKTIV",
            missedLabel: "VERPASST",
            saveChanges: "SPEICHERN",
            discardChanges: "VERWERFEN",
            editLabel: "BEARBEITEN",
            // Advanced Stats
            skillBalance: "FÄHIGKEITSBALANCE",
            fluencyVelocity: "FLÜSSIGKEITSGESCHWINDIGKEIT",
            vocabVault: "VOKABELTRESOR",
            chronotype: "CHRONOTYP",
            activityDistribution: "AKTIVITÄTSVERTEILUNG (24H)",
            studiedTime: "LERNZEIT",
            currentLabel: "AKTUELL",
            streakLabel: "STREAK",
            longestLabel: "REKORD",
            earlyBird: "FRÜHAUFSSTEHER",
            earlyBirdDesc: "Morgens am aktivsten",
            dayWalker: "TAGWÄCHTER",
            dayWalkerDesc: "Nachmittags am aktivsten",
            nightOwl: "NACHTEULE",
            nightOwlDesc: "Nach Einbruch der Dunkelheit am aktivsten",
            timeMastery: "ZEITBEHERRSCHUNG",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "Laden...",
            adaptiveQuiz: "Adaptives Quiz",
            adaptiveQuizDescription: "Wir zeigen erst eine falsche Übersetzung, dann das richtige Wort.",
            wordCheck: "Wortprüfung",
            wordCheckDescription: "Kacheln mischen sich erst, dann rasten sie zum richtigen Wort ein.",
            wordCheckExamplePrompt: "Tippen Sie auf die Buchstaben, um das Wort richtig zu ordnen.",
            quizPrompt: "Wählen Sie die richtige Übersetzung für das Wort.",
            answerConfirmation: "Sie haben das richtige Wort gebildet!",
            tryAgain: "Ups! Versuchen Sie es erneut.")
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
