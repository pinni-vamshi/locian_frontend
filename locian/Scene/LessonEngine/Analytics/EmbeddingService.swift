import Foundation
import NaturalLanguage

/// Centralized factory for creating text embeddings.
/// Pure input (Text + Language) -> Output (Vector).
class EmbeddingService {
    
    // Cache models to avoid reloading
    private static var loadedStaticModels: [String: NLEmbedding] = [:]
    // wrapper struct to hold contextual model safely
    struct ContextualWrapper {
        let model: Any
    }
    private static var loadedContextualWrappers: [String: ContextualWrapper] = [:]
    
    // Cache vectors to avoid redundant computations (Text_LangCode -> Vector)
    private static var vectorCache: [String: [Double]] = [:]
    
    /// Converts any text (Brick or Pattern) into a vector for the specified language.
    /// - Parameters:
    ///   - text: The text to embed.
    ///   - languageCode: The ISO language code (e.g. "es", "fr", "en").
    /// - Returns: A Double array representing the vector, or nil if model unavailable.
    static func getVector(for text: String, languageCode: String) -> [Double]? {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return nil }
        let code = normalizeCode(languageCode)
        
        // Cache Check
        let cacheKey = "\(cleanText)_\(code)"
        if let cached = vectorCache[cacheKey] {
            return cached
        }
        
