//
//  SpanishStrings.swift
//  locian
//

import Foundation

struct SpanishStrings: AppStrings, LocalizedStrings {
    
    var ui: UIStrings {
        UIStrings(
            camera: "Cámara",
            gallery: "Galería",
            nextUp: "Siguiente",
            historyLog: "Registro de Historial",

            moments: "Momentos",
            pastMoments: "Momentos Pasados",
            noHistory: "Sin Historial",
            generatingHistory: "Generando Historial",
            generatingMoments: "GENERANDO...",
            analyzingImage: "ANÁLISIS DE IMAGEN...",
            tapNextUpToGenerate: "Toca Siguiente para Generar",
            noUpcomingPlaces: "Sin Lugares Próximos",
            noDetails: "Sin Detalles",
            callingAI: "Calling AI...",
            preparingLesson: "Preparing your lesson...",

            startLearning: "Empezar a Aprender",
            continueLearning: "Continuar Aprendiendo",
            noPastMoments: "Sin Momentos Pasados",
            useCamera: "Usar Cámara",
            previouslyLearning: "Aprendiendo Anteriormente",
            sunShort: "Dom",
            monShort: "Lun",
            tueShort: "Mar",
            wedShort: "Mié",
            thuShort: "Jue",
            friShort: "Vie",
            satShort: "Sáb",
            login: "Iniciar Sesión",
            register: "Registrarse",
            settings: "Ajustes",
            back: "Atrás",
            done: "Hecho",
            cancel: "Cancelar",
            save: "Guardar",
            delete: "Eliminar",
            add: "Añadir",
            remove: "Quitar",
            edit: "Editar",
            error: "Error",
            ok: "OK",
            welcomeLabel: "Bienvenido",
            currentStreak: "RACHA_ACTUAL",
            notSet: "No establecido",
            learnTab: "Aprender",
            addTab: "Añadir",
            progressTab: "Progreso",
            settingsTab: "Ajustes",
            loading: "Cargando...",
            unknownPlace: "Lugar desconocido",
            noLanguageAvailable: "No hay idiomas disponibles",
            noInternetConnection: "Sin conexión a internet",
            retry: "Reintentar",
            tapToGetMoments: "Toca para obtener momentos",
            startLearningThisMoment: "Empieza a aprender ahora",
            daysLabel: "DÍAS",
            noNewPlace: "Añadir nuevo lugar",
            addNewPlaceInstruction: "Add a new place to get moments",
            start: "Empezar",
            typeYourMoment: "Escribe tu momento...",
            imagesLabel: "IMÁGENES",
            routinesLabel: "RUTINAS",
            whatAreYouDoing: "Qué estás haciendo ahora?",
            chooseContext: "Elige un contexto para empezar a aprender",
            typeHere: "ESCRIBE AQUÍ",
            nearbyLabel: "CERCANO",
            noNearbyPlaces: "No se encontraron lugares cercanos")
    }

    var settings: SettingsStrings {
        SettingsStrings(
            systemLanguage: "Interfaz de la Aplicación",
            targetLanguages: "Idiomas Objetivo",
            pastLanguagesArchived: "Aprendiendo Anteriormente",
            theme: "Tema",
            notifications: "Notificaciones",
            account: "Cuenta",
            profile: "Perfil",
            addLanguagePair: "Agregar Par de Idiomas",
            logout: "Cerrar Sesión",
            deleteAllData: "Eliminar Todos los Datos",
            deleteAccount: "Eliminar Cuenta Permanentemente",
            selectLevel: "Seleccionar Nivel",
            proFeatures: "Funciones Pro",
            showSimilarWordsToggle: "Mostrar Palabras Similares",
            nativeLanguage: "Idioma Nativo",
            selectNativeLanguage: "Seleccionar Idioma Nativo",
            targetLanguage: "Idioma Objetivo",
            selectTargetLanguage: "Seleccionar Idioma Objetivo",
            targetLanguageDescription: "Idioma que quieres aprender",
            beginner: "Principiante",
            intermediate: "Intermedio",
            advanced: "Avanzado",
            currentlyLearning: "Aprendiendo Actualmente",
            learnNewLanguage: "Aprender Nuevo Idioma",
            learn: "Aprender",
            neonGreen: "Verde Neón",
            neonFuchsia: "Fucsia neón",
            electricIndigo: "Índigo eléctrico",
            graphiteBlack: "Negro grafito",
            student: "Estudiante",
            softwareEngineer: "Ingeniero de Software",
            teacher: "Profesor",
            doctor: "Médico",
            artist: "Artista",
            businessProfessional: "Profesional de Negocios",
            salesOrMarketing: "Ventas o Marketing",
            traveler: "Viajero",
            homemaker: "Ama/o de Casa",
            chef: "Chef",
            police: "Policía",
            bankEmployee: "Empleado Bancario",
            nurse: "Enfermero/a",
            designer: "Diseñador",
            engineerManager: "Gerente de Ingeniería",
            photographer: "Fotógrafo",
            contentCreator: "Creador de Contenido",
            entrepreneur: "Emprendedor",
            other: "Otro",
            otherPlaces: "Otros Lugares",
            speaks: "Habla (Nativo)",
            neuralEngine: "Motor Neuronal",
            noLanguagePairsAdded: "Sin Pares de Idiomas Añadidos",
            setDefault: "Establecer como Predeterminado",
            defaultText: "Predeterminado",
            user: "Usuario",
            signOutFromAccount: "Cerrar Sesión de la Cuenta",
            permanentlyDeleteAccount: "Eliminar Cuenta Permanentemente",
            languageAddedSuccessfully: "Idioma añadido con éxito",
            failedToAddLanguage: "Error al añadir el idioma. Inténtalo de nuevo.",
            pleaseSelectLanguage: "Por favor, selecciona un idioma",
            systemConfig: "SISTEMA // CONFIG",
            currentLevel: "Nivel Actual",
            selectPhoto: "Seleccionar Foto",
            camera: "Cámara",
            photoLibrary: "Fototeca",
            selectTime: "Seleccionar Hora",
            hour: "Hora",
            minute: "Minuto",
            addTime: "Añadir Hora",
            location: "Ubicación",
            diagnosticBorders: "Bordes de Diagnóstico",
            areYouSureLogout: "¿Estás seguro de que quieres cerrar sesión?",
            areYouSureDeleteAccount: "¿Estás seguro de que deseas eliminar permanentemente tu cuenta? Esta acción no se puede deshacer.")
    }

