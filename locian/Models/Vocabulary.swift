import Foundation

// MARK: - Clicked Words Request
struct ClickedWordsRequest: Codable {
    let target_language: String?
}

// MARK: - Clicked Words Response
struct ClickedWordsResponse: Codable {
    let success: Bool
    let data: ClickedWordsData?
    let message: String?
    let error: String?
    let error_code: String?
    let timestamp: String?
    let request_id: String?
}

// MARK: - Clicked Words Category (with words array)
struct ClickedWordsCategory: Codable {
    let clicked: Bool
    let words: [VocabularyItem]
}

// MARK: - Clicked Words Place (contains categories)
struct ClickedWordsPlace: Codable {
    let categories: [String: ClickedWordsCategory]
    
    // Custom initializer for creating from categories dictionary
    init(categories: [String: ClickedWordsCategory]) {
        self.categories = categories
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var categoriesDict: [String: ClickedWordsCategory] = [:]
        
        for key in container.allKeys {
            if let category = try? container.decode(ClickedWordsCategory.self, forKey: key) {
                categoriesDict[key.stringValue] = category
            }
        }
        
        self.categories = categoriesDict
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (key, value) in categories {
            if let codingKey = DynamicCodingKeys(stringValue: key) {
                try container.encode(value, forKey: codingKey)
            }
        }
    }
}

struct ClickedWordsData: Codable {
    // NEW FORMAT: Nested structure: Place -> Category -> Words
    let places: [String: ClickedWordsPlace]?
    
    // OLD FORMAT: Flat structure with clicked_words
    let clicked_words: [String: ClickedWord]?
    let count: Int?
    
    enum CodingKeys: String, CodingKey {
        case clicked_words
        case count
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        // Check if this is the new nested format (Place -> Category -> Words)
        // New format has place names as top-level keys (e.g., "Home", "Office", "Airport")
        var placesDict: [String: ClickedWordsPlace] = [:]
        var isNewFormat = false
        
        // Try to decode as new format first
        for key in container.allKeys {
            // Skip known old format keys
            if key.stringValue == "clicked_words" || key.stringValue == "count" {
                continue
            }
            
            // Try to decode as a place (which contains categories)
            if let place = try? container.decode(ClickedWordsPlace.self, forKey: key) {
                placesDict[key.stringValue] = place
                isNewFormat = true
            }
        }
        
        if isNewFormat && !placesDict.isEmpty {
            self.places = placesDict
            self.clicked_words = nil
            self.count = nil
        } else {
            // Fallback to old format
            self.places = nil
            
            // Try nested "clicked_words" first (old preferred format)
            if let clickedWordsKey = DynamicCodingKeys(stringValue: "clicked_words"),
               let nestedWords = try? container.decodeIfPresent([String: ClickedWord].self, forKey: clickedWordsKey) {
                self.clicked_words = nestedWords
                if let countKey = DynamicCodingKeys(stringValue: "count") {
                    self.count = try? container.decodeIfPresent(Int.self, forKey: countKey)
                } else {
                    self.count = nil
                }
            } else {
                // Fallback: if backend returns words directly in "data"
            let singleContainer = try decoder.singleValueContainer()
            if let directWords = try? singleContainer.decode([String: ClickedWord].self) {
                self.clicked_words = directWords
                self.count = directWords.count
            } else {
                // Last resort: try to decode as object and extract all ClickedWord values
                var words: [String: ClickedWord] = [:]
                    for key in container.allKeys {
                    if key.stringValue != "count" {
                            if let word = try? container.decode(ClickedWord.self, forKey: key) {
                            words[key.stringValue] = word
                        }
                    }
                }
                    self.clicked_words = words.isEmpty ? nil : words
                    if let countKey = DynamicCodingKeys(stringValue: "count") {
                        self.count = try? container.decodeIfPresent(Int.self, forKey: countKey) ?? (words.isEmpty ? nil : words.count)
                    } else {
                        self.count = words.isEmpty ? nil : words.count
                    }
                }
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        
        if let places = places {
            // Encode new format
            for (placeName, place) in places {
                if let key = DynamicCodingKeys(stringValue: placeName) {
                    try container.encode(place, forKey: key)
                }
            }
        } else if let clickedWords = clicked_words {
            // Encode old format
            if let key = DynamicCodingKeys(stringValue: "clicked_words") {
                try container.encode(clickedWords, forKey: key)
            }
            if let count = count, let key = DynamicCodingKeys(stringValue: "count") {
                try container.encode(count, forKey: key)
            }
        }
    }
    
    // Helper to get all words as ClickedWord array (for backward compatibility)
    func getAllWordsAsClickedWords() -> [ClickedWord] {
        if let places = places {
            // Extract all words from nested structure
            var allWords: [ClickedWord] = []
            for (_, place) in places {
                for (_, category) in place.categories {
                    for word in category.words {
                        // Convert VocabularyItem to ClickedWord
                        let clickedWord = ClickedWord(
                            native_text: word.native_text,
                            target_text: word.target_text,
                            transliteration: word.transliteration
                        )
                        allWords.append(clickedWord)
            }
        }
            }
            return allWords
        } else if let clickedWords = clicked_words {
            // Old format - return as array
            return Array(clickedWords.values)
        }
        return []
    }
}

// Helper for dynamic keys
struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}

struct ClickedWord: Codable, Identifiable, Equatable {
    var id: String { native_text }
    let native_text: String
    let target_text: String
    let transliteration: String
    
