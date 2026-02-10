import Foundation

// MARK: - Data Models

struct MemoryEntry: Codable, Identifiable, Sendable {
    var id: String
    var text: String
    var languageCode: String // The "Namespace" (e.g. "Spanish", "French")
    var vector: [Double]
    
    var masteryScore: Double // 0.0 - 1.0 (Raw score)
    var stability: Double    // Days for score to decay by 10%
    var lastPracticed: Date
    
    // TRACKING: The last session step this was correctly recalled
    var lastRecallStep: Int = 0
}

struct SemanticDatabase: Codable, Sendable {
    var version: Int
    var entries: [MemoryEntry]
}
