import Foundation
import Combine

// MARK: - Data Models



// MARK: - Service

class SemanticMemoryService: ObservableObject {
    static let shared = SemanticMemoryService()
    
    private let fileName = "semantic_memory_db.json"
    private var db: SemanticDatabase
    
    // Fast Lookup: "Lang_Text" -> Index
    private var index: [String: Int] = [:]
    
    private init() {
        self.db = SemanticDatabase(version: 1, entries: [])
        load()
    }
    
    // MARK: - Linear Pipeline Entrance
    
    /// Processes enriched lesson data: Saves vectors and retrieves mastered scores
    func processLessonData(data: inout GenerateSentenceData) {
        guard let langCode = data.target_language else { return }
        print("\n🏛️ [MemoryService] Processing Lesson Data (Localized Groups)...")
        
        // 1. Process Groups
        if var groups = data.groups {
            for i in 0..<groups.count {
                // A. Prerequisites
                if var prereqs = groups[i].prerequisites {
                    for j in 0..<prereqs.count {
                        syncAndDecorate(item: &prereqs[j], languageCode: langCode)
                    }
                    groups[i].prerequisites = prereqs
                }
                
                // B. Patterns
                if var patterns = groups[i].patterns {
                    for j in 0..<patterns.count {
                        syncAndDecorate(pattern: &patterns[j], languageCode: langCode)
                    }
                    groups[i].patterns = patterns
                }
                
                // C. Bricks
                if var bricks = groups[i].bricks {
                    if var c = bricks.constants {
                        for j in 0..<c.count { syncAndDecorate(item: &c[j], languageCode: langCode) }
                        bricks.constants = c
                    }
                    if var v = bricks.variables {
                        for j in 0..<v.count { syncAndDecorate(item: &v[j], languageCode: langCode) }
                        bricks.variables = v
                    }
                    if var s = bricks.structural {
                        for j in 0..<s.count { syncAndDecorate(item: &s[j], languageCode: langCode) }
                        bricks.structural = s
                    }
                    groups[i].bricks = bricks
                }
            }
            data.groups = groups
        }
        
        // 2. Process Legacy Top-Level items (safety)
        if var patterns = data.patterns {
            for i in 0..<patterns.count { syncAndDecorate(pattern: &patterns[i], languageCode: langCode) }
            data.patterns = patterns
        }
        
        if var bricks = data.bricks {
            if var c = bricks.constants { for i in 0..<c.count { syncAndDecorate(item: &c[i], languageCode: langCode) } ; bricks.constants = c }
            if var v = bricks.variables { for i in 0..<v.count { syncAndDecorate(item: &v[i], languageCode: langCode) } ; bricks.variables = v }
            if var s = bricks.structural { for i in 0..<s.count { syncAndDecorate(item: &s[i], languageCode: langCode) } ; bricks.structural = s }
            data.bricks = bricks
        }
        
        print("🏛️ [MemoryService] Lesson Data Processed. Saving DB...")
        save()
    }
    
    private func syncAndDecorate(item: inout BrickItem, languageCode: String) {
        let text = item.meaning
        let vector = item.vector
        
        // Update DB with vector if provided
        if let vector = vector {
            updateVectorOnly(text: text, vector: vector, languageCode: languageCode)
        }
        
        // Retrieve Mastery
        item.mastery = getEffectiveMastery(text: text, vector: vector, languageCode: languageCode)
    }
    
    private func syncAndDecorate(pattern: inout PatternData, languageCode: String) {
        let text = pattern.meaning
        let vector = pattern.vector
        
        if let vector = vector {
            updateVectorOnly(text: text, vector: vector, languageCode: languageCode)
        }
        
        pattern.mastery = getEffectiveMastery(text: text, vector: vector, languageCode: languageCode)
    }
    
    private func updateVectorOnly(text: String, vector: [Double], languageCode: String) {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let existingIdx = db.entries.firstIndex(where: { $0.text == cleanText && $0.languageCode == languageCode }) {
            db.entries[existingIdx].vector = vector
        } else {
            // New entry with default mastery
            let newItem = MemoryEntry(
                id: UUID().uuidString,
                text: cleanText,
                languageCode: languageCode,
                vector: vector,
                masteryScore: 0.1,
                stability: 1.0,
                lastPracticed: Date(),
                lastRecallStep: 0
            )
            db.entries.append(newItem)
            updateIndex(for: newItem, at: db.entries.count - 1)
        }
    }
    
    // MARK: - Core API
    
    /// Retrieves a concept's mastery with FULL decay (Daily + Session)
    func getEffectiveMastery(
        text: String,
        vector: [Double]?,
        languageCode: String,
        currentStep: Int = 0
    ) -> Double {
        print("🧠 [MemoryService] getEffectiveMastery: '\(text)' (Lang: \(languageCode))")
        let entry = getEntry(text: text, vector: vector, languageCode: languageCode)
        guard let item = entry else { 
            print("   ⚠️ [MemoryService] No entry found for '\(text)'")
            return 0.0 
        }
        
        // 1. DAILY DECAY (Date based)
        let daysSince = Date().timeIntervalSince(item.lastPracticed) / (24 * 3600)
        let dayDecayFactor = pow(0.9, daysSince / max(1.0, item.stability))
        let dayDecayedScore = item.masteryScore * dayDecayFactor
        
        // 2. SESSION DECAY (Step based)
        let stepsSince = max(0, currentStep - item.lastRecallStep)
        let sessionDecay = stepsSince == 0 ? 0.0 : Double(stepsSince) * 0.02
        
        let finalScore = max(0.0, dayDecayedScore - sessionDecay)
        
        print("   ✅ [MemoryService] Entry Found. Calculating Decay:")
        print("      ↳ Stats: Mastery=\(item.masteryScore), Stability=\(item.stability), LastSeen=\(item.lastPracticed)")
        print("      ↳ Day Decay: \(String(format: "%.3f", dayDecayFactor)) (\(String(format: "%.2f", daysSince)) days since)")
        print("      ↳ Session Decay: -\(String(format: "%.2f", sessionDecay)) (\(stepsSince) steps since)")
        print("      ↳ Effective Mastery: \(String(format: "%.4f", finalScore))")
        
        return finalScore
    }
    