    init(native_text: String, target_text: String, transliteration: String) {
        self.native_text = native_text
        self.target_text = target_text
        self.transliteration = transliteration
    }
    
    static func == (lhs: ClickedWord, rhs: ClickedWord) -> Bool {
        lhs.native_text == rhs.native_text && lhs.target_text == rhs.target_text
    }
}

// MARK: - Previous Place (for previous_places array)
struct PreviousPlace: Codable {
    let place_name: String
    let time: String      // Full time string, e.g., "Friday, December 12, 2:00 PM"
    let date: String      // Date in YYYY-MM-DD format, e.g., "2025-12-12"
}

// MARK: - Future Place (for future_places array)
struct FuturePlace: Codable {
    let place_name: String
    let time: String      // Full time string, e.g., "Friday, December 12, 6:00 PM"
    let date: String      // Date in YYYY-MM-DD format, e.g., "2025-12-12"
}

// MARK: - Vocabulary Request
struct VocabularyRequest: Codable {
    // Session token is sent via Authorization header, not in body
    
    // REQUIRED fields (validated before request creation)
    let user_language: String?   // REQUIRED - e.g., "en" (validated before request)
    let target_language: String? // REQUIRED - e.g., "es", "ta", "zh" (validated before request)
    
    // OPTIONAL fields
    let place_name: String?      // OPTIONAL - scene/place name (exact as-is, no cleaning) - the current clicked place
    let place_detail: String?    // OPTIONAL - place detail (for image analysis only, max 200 chars)
    let time: String?            // OPTIONAL - Human-readable time string, e.g., "Saturday, December 13, 5:51 PM"
    let profession: String?      // OPTIONAL - User's profession, e.g., "software_engineer", "student"
    let user_name: String?      // OPTIONAL - User's name
    let user_level: String?      // OPTIONAL - User's level (e.g., "BEGINNER", "INTERMEDIATE", "ADVANCED")
    let previous_places: [PreviousPlace]? // OPTIONAL - Array of previous places (past moments)
    let future_places: [FuturePlace]?     // OPTIONAL - Array of future places (future moments)
    
    // Required for studied places saving (if provided, endpoint automatically saves to studied_places)
    let latitude: Double?        // REQUIRED for studied places - Latitude coordinate, e.g., 17.228375339202632
    let longitude: Double?      // REQUIRED for studied places - Longitude coordinate, e.g., 80.15349197661854
    let date: String?            // REQUIRED for studied places - Date in YYYY-MM-DD format, e.g., "2025-12-13"
    
    // Custom encoder to ensure latitude, longitude, and date are always included when present
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode all fields, including optional ones
        try container.encodeIfPresent(user_language, forKey: .user_language)
        try container.encodeIfPresent(target_language, forKey: .target_language)
        try container.encodeIfPresent(place_name, forKey: .place_name)
        try container.encodeIfPresent(place_detail, forKey: .place_detail)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(profession, forKey: .profession)
        try container.encodeIfPresent(user_name, forKey: .user_name)
        try container.encodeIfPresent(user_level, forKey: .user_level)
        try container.encodeIfPresent(previous_places, forKey: .previous_places)
        try container.encodeIfPresent(future_places, forKey: .future_places)
        
