//
//  SpanishStrings.swift
//  locian
//
//  Spanish localization strings
//

import Foundation

struct SpanishStrings: AppStrings, LocalizedStrings {
    var quiz: QuizStrings {
        QuizStrings(
            completed: "¡Quiz completado!",
            masteredEnvironment: "¡Has dominado tu entorno!",
            learnMoreAbout: "Aprende más sobre",
            backToHome: "Volver al inicio",
            next: "Siguiente",
            previous: "Anterior",
            check: "Verificar",
            tryAgain: "Intentar de nuevo",
            shuffled: "Mezclado",
            noQuizAvailable: "No hay quiz disponible",
            question: "Pregunta",
            correct: "Correcto",
            incorrect: "Incorrecto",
            notAttempted: "No intentado"
        )
    }
    
    var settings: SettingsStrings {
        SettingsStrings(
            languagePairs: "Mis idiomas",
            notifications: "Notificaciones",
            appearance: "Estética",
            account: "Cuenta",
            profile: "Perfil",
            addLanguagePair: "Agregar par de idiomas",
            enableNotifications: "Activar notificaciones",
            logout: "Cerrar sesión",
            deleteAllData: "Eliminar todos los datos",
            deleteAccount: "Eliminar cuenta",
            selectLevel: "Seleccionar nivel",
            selectAppLanguage: "Interfaz de la aplicación",
            proFeatures: "Herramientas avanzadas",
            showSimilarWordsToggle: "Mostrar palabras similares",
            showWordTensesToggle: "Mostrar tiempos verbales",
            nativeLanguage: "Idioma nativo:",
            selectNativeLanguage: "Seleccione su idioma nativo",
            targetLanguage: "Idioma objetivo:",
            selectTargetLanguage: "Seleccione el idioma que desea aprender",
            nativeLanguageDescription: "Su idioma nativo es el idioma que puede leer, escribir y hablar con fluidez. Este es el idioma con el que se siente más cómodo.",
            targetLanguageDescription: "Su idioma objetivo es el idioma que desea aprender y practicar. Elija el idioma en el que desea mejorar sus habilidades.",
            addPair: "Agregar par",
            adding: "Agregando...",
            failedToAddLanguagePair: "Error al agregar el par de idiomas. Por favor, inténtelo de nuevo.",
            settingAsDefault: "Estableciendo como predeterminado...",
            beginner: "Principiante",
            intermediate: "Intermedio",
            advanced: "Avanzado",
            currentlyLearning: "Aprendiendo",
            otherLanguages: "Otros idiomas",
            learnNewLanguage: "Aprender nuevo idioma",
            learn: "Aprender",
            tapToSelectNativeLanguage: "Toca para seleccionar tu idioma nativo",
            neonGreen: "Verde Neón",
            cyanMist: "Niebla Cian",
            violetHaze: "Bruma Violeta",
            softPink: "Rosa Suave",
            pureWhite: "Blanco Puro"
        )
    }
    
    var vocabulary: VocabularyStrings {
        VocabularyStrings(
            exploreCategories: "Explorar categorías",
            testYourself: "Pruébate a ti mismo",
            slideToStartQuiz: "Desliza para iniciar el quiz",
            similarWords: "Palabras similares",
            wordTenses: "Tiempos verbales",
            wordBreakdown: "Desglose de palabras",
            tapToSeeBreakdown: "Toca la palabra para ver el desglose",
            tapToHideBreakdown: "Toca la palabra para ocultar el desglose",
            tapWordsToExplore: "Toca las palabras para leer sus traducciones y explorar",
            loading: "Cargando...",
            learnTheWord: "Aprender la palabra",
            tryFromMemory: "Intentar de memoria",
            adjustingTo: "Ajuste",
            settingPlace: "Configuración",
            settingTime: "Configuración",
            generatingVocabulary: "Generación",
            analyzingVocabulary: "Análisis",
            analyzingCategories: "Análisis",
            analyzingWords: "Análisis",
            creatingQuiz: "Creación",
            organizingContent: "Organización",
            to: "a",
            place: "lugar",
            time: "tiempo",
            vocabulary: "vocabulario",
            your: "tu",
            interested: "interesado",
            categories: "categorías",
            words: "palabras",
            quiz: "cuestionario",
            content: "contenido"
        )
    }
    