        // 1. Try Contextual Embedding (Newer, Better, Supports Tamil/Hindi)
        if #available(macOS 14.0, iOS 17.0, *) {
            if let vector = getContextualVector(for: cleanText, languageCode: code) {
                print("   🎯 [LessonFlow] [Embedding] Model: CONTEXTUAL (Priority 1) | Text: '\(cleanText.prefix(25))...' | Lang: \(code) [CACHE MISS]")
                vectorCache[cacheKey] = vector
                return vector
            }
        }
        
        // 2. Fallback to Static Embedding (Legacy, limited languages)
        if let staticModel = getStaticModel(for: code) {
            let modelType = (NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: code)) != nil) ? "STATIC_SENTENCE" : "STATIC_WORD"
            if let vector = staticModel.vector(for: cleanText) {
                print("   ⚠️ [LessonFlow] [Embedding] Model: \(modelType) (Fallback) | Text: '\(cleanText.prefix(25))...' | Lang: \(code) [CACHE MISS]")
                vectorCache[cacheKey] = vector
                return vector
            }
        }
        
        print("   ❌ [LessonFlow] [Embedding] NO MODEL AVAILABLE for '\(cleanText)' (\(languageCode))")
        return nil
    }
    
    // MARK: - Contextual Embedding (New)
    
    @available(macOS 14.0, iOS 17.0, *)
    private static func getContextualVector(for text: String, languageCode: String) -> [Double]? {
        let code = normalizeCode(languageCode)
        guard let model = getContextualModel(for: code) else { return nil }
        let lang = NLLanguage(rawValue: code)
        
        do {
            // NLContextualEmbeddingResult provided by model
            let result = try model.embeddingResult(for: text, language: lang)
            
            var sumVector = [Double](repeating: 0.0, count: model.dimension)
            var tokenCount = 0
            
            // Correct API: enumerateTokenVectors(in:using:)
            result.enumerateTokenVectors(in: text.startIndex..<text.endIndex) { vector, range in
                for i in 0..<min(vector.count, sumVector.count) {
                    sumVector[i] += vector[i]
                }
                tokenCount += 1
                return true
            }
            
            if tokenCount > 0 {
                // Return averaged vector as a sentence heuristic
                return sumVector.map { $0 / Double(tokenCount) }
            }
        } catch {
            print("   ⚠️ [Embedding] Contextual error for '\(text)': \(error.localizedDescription)")
        }
        
        return nil 
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    @available(macOS 14.0, iOS 17.0, *)
    private static func getContextualModel(for languageCode: String) -> NLContextualEmbedding? {
        let code = normalizeCode(languageCode) // ensure we use the normalized code for cache key
        
        if let wrapper = loadedContextualWrappers[code], let model = wrapper.model as? NLContextualEmbedding {
            return model
        }
        
        let lang = NLLanguage(rawValue: code)
        // Only valid if this language is supported by the OS
        if let model = NLContextualEmbedding(language: lang) {
            print("   🧠 [EmbeddingService] Loaded/Cached Contextual Model for '\(code)'")
            loadedContextualWrappers[code] = ContextualWrapper(model: model)
            return model
        }
        return nil
    }

    
    // MARK: - Static Embedding (Legacy)
    
    private static func getStaticModel(for code: String) -> NLEmbedding? {
        if let cached = loadedStaticModels[code] { return cached }
        
        let lang = NLLanguage(rawValue: code)
        
        // Try Sentence Embedding First
        if let sentenceModel = NLEmbedding.sentenceEmbedding(for: lang) {
            print("   🧠 [EmbeddingService] Loaded Static Sentence Model for '\(code)'")
            loadedStaticModels[code] = sentenceModel
            return sentenceModel
        }
        
        // Fallback to Word Embedding
        if let wordModel = NLEmbedding.wordEmbedding(for: lang) {
            print("   🧠 [EmbeddingService] Loaded Static Word Model for '\(code)'")
            loadedStaticModels[code] = wordModel
            return wordModel
        }
        
        return nil
    }
    
    // MARK: - Utilities
    
    /// Normalizes language codes for Embedding models.
    /// Specifically maps 'zh' -> 'zh-Hans' for Chinese Simplified context.
    private static func normalizeCode(_ code: String) -> String {
        if code.lowercased() == "zh" { return "zh-Hans" }
        return code
    }
    
    static func resetCache() {
        print("🔄 [EmbeddingService] Clearing internal model cache...")
        loadedStaticModels.removeAll()
        loadedContextualWrappers.removeAll()
        vectorCache.removeAll()
    }
    
    static func cosineSimilarity(v1: [Double], v2: [Double]) -> Double {
        // Ensure dimensions match roughly (or truncate/pad if needed, but ideally they match)
        // Comparison of mixed vectors (Contextual vs Static) is technically mathematically weak,
        // but for "Is this remotely similar?" it acts as a heuristic.
        // Ideally, we compare V1(Contextual) vs V2(Contextual) OR V1(Static) vs V2(Static).
        
        let count = min(v1.count, v2.count)
        var dot = 0.0
        var mag1 = 0.0
        var mag2 = 0.0
        
        for i in 0..<count {
            dot += v1[i] * v2[i]
            mag1 += v1[i] * v1[i]
            mag2 += v2[i] * v2[i]
        }
        
        if mag1 == 0 || mag2 == 0 { return 0.0 }
        return dot / (sqrt(mag1) * sqrt(mag2))
    }
    
    static func compare(textA: String, textB: String, languageCode: String) -> Double {
        let code = normalizeCode(languageCode)
        
        // 1 & 2: Try Neural Embeddings (Contextual or Static)
        if let v1 = getVector(for: textA, languageCode: code),
           let v2 = getVector(for: textB, languageCode: code) {
            return cosineSimilarity(v1: v1, v2: v2)
        }
        
        // 3. Tertiary Fallback: Normalized Levenshtein Distance
        // This ensures Locians have "brain activity" even without downloaded models.
        let s1 = textA.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let s2 = textB.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !s1.isEmpty && !s2.isEmpty else { return 0.0 }
        
        let dist = Double(levenshteinDistance(s1, s2))
        let maxLen = Double(max(s1.count, s2.count))
        
        let score = 1.0 - (dist / maxLen)
        
        print("   ⚠️ [EmbeddingService] [FALLBACK] Using Levenshtein for '\(s1)' vs '\(s2)' -> Score: \(String(format: "%.3f", score))")
        
        return score
    }
    
    /// Utility for 3rd-tier fallback matching
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let a = Array(s1)
        let b = Array(s2)
        var dist = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)
        
        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i][j] = dist[i-1][j-1]
                } else {
                    dist[i][j] = min(dist[i-1][j] + 1, dist[i][j-1] + 1, dist[i-1][j-1] + 1)
                }
            }
        }
        return dist[a.count][b.count]
    }
    
    static func isModelAvailable(for code: String) -> Bool {
        let code = normalizeCode(code)
        // 1. Check Contextual (Preferred)
        if #available(macOS 14.0, iOS 17.0, *) {
            let lang = NLLanguage(rawValue: code)
            
            // Note: Instantiating NLContextualEmbedding might print "Unsupported locale" if assets are missing.
            // This is a system log we cannot suppress, but we can verify the object is valid.
            if let model = NLContextualEmbedding(language: lang) {
                // If assets are available, we are good.
                if model.hasAvailableAssets { 
                    print("   🧠 [EmbeddingService] Status: CONTEXTUAL Model is ready for '\(code)'")
                    return true 
                } else {
                    // Valid model, but needs download.
                    print("   ⚠️ [EmbeddingService] Status: CONTEXTUAL assets missing for '\(code)'. Checking Legacy...")
                    // DO NOT return false here. Fall through to check static.
                }
            }
        }
        
        // 2. Check Static (Fallback)
        let lang = NLLanguage(rawValue: code)
        if NLEmbedding.sentenceEmbedding(for: lang) != nil { 
            print("   🧠 [EmbeddingService] Status: STATIC (Legacy) Model is ready for '\(code)'")
            return true 
        }
        if NLEmbedding.wordEmbedding(for: lang) != nil { 
            print("   🧠 [EmbeddingService] Status: STATIC (Legacy) Model is ready for '\(code)'")
            return true 
        }
        
        return false
    }

    /// Returns the highest available model tier for a given language code.
    static func getAvailableMode(for code: String) -> String {
        let code = normalizeCode(code)
        
        // 1. Contextual
        if #available(macOS 14.0, iOS 17.0, *) {
            let lang = NLLanguage(rawValue: code)
            if let model = NLContextualEmbedding(language: lang), model.hasAvailableAssets { 
                return "CONTEXTUAL" 
            }
        }
        
        // 2. Static
        let lang = NLLanguage(rawValue: code)
        if NLEmbedding.sentenceEmbedding(for: lang) != nil || NLEmbedding.wordEmbedding(for: lang) != nil { 
            return "STATIC"
        }
        
        // 3. Fallback
        return "LEVENSHTEIN"
    }
    
    static func downloadModel(for code: String, completion: @escaping (Bool) -> Void) {
        let code = normalizeCode(code)
        print("⬇️ [EmbeddingService] Requesting assets for '\(code)'...")
        
        // 1. Try Contextual Download (New)
        if #available(macOS 14.0, iOS 17.0, *) {
            // Use getContextualModel to ensure the instance is retained in static cache
            // preventing deallocation during the async request
            if let model = getContextualModel(for: code) {
                print("   ⬇️ [Embedding] Contextual Model found for '\(code)'. Requesting assets...")
                
                var isCompleted = false
                
                // Timeout Failsafe (15 seconds)
                DispatchQueue.global().asyncAfter(deadline: .now() + 15) {
                    if !isCompleted {
                        print("   ⏰ [Embedding] Contextual download TIMED OUT for '\(code)' (15s). Falling back to legacy...")
                        isCompleted = true // Prevent double callback
                        downloadStaticModel(for: code, completion: completion)
                    }
                }
                
                model.requestAssets { result, error in
                    if isCompleted { return } // Already timed out
                    isCompleted = true
                    
                    if result == .available {
                        print("   🎉 [Embedding] SUCCESS: Downloaded CONTEXTUAL Assets for '\(code)'.")
                        completion(true)
                    } else {
                         print("   ⚠️ [Embedding] Contextual download failed for '\(code)'. Error: \(error?.localizedDescription ?? "Unknown"). Trying legacy...")
                         downloadStaticModel(for: code, completion: completion)
                    }
                }
                return
            } else {
                print("   ⚠️ [Embedding] Contextual Model NOT supported for '\(code)' (nil). Trying legacy...")
            }
        }
        
        // 2. Static Download (Legacy)
        downloadStaticModel(for: code, completion: completion)
    }
    
    private static func downloadStaticModel(for code: String, completion: @escaping (Bool) -> Void) {
        let lang = NLLanguage(rawValue: code)
        var isCompleted = false
        
        // Timeout Failsafe (5 seconds for static)
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            if !isCompleted {
                print("   ⏰ [Embedding] Static download TIMED OUT for '\(code)' (5s).")
                isCompleted = true
                completion(false)
            }
        }
        
        NLTagger.requestAssets(for: lang, tagScheme: NLTagScheme.tokenType) { result, error in
            if isCompleted { return }
            isCompleted = true
            
            if result == .available {
                print("   🎉 [Embedding] SUCCESS: Downloaded STATIC Assets for '\(code)'.")
                completion(true)
            } else {
                print("   ❌ [Embedding] Static Assets unavailable for '\(code)'. Error: \(error?.localizedDescription ?? "Unknown")")
                completion(false)
            }
        }
    }
    
    static func isContextualAvailable(for languageCode: String) -> Bool {
        let code = normalizeCode(languageCode)
        if #available(macOS 14.0, iOS 17.0, *) {
            // Check cache or capability
            if let _ = loadedContextualWrappers[code] { return true }
            let lang = NLLanguage(rawValue: code)
            if let _ = NLContextualEmbedding(language: lang) { return true }
        }
        return false
    }
}