        // CRITICAL: Always encode latitude, longitude, and date if they have values
        // These are required for studied places saving
        if let lat = latitude {
            try container.encode(lat, forKey: .latitude)
        }
        if let lon = longitude {
            try container.encode(lon, forKey: .longitude)
        }
        if let dateValue = date {
            try container.encode(dateValue, forKey: .date)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case user_language
        case target_language
        case place_name
        case place_detail
        case time
        case profession
        case user_name
        case user_level
        case previous_places
        case future_places
        case latitude
        case longitude
        case date
    }
}

// MARK: - Vocabulary Response (from generate endpoint)
struct VocabularyResponse: Codable {
    let success: Bool
    let message: String?
    let data: VocabularyGenerateData?
    let error: String?
    let error_code: String?
    let timestamp: String?
    let request_id: String?
}

// MARK: - Vocabulary Generate Data
struct VocabularyGenerateData: Codable {
    // New API format: only micro_situations (no vocabulary words)
    let micro_situations: [String]?
    let place_name: String?
    let profession: String?
    let time: String? // Time field from API response
    
    // Old API format: vocabulary words (for backward compatibility)
    let vocabulary: [String: VocabularyCategoryFlexible]?
    let session_id: String?
    let latest_session_id: String?
    let success: Bool? // Some API responses include nested success field - ignore it
    
    // Custom CodingKeys to handle optional nested fields
    enum CodingKeys: String, CodingKey {
        case micro_situations
        case vocabulary
        case session_id
        case latest_session_id
        case place_name
        case profession
        case time
        case success // Ignore this nested success field if present
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode new format: micro_situations (array of strings)
        micro_situations = try container.decodeIfPresent([String].self, forKey: .micro_situations)
        
        // Decode old format: vocabulary (for backward compatibility)
        vocabulary = try container.decodeIfPresent([String: VocabularyCategoryFlexible].self, forKey: .vocabulary)
        
        // Decode session IDs (optional)
        session_id = try container.decodeIfPresent(String.self, forKey: .session_id)
        latest_session_id = try container.decodeIfPresent(String.self, forKey: .latest_session_id)
        
        // Decode new fields (optional)
        place_name = try container.decodeIfPresent(String.self, forKey: .place_name)
        profession = try container.decodeIfPresent(String.self, forKey: .profession)
        time = try container.decodeIfPresent(String.self, forKey: .time)
        
        // Decode nested success field if present (but ignore it)
        success = try container.decodeIfPresent(Bool.self, forKey: .success)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(micro_situations, forKey: .micro_situations)
        try container.encodeIfPresent(vocabulary, forKey: .vocabulary)
        try container.encodeIfPresent(session_id, forKey: .session_id)
        try container.encodeIfPresent(latest_session_id, forKey: .latest_session_id)
        try container.encodeIfPresent(place_name, forKey: .place_name)
        try container.encodeIfPresent(profession, forKey: .profession)
        try container.encodeIfPresent(time, forKey: .time)
        // Don't encode success field
    }
    
    // Helper to convert to VocabularyData format (for backward compatibility)
    func toVocabularyData() -> VocabularyData? {
        // If we have vocabulary (old format), convert it
        if let vocabulary = vocabulary {
            var converted: [String: CategoryData] = [:]
            for (key, value) in vocabulary {
                converted[key] = value.toCategoryData()
            }
            return VocabularyData(
                vocabulary: converted,
                session_id: session_id,
                latest_session_id: latest_session_id
            )
        }
        // New format: no vocabulary, only micro_situations
        return nil
    }
}

// MARK: - Flexible Vocabulary Category (handles both array and object formats)
enum VocabularyCategoryFlexible: Codable {
    case array([VocabularyItem])
    case object(CategoryData)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Try to decode as array first (new API format)
        if let array = try? container.decode([VocabularyItem].self) {
            self = .array(array)
            return
        }
        
        // Try to decode as object (old API format with clicked field)
        if let object = try? container.decode(CategoryData.self) {
            self = .object(object)
            return
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode VocabularyCategoryFlexible")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let items):
            try container.encode(items)
        case .object(let categoryData):
            try container.encode(categoryData)
        }
    }
    
    func toCategoryData() -> CategoryData {
        switch self {
        case .array(let words):
            // New format: just array of words, default clicked to false, last_clicked to nil
            return CategoryData(clicked: false, last_clicked: nil, words: words)
        case .object(let categoryData):
            // Old format: already has clicked field
            return categoryData
        }
    }
}

// MARK: - Vocabulary Data (from generate endpoint - includes tracking fields)
struct VocabularyData: Codable {
    let vocabulary: [String: CategoryData]
    let session_id: String?
    let latest_session_id: String?
    