    var scene: SceneStrings {
        SceneStrings(
            hi: "Hola,",
            learnFromSurroundings: "Aprende de tu entorno",
            learnFromSurroundingsDescription: "Captura tu entorno y aprende vocabulario de contextos del mundo real",
            locianChoosing: "eligiendo...",
            chooseLanguages: "Elige idiomas",
            continueWith: "Continuar con lo que Locian eligió",
            slideToLearn: "Desliza para aprender",
            recommended: "Recomendado",
            intoYourLearningFlow: "A tu flujo de aprendizaje",
            intoYourLearningFlowDescription: "Lugares recomendados para practicar basados en tu historial de aprendizaje",
            customSituations: "Tus situaciones personalizadas",
            customSituationsDescription: "Crea y practica con tus propios escenarios de aprendizaje personalizados",
            max: "Máx",
            recentPlacesTitle: "Tus lugares recientes",
            allPlacesTitle: "Todos los lugares",
            recentPlacesEmpty: "Genera vocabulario para ver sugerencias aquí.",
            showMore: "Mostrar más",
            showLess: "Mostrar menos",
            takePhoto: "Tomar foto",
            chooseFromGallery: "Elegir de la galería",
            letLocianChoose: "DEJAR QUE LOCIAN ELIJA",
            lociansChoice: "Por Locian",
            cameraTileDescription: "Esta foto analiza tu entorno y te muestra momentos para aprender.",
            airport: "Aeropuerto",
            aquarium: "Acuario",
            bakery: "Panadería",
            beach: "Playa",
            bookstore: "Librería",
            cafe: "Café",
            cinema: "Cine",
            gym: "Gimnasio",
            hospital: "Hospital",
            hotel: "Hotel",
            home: "Casa",
            library: "Biblioteca",
            market: "Mercado",
            museum: "Museo",
            office: "Oficina",
            park: "Parque",
            restaurant: "Restaurante",
            shoppingMall: "Centro comercial",
            stadium: "Estadio",
            supermarket: "Supermercado",
            temple: "Templo",
            travelling: "Viajando",
            university: "Universidad",
            addCustomPlace: "Agregar lugar personalizado",
            addPlace: "Agregar lugar",
            enterCustomPlaceName: "Ingrese un nombre de lugar personalizado (máximo 30 caracteres)",
            maximumCustomPlaces: "Máximo 10 lugares personalizados",
            welcome: "Bienvenido",
            user: "Usuario",
            tapToCaptureContext: "Toca para capturar tu contexto y comenzar a aprender",
            customSection: "Personalizado",
            examples: "Ejemplos:",
            customPlacePlaceholder: "ej., viaje a la oficina",
            exampleTravellingToOffice: "viaje a la oficina",
            exampleTravellingToHome: "viaje a casa",
            exampleExploringParis: "explorar parís",
            exampleVisitingMuseum: "visitar museo",
            exampleCoffeeShop: "cafetería",
            characterCount: "caracteres",
            situationExample1: "Pedir café en un café concurrido",
            situationExample2: "Pedir direcciones en una ciudad nueva",
            situationExample3: "Comprar comestibles en el mercado",
            situationExample4: "Hacer una cita con el médico",
            situationExample5: "Registrarse en un hotel"
        )
    }
    
    var login: LoginStrings {
        LoginStrings(
            login: "Iniciar sesión",
            verify: "Verificar",
            selectProfession: "Seleccionar profesión",
            username: "Nombre de usuario",
            phoneNumber: "Número de teléfono",
            guestLogin: "Inicio de sesión de invitado",
            guestLoginDescription: ""
        )
    }
    
