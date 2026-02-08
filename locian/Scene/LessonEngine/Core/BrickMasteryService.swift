import Foundation
import Combine

// MARK: - Data Models

struct BrickMasteryEntry: Codable, Identifiable {
    var id: String
    var text: String
    var vector: [Double]
    
    var masteryScore: Double // 0.0 - 1.0
    var stability: Double    // Half-life in days
    var lastPracticed: Date
    
    struct HistoryItem: Codable {
        let date: Date
        let result: String // "SUCCESS" | "FAIL"
        let mode: String   // "typing", "speaking", etc.
        let timeTaken: TimeInterval
    }
    
    var history: [HistoryItem]
    
    // Computed property for "Deduction Memory" (Decay)
    var effectiveScore: Double {
        let daysSince = Date().timeIntervalSince(lastPracticed) / (24 * 3600)
        // Decay Formula: Score * (0.9 ^ (Days / Stability))
        // High stability (10) -> Days/10 -> Slower decay
        // Low stability (1) -> Days/1 -> Fast decay
        let decayFactor = pow(0.9, daysSince / max(1.0, stability))
        return masteryScore * decayFactor
    }
}

struct BrickDatabase: Codable {
    var version: Int
    var bricks: [BrickMasteryEntry]
}

// MARK: - Service

class BrickMasteryService: ObservableObject {
    static let shared = BrickMasteryService()
    
    private let fileName = "semantic_brick_db.json"
    private var db: BrickDatabase
    
    // Fast Lookup Cache
    private var textIndex: [String: Int] = [:] // Text -> Index in db.bricks
    
    init() {
        self.db = BrickDatabase(version: 1, bricks: [])
        load()
    }
    
    // MARK: - Core API
    
    /// Retrieves a brick's mastery, using Fuzzy Vector Search if needed.
    func getBrick(text: String, vector: [Double]?) -> BrickMasteryEntry? {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Tier 1: Exact Match (O(1))
        if let index = textIndex[cleanText] {
            // print("   🧱 [MasteryDB] Exact Match found for '\(cleanText)'")
            return db.bricks[index]
        }
        
        // Tier 2: Vector Search (O(N))
        guard let searchVector = vector else { return nil }
        
        // Only scan if we have vectors
        // Optimization: Simple linear scan is fine for <5k items.
        // For larger, we'd use a VP-Tree or similar, but User has ~2k items max typically.
        
        var bestMatch: (index: Int, sim: Double)?
        
        for (i, entry) in db.bricks.enumerated() {
            let sim = EmbeddingService.cosineSimilarity(v1: searchVector, v2: entry.vector)
            if sim > 0.85 { // Threshold
                if bestMatch == nil || sim > bestMatch!.sim {
                    bestMatch = (i, sim)
                }
            }
        }
        
        if let match = bestMatch {
            print("   🧱 [MasteryDB] Fuzzy Match: '\(cleanText)' ~= '\(db.bricks[match.index].text)' (Sim: \(match.sim))")
            return db.bricks[match.index]
        }
        
        return nil
    }
    
    /// Updates or Creates a brick entry based on practice result
    func updateBrick(text: String, vector: [Double]?, mode: String, isCorrect: Bool) {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var entry: BrickMasteryEntry
        var isNew = false
        
        if let existing = getBrick(text: cleanText, vector: vector) {
            entry = existing
        } else {
            // Create New
            guard let vec = vector else {
                 print("   ⚠️ [MasteryDB] Cannot create entry for '\(cleanText)' without vector!")
                 return 
            }
            isNew = true
            entry = BrickMasteryEntry(
                id: UUID().uuidString,
                text: cleanText,
                vector: vec,
                masteryScore: 0.1, // Start low
                stability: 1.0,    // Volatile
                lastPracticed: Date(),
                history: []
            )
        }
        
        // Update Logic
        let resultStr = isCorrect ? "SUCCESS" : "FAIL"
        entry.lastPracticed = Date()
        
        // Stability Growth (Simple Spaced Repetition Logic)
        if isCorrect {
            entry.masteryScore = min(1.0, entry.masteryScore + 0.1)
            entry.stability = min(30.0, entry.stability * 1.5) // Grows exponential-ish
        } else {
            entry.masteryScore = max(0.0, entry.masteryScore - 0.2)
            entry.stability = max(1.0, entry.stability * 0.5) // Penalty
        }
        
        // Log History
        let log = BrickMasteryEntry.HistoryItem(date: Date(), result: resultStr, mode: mode, timeTaken: 0)
        entry.history.append(log)
        // Keep history trim
        if entry.history.count > 10 { entry.history.removeFirst() }
        
        // Save back to DB array
        if isNew {
            db.bricks.append(entry)
            textIndex[cleanText] = db.bricks.count - 1
            print("   🧱 [MasteryDB] Created NEW entry for '\(cleanText)'")
        } else {
            // Find index again (since getBrick returns copy)
            // Ideally we'd optimize this but linear lookup by ID is safe
            if let idx = db.bricks.firstIndex(where: { $0.id == entry.id }) {
                db.bricks[idx] = entry
            }
            print("   🧱 [MasteryDB] Updated entry for '\(cleanText)' (Score: \(entry.masteryScore))")
        }
        
        save()
    }
    
    // MARK: - Persistence
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    private func save() {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(self.db)
                try data.write(to: self.getFileURL())
                print("   💾 [MasteryDB] Saved \(self.db.bricks.count) bricks to disk.")
            } catch {
                print("   ❌ [MasteryDB] Save Failed: \(error)")
            }
        }
    }
    
    private func load() {
        let url = getFileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            self.db = try JSONDecoder().decode(BrickDatabase.self, from: data)
            
            // Rebuild Index
            self.textIndex = [:]
            for (i, b) in db.bricks.enumerated() {
                self.textIndex[b.text] = i
            }
            print("   📂 [MasteryDB] Loaded \(db.bricks.count) bricks.")
        } catch {
            print("   ❌ [MasteryDB] Load Failed: \(error)")
        }
    }
}