    /// Updates the recall performance and INSTANTLY saves to disk
    func updateRecall(
        text: String,
        vector: [Double]?,
        languageCode: String,
        isCorrect: Bool,
        currentStep: Int
    ) {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        print("💾 [MemoryService] updateRecall: '\(cleanText)' (Lang: \(languageCode), Correct: \(isCorrect))")
        
        var item: MemoryEntry
        var isNew = false
        
        if let existing = getEntry(text: cleanText, vector: vector, languageCode: languageCode) {
            print("   🔄 [MemoryService] Updating existing entry for '\(cleanText)'")
            item = existing
        } else {
            guard let vec = vector else { 
                print("   ❌ [MemoryService] Cannot create new entry: Missing vector!")
                return 
            }
            print("   🆕 [MemoryService] Creating NEW entry for '\(cleanText)'")
            isNew = true
            item = MemoryEntry(
                id: UUID().uuidString,
                text: cleanText,
                languageCode: languageCode,
                vector: vec,
                masteryScore: 0.1,
                stability: 1.0,
                lastPracticed: Date(),
                lastRecallStep: currentStep
            )
        }
        
        let oldScore = item.masteryScore
        let oldStability = item.stability
        
        // 1. Apply Spaced Repetition Math
        item.lastPracticed = Date()
        if isCorrect {
            item.masteryScore = min(1.0, item.masteryScore + 0.1)
            item.stability = min(30.0, item.stability * 1.5)
            item.lastRecallStep = currentStep // Reset decay timer
        } else {
            item.masteryScore = max(0.0, item.masteryScore - 0.2)
            item.stability = max(1.0, item.stability * 0.5)
            // Note: We DON'T reset lastRecallStep on fail
        }
        
        print("   📊 [MemoryService] Result: Score \(String(format: "%.2f", oldScore)) -> \(String(format: "%.2f", item.masteryScore))")
        print("   📊 [MemoryService] Stability: \(String(format: "%.2f", oldStability)) -> \(String(format: "%.2f", item.stability))")
        
        // 2. Update Database
        if isNew {
            db.entries.append(item)
            updateIndex(for: item, at: db.entries.count - 1)
        } else if let idx = db.entries.firstIndex(where: { $0.id == item.id }) {
            db.entries[idx] = item
        }
        
        // 3. INSTANT SAVE
        save()
    }
    
    // MARK: - Private Helpers
    
    private func getEntry(text: String, vector: [Double]?, languageCode: String) -> MemoryEntry? {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let key = "\(languageCode)_\(cleanText)"
        
        // 1. Exact Match
        if let idx = index[key] { 
            // print("   🎯 [MemoryService] Exact Match found via Index: \(key)")
            return db.entries[idx] 
        }
        
        // 2. Fuzzy Match (Vector)
        guard let searchVector = vector else { return nil }
        var bestMatch: (index: Int, sim: Double)?
        
        // print("   🔍 [MemoryService] No exact match. Scanning \(db.entries.count) entries for fuzzy match...")
        
        for (i, entry) in db.entries.enumerated() {
            guard entry.languageCode == languageCode else { continue }
            
            let sim = EmbeddingService.cosineSimilarity(v1: searchVector, v2: entry.vector)
            if sim > 0.85 {
                if bestMatch == nil || sim > bestMatch!.sim {
                    bestMatch = (i, sim)
                }
            }
        }
        
        if let match = bestMatch {
            print("   🧱 [MemoryService] Fuzzy Match Found: '\(cleanText)' matches '\(db.entries[match.index].text)' (Sim: \(String(format: "%.3f", match.sim)))")
            return db.entries[match.index]
        }
        
        return nil
    }
    
    private func updateIndex(for entry: MemoryEntry, at idx: Int) {
        let key = "\(entry.languageCode)_\(entry.text)"
        index[key] = idx
    }
    
    // MARK: - Persistence
    
    private func getFileURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }
    
    private func save() {
        print("💾 [MemoryService] Initiating Background Save...")
        let snapshot = self.db // Capture value type on Main Actor
        do {
            // Encode on Main Actor to satisfy isolation requirements
            let data = try JSONEncoder().encode(snapshot)
            
            DispatchQueue.global(qos: .background).async {
                do {
                    try data.write(to: self.getFileURL())
                    print("   ✅ [MemoryService] Database saved to local disk (Total Items: \(snapshot.entries.count))")
                } catch {
                    print("   ❌ [MemoryService] Save FAILED: \(error.localizedDescription)")
                }
            }
        } catch {
            print("   ❌ [MemoryService] Encoding FAILED: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        print("📂 [MemoryService] Loading Database from disk...")
        let url = getFileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { 
            print("   ℹ️ [MemoryService] No local database found. Starting fresh.")
            return 
        }
        do {
            let data = try Data(contentsOf: url)
            self.db = try JSONDecoder().decode(SemanticDatabase.self, from: data)
            self.index = [:]
            for (i, entry) in db.entries.enumerated() {
                updateIndex(for: entry, at: i)
            }
            print("   ✅ [MemoryService] Successfully loaded \(db.entries.count) concept records.")
        } catch {
            print("   ❌ [MemoryService] Load FAILED: \(error.localizedDescription)")
        }
    }
}