    // Helper to get all words flattened (for backward compatibility)
    var allWords: [VocabularyItem] {
        vocabulary.values.flatMap { $0.words }
    }
    
    // Helper to get category names
    var categories: [String] {
        Array(vocabulary.keys).sorted()
    }
    
    // Helper to get words for a category
    func words(for category: String) -> [VocabularyItem] {
        vocabulary[category]?.words ?? []
    }
}

// MARK: - Category Data (includes tracking)
struct CategoryData: Codable {
    let clicked: Bool
    let last_clicked: String?    // New field: ISO 8601 datetime string or null
    let words: [VocabularyItem]
    
    enum CodingKeys: String, CodingKey {
        case clicked
        case last_clicked
        case words
    }
    
    init(clicked: Bool, last_clicked: String? = nil, words: [VocabularyItem]) {
        self.clicked = clicked
        self.last_clicked = last_clicked
        self.words = words
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clicked = try container.decode(Bool.self, forKey: .clicked)
        last_clicked = try container.decodeIfPresent(String.self, forKey: .last_clicked)
        words = try container.decode([VocabularyItem].self, forKey: .words)
    }
}

// MARK: - Quiz Stats
struct VocabularyQuizStats: Codable {
    let total_quizzed: Int?
    let last_quizzed: String?
    let days_since_last_quiz: Int?
    let avg_attempts: Double?
    let avg_time: Double?
    let correct_rate: Double?
    let first_attempt_correct_rate: Double?
}

// MARK: - Vocabulary Item (with tracking fields)
struct VocabularyItem: Codable, Identifiable {
    let id: UUID
    
    // ============================================
    // BASIC WORD INFORMATION
    // ============================================
    let native_text: String
    let native_language: String?
    let target_text: String
    let target_language: String?
    let transliteration: String
    let category: String?
    
    // ============================================
    // GENERATION METADATA
    // ============================================
    let generated_at: String?
    let generated_date: String?
    let generation_session_id: String?
    
    // ============================================
    // USER-SPECIFIC CLICKED STATES
    // ============================================
    let clicked: Bool?
    let clicked_count: Int?
    let last_clicked: String?
    let similar_words_clicked: Bool?
    let word_tenses_clicked: Bool?
    let breakdown_clicked: Bool?
    
    // ============================================
    // CACHE FLAGS
    // ============================================
    let tenses_cached: Bool?
    let tenses_last_updated: String?
    let similar_words_cached: Bool?
    let similar_words_last_updated: String?
    let breakdown_cached: Bool?
    let breakdown_last_updated: String?
    
    // ============================================
    // QUIZ HISTORY & STATS
    // ============================================
    let quiz_history: [String]?
    let quiz_stats: VocabularyQuizStats?
    
    // ============================================
    // REBUILD FEATURE TRACKING
    // ============================================
    let rebuild: VocabularyRebuildState?
    
    // ============================================
    // LEARN POV (PERSPECTIVE) TRACKING
    // ============================================
    let learn_pov: [String]? // List of up to 3 text strings for POV learning
    
    // ============================================
    // LEGACY FIELDS
    // ============================================
    let is_correct: Bool?
    let attempts: Int?
    
    // Custom initializer for manual creation
    init(
        native_text: String,
        target_text: String,
        transliteration: String,
        native_language: String? = nil,
        target_language: String? = nil,
        category: String? = nil,
        generated_at: String? = nil,
        generated_date: String? = nil,
        generation_session_id: String? = nil,
        clicked: Bool? = nil,
        clicked_count: Int? = nil,
        last_clicked: String? = nil,
        similar_words_clicked: Bool? = nil,
        word_tenses_clicked: Bool? = nil,
        breakdown_clicked: Bool? = nil,
        tenses_cached: Bool? = nil,
        tenses_last_updated: String? = nil,
        similar_words_cached: Bool? = nil,
        similar_words_last_updated: String? = nil,
        breakdown_cached: Bool? = nil,
        breakdown_last_updated: String? = nil,
        quiz_history: [String]? = nil,
        quiz_stats: VocabularyQuizStats? = nil,
        rebuild: VocabularyRebuildState? = nil,
        learn_pov: [String]? = nil,
        is_correct: Bool? = nil,
        attempts: Int? = nil
    ) {
        self.id = UUID()
        self.native_text = native_text
        self.native_language = native_language
        self.target_text = target_text
        self.target_language = target_language
        self.transliteration = transliteration
        self.category = category
        self.generated_at = generated_at
        self.generated_date = generated_date
        self.generation_session_id = generation_session_id
        self.clicked = clicked
        self.clicked_count = clicked_count
        self.last_clicked = last_clicked
        self.similar_words_clicked = similar_words_clicked
        self.word_tenses_clicked = word_tenses_clicked
        self.breakdown_clicked = breakdown_clicked
        self.tenses_cached = tenses_cached
        self.tenses_last_updated = tenses_last_updated
        self.similar_words_cached = similar_words_cached
        self.similar_words_last_updated = similar_words_last_updated
        self.breakdown_cached = breakdown_cached
        self.breakdown_last_updated = breakdown_last_updated
        self.quiz_history = quiz_history
        self.quiz_stats = quiz_stats
        self.rebuild = rebuild
        self.learn_pov = learn_pov
        self.is_correct = is_correct
        self.attempts = attempts
    }
    