    var login: LoginStrings {
        LoginStrings(
            login: "Iniciar Sesión",
            verify: "Verificar",
            selectProfession: "Seleccionar Profesión",
            selectUserProfession: "SELECT_USER_PROFESSION",
            username: "Nombre de Usuario",
            phoneNumber: "Número de Teléfono",
            guestLogin: "Inicio de Sesión como Invitado",
            selectProfessionInstruction: "Selecciona tu profesión para empezar",
            showMore: "Mostrar más",
            showLess: "Mostrar menos",
            forReview: "[Para revisión]",
            authenticatingUser: "AUTHENTICATING_USER...",
            bySigningInYouAgreeToOur: "By signing in, you agree to our",
            termsOfService: "TERMS_OF_SERVICE",
            privacyPolicy: "PRIVACY_POLICY"
        )
    }

    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "Aprende idiomas naturalmente a través de tu vida diaria",
            awarenessHeading: "Conciencia",
            awarenessDescription: "Nota las palabras a tu alrededor en tiempo real",
            breakdownHeading: "Desglose",
            breakdownDescription: "Entiende cómo se construyen las palabras",
            progressHeading: "Progreso",
            progressDescription: "Sigue tu viaje de aprendizaje",
            readyHeading: "Listo",
            readyDescription: "Empieza a aprender ahora",
            loginOrRegister: "Iniciar Sesión o Registrarse",
            pageIndicator: "Página",
            selectLanguageDescription: "Seleccione su idioma preferido",
            whichLanguageDoYouSpeakComfortably: "¿QUÉ IDIOMA HABLAS CÓMODAMENTE?",
            chooseTheLanguageYouWantToMaster: "ELIGE EL IDIOMA QUE QUIERES DOMINAR HOY",
            fromWhereYouStand: "DESDE DONDE\nESTÁS",
            toEveryWord: "A",
            everyWord: "CADA PALABRA",
            youNeed: "TÚ NECESITAS",
            lessonEngine: "MOTOR_LECCIÓN",
            nodesLive: "NODOS_ACTIVOS",
            locEngineVersion: "LOC_ENGINE_V2.0.4",
            holoGridActive: "RED_HOLO_ACTIVA",
            adaCr02: "ADA_CR-02",
            your: "TUS",
            places: "LUGARES,",
            lessons: "LECCIONES.",
            yourPlaces: "TUS LUGARES,",
            yourLessons: " TUS LECCIONES.",
            nearbyCafes: "¿Cafés cercanos?",
            unlockOrderFlow: " Desbloquear pedidos",
            modules: "módulos",
            activeHubs: "¿Hubs activos?",
            synthesizeGym: " Sintetizar gimnasio",
            vocabulary: "vocabulario",
            locationOpportunity: "Cada lugar se convierte en una oportunidad de aprendizaje",
            module03: "MÓDULO_03",
            notJustMemorization: "NO SOLO\nMEMORIZACIÓN",
            philosophy: "FILOSOFÍA",
            locianTeaches: "Locian no solo enseña palabras.\nLocian te enseña a ",
            think: "PENSAR",
            inTargetLanguage: "en tu idioma objetivo.",
            patternBasedLearning: "APRENDIZAJE DE PATRONES",
            patternBasedDesc: "Reconoce estructuras gramaticales intuitivamente sin reglas secas.",
            situationalIntelligence: "INTELIGENCIA SITUACIONAL",
            situationalDesc: "Escenarios dinámicos que se adaptan a tu entorno e historial.",
            adaptiveDrills: "EJERCICIOS ADAPTATIVOS",
            adaptiveDesc: "El Motor de Lecciones identifica tus debilidades y se recalibra.",
            systemReady: "SISTEMA_LISTO",
            quickSetup: "CONFIG_RÁPIDA",
            levelB2: "NIVEL_B2",
            authorized: "AUTORIZADO",
            notificationsPermission: "NOTIFICACIONES",
            notificationsDesc: "Recibe actualizaciones en tiempo real sobre prácticas cercanas y alertas de racha.",
            microphonePermission: "MICRÓFONO",
            microphoneDesc: "Esencial para la puntuación de pronunciación e interacciones en contextos reales.",
            geolocationPermission: "GEOLOCALIZACIÓN",
            geolocationDesc: "Identifica \"Zonas de Lección\" cercanas como cafeterías para práctica inmersiva.",
            granted: "CONCEDIDO",
            allow: "PERMITIR",
            skip: "SALTAR",
            letsStart: "EMPECEMOS",
            continueText: "CONTINUAR",
            wordTenses: "Tiempos:",
            similarWords: "Palabras similares:",
            wordBreakdown: "Desglose de palabras:",
            consonant: "Consonante",
            vowel: "Vocal",
            past: "Pasado",
            present: "Presente",
            future: "Futuro",
            learnWord: "Aprender")
    }

    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Progreso",
            current: "Actual",
            longest: "Más Largo",
            lastPracticed: "Última Práctica",
            days: "Días",
            addLanguagePairToSeeProgress: "Agrega un par de idiomas para ver tu progreso",
            startPracticingMessage: "Comienza a practicar para construir tu racha",
            consistencyQuote: "La consistencia es clave para aprender idiomas",
            practiceDateSavingDisabled: "El guardado de fechas de práctica está deshabilitado",
            editYourStreaks: "Editar Tus Rachas",
            editStreaks: "Editar Rachas",
            selectDatesToAddOrRemove: "Selecciona fechas para agregar o eliminar de tu racha",
            saving: "Guardando",
            statusOnFire: "Estado: En Llamas",
            youPracticed: "Practicaste ",
            yesterday: " ayer.",
            checkInNow: "Registrarse Ahora",
            nextGoal: "Próximo Objetivo",
            reward: "Recompensa",
            historyLogProgress: "Registro Historial",
            streakStatus: "Estado de Racha",
            streakLog: "Registro de Racha",
            consistency: "Consistencia",
            consistencyHigh: "Tu registro de actividad muestra un alto compromiso.",
            consistencyMedium: "Estás creando un buen impulso.",
            consistencyLow: "La consistencia es clave. Sigue avanzando.",
            reachMilestone: "¡Intenta llegar a %d días!",
            nextMilestone: "Próximo Hito",
            actionRequired: "Acción Requerida",
            logActivity: "Registrar Actividad",
            maintainStreak: "Maintain Streak",
            manualEntry: "Manual Entry",
            longestStreakLabel: "Racha Más Larga",
            streakData: "DATOS DE LA RACHA",
            activeLabel: "ACTIVO",
            missedLabel: "PERDIDO",
            saveChanges: "GUARDAR CAMBIOS",
            discardChanges: "RECHAZAR CAMBIOS",
            editLabel: "EDITAR",
            // Advanced Stats
            skillBalance: "EQUILIBRIO DE HABILIDADES",
            fluencyVelocity: "VELOCIDAD DE FLUIDEZ",
            vocabVault: "BÓVEDA DE VOCABULARIO",
            chronotype: "CRONOTIPO",
            activityDistribution: "DISTRIBUCIÓN DE ACTIVIDAD (24H)",
            studiedTime: "TIEMPO ESTUDIADO",
            currentLabel: "ACTUAL",
            streakLabel: "RACHA",
            longestLabel: "RÉCORD",
            earlyBird: "MADRUGADOR",
            earlyBirdDesc: "Más activo por la mañana",
            dayWalker: "CAMINANTE DIURNO",
            dayWalkerDesc: "Más activo por la tarde",
            nightOwl: "BÚHO NOCTURNO",
            nightOwlDesc: "Más activo después de anochecer",
            timeMastery: "MAESTRÍA DEL TIEMPO",
            wordsMastered: "Words Mastered",
            patternsMastered: "Patterns Active",
            avgResponseTime: "Avg Response Time",
            patternGalaxy: "PATTERN GALAXY")
    }

    var quiz: QuizStrings {
        QuizStrings(            loading: "Cargando...",
            adaptiveQuiz: "Cuestionario adaptativo",
            adaptiveQuizDescription: "Primero mostramos una traducción incorrecta y luego la correcta.",
            wordCheck: "Verificación de palabras",
            wordCheckDescription: "Las fichas se mezclan y luego encajan para confirmar la palabra.",
            wordCheckExamplePrompt: "Toca las letras para ordenar la palabra correctamente.",
            quizPrompt: "Elige la traducción correcta para la palabra.",
            answerConfirmation: "¡Has construido la palabra correcta!",
            tryAgain: "¡Uy! Inténtalo de nuevo.")
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