    var onboarding: OnboardingStrings {
        OnboardingStrings(
            locianHeading: "Locian",
            locianDescription: "Desde donde estás hasta cada tiempo que necesitas",
            awarenessHeading: "Conciencia",
            awarenessDescription: "La IA aprende de tu entorno",
            inputsHeading: "Entradas",
            inputsDescription: "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts",
            breakdownHeading: "Desglose",
            breakdownDescription: "Locian desglosa oraciones en tiempos, proporciona traducciones palabra por palabra",
            progressHeading: "Quiz",
            progressDescription: "Preview the rebuild puzzle, adaptive quizzes, and smart shuffle that keep practice fresh",
            readyHeading: "Listo",
            readyDescription: "",
            loginOrRegister: "Iniciar sesión / Registrarse",
            pageIndicator: " / 6",
            tapToNavigate: "Toca el lado izquierdo o derecho para navegar",
            selectAppLanguage: "Seleccionar idioma de la aplicación",
            selectLanguageDescription: "Este idioma convertirá la interfaz de usuario de la aplicación, encabezados, descripciones, botones, nombres y todo al idioma seleccionado"
        )
    }
    
    var common: CommonStrings {
        CommonStrings(
            cancel: "Cancelar",
            save: "Guardar",
            done: "Hecho",
            ok: "OK",
            back: "Atrás",
            next: "Siguiente",
            continueText: "Continuar"
        )
    }
    
    var customPractice: CustomPracticeStrings {
        CustomPracticeStrings(
            custom: "Personalizado",
            hint: "Pista",
            practiceDescription: "Toca cualquier palabra para traducirla a tu idioma objetivo. Si necesitas ayuda, usa el botón de pista para obtener sugerencias.",
            practiceTitle: "Práctica",
            practiceFollowUp: "Siguiente práctica",
            camera: "Cámara",
            cameraDescription: "Locian generará una conversación en {native} y puedes practicar convirtiendo a {target}.",
            useCamera: "Usar cámara",
            cameraButtonDescription: "Generar momentos desde foto",
            typeConversation: "Escribe una conversación",
            typeConversationDescription: "Locian generará una conversación en {native} y puedes practicar convirtiendo a {target}.",
            conversationPlaceholder: "ej. Pedir café en un café concurrido",
            submit: "Enviar",
            fullCustomText: "Texto personalizado completo",
            examples: "Ejemplos:",
            conversationExample1: "Pedir direcciones bajo la lluvia",
            conversationExample2: "Comprar verduras tarde en la noche",
            conversationExample3: "Trabajar en una oficina llena de gente",
            describeConversation: "Describe la conversación que quieres que Locian cree.",
            fullTextPlaceholder: "Escribe el texto completo o diálogo aquí...",
            startCustomPractice: "Iniciar práctica personalizada"
        )
    }
    
    var progress: ProgressStrings {
        ProgressStrings(
            progress: "Progreso",
            edit: "Editar",
            current: "Actual",
            longest: "Más largo",
            lastPracticed: "Última práctica",
            days: "días",
            addLanguagePairToSeeProgress: "Agrega un par de idiomas para ver tu progreso."
        )
    }
    
    func getString(_ key: String) -> String {
        return key
    }
    
