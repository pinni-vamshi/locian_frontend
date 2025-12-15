import Foundation

struct QuizState: Codable {
    var quiz_session_id: String
    var ordered_question_ids: [String]
    var questions: [String: QuizQuestion]
    var selectedAnswers: [String: QuizAnswerData] = [:]  // question_id -> answer data
    var checkedAnswers: [String: Bool] = [:]  // question_id -> isCorrect
    var currentQuestionIndex: Int = 0
    
    // Simple tracking for wrong/slow questions
    var questionTimes: [String: Double] = [:]  // question_id -> time taken in seconds
    var questionAttempts: [String: Int] = [:]  // question_id -> number of attempts
    var firstAttemptResults: [String: Bool] = [:]  // question_id -> isCorrect on FIRST attempt only
    var wrongQuestions: [String] = []  // Question IDs that were wrong (choosing type only)
    var slowQuestions: [String] = []  // Question IDs that took >6s (choosing type only)
    var isShowingWrongQuestions: Bool = false  // Whether showing wrong questions after quiz
    var wrongQuestionIndex: Int = 0  // Current index in wrong questions
    var optionRenderOrder: [String: [Int]] = [:]

    static let storageKey = "quiz_state"

    static func load() -> QuizState? {
        // Use file storage instead of UserDefaults for potentially large quiz state
        if let state: QuizState = FileStorageManager.shared.load(QuizState.self, forKey: storageKey) {
            return state
        }
        
        // Migrate from UserDefaults if exists (one-time migration)
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let state = try? JSONDecoder().decode(QuizState.self, from: data) {
            _ = FileStorageManager.shared.save(state, forKey: storageKey)
            UserDefaults.standard.removeObject(forKey: storageKey)
            return state
        }
        
        return nil
    }

    func save() {
        // Use file storage instead of UserDefaults for potentially large quiz state
        _ = FileStorageManager.shared.save(self, forKey: QuizState.storageKey)
    }
    
    static func clear() {
        FileStorageManager.shared.delete(forKey: storageKey)
        // Also clear from UserDefaults if exists (migration cleanup)
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    // MARK: - Simple Logic Functions
    
    // Next button only shows when answer is CORRECT
    func shouldShowNextButton(questionId: String, checkedAnswers: [String: Bool], selectedAnswers: [String: QuizAnswerData], currentQuestion: QuizQuestion?) -> Bool {
        // Must have an answer selected
        guard selectedAnswers[questionId] != nil else { return false }
        
        // For multiple choice and fill blank: only show Next if CORRECT
        if let isCorrect = checkedAnswers[questionId] {
            return isCorrect
        }
        return false
    }
    
    // Collect wrong and slow questions (choosing type only)
    mutating func collectWrongAndSlowQuestions(checkedAnswers: [String: Bool], questionTimes: [String: Double]) {
        wrongQuestions = []
        slowQuestions = []
        
        
        for questionId in ordered_question_ids {
            guard let question = questions[questionId] else { continue }
            
            // Only include "choosing" type (multiple_choice)
            let isChoosingType: Bool
            switch question {
            case .multiple_choice:
                isChoosingType = true
            case .fill_blank, .ordering:
                isChoosingType = false
            }
            
            if !isChoosingType {
                continue
            }
            
            // Check if wrong - only consider FIRST attempt result
            // This ensures we only count questions that were wrong on first try, not after multiple attempts
            let firstAttemptResult = firstAttemptResults[questionId]
            let firstAttemptWasWrong = firstAttemptResult == false
            
            
            if firstAttemptWasWrong {
                wrongQuestions.append(questionId)
            }
            
            // Check if took > 6 seconds
            if let timeTaken = questionTimes[questionId], timeTaken > 6.0 {
                slowQuestions.append(questionId)
            }
        }
        
        
        // Combine: wrong first, then slow (up to 5 total)
        var combined: [String] = []
        for questionId in wrongQuestions {
            if combined.count < 5 {
                combined.append(questionId)
            }
        }
        for questionId in slowQuestions {
            if combined.count >= 5 { break }
            if !combined.contains(questionId) {
                combined.append(questionId)
            }
        }
        
        wrongQuestions = combined
    }
    
    func getCurrentQuestionId() -> String? {
        if isShowingWrongQuestions {
            guard wrongQuestionIndex < wrongQuestions.count else {
                return nil
            }
            return wrongQuestions[wrongQuestionIndex]
        } else {
            guard currentQuestionIndex < ordered_question_ids.count else {
                return nil
            }
            return ordered_question_ids[currentQuestionIndex]
        }
    }
    
    func getTotalQuestions() -> Int {
        if isShowingWrongQuestions {
            return wrongQuestions.count
        } else {
            return ordered_question_ids.count
        }
    }
    
    func getCurrentQuestionNumber() -> Int {
        if isShowingWrongQuestions {
            return wrongQuestionIndex + 1
        } else {
            return currentQuestionIndex + 1
        }
    }
    
    func getProgress() -> Double {
        let total = getTotalQuestions()
        guard total > 0 else { return 0 }
        if isShowingWrongQuestions {
            return Double(wrongQuestionIndex + 1) / Double(total)
        } else {
            return Double(currentQuestionIndex + 1) / Double(total)
        }
    }
}

// Helper struct to encode/decode answer data (supports Int for MC/FB)
enum QuizAnswerData: Codable {
    case intValue(Int)
    case intArray([Int])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .intValue(intVal)
        } else if let intArr = try? container.decode([Int].self) {
            self = .intArray(intArr)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode QuizAnswerData")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .intValue(let val):
            try container.encode(val)
        case .intArray(let arr):
            try container.encode(arr)
        }
    }
    
    var intValue: Int? {
        if case .intValue(let val) = self { return val }
        return nil
    }
    
    var intArray: [Int]? {
        if case .intArray(let arr) = self { return arr }
        return nil
    }
}


