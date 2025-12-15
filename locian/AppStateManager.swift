//
//  AppStateManager.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    // MARK: - Theme State
    @Published var selectedTheme: String = "Neon Green" {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }
    
    // MARK: - Universal Color (Computed from selectedTheme)
    var selectedColor: Color {
        switch selectedTheme {
        case "Neon Green":
            return Color(hex: "#39FF14")
        case "Cyan Mist":
            return Color(hex: "#00E5FF")
        case "Solar Amber":
            return Color(hex: "#FFB300")
        case "Violet Haze":
            return Color(hex: "#A68CFF")
        case "Silver Pulse":
            return Color(hex: "#D1D1D1")
        case "Soft Pink":
            return Color(hex: "#FFB6C1")
        // Legacy support for old theme names
        case "Turquoise":
            return Color(hex: "#00E5FF") // Map to Cyan Mist
        case "Fuschia":
            return Color(hex: "#A68CFF") // Map to Violet Haze
        case "White":
            return Color.white
        case "Grey":
            return Color(hex: "#1E1E1E") // Map to Graphite Grey
        default:
            return Color(hex: "#39FF14") // Default Neon Green
        }
    }
    
    // Static version for backward compatibility (uses instance theme via UserDefaults)
    static var selectedColor: Color {
            if let themeName = UserDefaults.standard.string(forKey: "selectedTheme") {
                switch themeName {
                case "Neon Green":
                    return Color(hex: "#39FF14")
                case "Cyan Mist":
                    return Color(hex: "#00E5FF")
                case "Solar Amber":
                    return Color(hex: "#FFB300")
                case "Violet Haze":
                    return Color(hex: "#A68CFF")
                case "Silver Pulse":
                    return Color(hex: "#D1D1D1")
                case "Soft Pink":
                    return Color(hex: "#FFB6C1")
                // Legacy support for old theme names
                case "Turquoise":
                    return Color(hex: "#00E5FF") // Map to Cyan Mist
                case "Fuschia":
                    return Color(hex: "#A68CFF") // Map to Violet Haze
                case "White":
                    return Color.white
                case "Grey":
                    return Color(hex: "#1E1E1E") // Map to Graphite Grey
                default:
                    return Color(hex: "#39FF14") // Default Neon Green
                }
            }
            return Color(hex: "#39FF14") // Default Neon Green
    }
    
    // MARK: - Onboarding State
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    // MARK: - Auth State
    @Published var authToken: String? {
        didSet {
            if let token = authToken {
                UserDefaults.standard.set(token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }
    
    @Published var isLoggedIn: Bool = false
    @Published var isLoadingSession: Bool = false
    @Published var isOffline: Bool = false
    
    // MARK: - User Data (Persistent)
    @Published var username: String = "" {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    @Published var userPhoneNumber: String = "" {
        didSet {
            UserDefaults.standard.set(userPhoneNumber, forKey: "userPhoneNumber")
        }
    }
    
    @Published var profession: String = "" {
        didSet {
            UserDefaults.standard.set(profession, forKey: "profession")
        }
    }
    
    // MARK: - Notifications State
    @Published var notificationsMorning: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsMorning, forKey: "notificationsMorning")
            updateNotificationSchedules()
            }
        }
    
    @Published var notificationsAfternoon: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsAfternoon, forKey: "notificationsAfternoon")
            updateNotificationSchedules()
        }
    }
    
    @Published var notificationsEvening: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEvening, forKey: "notificationsEvening")
            updateNotificationSchedules()
        }
    }
    
    @Published var profileImageData: Data? {
        didSet {
            if let data = profileImageData {
                UserDefaults.standard.set(data, forKey: "profileImage")
            } else {
                UserDefaults.standard.removeObject(forKey: "profileImage")
            }
        }
    }
    
    // Removed legacy nearby places/location cache
    
    // MARK: - OTP State
    @Published var otpSent: Bool = false
    @Published var otpId: String?
    @Published var otpExpiresInMinutes: Int = 0
    @Published var phoneNumber: String = ""
    @Published var isSendingOTP: Bool = false
    @Published var isVerifyingOTP: Bool = false
    @Published var otpError: String?
    @Published var showOTPError: Bool = false
    
    // MARK: - Language State
    @Published var showGlobalLanguageModal: Bool = false
    @Published var showFirstLaunchLanguageModal: Bool = false
    @Published var userLanguagePairs: [LanguagePair] = [] {
        didSet {
            // Auto-save to UserDefaults when changed
            if let encoded = try? JSONEncoder().encode(userLanguagePairs) {
                UserDefaults.standard.set(encoded, forKey: "userLanguagePairs")
            }
        }
    }
    @Published var shouldAttemptInferInterest: Bool = false
    @Published var isLoadingLanguages: Bool = false
    
    // MARK: - App Language State
    @Published var appLanguage: String = "English" {
        didSet {
            // Auto-save to UserDefaults when changed
            UserDefaults.standard.set(appLanguage, forKey: "appLanguage")
        }
    }
    
    // Available app languages
    static let availableAppLanguages: [String] = [
        "English",
        "Japanese",
        "Hindi",
        "Telugu",
        "Tamil",
        "French",
        "German",
        "Spanish",
        "Chinese",
        "Korean",
        "Russian",
        "Malayalam"
    ]
    
    // MARK: - Image Analysis State
    @Published var isAnalyzingImage: Bool = false
    @Published var imageAnalysisResult: String?
    
    // MARK: - Infer Interest State
    @Published var isInferringInterest: Bool = false
    @Published var inferredPlaceCategory: String?
    
    // MARK: - Vocabulary State
    @Published var isGeneratingVocabulary: Bool = false
    @Published var vocabularyResult: VocabularyData?
    @Published var vocabularyError: String?
    @Published var showVocabularyError: Bool = false
    
    // Current vocabulary request parameters (for loading animation)
    @Published var currentVocabularyRequest: VocabularyRequest?
    
    // Stored vocabulary session_id (persisted for fallback when API doesn't return it)
    private var vocabularySessionId: String? {
        get {
            return UserDefaults.standard.string(forKey: "vocabularySessionId")
        }
        set {
            if let id = newValue {
                UserDefaults.standard.set(id, forKey: "vocabularySessionId")
            } else {
                UserDefaults.standard.removeObject(forKey: "vocabularySessionId")
            }
        }
    }
    
    // MARK: - Vocabulary Navigation State
    @Published var shouldShowVocabularyView: Bool = false
    @Published var vocabularyIsImageSelected: Bool = false
    @Published var vocabularySelectedPlace: String = ""
    
    // MARK: - Practice Words Selection State (Centralized)
    // Stores selected words for practice: first 5 clicked words, then non-clicked words
    // This remains consistent even when user navigates back
    @Published var practiceWordsSelection: [VocabularyItem] = []
    
    // Removed legacy practice state cache
    
    // Removed legacy practice/conversation navigation and state
    
    // MARK: - Quiz State
    @Published var isLoadingQuiz: Bool = false
    @Published var quizState: QuizState? = QuizState.load()
    // MARK: - Similar Words State
    @Published var isLoadingSimilarWords: Bool = false
    @Published var similarWordsResult: [String: SimilarWordDetail]?
    @Published var similarWordsError: String?
    @Published var showSimilarWordsError: Bool = false
    
    // MARK: - Word Tenses State
    @Published var isLoadingWordTenses: Bool = false
    @Published var wordTensesResult: [String: TenseDetail]?
    @Published var wordTensesError: String?
    @Published var showWordTensesError: Bool = false
    
    // MARK: - Word Decomposition State
    @Published var isLoadingWordDecomposition: Bool = false
    @Published var wordDecompositionResult: WordDecompositionData?
    @Published var wordDecompositionError: String?
    @Published var showWordDecompositionError: Bool = false
    
    // MARK: - Cache for Word Details
    var similarWordsCache: [String: [String: SimilarWordDetail]] = [:]
    var wordTensesCache: [String: [String: TenseDetail]] = [:]
    var wordDecompositionCache: [String: WordDecompositionData] = [:]
    
    // MARK: - Navigation State
    @Published var shouldShowSettingsView: Bool = false
    @Published var shouldShowQuizView: Bool = false
    
    // MARK: - Initialization
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "Neon Green"
        
        // Check if app language has been selected (first launch detection)
        let hasSelectedLanguage = UserDefaults.standard.bool(forKey: "hasSelectedAppLanguage")
        if !hasCompletedOnboarding && !hasSelectedLanguage {
            // First launch - show language selection modal
            self.showFirstLaunchLanguageModal = true
        }
        
        // Load auth token to check if we should load user data
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
        
        // DO NOT load user data here - wait for session validation
        // Session validation will load user data if valid, or clear it if invalid
        // This prevents loading data when session is expired/invalid
        
        // Session validation will be done in ContentView.onAppear via checkUserSession()
        // Do NOT validate here to avoid race conditions and double validation
    }
    
    // MARK: - Load User Data (called after successful session validation)
    private func loadUserData() {
        // Only load user data if we have a valid session token
        guard authToken != nil, !authToken!.isEmpty else {
            clearUserData()
            return
        }
        
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.userPhoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") ?? ""
        self.profession = UserDefaults.standard.string(forKey: "profession") ?? ""
        
        // Load notification settings (default to true if not set)
        if UserDefaults.standard.object(forKey: "notificationsMorning") == nil {
            // First time - set defaults to true
            self.notificationsMorning = true
            self.notificationsAfternoon = true
            self.notificationsEvening = true
        } else {
            self.notificationsMorning = UserDefaults.standard.bool(forKey: "notificationsMorning")
            self.notificationsAfternoon = UserDefaults.standard.bool(forKey: "notificationsAfternoon")
            self.notificationsEvening = UserDefaults.standard.bool(forKey: "notificationsEvening")
        }
        
        // Load profile image from UserDefaults
        self.profileImageData = UserDefaults.standard.data(forKey: "profileImage")
        
        // Load language pairs from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "userLanguagePairs"),
           let pairs = try? JSONDecoder().decode([LanguagePair].self, from: data) {
            self.userLanguagePairs = pairs
        }
        
        // Load quiz state from cache if present
        self.quizState = QuizState.load()
        
        // Update notification schedules with cached times (if available)
        self.updateNotificationSchedules()
    }
    
    // MARK: - Clear User Data (called when session invalid/expired)
    private func clearUserData() {
        
        // Clear user data
        self.username = ""
        self.userPhoneNumber = ""
        self.profession = ""
        self.profileImageData = nil
        
        // Clear from UserDefaults
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
        UserDefaults.standard.removeObject(forKey: "profession")
        UserDefaults.standard.removeObject(forKey: "profileImage")
        
        // Clear notification data (keep preferences but clear API times)
        
        // Clear language pairs
        self.userLanguagePairs = []
        UserDefaults.standard.removeObject(forKey: "userLanguagePairs")
        
        // Clear quiz state
        QuizState.clear()
        self.quizState = nil
        
    }
    
    // MARK: - Methods
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    // MARK: - Quiz API Calls
    func startQuiz(scene: String, completion: @escaping (Bool) -> Void) {
        guard let token = authToken, let vocab = vocabularyResult else { completion(false); return }
        isLoadingQuiz = true

        // Build categories from full vocabulary
        var cats: [QuizCategory] = []
        for (name, data) in vocab.vocabulary {
            let words = data.words.map { w in
                QuizWord(
                    native_text: w.native_text,
                    target_text: w.target_text,
                    transliteration: w.transliteration,
                    clicked: w.clicked ?? false,
                    is_correct: w.is_correct,
                    attempts: w.attempts
                )
            }
            cats.append(QuizCategory(category_name: name, clicked: data.clicked, words: words))
        }
        // Get current date and time with full information: month, day name, day of month, time
        let date = Date()
        let calendar = Calendar.current
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM" // e.g., "November"
        let month = monthFormatter.string(from: date)
        
        let dayNameFormatter = DateFormatter()
        dayNameFormatter.dateFormat = "EEEE" // e.g., "Sunday"
        let dayName = dayNameFormatter.string(from: date)
        
        let dayOfMonth = calendar.component(.day, from: date)
        let dayOrdinal: String
        if dayOfMonth % 10 == 1 && dayOfMonth != 11 {
            dayOrdinal = "\(dayOfMonth)st"
        } else if dayOfMonth % 10 == 2 && dayOfMonth != 12 {
            dayOrdinal = "\(dayOfMonth)nd"
        } else if dayOfMonth % 10 == 3 && dayOfMonth != 13 {
            dayOrdinal = "\(dayOfMonth)rd"
        } else {
            dayOrdinal = "\(dayOfMonth)th"
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // e.g., "11:30 AM"
        let timeString = timeFormatter.string(from: date)
        
        // Format: "November, Sunday, 2nd day, 11:30 AM"
        let currentTime = "\(month), \(dayName), \(dayOrdinal) day, \(timeString)"
        
        let req = QuizGenerateRequest(
            session_token: token,
            scene: scene,
            time: currentTime,
            vocabulary_session_id: vocab.session_id ?? vocab.latest_session_id,
            categories: cats
        )
        QuizAPIManager.shared.generateQuiz(request: req) { result in
            DispatchQueue.main.async {
                self.isLoadingQuiz = false
                switch result {
                case .success(let resp):
                    // Print decoded response to verify what we got
                    if resp.data != nil {
                        // Questions data available
                    }
                    if resp.quiz_session_id != nil {
                        // Quiz session ID available
                    }
                    if resp.questions != nil {
                        // Questions available
                    }
                    
                    // Handle both wrapped and direct formats
                    let quizData: QuizData?
                    if let wrappedData = resp.data {
                        // Wrapped format: {"success": true, "data": {...}}
                        quizData = wrappedData
                    } else if let quizSessionId = resp.quiz_session_id, let questions = resp.questions, !questions.isEmpty {
                        // Direct format: {"quiz_session_id": "...", "questions": {...}}
                        quizData = QuizData(quiz_session_id: quizSessionId, questions: questions)
                    } else {
                        quizData = nil
                    }
                    
                    // Check if we have valid quiz data
                    if let data = quizData, !data.questions.isEmpty {
                        // Extract question IDs in EXACT order from raw JSON response
                        // Swift Dictionary doesn't preserve order, so we must parse raw JSON string directly
                        var ordered: [String] = []
                        
                        // Try to get order from raw JSON string stored by BaseAPIManager
                        if let rawJSONString = UserDefaults.standard.string(forKey: "lastQuizResponseRawJSON") {
                            // Parse JSON string to extract question keys in EXACT order they appear
                            // Look for "questions": { "key1": {...}, "key2": {...}, ... }
                            
                            // Find the questions object - handle both "data": {"questions": {...}} and "questions": {...}
                            var questionsStartIndex: String.Index?
                            if let dataRange = rawJSONString.range(of: #""data"\s*:\s*\{[^}]*"questions"\s*:\s*\{"#, options: .regularExpression) {
                                // Wrapped format: find "questions" inside "data"
                                if let questionsRange = rawJSONString.range(of: #""questions"\s*:\s*\{"#, options: .regularExpression, range: rawJSONString.index(after: dataRange.lowerBound)..<rawJSONString.endIndex) {
                                    questionsStartIndex = questionsRange.upperBound
                                }
                            } else if let questionsRange = rawJSONString.range(of: #""questions"\s*:\s*\{"#, options: .regularExpression) {
                                // Direct format: "questions" at root level
                                questionsStartIndex = questionsRange.upperBound
                            }
                            
                            if let startIndex = questionsStartIndex {
                                // Extract everything after "questions": {
                                let remaining = String(rawJSONString[startIndex...])
                                
                                // Parse keys in order by finding "key": { patterns
                                // Handle nested braces properly by tracking brace depth
                                let keyPattern = "\"([^\"]+)\"\\s*:\\s*\\{"
                                let regex = try? NSRegularExpression(pattern: keyPattern, options: [])
                                let nsString = remaining as NSString
                                let matches = regex?.matches(in: remaining, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
                                
                                // Extract question IDs in order they appear
                                for match in matches {
                                    if match.numberOfRanges > 1 {
                                        let keyRange = match.range(at: 1)
                                        if keyRange.location != NSNotFound {
                                            let key = nsString.substring(with: keyRange)
                                            ordered.append(key)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Fallback: If we couldn't extract from raw JSON, use dictionary keys as-is
                        // (but warn that order might not be preserved)
                        if ordered.isEmpty {
                            ordered = Array(data.questions.keys)
                        }
                        
                        // Create new quiz state, clearing previous answer states
                        let state = QuizState(
                            quiz_session_id: data.quiz_session_id,
                            ordered_question_ids: ordered,
                            questions: data.questions,
                            selectedAnswers: [:],  // Clear previous answers
                            checkedAnswers: [:],   // Clear previous checks
                            currentQuestionIndex: 0
                        )
                        self.quizState = state
                        state.save()
                        
                        // Clear the raw JSON from UserDefaults after use
                        UserDefaults.standard.removeObject(forKey: "lastQuizResponseRawJSON")
                        
                        self.shouldShowQuizView = true  // Navigate to quiz UI
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }

    func updateQuizQuestion(questionId: String, isAttempted: Bool?, isCorrect: Bool?, timeTaken: Double?, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let token = authToken, let quizSessionId = quizState?.quiz_session_id else { completion(false); return }
        let updates = QuizQuestionUpdates(is_attempted: isAttempted, is_correct: isCorrect, time_taken: timeTaken)
        let req = QuizUpdateRequest(session_token: token, quiz_session_id: quizSessionId, question_id: questionId, updates: updates)
        QuizAPIManager.shared.updateQuestion(request: req) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp):
                    if resp.success {
                        completion(true)
                    } else { completion(false) }
                case .failure:
                    completion(false)
                }
            }
        }
    }

    // MARK: - Delete Practice Data (place by place)
    func deletePracticeData(deleteAll: Bool = false, clearMain: Bool = false, sessionId: String? = nil, completion: @escaping (Bool) -> Void) {
        guard let token = authToken else { completion(false); return }
        // Build places list: only selected place
        guard !vocabularySelectedPlace.isEmpty else { completion(false); return }
        let places: [String] = [vocabularySelectedPlace]

        // Build request (exactly one field)
        let req = PracticeDeleteRequest(
            delete_all: deleteAll ? true : nil,
            clear_main: clearMain ? true : nil,
            session_id: sessionId
        )

        var remaining = places.count
        var allOK = true
        for place in places {
            PracticeAPIManager.shared.deletePracticeData(placeName: place, request: req, sessionToken: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let resp):
                        if resp.status != "success" { allOK = false }
                    case .failure:
                        allOK = false
                    }
                    remaining -= 1
                    if remaining == 0 { completion(allOK) }
                }
            }
        }
    }
    
    // MARK: - Session Validation
    // validateStoredSession() removed - replaced by checkUserSession() to avoid race conditions
    
    // MARK: - Image Analysis Methods
    func analyzeImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🖼️ [STAGE 1] IMAGE ANALYSIS STARTED")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🖼️ [STAGE 1.1] analyzeImage() called in AppStateManager")
        
        // Check if we have a valid session token
        guard let sessionToken = authToken, !sessionToken.isEmpty else {
            print("❌ [STAGE 1.2] No session token available for image analysis")
            completion(false)
            return
        }
        
        print("✅ [STAGE 1.2] Session token found: \(sessionToken.prefix(20))...")
        print("🔄 [STAGE 1.3] Setting isAnalyzingImage = true")
        isAnalyzingImage = true
        
        // Convert UIImage to base64
        print("🔄 [STAGE 1.4] Converting UIImage to JPEG data...")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ [STAGE 1.4] Failed to convert UIImage to JPEG data")
            isAnalyzingImage = false
            completion(false)
            return
        }
        
        let base64String = imageData.base64EncodedString()
        let imageBase64 = "data:image/jpeg;base64,\(base64String)"
        print("✅ [STAGE 1.4] Image converted to base64")
        print("   - Image data size: \(imageData.count) bytes")
        print("   - Base64 string length: \(base64String.count) characters")
        print("   - Full base64 prefix: \(imageBase64.prefix(50))...")
        
        // Get language codes from default language pair
        let userLanguage: String?
        let targetLanguage: String?
        
        if let defaultPair = userLanguagePairs.first(where: { $0.is_default }) {
            userLanguage = getLanguageCodeForAPI(for: defaultPair.native_language)
            targetLanguage = getLanguageCodeForAPI(for: defaultPair.target_language)
            print("✅ [STAGE 1.5.1] Language codes from default pair:")
            print("   - user_language: \(userLanguage ?? "nil")")
            print("   - target_language: \(targetLanguage ?? "nil")")
        } else {
            userLanguage = nil
            targetLanguage = nil
            print("⚠️ [STAGE 1.5.1] No default language pair found - using nil for languages")
        }
        
        // Create analysis request
        print("🔄 [STAGE 1.5] Creating ImageAnalysisRequest...")
        let request = ImageAnalysisRequest(
            session_token: sessionToken,
            image_base64: imageBase64,
            user_language: userLanguage,
            target_language: targetLanguage
        )
        print("✅ [STAGE 1.5] ImageAnalysisRequest created")
        print("   - session_token: \(request.session_token.prefix(20))...")
        print("   - user_language: \(request.user_language ?? "nil")")
        print("   - target_language: \(request.target_language ?? "nil")")
        
        print("📤 [STAGE 1.6] Calling ImageAPIManager.analyzeImage()...")
        
        // Call the image analysis API
        ImageAPIManager.shared.analyzeImage(request: request) { result in
            DispatchQueue.main.async {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📥 [STAGE 1.7] Image analysis API callback received")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                self.isAnalyzingImage = false
                print("🔄 [STAGE 1.7.1] Setting isAnalyzingImage = false")
                
                switch result {
                case .success(let response):
                    print("✅ [STAGE 1.7.2] API returned success response")
                    print("   - Response success flag: \(response.success)")
                    print("   - Response message: \(response.message ?? "nil")")
                    if response.success {
                        // Log full response data structure for debugging
                        print("🔍 [STAGE 1.7.2.1] Full response data structure:")
                        if let data = response.data {
                            print("   - data.place_name: \(data.place_name)")
                            print("   - place_name length: \(data.place_name.count) characters")
                            print("   - place_name content: '\(data.place_name)'")
                        } else {
                            print("   - response.data is nil")
                        }
                        
                        // Get place name from response
                        print("🔄 [STAGE 1.7.3] Extracting place name from response...")
                        if let placeName = response.data?.place_name, !placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let trimmedPlaceName = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
                            print("✅ [STAGE 1.7.3] Place name extracted successfully")
                            print("   - Raw place_name: '\(placeName)'")
                            print("   - Trimmed place name: '\(trimmedPlaceName)'")
                            print("   - Place name length: \(trimmedPlaceName.count) characters")
                            print("🔄 [STAGE 1.7.4] Setting imageAnalysisResult = '\(trimmedPlaceName)'")
                            self.imageAnalysisResult = trimmedPlaceName
                            print("✅ [STAGE 1.7.5] imageAnalysisResult set successfully")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("✅ [STAGE 1] IMAGE ANALYSIS COMPLETED SUCCESSFULLY")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            completion(true)
                        } else {
                            print("⚠️ [STAGE 1.7.3] Place name is nil or empty")
                            print("   - response.data: \(response.data != nil ? "exists" : "nil")")
                            print("   - response.data?.place_name: \(response.data?.place_name ?? "nil")")
                            if let data = response.data {
                                print("   - Full data object: place_name='\(data.place_name)'")
                            }
                            print("🔄 [STAGE 1.7.4] Setting imageAnalysisResult = nil")
                            self.imageAnalysisResult = nil
                            print("❌ [STAGE 1] IMAGE ANALYSIS FAILED - NO PLACE NAME")
                            completion(false)
                        }
                    } else {
                        print("⚠️ [STAGE 1.7.2] Response success flag is false")
                        print("   - Response message: \(response.message ?? "nil")")
                        print("   - Response error: \(response.error ?? "nil")")
                        print("🔄 [STAGE 1.7.3] Setting imageAnalysisResult = nil")
                        self.imageAnalysisResult = nil
                        print("❌ [STAGE 1] IMAGE ANALYSIS FAILED - API RETURNED FALSE")
                        completion(false)
                    }
                case .failure(let error):
                    print("❌ [STAGE 1.7.2] API returned failure")
                    print("   - Error: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("   - Error code: \(nsError.code)")
                        print("   - Error domain: \(nsError.domain)")
                    }
                    print("🔄 [STAGE 1.7.3] Setting imageAnalysisResult = nil")
                    self.imageAnalysisResult = nil
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("❌ [STAGE 1] IMAGE ANALYSIS FAILED - API ERROR")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Infer Interest Methods
    // Non-blocking: Runs in background, stores result when complete, doesn't block UI navigation
    func inferUserInterest(time: String? = nil, completion: @escaping (String?) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(nil)
            return
        }
        
        guard let (userLanguageCode, targetLanguageCode) = getLanguageCodesForAPIOrPrompt() else {
            print("⚠️ [INFER INTEREST] No valid language pair found. Showing language modal before calling API.")
            completion(nil)
            return
        }
        
        // Set inference state (non-blocking - user can still navigate)
        isInferringInterest = true
        // Don't clear inferredPlaceCategory - keep previous result if available
        
        // Format time if provided (convert to "07:45 PM" format if needed)
        let formattedTime: String? = {
            if let time = time {
                // If time is already in "07:45 PM" format, use it as-is
                if time.contains(":") && (time.contains("AM") || time.contains("PM")) {
                    return time
                }
                // Otherwise, try to format current time if time is nil or invalid
                return formatCurrentTime()
            }
            // If no time provided, use current time
            return formatCurrentTime()
        }()
        
        let request = InferInterestRequest(
            session_token: token,
            time: formattedTime,
            user_language: userLanguageCode,
            target_language: targetLanguageCode
        )
        
        // Run inference in background - won't block UI navigation
        PlacesAPIManager.shared.inferInterest(request: request) { result in
            // Always update on main thread, but don't block user
            DispatchQueue.main.async {
                self.isInferringInterest = false
                
                switch result {
                case .success(let response):
                    if response.success == true, let category = response.data?.category {
                        // Store result even if user navigated away
                        // Category is now in user's native language (e.g., "कैफे", "café", "カフェ")
                        self.inferredPlaceCategory = category
                        completion(category)
                    } else {
                        // Don't clear existing category on error - keep previous result
                        completion(nil)
                    }
                case .failure:
                    // Don't clear existing category on network error - keep previous result
                    // User can still use cached/previous result
                    completion(nil)
                }
            }
        }
    }
    
    // Helper function to format current time as "07:45 PM"
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
    
    func hasValidLanguagePair() -> Bool {
        if userLanguagePairs.contains(where: { $0.is_default && !$0.native_language.isEmpty && !$0.target_language.isEmpty }) {
            return true
        }
        
        if userLanguagePairs.contains(where: { !$0.native_language.isEmpty && !$0.target_language.isEmpty }) {
            return true
        }
        
        return false
    }
    
    private func getLanguageCodesForAPIOrPrompt() -> (String, String)? {
        if let defaultPair = userLanguagePairs.first(where: { $0.is_default && !$0.native_language.isEmpty && !$0.target_language.isEmpty }) {
            let userCode = getLanguageCodeForAPI(for: defaultPair.native_language)
            let targetCode = getLanguageCodeForAPI(for: defaultPair.target_language)
            return (userCode, targetCode)
        }
        
        if let firstPair = userLanguagePairs.first(where: { !$0.native_language.isEmpty && !$0.target_language.isEmpty }) {
            let userCode = getLanguageCodeForAPI(for: firstPair.native_language)
            let targetCode = getLanguageCodeForAPI(for: firstPair.target_language)
            return (userCode, targetCode)
        }
        
        DispatchQueue.main.async {
            self.checkLanguagePairsAndShowModalIfNeeded()
        }
        return nil
    }
    
    // Helper function to convert language name to ISO 639-1 code for API
    private func getLanguageCodeForAPI(for languageName: String) -> String {
        let mapping: [String: String] = [
            "English": "en",
            "Spanish": "es",
            "French": "fr",
            "German": "de",
            "Italian": "it",
            "Portuguese": "pt",
            "Russian": "ru",
            "Japanese": "ja",
            "Korean": "ko",
            "Chinese": "zh",
            "Arabic": "ar",
            "Hindi": "hi",
            "Telugu": "te",
            "Tamil": "ta",
            "Bengali": "bn",
            "Gujarati": "gu",
            "Kannada": "kn",
            "Malayalam": "ml",
            "Marathi": "mr",
            "Punjabi": "pa",
            "Urdu": "ur",
            "Turkish": "tr",
            "Dutch": "nl",
            "Swedish": "sv"
        ]
        return mapping[languageName] ?? languageName.lowercased()
    }
    
    // MARK: - Vocabulary Generation Methods
    func generateVocabulary(placeName: String, isFromImageAnalysis: Bool = false, completion: @escaping (Bool) -> Void) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📚 [STAGE 2] VOCABULARY GENERATION STARTED")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📚 [STAGE 2.1] generateVocabulary() called in AppStateManager")
        print("   - placeName: '\(placeName)'")
        print("   - isFromImageAnalysis: \(isFromImageAnalysis)")
        
        // Validate place name
        let trimmedPlaceName = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔄 [STAGE 2.2] Validating place name...")
        guard !trimmedPlaceName.isEmpty else {
            print("❌ [STAGE 2.2] Place name is empty after trimming")
            vocabularyError = "Place name is required."
            showVocabularyError = true
            completion(false)
            return
        }
        print("✅ [STAGE 2.2] Place name validation passed")
        
        // NO length restrictions - use full place name for both image analysis and manual input
        let finalPlaceName = trimmedPlaceName
        print("🔄 [STAGE 2.3] Preparing final place name...")
        print("   - Final place name: '\(finalPlaceName)'")
        print("   - Final place name length: \(finalPlaceName.count) characters")
        
        // Check if we have a valid session token
        print("🔄 [STAGE 2.4] Checking session token...")
        guard let sessionToken = authToken, !sessionToken.isEmpty else {
            print("❌ [STAGE 2.4] No session token available")
            vocabularyError = "Please log in to generate vocabulary."
            showVocabularyError = true
            completion(false)
            return
        }
        print("✅ [STAGE 2.4] Session token found: \(sessionToken.prefix(20))...")
        
        print("🔄 [STAGE 2.5] Setting isGeneratingVocabulary = true")
        isGeneratingVocabulary = true
        
        // Get current date and time with full information: month, day name, day of month, time
        print("🔄 [STAGE 2.6] Formatting current time...")
        let date = Date()
        let calendar = Calendar.current
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM" // e.g., "November"
        let month = monthFormatter.string(from: date)
        
        let dayNameFormatter = DateFormatter()
        dayNameFormatter.dateFormat = "EEEE" // e.g., "Sunday"
        let dayName = dayNameFormatter.string(from: date)
        
        let dayOfMonth = calendar.component(.day, from: date)
        let dayOrdinal: String
        if dayOfMonth % 10 == 1 && dayOfMonth != 11 {
            dayOrdinal = "\(dayOfMonth)st"
        } else if dayOfMonth % 10 == 2 && dayOfMonth != 12 {
            dayOrdinal = "\(dayOfMonth)nd"
        } else if dayOfMonth % 10 == 3 && dayOfMonth != 13 {
            dayOrdinal = "\(dayOfMonth)rd"
        } else {
            dayOrdinal = "\(dayOfMonth)th"
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // e.g., "11:30 AM"
        let timeString = timeFormatter.string(from: date)
        
        // Format: "November, Sunday, 2nd day, 11:30 AM"
        let currentTime = "\(month), \(dayName), \(dayOrdinal) day, \(timeString)"
        print("✅ [STAGE 2.6] Time formatted: '\(currentTime)'")
        
        // Get language pair from user's stored pairs (find the one marked as default)
        print("🔄 [STAGE 2.7] Getting language pair from user's stored pairs...")
        var userLanguage: String?
        var targetLanguage: String?
        
        for pair in userLanguagePairs {
            if pair.is_default {
                userLanguage = pair.native_language
                targetLanguage = pair.target_language
                break
            }
        }
        print("✅ [STAGE 2.7] Language pair found")
        print("   - user_language: \(userLanguage ?? "nil")")
        print("   - target_language: \(targetLanguage ?? "nil")")
        
        // Create vocabulary request
        print("🔄 [STAGE 2.8] Creating VocabularyRequest...")
        let request = VocabularyRequest(
            session_token: sessionToken,
            place_name: finalPlaceName,
            user_language: userLanguage,
            target_language: targetLanguage,
            time: currentTime
        )
        
        print("✅ [STAGE 2.8] VocabularyRequest created:")
        print("   - session_token: \(request.session_token.prefix(20))...")
        print("   - place_name: '\(request.place_name ?? "nil")'")
        print("   - user_language: \(request.user_language ?? "nil")")
        print("   - target_language: \(request.target_language ?? "nil")")
        print("   - time: '\(request.time ?? "nil")'")
        
        // Store request for loading animation
        print("🔄 [STAGE 2.9] Storing request for loading animation...")
        currentVocabularyRequest = request
        
        // Call generate endpoint (generates and stores vocabulary, returns it immediately)
        print("📤 [STAGE 2.10] Calling VocabularyAPIManager.generateVocabulary()...")
        VocabularyAPIManager.shared.generateVocabulary(request: request) { result in
            DispatchQueue.main.async {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📥 [STAGE 2.11] Vocabulary API callback received")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                self.isGeneratingVocabulary = false
                print("🔄 [STAGE 2.11.1] Setting isGeneratingVocabulary = false")
                
                // Clear request after generation completes (animation will stop)
                self.currentVocabularyRequest = nil
                print("🔄 [STAGE 2.11.2] Clearing currentVocabularyRequest")
                
                switch result {
                case .success(let response):
                    print("✅ [STAGE 2.11.3] API returned success response")
                    print("   - Response success flag: \(response.success)")
                    if response.success {
                        // Use generate response directly (it includes tracking fields)
                        print("🔄 [STAGE 2.11.4] Processing vocabulary data...")
                        if let generateData = response.data {
                            let vocabularyData = generateData.toVocabularyData()
                            
                            // Debug: Check session_id before storing
                            print("🔄 [STAGE 2.11.5] Checking session_id...")
                            
                            // Store session_id whenever we get it from API
                            if let sessionId = vocabularyData.session_id ?? vocabularyData.latest_session_id {
                                print("✅ [STAGE 2.11.5] Session ID found: \(sessionId)")
                                self.vocabularySessionId = sessionId
                                self.vocabularyResult = vocabularyData
                                print("✅ [STAGE 2.11.6] Vocabulary data stored successfully")
                            } else if let storedSessionId = self.vocabularySessionId, !storedSessionId.isEmpty {
                                print("⚠️ [STAGE 2.11.5] No session_id in response, using stored: \(storedSessionId)")
                                // If API didn't return session_id, use stored one (from previous vocabulary generation)
                                let updatedData = VocabularyData(
                                    vocabulary: vocabularyData.vocabulary,
                                    session_id: storedSessionId,
                                    latest_session_id: nil
                                )
                                self.vocabularyResult = updatedData
                                print("✅ [STAGE 2.11.6] Vocabulary data updated with stored session_id")
                            } else {
                                print("⚠️ [STAGE 2.11.5] No session_id available - vocabulary events will fail")
                                // No session_id available - vocabulary events will fail
                                self.vocabularyResult = vocabularyData
                                print("✅ [STAGE 2.11.6] Vocabulary data stored without session_id")
                            }
                            
                            // Initialize practice words selection: first 5 clicked, then non-clicked
                            print("🔄 [STAGE 2.11.7] Initializing practice words selection...")
                            self.initializePracticeWordsSelection()
                            print("✅ [STAGE 2.11.7] Practice words selection initialized")
                            
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            print("✅ [STAGE 2] VOCABULARY GENERATION COMPLETED SUCCESSFULLY")
                            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            completion(true)
                        } else {
                            print("❌ [STAGE 2.11.4] No vocabulary data in response")
                            self.vocabularyError = "Unable to generate vocabulary. Please try again."
                            self.showVocabularyError = true
                            print("❌ [STAGE 2] VOCABULARY GENERATION FAILED - NO DATA")
                            completion(false)
                        }
                    } else {
                        print("⚠️ [STAGE 2.11.3] Response success flag is false")
                        self.vocabularyError = "Unable to generate vocabulary. Please try again."
                        self.showVocabularyError = true
                        print("❌ [STAGE 2] VOCABULARY GENERATION FAILED - API RETURNED FALSE")
                        completion(false)
                    }
                case .failure(let error):
                    print("❌ [STAGE 2.11.3] API returned failure")
                    print("   - Error: \(error.localizedDescription)")
                    // Check if it's a decoding error vs network error
                    if error is DecodingError {
                        print("   - Error type: DecodingError")
                        self.vocabularyError = "Failed to parse vocabulary response. Please try again."
                    } else {
                        print("   - Error type: NetworkError")
                        self.vocabularyError = "No internet connection. Please check your network and try again."
                    }
                    self.showVocabularyError = true
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("❌ [STAGE 2] VOCABULARY GENERATION FAILED - API ERROR")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    completion(false)
                }
            }
        }
    }

    // MARK: - Initialize Practice Words Selection
    func initializePracticeWordsSelection() {
        guard let vocabulary = vocabularyResult else {
            practiceWordsSelection = []
            return
        }
        
        // Get all words
        let allWords = vocabulary.allWords
        
        // Separate clicked and non-clicked words
        let clickedWords = allWords.filter { $0.clicked == true }
        let nonClickedWords = allWords.filter { $0.clicked != true }
        
        // Select first 5 clicked words, then remaining non-clicked words
        let first5Clicked = Array(clickedWords.prefix(5))
        let remainingWords = clickedWords.dropFirst(5) + nonClickedWords
        
        // Combine: first 5 clicked, then others
        practiceWordsSelection = first5Clicked + remainingWords
        
    }
    
    // MARK: - Update Word Clicked State (syncs to API)
    // MARK: - Update Category Clicked State (Database-First)
    func updateCategoryClickedState(
        category: String,
        clicked: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        guard let sessionToken = authToken,
              let vocabulary = vocabularyResult,
              !vocabularySelectedPlace.isEmpty else {
            completion(false)
            return
        }
        
        // Check if already in desired state (skip API call if no change)
        if let categoryData = vocabulary.vocabulary[category],
           categoryData.clicked == clicked {
            completion(true)
            return
        }
        
        // Call API first (database-first approach)
        let sessionId = vocabulary.session_id ?? vocabulary.latest_session_id ?? ""
        
        // Validate session_id exists
        guard !sessionId.isEmpty else {
            completion(false)
            return
        }
        
        
        let request = PracticeCategoryEventUpdateRequest(
            place_name: vocabularySelectedPlace,
            session_id: sessionId,
            session_token: sessionToken,
            category: category,
            updates: VocabularyEventUpdates(clicked: clicked, is_correct: nil, attempts: nil, time_taken_to_choose: nil)
        )
        PracticeCategoryAPIManager.shared.updateCategory(
            request: request,
            sessionToken: sessionToken
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success {
                    // Update cache only on success
                    self.updateCategoryClickedInCache(category: category, clicked: clicked)
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    // MARK: - Update Word Clicked State (Database-First)
    func updateWordClickedState(
        nativeText: String,
        category: String,
        clicked: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        guard let sessionToken = authToken,
              let vocabulary = vocabularyResult,
              !vocabularySelectedPlace.isEmpty else {
            completion(false)
            return
        }
        
        // Check if already in desired state (skip API call if no change)
        if let categoryData = vocabulary.vocabulary[category],
           let wordItem = categoryData.words.first(where: { $0.native_text == nativeText }),
           wordItem.clicked == clicked {
            if clicked {
                // Still open modal even if already clicked
                completion(true)
            } else {
                completion(true)
            }
            return
        }
        
        // Call API first (database-first approach)
        let sessionId = vocabulary.session_id ?? vocabulary.latest_session_id ?? ""
        let request = PracticeWordEventUpdateRequest(
            place_name: vocabularySelectedPlace,
            session_id: sessionId,
            session_token: sessionToken,
            category: category,
            word: nativeText,
            updates: VocabularyEventUpdates(clicked: clicked, is_correct: nil, attempts: nil, time_taken_to_choose: nil)
        )
        PracticeWordAPIManager.shared.updateWord(
            request: request,
            sessionToken: sessionToken
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success {
                    // Update cache only on success
                    self.updateWordClickedInCache(nativeText: nativeText, category: category, clicked: clicked)
                    
                    // Update practice words selection if needed
                    if self.practiceWordsSelection.isEmpty {
                        self.initializePracticeWordsSelection()
                    }
                    
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    // MARK: - Private: Update Cache (Called after API success)
    private func updateCategoryClickedInCache(category: String, clicked: Bool) {
        guard let vocabulary = vocabularyResult else { return }
        var updatedVocabulary = vocabulary.vocabulary
        
        if let categoryData = updatedVocabulary[category] {
            // Update category clicked state
            let updatedCategoryData = CategoryData(clicked: clicked, words: categoryData.words)
            updatedVocabulary[category] = updatedCategoryData
            
            vocabularyResult = VocabularyData(
                vocabulary: updatedVocabulary,
                session_id: vocabulary.session_id,
                latest_session_id: vocabulary.latest_session_id
            )
        }
    }
    
    private func updateWordClickedInCache(nativeText: String, category: String, clicked: Bool) {
        guard let vocabulary = vocabularyResult else { return }
        var updatedVocabulary = vocabulary.vocabulary
        
        if let categoryData = updatedVocabulary[category] {
            var updatedWords = categoryData.words
            if let wordIndex = updatedWords.firstIndex(where: { $0.native_text == nativeText }) {
                let oldWord = updatedWords[wordIndex]
                let updatedWord = VocabularyItem(
                    native_text: oldWord.native_text,
                    target_text: oldWord.target_text,
                    transliteration: oldWord.transliteration,
                    clicked: clicked,
                    is_correct: oldWord.is_correct,
                    attempts: oldWord.attempts
                )
                updatedWords[wordIndex] = updatedWord
            }
            
            let updatedCategoryData = CategoryData(clicked: categoryData.clicked, words: updatedWords)
            updatedVocabulary[category] = updatedCategoryData
            
            vocabularyResult = VocabularyData(
                vocabulary: updatedVocabulary,
                session_id: vocabulary.session_id,
                latest_session_id: vocabulary.latest_session_id
            )
        }
    }
    
    // MARK: - Update Word Practice State (Database-First)
    func updateWordPracticeState(
        nativeText: String,
        category: String?,
        isCorrect: Bool?,
        attempts: Int?,
        timeTaken: Double? = nil,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        guard let sessionToken = authToken,
              let vocabulary = vocabularyResult,
              !vocabularySelectedPlace.isEmpty else {
            completion(false)
            return
        }
        
        // Find category if not provided
        var foundCategory: String? = category
        if foundCategory == nil {
            for (categoryName, categoryData) in vocabulary.vocabulary {
                if categoryData.words.contains(where: { $0.native_text == nativeText }) {
                    foundCategory = categoryName
                    break
                }
            }
        }
        
        guard let categoryName = foundCategory else {
            completion(false)
            return
        }
        
        // Determine if word should be marked as clicked (if not already)
        var shouldMarkClicked: Bool? = nil
        if let wordItem = vocabulary.vocabulary[categoryName]?.words.first(where: { $0.native_text == nativeText }),
           wordItem.clicked != true {
            shouldMarkClicked = true
        }
        
        // Call API first (database-first approach)
        let sessionId = vocabulary.session_id ?? vocabulary.latest_session_id ?? ""
        let request = PracticeWordEventUpdateRequest(
            place_name: vocabularySelectedPlace,
            session_id: sessionId,
            session_token: sessionToken,
            category: categoryName,
            word: nativeText,
            updates: VocabularyEventUpdates(clicked: shouldMarkClicked, is_correct: isCorrect, attempts: attempts, time_taken_to_choose: timeTaken)
        )
        PracticeWordAPIManager.shared.updateWord(
            request: request,
            sessionToken: sessionToken
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success {
                    // Update cache only on success
                    self.updateWordPracticeStateInCache(
                        nativeText: nativeText,
                        category: categoryName,
                        isCorrect: isCorrect,
                        attempts: attempts
                    )
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    // MARK: - Private: Update Practice State in Cache (Called after API success)
    private func updateWordPracticeStateInCache(
        nativeText: String,
        category: String,
        isCorrect: Bool?,
        attempts: Int?
    ) {
        guard let vocabulary = vocabularyResult else { return }
        var updatedVocabulary = vocabulary.vocabulary
        
        if let categoryData = updatedVocabulary[category] {
            var updatedWords = categoryData.words
            if let wordIndex = updatedWords.firstIndex(where: { $0.native_text == nativeText }) {
                let oldWord = updatedWords[wordIndex]
                
                // Create updated word with new practice state
                let updatedWord = VocabularyItem(
                    native_text: oldWord.native_text,
                    target_text: oldWord.target_text,
                    transliteration: oldWord.transliteration,
                    clicked: true, // Mark as clicked when practice answered
                    is_correct: isCorrect ?? oldWord.is_correct,
                    attempts: attempts ?? oldWord.attempts
                )
                
                updatedWords[wordIndex] = updatedWord
                
                // Update category data
                let updatedCategoryData = CategoryData(clicked: categoryData.clicked, words: updatedWords)
                updatedVocabulary[category] = updatedCategoryData
            }
        }
        
        // Update vocabulary result
        vocabularyResult = VocabularyData(
            vocabulary: updatedVocabulary,
            session_id: vocabulary.session_id,
            latest_session_id: vocabulary.latest_session_id
        )
        
        // Update practice words selection to reflect changes
        updatePracticeWordsSelection(nativeText: nativeText, isCorrect: isCorrect, attempts: attempts)
    }
    
    // MARK: - Update Practice Words Selection (maintains consistency)
    private func updatePracticeWordsSelection(nativeText: String, isCorrect: Bool?, attempts: Int?) {
        // Update the word in practiceWordsSelection if it exists
        if let index = practiceWordsSelection.firstIndex(where: { $0.native_text == nativeText }) {
            let oldWord = practiceWordsSelection[index]
            let updatedWord = VocabularyItem(
                native_text: oldWord.native_text,
                target_text: oldWord.target_text,
                transliteration: oldWord.transliteration,
                clicked: oldWord.clicked ?? false,
                is_correct: isCorrect ?? oldWord.is_correct,
                attempts: attempts ?? oldWord.attempts
            )
            practiceWordsSelection[index] = updatedWord
        }
    }
    
    // MARK: - Similar Words Methods
    func getSimilarWords(word: String, completion: @escaping (Bool) -> Void) {
        
        // Check cache first
        if let cachedData = similarWordsCache[word] {
            self.similarWordsResult = cachedData
            completion(true)
            return
        }
        
        // Check if we have a valid session token
        guard let sessionToken = authToken, !sessionToken.isEmpty else {
            completion(false)
            return
        }
        
        isLoadingSimilarWords = true
        
        // Get language pair from user's stored pairs (find the one marked as default)
        var userLanguage: String?
        var targetLanguage: String?
        
        for pair in userLanguagePairs {
            if pair.is_default {
                userLanguage = pair.native_language
                targetLanguage = pair.target_language
                break
            }
        }
        
        // Create similar words request
        let request = SimilarWordsRequest(
            session_token: sessionToken,
            word: word,
            user_language: userLanguage ?? "English",
            target_language: targetLanguage ?? "Spanish"
        )
        
        // Call similar words API
        SimilarWordsAPIManager.shared.getSimilarWords(request: request) { result in
            DispatchQueue.main.async {
                self.isLoadingSimilarWords = false
                
                switch result {
                case .success(let response):
                    if response.success {
                        if let similarWords = response.data?.similar_words {
                            // Cache the result
                            self.similarWordsCache[word] = similarWords
                            self.similarWordsResult = similarWords
                        }
                        completion(true)
                    } else {
                        self.similarWordsError = "Unable to get similar words. Please try again."
                        self.showSimilarWordsError = true
                        completion(false)
                    }
                case .failure:
                    self.similarWordsError = "No internet connection. Please check your network and try again."
                    self.showSimilarWordsError = true
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Word Tenses Methods
    func getWordTenses(word: String, completion: @escaping (Bool) -> Void) {
        print("⏰ [APP STATE] getWordTenses called with word: '\(word)'")
        
        // Check cache first
        if let cachedData = wordTensesCache[word] {
            print("✅ [APP STATE] Found cached word tenses for: '\(word)'")
            self.wordTensesResult = cachedData
            completion(true)
            return
        }
        
        // Check if we have a valid session token
        guard let sessionToken = authToken, !sessionToken.isEmpty else {
            print("❌ [APP STATE] No session token available for word tenses")
            completion(false)
            return
        }
        
        print("✅ [APP STATE] Session token found, starting word tenses API call")
        isLoadingWordTenses = true
        
        // Get language pair from user's stored pairs (find the one marked as default)
        var userLanguage: String?
        var targetLanguage: String?
        
        for pair in userLanguagePairs {
            if pair.is_default {
                userLanguage = pair.native_language
                targetLanguage = pair.target_language
                break
            }
        }
        
        print("📋 [APP STATE] Language pair: \(userLanguage ?? "English") -> \(targetLanguage ?? "Spanish")")
        
        // Create word tenses request
        let request = WordTensesRequest(
            session_token: sessionToken,
            word: word,
            user_language: userLanguage ?? "English",
            target_language: targetLanguage ?? "Spanish"
        )
        
        print("📤 [APP STATE] Calling WordTensesAPIManager.getWordTenses")
        
        // Call word tenses API
        WordTensesAPIManager.shared.getWordTenses(request: request) { result in
            DispatchQueue.main.async {
                print("📥 [APP STATE] Word tenses API callback received")
                self.isLoadingWordTenses = false
                
                switch result {
                case .success(let response):
                    print("✅ [APP STATE] Word tenses API returned success")
                    print("✅ [APP STATE] Response success flag: \(response.success)")
                    if response.success {
                        if let tenses = response.data?.tenses {
                            print("✅ [APP STATE] Received \(tenses.count) tenses")
                            // Cache the result
                            self.wordTensesCache[word] = tenses
                            self.wordTensesResult = tenses
                            print("✅ [APP STATE] Cached and set wordTensesResult")
                        } else {
                            print("⚠️ [APP STATE] Response success but no tenses data")
                        }
                        completion(true)
                    } else {
                        print("⚠️ [APP STATE] Response success flag is false")
                        print("⚠️ [APP STATE] Response message: \(response.message ?? "nil")")
                        self.wordTensesError = "Unable to get word tenses. Please try again."
                        self.showWordTensesError = true
                        completion(false)
                    }
                case .failure(let error):
                    print("❌ [APP STATE] Word tenses API returned failure")
                    print("❌ [APP STATE] Error: \(error.localizedDescription)")
                    self.wordTensesError = "No internet connection. Please check your network and try again."
                    self.showWordTensesError = true
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Word Decomposition Methods
    func getWordDecomposition(word: String, targetWord: String, completion: @escaping (Bool) -> Void) {
        
        // Use target word as the word to decompose, cache key includes both
        let cacheKey = "\(word)_\(targetWord)"
        
        // Check cache first
        if let cachedData = wordDecompositionCache[cacheKey] {
            self.wordDecompositionResult = cachedData
            completion(true)
            return
        }
        
        // Check if we have a valid session token
        guard let sessionToken = authToken, !sessionToken.isEmpty else {
            completion(false)
            return
        }
        
        isLoadingWordDecomposition = true
        
        // Get language pair from user's stored pairs (find the one marked as default)
        var userLanguage: String?
        var targetLanguage: String?
        
        for pair in userLanguagePairs {
            if pair.is_default {
                userLanguage = pair.native_language
                targetLanguage = pair.target_language
                break
            }
        }
        
        // Create word decomposition request
        // Convert language names to codes
        let targetLanguageCode = getLanguageCode(for: targetLanguage ?? "Spanish")
        let userLanguageCode = getLanguageCode(for: userLanguage ?? "English")
        
        let request = WordDecompositionRequest(
            session_token: sessionToken,
            word: targetWord, // Use target word (foreign language) for decomposition
            target_language: targetLanguageCode,
            user_language: userLanguageCode
        )
        
        // Call word decomposition API
        WordDecompositionAPIManager.shared.getWordDecomposition(request: request) { result in
            DispatchQueue.main.async {
                self.isLoadingWordDecomposition = false
                
                switch result {
                case .success(let response):
                    if response.success {
                        if let decomposition = response.data {
                            // Cache the result
                            self.wordDecompositionCache[cacheKey] = decomposition
                            self.wordDecompositionResult = decomposition
                        }
                        completion(true)
                    } else {
                        self.wordDecompositionError = "Unable to get word breakdown. Please try again."
                        self.showWordDecompositionError = true
                        completion(false)
                    }
                case .failure:
                    self.wordDecompositionError = "No internet connection. Please check your network and try again."
                    self.showWordDecompositionError = true
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Clear Caches
    func clearWordCaches() {
        similarWordsCache.removeAll()
        wordTensesCache.removeAll()
        wordDecompositionCache.removeAll()
        similarWordsResult = nil
        wordTensesResult = nil
        wordDecompositionResult = nil
    }

    // Removed deleteAllPracticeData (legacy practice)
    
    // MARK: - OTP Methods
    func sendOTP(phone: String) {
        // Validate phone number
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPhone.isEmpty else {
            self.otpError = "Phone number cannot be empty."
            self.showOTPError = true
            return
        }
        
        // Basic phone validation: should contain only digits, +, -, spaces after trimming
        let digitsOnly = trimmedPhone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        guard digitsOnly.count >= 10, digitsOnly.count <= 20 else {
            self.otpError = "Please enter a valid phone number."
            self.showOTPError = true
            return
        }
        
        isSendingOTP = true  // Set loading to true
        
        let request = SendOTPRequest(phone_number: trimmedPhone)
        
        AuthAPIManager.shared.sendOTP(request: request) { result in
            DispatchQueue.main.async {
                self.isSendingOTP = false  // Set loading to false
                
                switch result {
                case .success(let response):
                    if response.success {
                        // ✅ OTP sent successfully
                        self.otpSent = true
                        self.otpId = response.data?.otp_id
                        self.otpExpiresInMinutes = response.data?.expires_in_minutes ?? 5
                        self.phoneNumber = phone
                    } else {
                        // ❌ OTP send failed - Show error and reset
                        self.otpError = "Unable to send OTP. Please check your phone number and try again."
                        self.showOTPError = true
                        self.resetOTPState()
                    }
                case .failure:
                    // ❌ Network error - Show error and reset
                    self.otpError = "No internet connection. Please check your network and try again."
                    self.showOTPError = true
                    self.resetOTPState()
                }
            }
        }
    }
    
    func verifyOTP(otpCode: String, username: String, profession: String? = nil) {
        // Validate inputs
        let trimmedOTP = otpCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOTP.isEmpty else {
            self.otpError = "OTP code cannot be empty."
            self.showOTPError = true
            return
        }
        
        guard trimmedOTP.count >= 4, trimmedOTP.count <= 8 else {
            self.otpError = "OTP code must be between 4 and 8 digits."
            self.showOTPError = true
            return
        }
        
        guard trimmedOTP.range(of: "^[0-9]+$", options: .regularExpression) != nil else {
            self.otpError = "OTP code must contain only numbers."
            self.showOTPError = true
            return
        }
        
        guard !trimmedUsername.isEmpty else {
            self.otpError = "Username cannot be empty."
            self.showOTPError = true
            return
        }
        
        guard trimmedUsername.count >= 2, trimmedUsername.count <= 50 else {
            self.otpError = "Username must be between 2 and 50 characters."
            self.showOTPError = true
            return
        }
        
        guard let otpId = self.otpId, !otpId.isEmpty else {
            self.otpError = "Session expired. Please request a new OTP."
            self.showOTPError = true
            self.resetOTPState()
            return
        }
        
        guard !self.phoneNumber.isEmpty else {
            self.otpError = "Phone number not found. Please request a new OTP."
            self.showOTPError = true
            self.resetOTPState()
            return
        }
        
        isVerifyingOTP = true  // Set loading to true
        
        let request = VerifyOTPRequest(
            phone_number: self.phoneNumber,
            verification_code: trimmedOTP,
            username: trimmedUsername,
            otp_id: otpId,
            profession: profession  // Optional profession
        )
        
        AuthAPIManager.shared.verifyOTP(request: request) { result in
            DispatchQueue.main.async {
                self.isVerifyingOTP = false  // Set loading to false
                
                switch result {
                case .success(let response):
                    if response.success {
                        // Validate session token exists
                        guard let sessionToken = response.data?.session_token, !sessionToken.isEmpty else {
                            self.otpError = "Session token not received. Please try again."
                            self.showOTPError = true
                            self.resetOTPState()
                            return
                        }
                        
                        // ✅ Save persistent data - No alert, proceed normally
                        self.authToken = sessionToken
                        self.username = response.data?.username ?? trimmedUsername
                        self.userPhoneNumber = response.data?.phone_number ?? self.phoneNumber
                        
                        // Store profession if provided
                        if let userProfession = response.data?.profession, !userProfession.isEmpty {
                            self.profession = userProfession
                        } else if let providedProfession = profession, !providedProfession.isEmpty {
                            // Use provided profession if not in response
                            self.profession = providedProfession
                        } else {
                        }
                        
                        // Clear temporary OTP data
                        self.otpSent = false
                        self.otpId = nil
                        self.otpExpiresInMinutes = 0
                        self.phoneNumber = ""
                        
                        // Set logged in state
                        self.isLoggedIn = true
                        
                        // Check language pairs after successful login
                        self.checkLanguagePairsAndShowModalIfNeeded()
                        
                    } else {
                        // ❌ OTP verification failed - Show error and reset
                        self.otpError = "Incorrect OTP. Please check and try again."
                        self.showOTPError = true
                        self.resetOTPState()
                    }
                case .failure:
                    // ❌ Network error - Show error and reset
                    self.otpError = "No internet connection. Please check your network and try again."
                    self.showOTPError = true
                    self.resetOTPState()
                }
            }
        }
    }
    
    func resetOTPState() {
        // Reset OTP state to allow user to try again
        self.otpSent = false
        self.otpId = nil
        self.otpExpiresInMinutes = 0
    }
    
    // MARK: - Button Visibility Check
    func checkButtonVisibility() {
        print("🔍 [BUTTON VISIBILITY] Checking guest login button visibility...")
        AuthAPIManager.shared.checkButtonVisibility { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Response format: {"visibility": "on"} or {"visibility": "off"}
                    let shouldShow = response.visibility.lowercased() == "on"
                    print("✅ [BUTTON VISIBILITY] Visibility: \(response.visibility), Showing button: \(shouldShow)")
                    self.showGuestLoginButton = shouldShow
                case .failure(let error):
                    print("❌ [BUTTON VISIBILITY] Failed to check visibility: \(error.localizedDescription)")
                    // Default to hiding button on error
                    self.showGuestLoginButton = false
                }
            }
        }
    }
    
    // MARK: - Guest Login
    @Published var isGuestLoginLoading: Bool = false
    @Published var showGuestLoginButton: Bool = false // Controls guest login button visibility
    
    func guestLogin(username: String? = nil, phoneNumber: String? = nil, profession: String? = nil) {
        isGuestLoginLoading = true
        
        let request = GuestLoginRequest(
            username: username ?? "Guest",
            phone_number: phoneNumber ?? nil,
            profession: profession ?? "Software Developer"
        )
        
        AuthAPIManager.shared.guestLogin(request: request) { result in
            DispatchQueue.main.async {
                self.isGuestLoginLoading = false
                
                switch result {
                case .success(let response):
                    if response.success, let data = response.data {
                        // Save session token
                        self.authToken = data.session_token
                        
                        // Save user data
                        self.username = data.username
                        self.userPhoneNumber = data.phone_number
                        if let userProfession = data.profession {
                            self.profession = userProfession
                        }
                        
                        // Save language pairs if available
                        if let pairs = data.language_pairs {
                            self.userLanguagePairs = pairs
                        }
                        
                        // Set logged in state
                        self.isLoggedIn = true
                        
                        // Check language pairs after successful login
                        self.checkLanguagePairsAndShowModalIfNeeded()
                    } else {
                        // Guest login failed
                        self.otpError = response.error ?? "Guest login failed. Please try again."
                        self.showOTPError = true
                    }
                case .failure(_):
                    // Network error
                    self.otpError = "No internet connection. Please check your network and try again."
                    self.showOTPError = true
                }
            }
        }
    }
    
    func logout() {
        // Clear all persistent data
        self.authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        
        // Clear temporary OTP data
        self.otpSent = false
        self.otpId = nil
        self.otpExpiresInMinutes = 0
        self.phoneNumber = ""
        
        // Set logged out state
        self.isLoggedIn = false
        
        // Clear all user data
        self.clearUserData()
    }
    
    func checkUserSession() {
        isLoadingSession = true
        isOffline = false
        isLoggedIn = false  // Start as logged out - only set true after successful validation
        
        // STEP 1: Check if session token exists
        guard let token = authToken, !token.isEmpty else {
            // No token - clear all user data and go to login
            clearUserData()
            isLoggedIn = false
            isLoadingSession = false
            return
        }
        
        
        // Token exists - but user is NOT logged in yet
        // Must validate with API endpoint first
        let request = SessionCheckRequest(session_token: token)
        
        // Set up timeout (using atomic flag to prevent race conditions)
        var hasCompleted = false
        var timeoutCancelled = false
        
        // Start timeout timer (25 seconds to give URLSession timeout (20s) a chance first)
        DispatchQueue.main.asyncAfter(deadline: .now() + 25.0) {
            guard !timeoutCancelled else {
                return
            }
            if !hasCompleted {
                hasCompleted = true
                self.isOffline = true
                self.isLoadingSession = true  // Show retry button in LoadingView
                self.isLoggedIn = false  // Validation timed out = not logged in
                // DO NOT clear authToken on timeout - keep it for retry attempt
            }
        }
        
        AuthAPIManager.shared.checkSession(request: request) { result in
            DispatchQueue.main.async {
                timeoutCancelled = true
                
                let isLateResponse = hasCompleted  // Check if timeout already fired
                
                if isLateResponse {
                } else {
                hasCompleted = true
                }
                
                // Only stop loading if we haven't timed out (keep retry screen visible)
                if !isLateResponse {
                self.isLoadingSession = false
                }
                
                switch result {
                case .success(let response):
                    // Check if session is valid
                    let isValid = response.success && (response.data?.valid == true)
                    
                    if isValid {
                        // Valid session - accept it even if timeout fired (slow network but valid)
                        self.isLoggedIn = true
                        self.isOffline = false  // Clear offline state since we got a response
                        self.isLoadingSession = false  // Stop loading when we have a valid session
                        
                        // Load user data after successful session validation
                        self.loadUserData()
                        
                        // Check language pairs during session validation
                        self.checkLanguagePairsAndShowModalIfNeeded()
                    } else {
                        // Invalid session
                        // If this is a late response and invalid, keep showing retry screen
                        if isLateResponse {
                            // Don't change any state - keep isOffline=true, isLoadingSession=true
                            return  // Exit early - don't clear token or change state
                        }
                        
                        // Only clear token if response came on time and was invalid
                        self.isLoggedIn = false
                        self.authToken = nil
                        // Clear from UserDefaults
                        UserDefaults.standard.removeObject(forKey: "authToken")
                        // Clear all user data since session is invalid
                        self.clearUserData()
                    }
                    
                case .failure(let error):
                    // Handle validation errors appropriately
                    
                    // If this is a late response and it failed, keep showing retry screen
                    if isLateResponse {
                        // Don't change any state - keep isOffline=true, isLoadingSession=true
                        return  // Exit early - user already sees retry screen from timeout
                    }
                    
                    // Only process errors if response came on time
                    // Check if it's a network error (offline)
                    if self.isNetworkError(error) {
                        // Network error - validation failed, user is NOT logged in
                        // Show retry screen - user can retry validation when network available
                        self.isOffline = true
                        self.isLoadingSession = true  // Show retry button in LoadingView
                        self.isLoggedIn = false  // Validation failed = not logged in
                        // Keep authToken so user can retry validation
                    } else if let apiError = error as? APIError {
                        // Handle APIError types
                        switch apiError {
                        case .networkError(let message):
                            if message.contains("401") || message.contains("403") {
                        self.isLoadingSession = false
                            self.isLoggedIn = false
                            self.authToken = nil
                                UserDefaults.standard.removeObject(forKey: "authToken")
                                // Clear all user data since session is invalid
                                self.clearUserData()
                        } else {
                            self.isOffline = true
                            self.isLoadingSession = true
                                self.isLoggedIn = false
                            }
                        case .noData:
                            self.isOffline = true
                            self.isLoadingSession = true
                            self.isLoggedIn = false
                        case .invalidURL:
                            self.isLoadingSession = false
                            self.isLoggedIn = false
                            self.authToken = nil
                            UserDefaults.standard.removeObject(forKey: "authToken")
                            // Clear all user data
                            self.clearUserData()
                        case .decodingError:
                            self.isLoadingSession = false
                            self.isLoggedIn = false
                            // Don't clear token on decode error - might be API issue
                        }
                    } else {
                        // Unknown error - check error message for session-related keywords
                        let errorMsg = error.localizedDescription.lowercased()
                        if errorMsg.contains("invalid session") || 
                           errorMsg.contains("unauthorized") ||
                           errorMsg.contains("401") ||
                           errorMsg.contains("403") {
                            self.isLoadingSession = false
                            self.isLoggedIn = false
                            self.authToken = nil
                            UserDefaults.standard.removeObject(forKey: "authToken")
                        } else {
                            // Unknown error - could be decode error or other issue
                            self.isLoadingSession = false
                            self.isOffline = false
                            self.isLoggedIn = false
                            self.authToken = nil
                            UserDefaults.standard.removeObject(forKey: "authToken")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Language Methods
    func showLanguageModal() {
        guard !showGlobalLanguageModal else { return }
        showGlobalLanguageModal = true
    }
    
    func hideLanguageModal() {
        showGlobalLanguageModal = false
    }
    
    func checkLanguagePairsAndShowModalIfNeeded() {
        if hasValidLanguagePair() {
            return
        }
        
        if showGlobalLanguageModal {
            return
        }
        
        showLanguageModal()
        
        if !isLoadingLanguages {
            loadAvailableLanguagePairs { hasPairs in
                if hasPairs {
                    DispatchQueue.main.async {
                        self.hideLanguageModal()
                    }
                }
            }
        }
    }
    
    func loadAvailableLanguagePairs(completion: @escaping (Bool) -> Void) {
        isLoadingLanguages = true
        
        guard let token = authToken, !token.isEmpty else {
            isLoadingLanguages = false
            completion(false)
            return
        }
        
        // Set up 10-second timeout
        var hasCompleted = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if !hasCompleted {
                hasCompleted = true
                self.isLoadingLanguages = false
                completion(false)  // Show modal on timeout
            }
        }
        
        let request = AvailableLanguagePairsRequest(session_token: token)
        
        LanguageAPIManager.shared.getAvailableLanguagePairs(request: request) { result in
            DispatchQueue.main.async {
                guard !hasCompleted else { return }  // Ignore if already timed out
                hasCompleted = true
                self.isLoadingLanguages = false
                
                switch result {
                case .success(let response):
                    if response.success {
                        let pairs = response.data?.language_pairs ?? []
                        self.userLanguagePairs = pairs
                        if !pairs.isEmpty {
                            self.shouldAttemptInferInterest = true
                        }
                        completion(!pairs.isEmpty)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    func addLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        // Convert language names to codes
        let nativeCode = getLanguageCode(for: nativeLanguage)
        let targetCode = getLanguageCode(for: targetLanguage)
        
        
        let request = AddLanguagePairRequest(
            session_token: token,
            native_language: nativeCode,
            target_language: targetCode
        )
        
        LanguageAPIManager.shared.addLanguagePair(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        // Language pair added successfully to database
                        
                        // Set this pair as default automatically
                        self.setDefaultLanguagePair(nativeLanguage: nativeCode, targetLanguage: targetCode) { _ in
                            // Refresh from API to get latest data from server
                            self.loadAvailableLanguagePairs { _ in
                                DispatchQueue.main.async {
                                    
                                    // Close modal after refresh attempt (even if refresh failed)
                                    self.hideLanguageModal()
                                    self.shouldAttemptInferInterest = true
                                    // Always return true since the pair was successfully added
                                    // Refresh failure is not critical - pair was already added to backend
                                    completion(true)
                                }
                            }
                        }
                    } else {
                        // Handle specific error cases
                        let errorMessage = response.error ?? "Unknown error"
                        let errorCode = response.error_code ?? "ERROR"
                        
                        
                        // Handle specific error codes
                        switch errorCode {
                        case "LANGUAGE_PAIR_LIMIT_REACHED":
                            break
                        case "ERROR":
                            if errorMessage.contains("already exists") {
                                break
                            } else {
                                break
                            }
                        default:
                            break
                        }
                        
                        completion(false)
                    }
                    
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getLanguageCode(for languageName: String) -> String {
        let mapping = [
            "English": "en",
            "Spanish": "es",
            "French": "fr",
            "German": "de",
            "Italian": "it",
            "Portuguese": "pt",
            "Russian": "ru",
            "Japanese": "ja",
            "Korean": "ko",
            "Chinese": "zh",
            "Arabic": "ar",
            "Hindi": "hindi",
            "Telugu": "telugu",
            "Tamil": "tamil",
            "Bengali": "bengali",
            "Gujarati": "gujarati",
            "Kannada": "kannada",
            "Malayalam": "malayalam",
            "Marathi": "marathi",
            "Punjabi": "punjabi",
            "Urdu": "urdu",
            "Turkish": "tr",
            "Dutch": "nl",
            "Swedish": "sv"
        ]
        return mapping[languageName] ?? languageName.lowercased()
    }
    
    // Set default language pair
    func setDefaultLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let request = SetDefaultLanguagePairRequest(
            session_token: token,
            native_language: nativeLanguage,
            target_language: targetLanguage
        )
        
        LanguageAPIManager.shared.setDefaultLanguagePair(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        
                        // Refresh from API to get latest data with updated is_default flags
                        self.loadAvailableLanguagePairs { _ in }
                        
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // Delete language pair
    func deleteLanguagePair(nativeLanguage: String, targetLanguage: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let request = DeleteLanguagePairRequest(
            session_token: token,
            native_language: nativeLanguage,
            target_language: targetLanguage
        )
        
        LanguageAPIManager.shared.deleteLanguagePair(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        
                        // Remove from local array
                        self.userLanguagePairs.removeAll { pair in
                            pair.native_language == nativeLanguage && pair.target_language == targetLanguage
                        }
                        
                        // Refresh from API to get latest data
                        self.loadAvailableLanguagePairs { _ in }
                        
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    // Update language pair level
    func updateLanguagePairLevel(nativeLanguage: String, targetLanguage: String, newLevel: String, completion: @escaping (Bool) -> Void) {
        
        guard let token = authToken, !token.isEmpty else {
            completion(false)
            return
        }
        
        let request = UpdateLanguagePairLevelRequest(
            session_token: token,
            native_language: nativeLanguage,
            target_language: targetLanguage,
            new_level: newLevel
        )
        
        LanguageAPIManager.shared.updateLanguagePairLevel(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        
                        // Update local array - refresh from API
                        if let _ = self.userLanguagePairs.firstIndex(where: { $0.native_language == nativeLanguage && $0.target_language == targetLanguage }) {
                            // Refresh language pairs from API
                            self.loadAvailableLanguagePairs { _ in }
                        }
                        
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    private func isNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    // MARK: - Notification Methods
    
    func updateNotificationSchedules() {
        // Disabled - no longer using API-based notification times
        // Only custom user-added times are used
    }
    
    // Update notification schedules with only custom user-added times
    func updateNotificationSchedulesWithCustomTimes(customTimes: [String]) {
        print("🔄 Updating notification schedules with custom times: \(customTimes)")
        // First cancel existing custom notifications, then schedule new ones
        NotificationService.shared.cancelCustomNotificationTimes {
            // Schedule only custom times (if notifications are enabled)
            let notificationsEnabled = self.notificationsMorning || self.notificationsAfternoon || self.notificationsEvening
            print("📊 Notifications enabled: \(notificationsEnabled), custom times count: \(customTimes.count)")
            if notificationsEnabled && !customTimes.isEmpty {
                NotificationService.shared.scheduleCustomNotificationTimes(
                    customTimes: customTimes,
                    enabled: true
                )
            } else {
                print("⚠️ Notifications not scheduled: enabled=\(notificationsEnabled), times=\(customTimes.count)")
            }
        }
    }
    
    // MARK: - Clear All Data (Centralized)
    func clearAllUserData() {
        // Clear auth token
        self.authToken = nil
        
        // Clear user data
        self.username = ""
        self.userPhoneNumber = ""
        self.profession = ""
        self.profileImageData = nil
        
        // Reset notification settings to defaults (all true)
        self.notificationsMorning = true
        self.notificationsAfternoon = true
        self.notificationsEvening = true
        
        // Cancel all scheduled notifications
        NotificationService.shared.cancelAllNotifications()
        
        // Clear language pairs
        self.userLanguagePairs = []
        
        // Clear vocabulary session_id
        self.vocabularySessionId = nil
        
        // Clear vocabulary cache
        self.vocabularyResult = nil
        UserDefaults.standard.removeObject(forKey: "vocabularyItems")
        
        // Clear practice selection
        self.practiceWordsSelection = []
        
        // Clear similar words cache
        self.similarWordsCache.removeAll()
        
        // Clear word tenses cache
        self.wordTensesCache.removeAll()
        
        // Clear image analysis
        self.imageAnalysisResult = nil
        
        // Clear quiz state and answer caches
        self.quizState = nil
        QuizState.clear()
        
        // Clear all navigation states
        self.shouldShowVocabularyView = false
        self.shouldShowSettingsView = false
        self.shouldShowQuizView = false
        
        // Reset logged in state
        self.isLoggedIn = false
        
        // Clear all UserDefaults except onboarding state
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Restore onboarding state (don't reset it)
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
    }
    
    // MARK: - Logout
    func logout(completion: @escaping (Bool, String?) -> Void) {
        guard let token = authToken else {
            clearAllUserData()
            completion(true, nil)
            return
        }
        
        let request = LogoutRequest(session_token: token)
        
        AuthAPIManager.shared.logout(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self.clearAllUserData()
                        completion(true, nil)
                    } else {
                        let errorMessage = response.error ?? "Logout failed"
                        // Clear data even if API fails
                        self.clearAllUserData()
                        completion(false, errorMessage)
                    }
                case .failure(let error):
                    // Clear data even if API fails
                    self.clearAllUserData()
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let token = authToken else {
            clearAllUserData()
            completion(false, "No session token found")
            return
        }
        
        let request = DeleteAccountRequest(session_token: token, confirm_deletion: true)
        
        AuthAPIManager.shared.deleteAccount(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self.clearAllUserData()
                        completion(true, nil)
                    } else {
                        let errorMessage = response.error ?? "Account deletion failed"
                        completion(false, errorMessage)
                    }
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}