    // Also implement LocalizedStrings protocol
    func getString(for key: StringKey) -> String {
        switch key {
        // Settings
        case .languagePairs: return "Mis idiomas"
        case .notifications: return "Notificaciones"
        case .aesthetics: return "Estética"
        case .account: return "Cuenta"
        case .appLanguage: return "Interfaz de la aplicación"
        
        // Common
        case .login: return "Iniciar sesión /"
        case .register: return "Registrarse"
        case .settings: return "Configuración"
        case .home: return "Inicio"
        case .back: return "Atrás"
        case .next: return "Siguiente"
        case .previous: return "Anterior"
        case .done: return "Hecho"
        case .cancel: return "Cancelar"
        case .save: return "Guardar"
        case .delete: return "Eliminar"
        case .add: return "Agregar"
        case .remove: return "Quitar"
        case .edit: return "Editar"
        case .continueText: return "Continuar"
        
        // Quiz
        case .quizCompleted: return "¡Quiz completado!"
        case .sessionCompleted: return "¡Sesión completada!"
        case .masteredEnvironment: return "¡Has dominado tu entorno!"
        case .learnMoreAbout: return "Aprende más sobre"
        case .backToHome: return "Volver al inicio"
        case .tryAgain: return "Intentar de nuevo"
        case .shuffled: return "Mezclado"
        case .check: return "Verificar"
        
        // Vocabulary
        case .exploreCategories: return "Explorar categorías"
        case .testYourself: return "Pruébate"
        case .similarWords: return "Palabras similares:"
        case .wordTenses: return "Tiempos verbales:"
        case .tapWordsToExplore: return "Toca las palabras para leer sus traducciones y explorar"
        case .wordBreakdown: return "Desglose de palabras:"
        
        // Scene
        case .analyzingImage: return "Analizando imagen..."
        case .imageAnalysisCompleted: return "Análisis de imagen completado"
        case .imageSelected: return "Imagen seleccionada"
        case .placeNotSelected: return "Lugar no seleccionado"
        case .chooseLanguages: return "Elige idiomas"
        case .locianChoose: return "Locian elige"
        
        // Settings
        case .enableNotifications: return "Activar notificaciones"
        case .thisPlace: return "este lugar"
        case .tapOnAnySection: return "Toca cualquier sección arriba para ver y administrar la configuración"
        case .addNewLanguagePair: return "Agregar nuevo par de idiomas"
        case .noLanguagePairsAdded: return "Aún no se han agregado pares de idiomas"
        case .setDefault: return "Establecer predeterminado"
        case .defaultText: return "Predeterminado"
        case .user: return "Usuario"
        case .noPhone: return "Sin teléfono"
        case .signOutFromAccount: return "Cerrar sesión de tu cuenta"
        case .removeAllPracticeData: return "Eliminar todos tus datos de práctica"
        case .permanentlyDeleteAccount: return "Eliminar permanentemente tu cuenta y todos los datos"
        case .currentLevel: return "Nivel actual"
        case .selectPhoto: return "Seleccionar foto"
        case .camera: return "Cámara"
        case .photoLibrary: return "Biblioteca de fotos"
        case .selectTime: return "Seleccionar hora"
        case .hour: return "Hora"
        case .minute: return "Minuto"
        case .addTime: return "Agregar hora"
        case .areYouSureLogout: return "¿Estás seguro de que quieres cerrar sesión?"
        case .areYouSureDeleteAccount: return "¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer."
        
        // Quiz
        case .goBack: return "Volver"
        case .fillInTheBlank: return "Completa el espacio en blanco:"
        case .arrangeWordsInOrder: return "Ordena las palabras en el orden correcto:"
        case .tapWordsBelowToAdd: return "Toca las palabras debajo para agregarlas aquí"
        case .availableWords: return "Palabras disponibles:"
        case .correctAnswer: return "Respuesta correcta:"
        
        // Common
        case .error: return "Error"
        case .ok: return "OK"
        case .close: return "Cerrar"
        
        // Onboarding
        case .locianHeading: return "Locian"
        case .locianDescription: return "Desde donde estás hasta cada tiempo que necesitas"
        case .awarenessHeading: return "Conciencia"
        case .awarenessDescription: return "La IA aprende de tu entorno"
        case .inputsHeading: return "Entradas"
        case .inputsDescription: return "Locian surfaces similar words, word tenses, and full word breakdowns—not just consonant and vowel charts"
        case .breakdownHeading: return "Desglose"
        case .breakdownDescription: return "Locian desglosa oraciones en tiempos, proporciona traducciones palabra por palabra"
        case .progressHeading: return "Quiz"
        case .progressDescription: return "Preview the rebuild mini-game, adaptive quizzes, and smart shuffle that keep practice fresh"
        case .readyHeading: return "Listo"
        case .readyDescription: return ""
        
        // Onboarding additional strings
        case .loginOrRegister: return "Iniciar sesión / Registrarse"
        case .pageIndicator: return " / 6"
        case .tapToNavigate: return "Toca el lado izquierdo o derecho para navegar"
        case .selectAppLanguage: return "Seleccionar idioma de la aplicación"
        case .selectLanguageDescription: return "Este idioma convertirá la interfaz de usuario de la aplicación, encabezados, descripciones, botones, nombres y todo al idioma seleccionado"
        
        // Login
        case .username: return "Nombre de usuario"
        case .phoneNumber: return "Número de teléfono"
        case .guestLogin: return "Inicio de sesión de invitado"
        case .guestLoginDescription: return "El inicio de sesión de invitado es para verificación y permitirá al invitado acceder a todas las funciones de la aplicación. Se eliminará después de la verificación."
        
        // Professions
        case .student: return "Estudiante"
        case .softwareEngineer: return "Ingeniero de Software"
        case .teacher: return "Maestro"
        case .doctor: return "Doctor"
        case .artist: return "Artista"
        case .businessProfessional: return "Profesional de Negocios"
        case .salesOrMarketing: return "Ventas o Marketing"
        case .traveler: return "Viajero"
        case .homemaker: return "Ama de Casa"
        case .chef: return "Chef"
        case .police: return "Policía"
        case .bankEmployee: return "Empleado de Banco"
        case .nurse: return "Enfermera"
        case .designer: return "Diseñador"
        case .engineerManager: return "Ingeniero Gerente"
        case .photographer: return "Fotógrafo"
        case .contentCreator: return "Creador de Contenido"
        case .other: return "Otro"
        
        // Scene Places
        case .lociansChoice: return "Elección de Locian"
        case .airport: return "Aeropuerto"
        case .cafe: return "Café"
        case .gym: return "Gimnasio"
        case .library: return "Biblioteca"
        case .office: return "Oficina"
        case .park: return "Parque"
        case .restaurant: return "Restaurante"
        case .shoppingMall: return "Centro comercial"
        case .travelling: return "Viajando"
        case .university: return "Universidad"
        case .addCustomPlace: return "Agregar lugar personalizado"
        case .enterCustomPlaceName: return "Ingrese un nombre de lugar personalizado (máximo 30 caracteres)"
        case .maximumCustomPlaces: return "Máximo 10 lugares personalizados"
        case .welcome: return "Bienvenido"
        case .tapToCaptureContext: return "Toca para capturar tu contexto y comenzar a aprender"
        case .customSection: return "Personalizado"
        case .examples: return "Ejemplos:"
        case .customPlacePlaceholder: return "ej., viaje a la oficina"
        case .exampleTravellingToOffice: return "viaje a la oficina"
        case .exampleTravellingToHome: return "viaje a casa"
        case .exampleExploringParis: return "explorar parís"
        case .exampleVisitingMuseum: return "visitar museo"
        case .exampleCoffeeShop: return "cafetería"
        case .characterCount: return "caracteres"
        
        // Settings Modal Strings
        case .nativeLanguage: return "Idioma nativo:"
        case .selectNativeLanguage: return "Seleccione su idioma nativo"
        case .targetLanguage: return "Idioma objetivo:"
        case .selectTargetLanguage: return "Seleccione el idioma que desea aprender"
        case .nativeLanguageDescription: return "Su idioma nativo es el idioma que puede leer, escribir y hablar con fluidez. Este es el idioma con el que se siente más cómodo."
        case .targetLanguageDescription: return "Su idioma objetivo es el idioma que desea aprender y practicar. Elija el idioma en el que desea mejorar sus habilidades."
        case .addPair: return "Agregar par"
        case .adding: return "Agregando..."
        case .failedToAddLanguagePair: return "Error al agregar el par de idiomas. Por favor, inténtelo de nuevo."
        case .settingAsDefault: return "Estableciendo como predeterminado..."
        case .beginner: return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced: return "Avanzado"
        case .currentlyLearning: return "Aprendiendo"
        case .otherLanguages: return "Otros idiomas"
        case .learnNewLanguage: return "Aprender nuevo idioma"
        case .learn: return "Aprender"
        case .tapToSelectNativeLanguage: return "Toca para seleccionar tu idioma nativo"
        
        // Theme color names
        case .neonGreen: return "Verde Neón"
        case .cyanMist: return "Niebla Cian"
        case .violetHaze: return "Bruma Violeta"
        case .softPink: return "Rosa Suave"
        case .pureWhite: return "Blanco Puro"
        
        // Quick Look
        case .quickRecall: return "Recuerdo rápido"
        case .startQuickPuzzle: return "Iniciar puzzle rápido"
        case .stopPuzzle: return "Detener puzzle"
        
        // Streak
        case .streak: return "Racha"
        case .dayStreak: return "día de racha"
        case .daysStreak: return "días de racha"
        case .editYourStreaks: return "Editar tus rachas"
        case .editStreaks: return "Editar rachas"
        case .selectDatesToAddOrRemove: return "Selecciona fechas para agregar o eliminar días de práctica"
        case .saving: return "Guardando..."
        }
    }
}