    // Custom decoder to generate UUID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        
        // Basic word information
        self.native_text = try container.decode(String.self, forKey: .native_text)
        self.native_language = try container.decodeIfPresent(String.self, forKey: .native_language)
        self.target_text = try container.decode(String.self, forKey: .target_text)
        self.target_language = try container.decodeIfPresent(String.self, forKey: .target_language)
        self.transliteration = try container.decode(String.self, forKey: .transliteration)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        
        // Generation metadata
        self.generated_at = try container.decodeIfPresent(String.self, forKey: .generated_at)
        self.generated_date = try container.decodeIfPresent(String.self, forKey: .generated_date)
        self.generation_session_id = try container.decodeIfPresent(String.self, forKey: .generation_session_id)
        
        // User-specific clicked states
        self.clicked = try container.decodeIfPresent(Bool.self, forKey: .clicked)
        self.clicked_count = try container.decodeIfPresent(Int.self, forKey: .clicked_count)
        self.last_clicked = try container.decodeIfPresent(String.self, forKey: .last_clicked)
        self.similar_words_clicked = try container.decodeIfPresent(Bool.self, forKey: .similar_words_clicked)
        self.word_tenses_clicked = try container.decodeIfPresent(Bool.self, forKey: .word_tenses_clicked)
        self.breakdown_clicked = try container.decodeIfPresent(Bool.self, forKey: .breakdown_clicked)
        
        // Cache flags
        self.tenses_cached = try container.decodeIfPresent(Bool.self, forKey: .tenses_cached)
        self.tenses_last_updated = try container.decodeIfPresent(String.self, forKey: .tenses_last_updated)
        self.similar_words_cached = try container.decodeIfPresent(Bool.self, forKey: .similar_words_cached)
        self.similar_words_last_updated = try container.decodeIfPresent(String.self, forKey: .similar_words_last_updated)
        self.breakdown_cached = try container.decodeIfPresent(Bool.self, forKey: .breakdown_cached)
        self.breakdown_last_updated = try container.decodeIfPresent(String.self, forKey: .breakdown_last_updated)
        
        // Quiz history & stats
        self.quiz_history = try container.decodeIfPresent([String].self, forKey: .quiz_history)
        self.quiz_stats = try container.decodeIfPresent(VocabularyQuizStats.self, forKey: .quiz_stats)
        
        // Rebuild feature
        self.rebuild = try container.decodeIfPresent(VocabularyRebuildState.self, forKey: .rebuild)
        
        // Learn POV feature
        self.learn_pov = try container.decodeIfPresent([String].self, forKey: .learn_pov)
        
