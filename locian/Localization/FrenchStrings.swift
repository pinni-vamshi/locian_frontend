//
//  FrenchStrings.swift
//  locian
//

import Foundation

struct FrenchStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "Caméra",
            gallery: "Galerie",
            nextUp: "À Venir",
            historyLog: "Journal d'Historique",

            moments: "Moments",
            pastMoments: "Moments Passés",
            noHistory: "Aucun Historique",
            generatingHistory: "Génération de l'Historique",
            generatingMoments: "GÉNÉRATION...",
            analyzingImage: "ANALYSE D'IMAGE...",
            tapNextUpToGenerate: "Appuyez sur À Venir pour Générer",
            noUpcomingPlaces: "Aucun Endroit à Venir",
            noDetails: "Aucun Détail",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "Commencer à Apprendre",
            continueLearning: "Continuer à Apprendre",
            noPastMoments: "Aucun Moment Passé",
            useCamera: "Utiliser la Caméra",
            previouslyLearning: "Apprentissage Précédent",
            sunShort: "Dim",
            monShort: "Lun",
            tueShort: "Mar",
            wedShort: "Mer",
            thuShort: "Jeu",
            friShort: "Ven",
            satShort: "Sam",
            login: "Connexion",
            register: "S'inscrire",
            settings: "Réglages",
            back: "Retour",
            done: "Terminé",
            cancel: "Annuler",
            save: "Enregistrer",
            delete: "Supprimer",
            add: "Ajouter",
            remove: "Retirer",
            edit: "Modifier",
            error: "Erreur",
            ok: "OK",
            welcomeLabel: "Bienvenue",
            currentStreak: "SÉRIE_ACTUELLE",
            notSet: "Non défini",
            learnTab: "Apprendre",
            addTab: "Ajouter",
            progressTab: "Progrès",
            settingsTab: "Réglages",
            loading: "Chargement...",
            unknownPlace: "Lieu inconnu",
            noLanguageAvailable: "Aucun langage disponible",
            noInternetConnection: "Pas de connexion internet",
            retry: "Réessayer",
            tapToGetMoments: "Appuyez pour les moments",
            startLearningThisMoment: "Commencer à apprendre",
            daysLabel: "JOURS",
            noNewPlace: "Ajouter un lieu",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "Démarrer",
            typeYourMoment: "Tapez votre moment...",
            imagesLabel: "IMAGES",
            routinesLabel: "ROUTINES",
            whatAreYouDoing: "Que faites-vous maintenant ?",
            chooseContext: "Choisissez un contexte pour commencer",
            typeHere: "ÉCRIVEZ ICI",
            nearbyLabel: "À PROXIMITÉ",
            noNearbyPlaces: "{noNearby}",
            addRoutine: "Ajouter une Routine",
            tapToSetup: "Appuyez pour Configurer",
            tapToStartLearning: "Appuyez pour Commencer à Apprendre")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "Interface de l'Application",
            targetLanguages: "Langues Cibles",
            pastLanguagesArchived: "Apprentissage Précédent",
            theme: "Thème",
            notifications: "Notifications",
            account: "Compte",
            profile: "Profil",
            addLanguagePair: "Ajouter une Paire de Langues",
            logout: "Déconnexion",
            deleteAllData: "Supprimer Toutes les Données",
            deleteAccount: "Supprimer Définitivement le Compte",
            selectLevel: "Sélectionner le Niveau",
            proFeatures: "Fonctionnalités Pro",
            showSimilarWordsToggle: "Afficher les Mots Similaires",
            nativeLanguage: "Langue Maternelle",
            selectNativeLanguage: "Sélectionner la Langue Maternelle",
            targetLanguage: "Langue Cible",
            selectTargetLanguage: "Sélectionner la Langue Cible",
            targetLanguageDescription: "Langue que vous voulez apprendre",
            beginner: "Débutant",
            intermediate: "Intermédiaire",
            advanced: "Avancé",
            currentlyLearning: "Apprentissage en Cours",
            learnNewLanguage: "Apprendre une Nouvelle Langue",
            learn: "Apprendre",
            neonGreen: "Vert Néon",
            neonFuchsia: "Fuchsia néon",
            electricIndigo: "Indigo électrique",
            graphiteBlack: "Noir graphite",
            student: "Étudiant",
            softwareEngineer: "Ingénieur Logiciel",
            teacher: "Enseignant",
            doctor: "Médecin",
            artist: "Artiste",
            businessProfessional: "Professionnel d'Affaires",
            salesOrMarketing: "Ventes ou Marketing",
            traveler: "Voyageur",
            homemaker: "Ménagère/Ménager",
            chef: "Chef",
            police: "Police",
            bankEmployee: "Employé de Banque",
            nurse: "Infirmière/Infirmier",
            designer: "Designer",
            engineerManager: "Ingénieur Manager",
            photographer: "Photographe",
            contentCreator: "Créateur de Contenu",
            entrepreneur: "Entrepreneur",
            other: "Autre",
            otherPlaces: "Autres Lieux",
            speaks: "Parle",
            neuralEngine: "Moteur Neuronal",
            noLanguagePairsAdded: "Aucune Paire de Langues Ajoutée",
            setDefault: "Définir par Défaut",
            defaultText: "Par Défaut",
            user: "Utilisateur",
            signOutFromAccount: "Se Déconnecter du Compte",
            permanentlyDeleteAccount: "Supprimer Définitivement le Compte",
            languageAddedSuccessfully: "Langue ajoutée avec succès",
            failedToAddLanguage: "Échec de l'ajout de la langue. Veuillez réessayer.",
            pleaseSelectLanguage: "Veuillez sélectionner une langue",
            systemConfig: "SYSTÈME // CONFIG",
            currentLevel: "Niveau Actuel",
            selectPhoto: "Sélectionner une Photo",
            camera: "Caméra",
            photoLibrary: "Photothèque",
            selectTime: "Sélectionner l'Heure",
            hour: "Heure",
            minute: "Minute",
            addTime: "Ajouter l'Heure",
            location: "Localisation",
            diagnosticBorders: "Bordures de Diagnostic",
            areYouSureLogout: "Êtes-vous sûr de vouloir vous déconnecter ?",
            areYouSureDeleteAccount: "Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.",
            
            // Personalization Refresh
            refreshHeading: "ACTUALISER",
            refreshSubheading: "CONTEXTE UTILISATEUR // ÉVOLUER",
            refreshDescription: "Vos moments deviennent plus personnalisés avec le temps en fonction de votre pratique.",
            refreshButton: "METTRE À JOUR LA PERSONALISATION")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "Connexion",
            verify: "Vérifier",
            selectProfession: "Sélectionner la Profession",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "Nom d'Utilisateur",
            phoneNumber: "Numéro de Téléphone",
            guestLogin: "Connexion Invité",
            selectProfessionInstruction: "Sélectionnez votre profession",
            showMore: "Voir plus",
            showLess: "Voir moins",
            forReview: "[Pour révision]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "Apprenez les langues naturellement à travers votre vie quotidienne",
            awarenessHeading: "Conscience",
            awarenessDescription: "Remarquez les mots autour de vous en temps réel",
            breakdownHeading: "Analyse",
            breakdownDescription: "Comprenez comment les mots sont construits",
            progressHeading: "Progrès",
            progressDescription: "Suivez votre parcours d'apprentissage",
            readyHeading: "Prêt",
            readyDescription: "Commencez à apprendre maintenant",
            loginOrRegister: "Connexion ou Inscription",
            pageIndicator: "Page",
            selectLanguageDescription: "Sélectionnez votre langue préférée",
            whichLanguageDoYouSpeakComfortably: "QUELLE LANGUE PARLEZ-VOUS CONFORTABLEMENT?",
            chooseTheLanguageYouWantToMaster: "CHOISISSEZ LA LANGUE QUE VOUS VOULEZ MAÎTRISER AUJOURD'HUI",

            fromWhereYouStand: "D'OÙ VOUS\nÊTES",
            toEveryWord: "À",
            everyWord: "CHAQUE MOT",
            youNeed: "VOUS DEVEZ",
            lessonEngine: "MOTEUR_LEÇON",
            nodesLive: "NOEUDS_ACTIFS",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "GRILLE_HOLO_ACTIVE",
            adaCr02: "ADA_CR-02",
            your: "VOS",
            places: "LIEUX,",
            lessons: "LEÇONS.",
            yourPlaces: "VOS LIEUX,",
            yourLessons: " VOS LEÇONS.",
            nearbyCafes: "Cafés à proximité ?",
            unlockOrderFlow: " Débloquer commande",
            modules: "modules",
            activeHubs: "Hubs actifs ?",
            synthesizeGym: " Synthétiser salle de sport",
            vocabulary: "vocabulaire",
            locationOpportunity: "Chaque lieu devient une opportunité d'apprentissage",
            module03: "MODULE_03",
            notJustMemorization: "PAS SEULEMENT\nLA MÉMORISATION",
            philosophy: "PHILOSOPHIE",
            locianTeaches: "Locian n'enseigne pas seulement des mots.\nLocian vous apprend à ",
            think: "PENSER",
            inTargetLanguage: "dans votre langue cible.",
            patternBasedLearning: "APPRENTISSAGE PAR MODÈLES",
            patternBasedDesc: "Reconnaissez les structures grammaticales intuitivement sans règles arides.",
            situationalIntelligence: "INTELLIGENCE SITUATIONNELLE",
            situationalDesc: "Scénarios dynamiques qui s'adaptent à votre environnement et à votre historique.",
            adaptiveDrills: "EXERCICES ADAPTATIFS",
            adaptiveDesc: "Le moteur de leçon identifie vos faiblesses et se recalibre.",
            systemReady: "SYSTÈME_PRÊT",
            quickSetup: "CONFIG_RAPIDE",
            levelB2: "NIVEAU_B2",
            authorized: "AUTORISÉ",
            notificationsPermission: "NOTIFICATIONS",
            notificationsDesc: "Obtenez des mises à jour en temps réel sur les opportunités de pratique et les alertes de série.",
            microphonePermission: "MICROPHONE",
            microphoneDesc: "Essentiel pour la notation de la prononciation et les interactions en contexte réel.",
            geolocationPermission: "GÉOLOCALISATION",
            geolocationDesc: "Identifiez les \"Zones de Leçon\" à proximité comme les cafés pour une pratique immersive.",
            granted: "ACCORDÉ",
            allow: "AUTORISER",
            skip: "PASSER",
            letsStart: "COMMENÇONS",
            continueText: "CONTINUER",
            wordTenses: "Temps verbaux :",
            similarWords: "Mots similaires :",
            wordBreakdown: "Analyse du mot :",
            consonant: "Consonne",
            vowel: "Voyelle",
            past: "Passé",
            present: "Présent",
            future: "Futur",
            learnWord: "Apprendre")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Progrès",
            current: "Actuel",
            longest: "Le Plus Long",
            lastPracticed: "Dernière Pratique",
            days: "Jours",
            addLanguagePairToSeeProgress: "Ajoutez une paire de langues pour voir vos progrès",
            startPracticingMessage: "Commencez à pratiquer pour construire votre série",
            consistencyQuote: "La cohérence est la clé de l'apprentissage des langues",
            practiceDateSavingDisabled: "L'enregistrement des dates de pratique est désactivé",
            editYourStreaks: "Modifier Vos Séries",
            editStreaks: "Modifier les Séries",
            selectDatesToAddOrRemove: "Sélectionnez les dates à ajouter ou supprimer de votre série",
            saving: "Enregistrement",
            statusOnFire: "Statut : En Feu",
            youPracticed: "Vous avez pratiqué ",
            yesterday: " hier.",
            checkInNow: "Se Signaler Maintenant",
            nextGoal: "Prochain Objectif",
            reward: "Récompense",
            historyLogProgress: "Journal d'historique",
            streakStatus: "Statut de série",
            streakLog: "Journal de série",
            consistency: "Cohérence",
            consistencyHigh: "Votre journal d'activité montre un fort engagement.",
            consistencyMedium: "Vous créez un bon élan.",
            consistencyLow: "La cohérence est la clé. Continuez à pousser.",
            reachMilestone: "Essayez d'atteindre %d jours !",
            nextMilestone: "Prochain jalon",
            actionRequired: "Action requise",
            logActivity: "Enregistrer l'activité",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "Plus longue série",
            streakData: "DONNÉES DE SÉRIE",
            activeLabel: "ACTIF",
            missedLabel: "MANQUÉ",
            saveChanges: "ENREGISTRER",
            discardChanges: "ABANDONNER",
            editLabel: "MODIFIER",
            // Advanced Stats
            skillBalance: "ÉQUILIBRE DES COMPÉTENCES",
            fluencyVelocity: "VÉLOCITÉ DE FLUIDITÉ",
            vocabVault: "COFFRE DE VOCABULAIRE",
            chronotype: "CHRONOTYPE",
            activityDistribution: "DISTRIBUTION DE L'ACTIVITÉ (24H)",
            studiedTime: "TEMPS ÉTUDIÉ",
            currentLabel: "ACTUELLE",
            streakLabel: "SÉRIE",
            longestLabel: "RECORD",
            earlyBird: "LÈVE-TÔT",
            earlyBirdDesc: "Plus actif le matin",
            dayWalker: "MARCHEUR DE JOUR",
            dayWalkerDesc: "Plus actif l'après-midi",
            nightOwl: "HIBOU NOCTURNE",
            nightOwlDesc: "Plus actif après la tombée de la nuit",
            timeMastery: "MAÎTRISE DU TEMPS",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "Chargement...",
            adaptiveQuiz: "Quiz adaptatif",
            adaptiveQuizDescription: "Nous affichons d'abord une erreur, puis le mot correct.",
            wordCheck: "Vérification de mots",
            wordCheckDescription: "Les tuiles se mélangent puis s'assemblent pour confirmer le mot.",
            wordCheckExamplePrompt: "Appuyez sur les lettres pour ordonner le mot correctement.",
            quizPrompt: "Choisissez la bonne traduction pour le mot.",
            answerConfirmation: "Vous avez construit le mot correct !",
            tryAgain: "Oups ! Réessayez.")
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
        case .smartNotificationExactPlace: return "Si vous êtes à %@, lisez à propos de cet endroit !"
        }
    }
}
