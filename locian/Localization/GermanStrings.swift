//
//  GermanStrings.swift
//  locian
//
//  German localization strings
//

import Foundation

struct GermanStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "Quiz abgeschlossen!",
            masteredEnvironment: "Sie haben Ihre Umgebung gemeistert!",
            learnMoreAbout: "Mehr erfahren über",
            backToHome: "Zurück zum Start",
            next: "Weiter",
            previous: "Zurück",
            check: "Prüfen",
            tryAgain: "Erneut versuchen",
            shuffled: "Gemischt",
            noQuizAvailable: "Kein Quiz verfügbar",
            question: "Frage",
            correct: "Richtig",
            incorrect: "Falsch",
            notAttempted: "Nicht versucht"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "Meine Sprachen",
            notifications: "Benachrichtigungen",
            appearance: "Ästhetik",
            account: "Konto",
            profile: "Profil",
            addLanguagePair: "Sprachpaar hinzufügen",
            enableNotifications: "Benachrichtigungen aktivieren",
            logout: "Abmelden",
            deleteAllData: "Alle Daten löschen",
            deleteAccount: "Konto löschen",
            selectLevel: "Stufe auswählen",
            selectAppLanguage: "App-Oberfläche",
            proFeatures: "Power-Tools",
            showSimilarWordsToggle: "Ähnliche Wörter anzeigen",
            showWordTensesToggle: "Zeitformen anzeigen",
            nativeLanguage: "Muttersprache:",
            selectNativeLanguage: "Wählen Sie Ihre Muttersprache",
            targetLanguage: "Zielsprache:",
            selectTargetLanguage: "Wählen Sie die Sprache, die Sie lernen möchten",
            nativeLanguageDescription: "Ihre Muttersprache ist die Sprache, die Sie fließend lesen, schreiben und sprechen können. Dies ist die Sprache, mit der Sie sich am wohlsten fühlen.",
            targetLanguageDescription: "Ihre Zielsprache ist die Sprache, die Sie lernen und üben möchten. Wählen Sie die Sprache aus, in der Sie Ihre Fähigkeiten verbessern möchten.",
            addPair: "Paar hinzufügen",
            adding: "Hinzufügen...",
            failedToAddLanguagePair: "Sprachpaar konnte nicht hinzugefügt werden. Bitte versuchen Sie es erneut.",
            settingAsDefault: "Als Standard festlegen...",
            beginner: "Anfänger",
            intermediate: "Mittelstufe",
            advanced: "Fortgeschritten",
            currentlyLearning: "Lernen",
            otherLanguages: "Andere Sprachen",
            learnNewLanguage: "Neue Sprache lernen",
            learn: "Lernen",
            tapToSelectNativeLanguage: "Tippen Sie, um Ihre Muttersprache auszuwählen",
            neonGreen: "Neongrün",
            cyanMist: "Cyan-Nebel",
            violetHaze: "Violetter Dunst",
            softPink: "Sanftes Rosa",
            pureWhite: "Reines Weiß"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "Kategorien erkunden",
            testYourself: "Testen Sie sich selbst",
            slideToStartQuiz: "Zum Starten des Quiz schieben",
            similarWords: "Ähnliche Wörter",
            wordTenses: "Wortzeiten",
            wordBreakdown: "Wortaufschlüsselung",
            tapToSeeBreakdown: "Tippen Sie auf das Wort, um die Aufschlüsselung zu sehen",
            tapToHideBreakdown: "Tippen Sie auf das Wort, um die Aufschlüsselung zu verbergen",
            tapWordsToExplore: "Tippen Sie auf die Wörter, um ihre Übersetzungen zu lesen und zu erkunden",
            loading: "Lädt...",
            learnTheWord: "Das Wort lernen",
            tryFromMemory: "Aus dem Gedächtnis versuchen",
            adjustingTo: "Anpassung",
            settingPlace: "Einstellung",
            settingTime: "Einstellung",
            generatingVocabulary: "Generierung",
            analyzingVocabulary: "Analyse",
            analyzingCategories: "Analyse",
            analyzingWords: "Analyse",
            creatingQuiz: "Erstellung",
            organizingContent: "Organisation",
            to: "zu",
            place: "Ort",
            time: "Zeit",
            vocabulary: "Wortschatz",
            your: "Ihr",
            interested: "interessiert",
            categories: "Kategorien",
            words: "Wörter",
            quiz: "Quiz",
            content: "Inhalt"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "Hallo,",
            learnFromSurroundings: "Lernen Sie aus Ihrer Umgebung",
            learnFromSurroundingsDescription: "Erfassen Sie Ihre Umgebung und lernen Sie Vokabeln aus realen Kontexten",
            locianChoosing: "wählt...",
            chooseLanguages: "Sprachen auswählen",
            continueWith: "Mit dem fortfahren, was Locian gewählt hat",
            slideToLearn: "Zum Lernen schieben",
            recommended: "Empfohlen",
            intoYourLearningFlow: "In deinen Lernfluss",
            intoYourLearningFlowDescription: "Empfohlene Orte zum Üben basierend auf Ihrer Lernhistorie",
            customSituations: "Ihre benutzerdefinierten Situationen",
            customSituationsDescription: "Erstellen und üben Sie mit Ihren eigenen personalisierten Lernszenarien",
            max: "Max",
            recentPlacesTitle: "Deine letzten Orte",
            allPlacesTitle: "Alle Orte",
            recentPlacesEmpty: "Generiere Vokabeln, um hier Vorschläge zu sehen.",
            showMore: "Mehr anzeigen",
            showLess: "Weniger anzeigen",
            takePhoto: "Foto aufnehmen",
            chooseFromGallery: "Aus Galerie wählen",
            letLocianChoose: "LASS LOCIAN WÄHLEN",
            lociansChoice: "Von Locian",
            cameraTileDescription: "Dieses Foto analysiert Ihre Umgebung und zeigt Ihnen Momente zum Lernen.",
            airport: "Flughafen",
            aquarium: "Aquarium",
            bakery: "Bäckerei",
            beach: "Strand",
            bookstore: "Buchhandlung",
            cafe: "Café",
            cinema: "Kino",
            gym: "Fitnessstudio",
            hospital: "Krankenhaus",
            hotel: "Hotel",
            home: "Zuhause",
            library: "Bibliothek",
            market: "Markt",
            museum: "Museum",
            office: "Büro",
            park: "Park",
            restaurant: "Restaurant",
            shoppingMall: "Einkaufszentrum",
            stadium: "Stadion",
            supermarket: "Supermarkt",
            temple: "Tempel",
            travelling: "Reisen",
            university: "Universität",
            addCustomPlace: "Benutzerdefinierten Ort hinzufügen",
            addPlace: "Ort hinzufügen",
            enterCustomPlaceName: "Geben Sie einen benutzerdefinierten Ortsnamen ein (max. 30 Zeichen)",
            maximumCustomPlaces: "Maximal 10 benutzerdefinierte Orte",
            welcome: "Willkommen",
            user: "Benutzer",
            tapToCaptureContext: "Tippen Sie, um Ihren Kontext zu erfassen und mit dem Lernen zu beginnen",
            customSection: "Benutzerdefiniert",
            examples: "Beispiele:",
            customPlacePlaceholder: "z.B., Fahrt ins Büro",
            exampleTravellingToOffice: "Fahrt ins Büro",
            exampleTravellingToHome: "Fahrt nach Hause",
            exampleExploringParis: "Paris erkunden",
            exampleVisitingMuseum: "Museum besuchen",
            exampleCoffeeShop: "Café",
            characterCount: "Zeichen",
            situationExample1: "Kaffee in einem belebten Café bestellen",
            situationExample2: "In einer neuen Stadt nach dem Weg fragen",
            situationExample3: "Lebensmittel auf dem Markt einkaufen",
            situationExample4: "Einen Arzttermin vereinbaren",
            situationExample5: "In ein Hotel einchecken"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "Anmelden",
            verify: "Verifizieren",
            selectProfession: "Beruf auswählen",
            username: "Benutzername",
            phoneNumber: "Telefonnummer",
            guestLogin: "Gast-Anmeldung",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "Von wo Sie stehen bis zu jeder Zeit, die Sie brauchen",
            awarenessHeading: "Bewusstsein",
            awarenessDescription: "KI lernt aus Ihrer Umgebung",
            inputsHeading: "Eingaben",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "Aufschlüsselung",
            breakdownDescription: "Locian zerlegt Sätze in Zeiten, bietet Wort-für-Wort-Übersetzungen",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "Bereit",
            readyDescription: "",
            loginOrRegister: "Anmelden / Registrieren",
            pageIndicator: " / 6",
            tapToNavigate: "Tippen Sie links oder rechts, um zu navigieren",
            selectAppLanguage: "App-Sprache auswählen",
            selectLanguageDescription: "Diese Sprache wandelt die App-Benutzeroberfläche, Überschriften, Beschreibungen, Schaltflächen, Namen und alles in die ausgewählte Sprache um"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "Abbrechen",
            save: "Speichern",
            done: "Fertig",
            ok: "OK",
            back: "Zurück",
            next: "Weiter",
            continueText: "Fortsetzen"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "Benutzerdefiniert",
            hint: "Hinweis",
            practiceDescription: "Tippen Sie auf ein beliebiges Wort, um es in Ihre Zielsprache zu übersetzen. Wenn Sie Hilfe benötigen, verwenden Sie die Hinweis-Schaltfläche, um Vorschläge zu erhalten.",
            practiceTitle: "Übung",
            practiceFollowUp: "Nächste Übung",
            camera: "Kamera",
            cameraDescription: "Locian wird ein Gespräch auf {native} generieren und Sie können die Umwandlung in {target} üben.",
            useCamera: "Kamera verwenden",
            cameraButtonDescription: "Momente aus Foto generieren",
            typeConversation: "Geben Sie ein Gespräch ein",
            typeConversationDescription: "Locian wird ein Gespräch auf {native} generieren und Sie können die Umwandlung in {target} üben.",
            conversationPlaceholder: "z.B. Kaffee in einem belebten Café bestellen",
            submit: "Senden",
            fullCustomText: "Vollständiger benutzerdefinierter Text",
            examples: "Beispiele:",
            conversationExample1: "Im Regen nach dem Weg fragen",
            conversationExample2: "Spät abends Gemüse kaufen",
            conversationExample3: "In einem überfüllten Büro arbeiten",
            describeConversation: "Beschreiben Sie das Gespräch, das Locian erstellen soll.",
            fullTextPlaceholder: "Geben Sie hier den vollständigen Text oder Dialog ein...",
            startCustomPractice: "Benutzerdefinierte Übung starten"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Fortschritt",
            edit: "Bearbeiten",
            current: "Aktuell",
            longest: "Längste",
            lastPracticed: "Zuletzt geübt",
            days: "Tage",
            addLanguagePairToSeeProgress: "Fügen Sie ein Sprachpaar hinzu, um Ihren Fortschritt zu sehen."
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "Meine Sprachen"
        case .notifications: return "Benachrichtigungen"
        case .aesthetics: return "Ästhetik"
        case .account: return "Konto"
        case .appLanguage: return "App-Oberfläche"
        
        // Common
        case .login: return "Anmelden /"
        case .register: return "Registrieren"
        case .settings: return "Einstellungen"
        case .home: return "Startseite"
        case .back: return "Zurück"
        case .next: return "Weiter"
        case .previous: return "Vorherige"
        case .done: return "Fertig"
        case .cancel: return "Abbrechen"
        case .save: return "Speichern"
        case .delete: return "Löschen"
        case .add: return "Hinzufügen"
        case .remove: return "Entfernen"
        case .edit: return "Bearbeiten"
        case .continueText: return "Fortsetzen"
        
        // Quiz
        case .quizCompleted: return "Quiz abgeschlossen!"
        case .sessionCompleted: return "Sitzung abgeschlossen!"
        case .masteredEnvironment: return "Sie haben Ihre Umgebung gemeistert!"
        case .learnMoreAbout: return "Mehr erfahren über"
        case .backToHome: return "Zurück zur Startseite"
        case .tryAgain: return "Nochmal versuchen"
        case .shuffled: return "Gemischt"
        case .check: return "Prüfen"
        
        // Vocabulary
        case .exploreCategories: return "Kategorien erkunden"
        case .testYourself: return "Sich selbst testen"
        case .similarWords: return "Ähnliche Wörter:"
        case .wordTenses: return "Wortzeiten:"
        case .tapWordsToExplore: return "Tippen Sie auf die Wörter, um ihre Übersetzungen zu lesen und zu erkunden"
        case .wordBreakdown: return "Wortaufschlüsselung:"
        
        // Scene
        case .analyzingImage: return "Bild wird analysiert..."
        case .imageAnalysisCompleted: return "Bildanalyse abgeschlossen"
        case .imageSelected: return "Bild ausgewählt"
        case .placeNotSelected: return "Ort nicht ausgewählt"
        case .chooseLanguages: return "Sprachen auswählen"
        case .locianChoose: return "Locian wählt"
        
        // Settings
        case .enableNotifications: return "Benachrichtigungen aktivieren"
        case .thisPlace: return "dieser Ort"
        case .tapOnAnySection: return "Tippen Sie auf einen beliebigen Abschnitt oben, um Einstellungen anzuzeigen und zu verwalten"
        case .addNewLanguagePair: return "Neues Sprachpaar hinzufügen"
        case .noLanguagePairsAdded: return "Noch keine Sprachpaare hinzugefügt"
        case .setDefault: return "Als Standard festlegen"
        case .defaultText: return "Standard"
        case .user: return "Benutzer"
        case .noPhone: return "Kein Telefon"
        case .signOutFromAccount: return "Von Ihrem Konto abmelden"
        case .removeAllPracticeData: return "Alle Ihre Übungsdaten entfernen"
        case .permanentlyDeleteAccount: return "Ihr Konto und alle Daten dauerhaft löschen"
        case .currentLevel: return "Aktuelles Niveau"
        case .selectPhoto: return "Foto auswählen"
        case .camera: return "Kamera"
        case .photoLibrary: return "Fotobibliothek"
        case .selectTime: return "Zeit auswählen"
        case .hour: return "Stunde"
        case .minute: return "Minute"
        case .addTime: return "Zeit hinzufügen"
        case .areYouSureLogout: return "Möchten Sie sich wirklich abmelden?"
        case .areYouSureDeleteAccount: return "Möchten Sie Ihr Konto wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden."
        
        // Quiz
        case .goBack: return "Zurück"
        case .fillInTheBlank: return "Füllen Sie die Lücke aus:"
        case .arrangeWordsInOrder: return "Ordnen Sie die Wörter in der richtigen Reihenfolge:"
        case .tapWordsBelowToAdd: return "Tippen Sie auf die Wörter unten, um sie hier hinzuzufügen"
        case .availableWords: return "Verfügbare Wörter:"
        case .correctAnswer: return "Richtige Antwort:"
        
        // Common
        case .error: return "Fehler"
        case .ok: return "OK"
        case .close: return "Schließen"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "Von wo Sie stehen bis zu jeder Zeit, die Sie brauchen"
        case .awarenessHeading: return "Bewusstsein"
        case .awarenessDescription: return "KI lernt aus Ihrer Umgebung"
        case .inputsHeading: return "Eingaben"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "Aufschlüsselung"
        case .breakdownDescription: return "Locian zerlegt Sätze in Zeiten, bietet Wort-für-Wort-Übersetzungen"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "Bereit"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "Anmelden / Registrieren"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "Tippen Sie links oder rechts, um zu navigieren"
        case .selectAppLanguage: return "App-Sprache auswählen"
        case .selectLanguageDescription: return "Diese Sprache wandelt die App-Benutzeroberfläche, Überschriften, Beschreibungen, Schaltflächen, Namen und alles in die ausgewählte Sprache um"
        
        // Login
        case .username: return "Benutzername"
        case .phoneNumber: return "Telefonnummer"
        case .guestLogin: return "Gast-Anmeldung"
        case .guestLoginDescription: return "Gast-Anmeldung ist für die Überprüfung gedacht und ermöglicht dem Gast den Zugriff auf alle App-Funktionen. Wird nach der Überprüfung entfernt."
        
        // Professions
        case .student: return "Student"
        case .softwareEngineer: return "Software-Ingenieur"
        case .teacher: return "Lehrer"
        case .doctor: return "Arzt"
        case .artist: return "Künstler"
        case .businessProfessional: return "Business-Experte"
        case .salesOrMarketing: return "Vertrieb oder Marketing"
        case .traveler: return "Reisender"
        case .homemaker: return "Hausfrau"
        case .chef: return "Koch"
        case .police: return "Polizei"
        case .bankEmployee: return "Bankangestellter"
        case .nurse: return "Krankenschwester"
        case .designer: return "Designer"
        case .engineerManager: return "Ingenieur Manager"
        case .photographer: return "Fotograf"
        case .contentCreator: return "Content-Ersteller"
        case .other: return "Andere"
        
        // Scene Places
        case .lociansChoice: return "Locians Wahl"
        case .airport: return "Flughafen"
        case .cafe: return "Café"
        case .gym: return "Fitnessstudio"
        case .library: return "Bibliothek"
        case .office: return "Büro"
        case .park: return "Park"
        case .restaurant: return "Restaurant"
        case .shoppingMall: return "Einkaufszentrum"
        case .travelling: return "Reisen"
        case .university: return "Universität"
        case .addCustomPlace: return "Benutzerdefinierten Ort hinzufügen"
        case .enterCustomPlaceName: return "Geben Sie einen benutzerdefinierten Ortsnamen ein (max. 30 Zeichen)"
        case .maximumCustomPlaces: return "Maximal 10 benutzerdefinierte Orte"
        case .welcome: return "Willkommen"
        case .tapToCaptureContext: return "Tippen Sie, um Ihren Kontext zu erfassen und mit dem Lernen zu beginnen"
        case .customSection: return "Benutzerdefiniert"
        case .examples: return "Beispiele:"
        case .customPlacePlaceholder: return "z.B., Fahrt ins Büro"
        case .exampleTravellingToOffice: return "Fahrt ins Büro"
        case .exampleTravellingToHome: return "Fahrt nach Hause"
        case .exampleExploringParis: return "Paris erkunden"
        case .exampleVisitingMuseum: return "Museum besuchen"
        case .exampleCoffeeShop: return "Café"
        case .characterCount: return "Zeichen"
        
        // Settings Modal Strings
        case .nativeLanguage: return "Muttersprache:"
        case .selectNativeLanguage: return "Wählen Sie Ihre Muttersprache"
        case .targetLanguage: return "Zielsprache:"
        case .selectTargetLanguage: return "Wählen Sie die Sprache, die Sie lernen möchten"
        case .nativeLanguageDescription: return "Ihre Muttersprache ist die Sprache, die Sie fließend lesen, schreiben und sprechen können. Dies ist die Sprache, mit der Sie sich am wohlsten fühlen."
        case .targetLanguageDescription: return "Ihre Zielsprache ist die Sprache, die Sie lernen und üben möchten. Wählen Sie die Sprache aus, in der Sie Ihre Fähigkeiten verbessern möchten."
        case .addPair: return "Paar hinzufügen"
        case .adding: return "Hinzufügen..."
        case .failedToAddLanguagePair: return "Sprachpaar konnte nicht hinzugefügt werden. Bitte versuchen Sie es erneut."
        case .settingAsDefault: return "Als Standard festlegen..."
        case .beginner: return "Anfänger"
        case .intermediate: return "Mittelstufe"
        case .advanced: return "Fortgeschritten"
        case .currentlyLearning: return "Lernen"
        case .otherLanguages: return "Andere Sprachen"
        case .learnNewLanguage: return "Neue Sprache lernen"
        case .learn: return "Lernen"
        case .tapToSelectNativeLanguage: return "Tippen Sie, um Ihre Muttersprache auszuwählen"
        
        // Theme color names
        case .neonGreen: return "Neongrün"
        case .cyanMist: return "Cyan-Nebel"
        case .violetHaze: return "Violetter Dunst"
        case .softPink: return "Sanftes Rosa"
        case .pureWhite: return "Reines Weiß"
        
        // Quick Look
        case .quickRecall: return "Schneller Abruf"
        case .startQuickPuzzle: return "Schnelles Puzzle starten"
        case .stopPuzzle: return "Puzzle stoppen"
        
        // Streak
        case .streak: return "Serie"
        case .dayStreak: return "Tag Serie"
        case .daysStreak: return "Tage Serie"
        case .editYourStreaks: return "Ihre Serien bearbeiten"
        case .editStreaks: return "Serien bearbeiten"
        case .selectDatesToAddOrRemove: return "Wählen Sie Daten aus, um Übungstage hinzuzufügen oder zu entfernen"
        case .saving: return "Speichern..."
        }
    }
}