        // Legacy fields
        self.is_correct = try container.decodeIfPresent(Bool.self, forKey: .is_correct)
        self.attempts = try container.decodeIfPresent(Int.self, forKey: .attempts)
    }
    
    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Basic word information
        try container.encode(native_text, forKey: .native_text)
        try container.encodeIfPresent(native_language, forKey: .native_language)
        try container.encode(target_text, forKey: .target_text)
        try container.encodeIfPresent(target_language, forKey: .target_language)
        try container.encode(transliteration, forKey: .transliteration)
        try container.encodeIfPresent(category, forKey: .category)
        
        // Generation metadata
        try container.encodeIfPresent(generated_at, forKey: .generated_at)
        try container.encodeIfPresent(generated_date, forKey: .generated_date)
        try container.encodeIfPresent(generation_session_id, forKey: .generation_session_id)
        
        // User-specific clicked states
        try container.encodeIfPresent(clicked, forKey: .clicked)
        try container.encodeIfPresent(clicked_count, forKey: .clicked_count)
        try container.encodeIfPresent(last_clicked, forKey: .last_clicked)
        try container.encodeIfPresent(similar_words_clicked, forKey: .similar_words_clicked)
        try container.encodeIfPresent(word_tenses_clicked, forKey: .word_tenses_clicked)
        try container.encodeIfPresent(breakdown_clicked, forKey: .breakdown_clicked)
        
        // Cache flags
        try container.encodeIfPresent(tenses_cached, forKey: .tenses_cached)
        try container.encodeIfPresent(tenses_last_updated, forKey: .tenses_last_updated)
        try container.encodeIfPresent(similar_words_cached, forKey: .similar_words_cached)
        try container.encodeIfPresent(similar_words_last_updated, forKey: .similar_words_last_updated)
        try container.encodeIfPresent(breakdown_cached, forKey: .breakdown_cached)
        try container.encodeIfPresent(breakdown_last_updated, forKey: .breakdown_last_updated)
        
        // Quiz history & stats
        try container.encodeIfPresent(quiz_history, forKey: .quiz_history)
        try container.encodeIfPresent(quiz_stats, forKey: .quiz_stats)
        
        // Rebuild feature
        try container.encodeIfPresent(rebuild, forKey: .rebuild)
        
        // Learn POV feature
        try container.encodeIfPresent(learn_pov, forKey: .learn_pov)
        
        // Legacy fields
        try container.encodeIfPresent(is_correct, forKey: .is_correct)
        try container.encodeIfPresent(attempts, forKey: .attempts)
    }
    
    // Custom coding keys to exclude id from Codable
    private enum CodingKeys: String, CodingKey {
        case native_text, native_language, target_text, target_language, transliteration, category
        case generated_at, generated_date, generation_session_id
        case clicked, clicked_count, last_clicked
        case similar_words_clicked, word_tenses_clicked, breakdown_clicked
        case tenses_cached, tenses_last_updated
        case similar_words_cached, similar_words_last_updated
        case breakdown_cached, breakdown_last_updated
        case quiz_history, quiz_stats
        case rebuild
        case learn_pov
        case is_correct, attempts
    }
}

// MARK: - Rebuild state (nested object on vocabulary word)
struct VocabularyRebuildState: Codable {
    let clicked: Bool?
    let is_correct: Bool?
    let attempts: Int?
}

// MARK: - Vocabulary Event Batch Request
struct VocabularyEventBatchRequest: Codable {
    let place_name: String
    let session_id: String
    let events: [VocabularyEventBatchItem]
}

struct VocabularyEventBatchItem: Codable {
    let category: String
    let word: String
    let updates: VocabularyEventBatchUpdates
}

struct VocabularyEventBatchUpdates: Codable {
    let clicked: Bool?
    let is_correct: Bool?
    let attempts: Int?
    let time_taken_to_choose: Double?
    let similar_words_clicked: Bool?
    let word_tenses_clicked: Bool?
    // New API fields
    let breakdown_clicked: Bool?
    let rebuild: VocabularyRebuildUpdates?
    
    // Backward-compatibility (legacy)
    let breakdown: VocabularyBreakdownUpdates?
}

struct VocabularyBreakdownUpdates: Codable {
    let clicked: Bool?
    let is_correct: Bool?
    let attempts: Int?
}

// MARK: - Rebuild updates (new API)
struct VocabularyRebuildUpdates: Codable {
    let clicked: Bool?
    let is_correct: Bool?
    let attempts: Int?
}

struct VocabularyEventBatchResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
    let data: VocabularyEventBatchResponseData?
}

struct VocabularyEventBatchResponseData: Codable {
    let errors: [VocabularyEventBatchError]?
}

struct VocabularyEventBatchError: Codable {
    let index: Int?
    let place_name: String?
    let session_id: String?
    let category: String?
    let word: String?
    let error: String?
}

// MARK: - Bulk Vocabulary Update Request
struct VocabularyBulkUpdateRequest: Codable {
    let vocabulary: [String: CategoryData]
    let session_id: String
    let place_name: String
    let target_language: String?
}

// MARK: - Bulk Vocabulary Update Response
struct VocabularyBulkUpdateResponse: Codable {
    let success: Bool
    let message: String?
    let data: VocabularyBulkUpdateData?
    let error: String?
    let error_code: String?
    let status_code: Int?
}

struct VocabularyBulkUpdateData: Codable {
    let updated_count: Int?
    let categories_updated: Int?
    let update_results: [String]?
    let retrieved_vocabulary: [String: VocabularyCategoryFlexible]?
    let session_id: String?
    let place_name: String?
}
