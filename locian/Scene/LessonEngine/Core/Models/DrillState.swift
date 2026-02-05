import Foundation
import SwiftUI

// MARK: - Core Enums (Moved from LessonEnums)

enum DrillMode: String, Codable {
    case mcq = "MCQ"
    case voiceMcq = "Voice-MCQ"
    case typing = "Typing"
    case voiceTyping = "Voice-Typing"
    case voiceNativeTyping = "Voice-Native-Typing"
    case sentenceBuilder = "Sentence-Builder"
    case vocabMatch = "VocabMatch"
    case mastery = "Mastery"
    case vocabIntro = "Vocab-Intro"
    case componentMcq = "Component-MCQ"
    case cloze = "Cloze"
    case componentTyping = "Component-Typing"
    case speaking = "Speaking"
    case ghostManager = "Ghost-Manager"
    
    var displayName: String {
        switch self {
        case .mcq: return "MULTIPLE CHOICE"
        case .voiceMcq: return "AUDIO MCQ"
        case .typing: return "TYPING"
        case .voiceTyping: return "DICTATION"
        case .voiceNativeTyping: return "TRANSLATION"
        case .sentenceBuilder: return "SENTENCE BUILDER"
        case .vocabMatch: return "VOCAB MATCH"
        case .mastery: return "MASTERY"
        case .componentMcq: return "BRICK MCQ"
        case .cloze: return "COMPLETE THE SENTENCE"
        case .componentTyping: return "BRICK TYPING"
        case .speaking: return "SPEAKING"
        case .vocabIntro: return "VOCAB INTRODUCTION"
        case .ghostManager: return "REHEARSAL"
        }
    }
}

enum DrillResult: String, Codable {
    case correct = "Correct"
    case wrong = "Wrong"
    case skipped = "Skipped"
    case nearMiss = "NearMiss"
}

enum DrillType: String, Codable {
    case vocabMatch
    case multipleChoice
    case reorder
    case typing
    case dictation
    case listenAndTranslate
    case speaking
    case masteryCheck
    case cloze
    case vocabIntro
}

struct DrillResultEntry: Codable {
    let id: String
    let patternId: String
    let lastResult: DrillResult
    let currentMode: DrillMode?
}

struct BrickAnalysisResult: Codable {
    let brickId: String
    let word: String
    let isCorrect: Bool
    let similarity: Double
    let masteryChange: Double
}

// MARK: - DrillState (Purified Carrier)

struct DrillState: Identifiable, Codable {
    let id: String
    let patternId: String
    let drillIndex: Int
    let drillData: DrillItem
    
    // UI Context
    var hint: String?
    var contextMeaning: String?
    var contextSentence: String?
    
    // Stateless Metadata (Per-Session)
    var isBrick: Bool
    var masteryScore: Double = 0.0 // Single point of truth for UI/Dispatch
    
    // JIT Content (for specific modes)
    var batchBricks: [BrickItem]?
    var embedding: [Double]?
    var mcqOptions: [String]?
    
    // Logic state (Transient)
    var currentMode: DrillMode?
}


