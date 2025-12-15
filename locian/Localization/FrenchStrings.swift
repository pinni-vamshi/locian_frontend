//
//  FrenchStrings.swift
//  locian
//
//  French localization strings
//

import Foundation

struct FrenchStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "Quiz terminé!",
            masteredEnvironment: "Vous avez maîtrisé votre environnement!",
            learnMoreAbout: "En savoir plus sur",
            backToHome: "Retour à l'accueil",
            next: "Suivant",
            previous: "Précédent",
            check: "Vérifier",
            tryAgain: "Réessayer",
            shuffled: "Mélangé",
            noQuizAvailable: "Aucun quiz disponible",
            question: "Question",
            correct: "Correct",
            incorrect: "Incorrect",
            notAttempted: "Non tenté"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "Mes langues",
            notifications: "Notifications",
            appearance: "Esthétique",
            account: "Compte",
            profile: "Profil",
            addLanguagePair: "Ajouter une paire de langues",
            enableNotifications: "Activer les notifications",
            logout: "Déconnexion",
            deleteAllData: "Supprimer toutes les données",
            deleteAccount: "Supprimer le compte",
            selectLevel: "Sélectionner le niveau",
            selectAppLanguage: "Interface de l'application",
            proFeatures: "Outils avancés",
            showSimilarWordsToggle: "Afficher les mots similaires",
            showWordTensesToggle: "Afficher les temps",
            nativeLanguage: "Langue maternelle:",
            selectNativeLanguage: "Sélectionnez votre langue maternelle",
            targetLanguage: "Langue cible:",
            selectTargetLanguage: "Sélectionnez la langue que vous souhaitez apprendre",
            nativeLanguageDescription: "Votre langue maternelle est la langue que vous pouvez lire, écrire et parler couramment. C'est la langue avec laquelle vous êtes le plus à l'aise.",
            targetLanguageDescription: "Votre langue cible est la langue que vous souhaitez apprendre et pratiquer. Choisissez la langue dans laquelle vous souhaitez améliorer vos compétences.",
            addPair: "Ajouter la paire",
            adding: "Ajout en cours...",
            failedToAddLanguagePair: "Échec de l'ajout de la paire de langues. Veuillez réessayer.",
            settingAsDefault: "Définition par défaut...",
            beginner: "Débutant",
            intermediate: "Intermédiaire",
            advanced: "Avancé",
            currentlyLearning: "En cours d'apprentissage",
            otherLanguages: "Autres langues",
            learnNewLanguage: "Apprendre une nouvelle langue",
            learn: "Apprendre",
            tapToSelectNativeLanguage: "Appuyez pour sélectionner votre langue maternelle",
            neonGreen: "Vert Néon",
            cyanMist: "Brum Cyan",
            violetHaze: "Brume Violette",
            softPink: "Rose Doux",
            pureWhite: "Blanc Pur"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "Explorer les catégories",
            testYourself: "Testez-vous",
            slideToStartQuiz: "Faites glisser pour lancer le quiz",
            similarWords: "Mots similaires",
            wordTenses: "Temps des verbes",
            wordBreakdown: "Décomposition des mots",
            tapToSeeBreakdown: "Touchez le mot pour voir la décomposition",
            tapToHideBreakdown: "Touchez le mot pour masquer la décomposition",
            tapWordsToExplore: "Touchez les mots pour lire leurs traductions et explorer",
            loading: "Chargement...",
            learnTheWord: "Apprendre le mot",
            tryFromMemory: "Essayer de mémoire",
            adjustingTo: "Ajustement",
            settingPlace: "Réglage",
            settingTime: "Réglage",
            generatingVocabulary: "Génération",
            analyzingVocabulary: "Analyse",
            analyzingCategories: "Analyse",
            analyzingWords: "Analyse",
            creatingQuiz: "Création",
            organizingContent: "Organisation",
            to: "à",
            place: "lieu",
            time: "temps",
            vocabulary: "vocabulaire",
            your: "votre",
            interested: "intéressé",
            categories: "catégories",
            words: "mots",
            quiz: "quiz",
            content: "contenu"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "Salut,",
            learnFromSurroundings: "Apprenez de votre environnement",
            learnFromSurroundingsDescription: "Capturez votre environnement et apprenez le vocabulaire à partir de contextes réels",
            locianChoosing: "choisit...",
            chooseLanguages: "Choisissez des langues",
            continueWith: "Continuer avec ce que Locian a choisi",
            slideToLearn: "Faites glisser pour apprendre",
            recommended: "Recommandé",
            intoYourLearningFlow: "Dans votre flux d'apprentissage",
            intoYourLearningFlowDescription: "Lieux recommandés pour pratiquer basés sur votre historique d'apprentissage",
            customSituations: "Vos situations personnalisées",
            customSituationsDescription: "Créez et pratiquez avec vos propres scénarios d'apprentissage personnalisés",
            max: "Max",
            recentPlacesTitle: "Vos lieux récents",
            allPlacesTitle: "Tous les lieux",
            recentPlacesEmpty: "Générez du vocabulaire pour voir des suggestions ici.",
            showMore: "Afficher plus",
            showLess: "Afficher moins",
            takePhoto: "Prendre une photo",
            chooseFromGallery: "Choisir dans la galerie",
            letLocianChoose: "LAISSER LOCIAN CHOISIR",
            lociansChoice: "Par Locian",
            cameraTileDescription: "Cette photo analyse votre environnement et vous montre des moments à apprendre.",
            airport: "Aéroport",
            aquarium: "Aquarium",
            bakery: "Boulangerie",
            beach: "Plage",
            bookstore: "Librairie",
            cafe: "Café",
            cinema: "Cinéma",
            gym: "Salle de sport",
            hospital: "Hôpital",
            hotel: "Hôtel",
            home: "Maison",
            library: "Bibliothèque",
            market: "Marché",
            museum: "Musée",
            office: "Bureau",
            park: "Parc",
            restaurant: "Restaurant",
            shoppingMall: "Centre commercial",
            stadium: "Stade",
            supermarket: "Supermarché",
            temple: "Temple",
            travelling: "Voyage",
            university: "Université",
            addCustomPlace: "Ajouter un lieu personnalisé",
            addPlace: "Ajouter un lieu",
            enterCustomPlaceName: "Entrez un nom de lieu personnalisé (30 caractères max)",
            maximumCustomPlaces: "Maximum 10 lieux personnalisés",
            welcome: "Bienvenue",
            user: "Utilisateur",
            tapToCaptureContext: "Appuyez pour capturer votre contexte et commencer à apprendre",
            customSection: "Personnalisé",
            examples: "Exemples:",
            customPlacePlaceholder: "par ex., voyage au bureau",
            exampleTravellingToOffice: "voyage au bureau",
            exampleTravellingToHome: "voyage à la maison",
            exampleExploringParis: "explorer paris",
            exampleVisitingMuseum: "visiter le musée",
            exampleCoffeeShop: "café",
            characterCount: "caractères",
            situationExample1: "Commander du café dans un café animé",
            situationExample2: "Demander son chemin dans une nouvelle ville",
            situationExample3: "Faire ses courses au marché",
            situationExample4: "Prendre rendez-vous chez le médecin",
            situationExample5: "S'enregistrer dans un hôtel"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "Connexion",
            verify: "Vérifier",
            selectProfession: "Sélectionner la profession",
            username: "Nom d'utilisateur",
            phoneNumber: "Numéro de téléphone",
            guestLogin: "Connexion invité",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "De là où vous êtes à chaque temps dont vous avez besoin",
            awarenessHeading: "Conscience",
            awarenessDescription: "L'IA apprend de votre environnement",
            inputsHeading: "Entrées",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "Décomposition",
            breakdownDescription: "Locian décompose les phrases en temps, fournit des traductions mot par mot",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "Prêt",
            readyDescription: "",
            loginOrRegister: "Connexion / Inscription",
            pageIndicator: " / 6",
            tapToNavigate: "Appuyez sur le côté gauche ou droit pour naviguer",
            selectAppLanguage: "Sélectionner la langue de l'application",
            selectLanguageDescription: "Cette langue transformera l'interface utilisateur de l'application, les en-têtes, les descriptions, les boutons, les noms et tout en la langue sélectionnée"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "Annuler",
            save: "Enregistrer",
            done: "Terminé",
            ok: "OK",
            back: "Retour",
            next: "Suivant",
            continueText: "Continuer"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "Personnalisé",
            hint: "Indice",
            practiceDescription: "Appuyez sur n'importe quel mot pour le traduire dans votre langue cible. Si vous avez besoin d'aide, utilisez le bouton indice pour obtenir des suggestions.",
            practiceTitle: "Pratique",
            practiceFollowUp: "Pratique suivante",
            camera: "Appareil photo",
            cameraDescription: "Locian générera une conversation en {native} et vous pourrez vous entraîner à convertir en {target}.",
            useCamera: "Utiliser l'appareil photo",
            cameraButtonDescription: "Générer des moments depuis la photo",
            typeConversation: "Tapez une conversation",
            typeConversationDescription: "Locian générera une conversation en {native} et vous pourrez vous entraîner à convertir en {target}.",
            conversationPlaceholder: "ex. Commander du café dans un café animé",
            submit: "Envoyer",
            fullCustomText: "Texte personnalisé complet",
            examples: "Exemples:",
            conversationExample1: "Demander son chemin sous la pluie",
            conversationExample2: "Acheter des légumes tard le soir",
            conversationExample3: "Travailler dans un bureau bondé",
            describeConversation: "Décrivez la conversation que vous souhaitez que Locian crée.",
            fullTextPlaceholder: "Tapez le texte complet ou le dialogue ici...",
            startCustomPractice: "Commencer la pratique personnalisée"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Progrès",
            edit: "Modifier",
            current: "Actuel",
            longest: "Le plus long",
            lastPracticed: "Dernière pratique",
            days: "jours",
            addLanguagePairToSeeProgress: "Ajoutez une paire de langues pour voir votre progrès."
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "Mes langues"
        case .notifications: return "Notifications"
        case .aesthetics: return "Esthétique"
        case .account: return "Compte"
        case .appLanguage: return "Interface de l'application"
        
        // Common
        case .login: return "Connexion /"
        case .register: return "S'inscrire"
        case .settings: return "Paramètres"
        case .home: return "Accueil"
        case .back: return "Retour"
        case .next: return "Suivant"
        case .previous: return "Précédent"
        case .done: return "Terminé"
        case .cancel: return "Annuler"
        case .save: return "Enregistrer"
        case .delete: return "Supprimer"
        case .add: return "Ajouter"
        case .remove: return "Retirer"
        case .edit: return "Modifier"
        case .continueText: return "Continuer"
        
        // Quiz
        case .quizCompleted: return "Quiz terminé !"
        case .sessionCompleted: return "Session terminée !"
        case .masteredEnvironment: return "Vous avez maîtrisé votre environnement !"
        case .learnMoreAbout: return "En savoir plus sur"
        case .backToHome: return "Retour à l'accueil"
        case .tryAgain: return "Réessayer"
        case .shuffled: return "Mélangé"
        case .check: return "Vérifier"
        
        // Vocabulary
        case .exploreCategories: return "Explorer les catégories"
        case .testYourself: return "Testez-vous"
        case .similarWords: return "Mots similaires :"
        case .wordTenses: return "Temps des mots :"
        case .tapWordsToExplore: return "Touchez les mots pour lire leurs traductions et explorer"
        case .wordBreakdown: return "Décomposition du mot :"
        
        // Scene
        case .analyzingImage: return "Analyse de l'image..."
        case .imageAnalysisCompleted: return "Analyse d'image terminée"
        case .imageSelected: return "Image sélectionnée"
        case .placeNotSelected: return "Lieu non sélectionné"
        case .chooseLanguages: return "Choisissez des langues"
        case .locianChoose: return "Locian choisit"
        
        // Settings
        case .enableNotifications: return "Activer les notifications"
        case .thisPlace: return "ce lieu"
        case .tapOnAnySection: return "Appuyez sur n'importe quelle section ci-dessus pour afficher et gérer les paramètres"
        case .addNewLanguagePair: return "Ajouter une nouvelle paire de langues"
        case .noLanguagePairsAdded: return "Aucune paire de langues ajoutée pour le moment"
        case .setDefault: return "Définir par défaut"
        case .defaultText: return "Par défaut"
        case .user: return "Utilisateur"
        case .noPhone: return "Pas de téléphone"
        case .signOutFromAccount: return "Se déconnecter de votre compte"
        case .removeAllPracticeData: return "Supprimer toutes vos données de pratique"
        case .permanentlyDeleteAccount: return "Supprimer définitivement votre compte et toutes les données"
        case .currentLevel: return "Niveau actuel"
        case .selectPhoto: return "Sélectionner une photo"
        case .camera: return "Appareil photo"
        case .photoLibrary: return "Bibliothèque de photos"
        case .selectTime: return "Sélectionner l'heure"
        case .hour: return "Heure"
        case .minute: return "Minute"
        case .addTime: return "Ajouter l'heure"
        case .areYouSureLogout: return "Êtes-vous sûr de vouloir vous déconnecter ?"
        case .areYouSureDeleteAccount: return "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action ne peut pas être annulée."
        
        // Quiz
        case .goBack: return "Retour"
        case .fillInTheBlank: return "Remplissez le vide :"
        case .arrangeWordsInOrder: return "Classez les mots dans le bon ordre :"
        case .tapWordsBelowToAdd: return "Appuyez sur les mots ci-dessous pour les ajouter ici"
        case .availableWords: return "Mots disponibles :"
        case .correctAnswer: return "Bonne réponse :"
        
        // Common
        case .error: return "Erreur"
        case .ok: return "OK"
        case .close: return "Fermer"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "De là où vous êtes à chaque temps dont vous avez besoin"
        case .awarenessHeading: return "Conscience"
        case .awarenessDescription: return "L'IA apprend de votre environnement"
        case .inputsHeading: return "Entrées"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "Décomposition"
        case .breakdownDescription: return "Locian décompose les phrases en temps, fournit des traductions mot par mot"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "Prêt"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "Connexion / Inscription"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "Appuyez sur le côté gauche ou droit pour naviguer"
        case .selectAppLanguage: return "Sélectionner la langue de l'application"
        case .selectLanguageDescription: return "Cette langue transformera l'interface utilisateur de l'application, les en-têtes, les descriptions, les boutons, les noms et tout en la langue sélectionnée"
        
        // Login
        case .username: return "Nom d'utilisateur"
        case .phoneNumber: return "Numéro de téléphone"
        case .guestLogin: return "Connexion invité"
        case .guestLoginDescription: return "La connexion invité est destinée à la vérification et permettra à l'invité d'accéder à toutes les fonctionnalités de l'application. Sera supprimé après vérification."
        
        // Professions
        case .student: return "Étudiant"
        case .softwareEngineer: return "Ingénieur Logiciel"
        case .teacher: return "Enseignant"
        case .doctor: return "Médecin"
        case .artist: return "Artiste"
        case .businessProfessional: return "Professionnel des Affaires"
        case .salesOrMarketing: return "Ventes ou Marketing"
        case .traveler: return "Voyageur"
        case .homemaker: return "Femme au Foyer"
        case .chef: return "Chef"
        case .police: return "Police"
        case .bankEmployee: return "Employé de Banque"
        case .nurse: return "Infirmière"
        case .designer: return "Designer"
        case .engineerManager: return "Ingénieur Manager"
        case .photographer: return "Photographe"
        case .contentCreator: return "Créateur de contenu"
        case .other: return "Autre"
        
        // Scene Places
        case .lociansChoice: return "Choix de Locian"
        case .airport: return "Aéroport"
        case .cafe: return "Café"
        case .gym: return "Salle de sport"
        case .library: return "Bibliothèque"
        case .office: return "Bureau"
        case .park: return "Parc"
        case .restaurant: return "Restaurant"
        case .shoppingMall: return "Centre commercial"
        case .travelling: return "Voyage"
        case .university: return "Université"
        case .addCustomPlace: return "Ajouter un lieu personnalisé"
        case .enterCustomPlaceName: return "Entrez un nom de lieu personnalisé (30 caractères max)"
        case .maximumCustomPlaces: return "Maximum 10 lieux personnalisés"
        case .welcome: return "Bienvenue"
        case .tapToCaptureContext: return "Appuyez pour capturer votre contexte et commencer à apprendre"
        case .customSection: return "Personnalisé"
        case .examples: return "Exemples:"
        case .customPlacePlaceholder: return "par ex., voyage au bureau"
        case .exampleTravellingToOffice: return "voyage au bureau"
        case .exampleTravellingToHome: return "voyage à la maison"
        case .exampleExploringParis: return "explorer paris"
        case .exampleVisitingMuseum: return "visiter le musée"
        case .exampleCoffeeShop: return "café"
        case .characterCount: return "caractères"
        
        // Settings Modal Strings
        case .nativeLanguage: return "Langue maternelle:"
        case .selectNativeLanguage: return "Sélectionnez votre langue maternelle"
        case .targetLanguage: return "Langue cible:"
        case .selectTargetLanguage: return "Sélectionnez la langue que vous souhaitez apprendre"
        case .nativeLanguageDescription: return "Votre langue maternelle est la langue que vous pouvez lire, écrire et parler couramment. C'est la langue avec laquelle vous êtes le plus à l'aise."
        case .targetLanguageDescription: return "Votre langue cible est la langue que vous souhaitez apprendre et pratiquer. Choisissez la langue dans laquelle vous souhaitez améliorer vos compétences."
        case .addPair: return "Ajouter la paire"
        case .adding: return "Ajout en cours..."
        case .failedToAddLanguagePair: return "Échec de l'ajout de la paire de langues. Veuillez réessayer."
        case .settingAsDefault: return "Définition par défaut..."
        case .beginner: return "Débutant"
        case .intermediate: return "Intermédiaire"
        case .advanced: return "Avancé"
        case .currentlyLearning: return "En cours d'apprentissage"
        case .otherLanguages: return "Autres langues"
        case .learnNewLanguage: return "Apprendre une nouvelle langue"
        case .learn: return "Apprendre"
        case .tapToSelectNativeLanguage: return "Appuyez pour sélectionner votre langue maternelle"
        case .neonGreen: return "Vert Néon"
        
        // Theme color names
        case .cyanMist: return "Brum Cyan"
        case .violetHaze: return "Brume Violette"
        case .softPink: return "Rose Doux"
        case .pureWhite: return "Blanc Pur"
        
        // Quick Look
        case .quickRecall: return "Rappel rapide"
        case .startQuickPuzzle: return "Démarrer le puzzle rapide"
        case .stopPuzzle: return "Arrêter le puzzle"
        
        // Streak
        case .streak: return "Série"
        case .dayStreak: return "jour de série"
        case .daysStreak: return "jours de série"
        case .editYourStreaks: return "Modifier vos séries"
        case .editStreaks: return "Modifier les séries"
        case .selectDatesToAddOrRemove: return "Sélectionnez les dates pour ajouter ou supprimer des jours de pratique"
        case .saving: return "Enregistrement..."
        }
    }
}

