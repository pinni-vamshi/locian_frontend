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
        print("\n🆔 [Embedding] getVector START | Text: '\(text)' | Lang: '\(languageCode)'")
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        print("   🧹 [Embedding] Cleaned Text: '\(cleanText)'")
        
        guard !cleanText.isEmpty else {
            print("   ❌ [Embedding] Text is empty. Returning nil.")
            return nil
        }
        
        let code = normalizeCode(languageCode)
        print("   🌍 [Embedding] Normalized Language Code: '\(code)'")
        
        // Cache Check
        let cacheKey = "\(cleanText)_\(code)"
        print("   🔑 [Embedding] Checking Cache Key: '\(cacheKey)'")
        if let cached = vectorCache[cacheKey] {
            print("   🟢 [Embedding] Cache HIT for '\(cleanText)'")
            print("   📦 [Embedding] Cached Vector Dim: \(cached.count)")
            // print("   🔢 [Embedding] Cached Vector (First 5): \(cached.prefix(5))") // Optional
            return cached
        }
        print("   🟠 [Embedding] Cache MISS. Proceeding to generation.")
        
        print("   🚀 [Embedding] Requesting Vector Generation: '\(cleanText)' (Lang: \(code))")
        
        // 1. Try Contextual Embedding (Newer, Better, Supports Tamil/Hindi)
        print("   🔍 [Embedding] Attempting Contextual Embedding (Priority 1)...")
        if #available(macOS 14.0, iOS 17.0, *) {
            print("   💻 [Embedding] OS Version Check: PASS (iOS 17+ / macOS 14+)")
            if let vector = getContextualVector(for: cleanText, languageCode: code) {
                print("   🎯 [Embedding] Model: CONTEXTUAL | Success")
                print("   📏 [Embedding] Vector Dimension: \(vector.count)")
                print("   📝 [Embedding] Text Preview: '\(cleanText.prefix(25))...'")
                
                print("   📊 [Embedding] RAW VECTOR DATA (First 10 values):")
                print("      " + vector.prefix(10).map { String(format: "%.4f", $0) }.joined(separator: ", "))
                print("   📊 [Embedding] RAW VECTOR DATA (Last 5 values):")
                print("      " + vector.suffix(5).map { String(format: "%.4f", $0) }.joined(separator: ", "))
                
                vectorCache[cacheKey] = vector
                print("   💾 [Embedding] Saved to cache.")
                return vector
            } else {
                print("   ⚠️ [Embedding] Contextual Vector Generation FAILED for '\(cleanText)'.")
            }
        } else {
            print("   ⚠️ [Embedding] OS Version Check: FAIL (Contextual not supported)")
        }
        
        // 2. Fallback to Static Embedding (Legacy, limited languages)
        print("   🔍 [Embedding] Attempting Static Embedding (Priority 2)...")
        if let staticModel = getStaticModel(for: code) {
            let modelType = (NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: code)) != nil) ? "STATIC_SENTENCE" : "STATIC_WORD"
            print("   ℹ️ [Embedding] Static Model Found: \(modelType)")
            
            if let vector = staticModel.vector(for: cleanText) {
                print("   ⚠️ [Embedding] Model: \(modelType) (Fallback) | Success")
                print("   📏 [Embedding] Vector Dimension: \(vector.count)")
                
                print("   📊 [Embedding] RAW STATIC VECTOR (First 10):")
                 print("      " + vector.prefix(10).map { String(format: "%.4f", $0) }.joined(separator: ", "))
                
                vectorCache[cacheKey] = vector
                print("   💾 [Embedding] Saved to cache.")
                return vector
            } else {
                print("   ❌ [Embedding] Static vector() returned nil for '\(cleanText)'")
            }
        } else {
             print("   ❌ [Embedding] No Static Model found for '\(code)'")
        }

        print("   ❌ [Embedding] FAILED: No model available for '\(cleanText)' (\(languageCode)) -> Parsed: \(code)")
        print("   🚫 [Embedding] Returning nil.")
        return nil
    }
    
    // MARK: - Contextual Embedding (New)
    
    // MARK: - Contextual Embedding (New)
    
    @available(macOS 14.0, iOS 17.0, *)
    private static func getContextualVector(for text: String, languageCode: String) -> [Double]? {
        print("      🧠 [Contextual] getContextualVector START | Text: '\(text)'")
        let code = normalizeCode(languageCode)
        
        guard let model = getContextualModel(for: code) else {
            print("      ❌ [Contextual] getContextualModel returned nil for '\(code)'")
            return nil
        }
        print("      ✅ [Contextual] Model retrieved successfully.")
        
        let lang = NLLanguage(rawValue: code)
        
        do {
            // NLContextualEmbeddingResult provided by model
            print("      🧠 [Contextual] Requesting embeddingResult...")
            let result = try model.embeddingResult(for: text, language: lang)
            print("      ✅ [Contextual] embeddingResult generated.")
            
            var sumVector = [Double](repeating: 0.0, count: model.dimension)
            var tokenCount = 0
            
            print("      🧠 [Embedding: Contextual] Enumerating tokens for '\(text.prefix(15))...'")
            
            // Correct API: enumerateTokenVectors(in:using:)
            result.enumerateTokenVectors(in: text.startIndex..<text.endIndex) { vector, range in
                // print("         🔹 [Token] Processing vector dim: \(vector.count)")
                for i in 0..<min(vector.count, sumVector.count) {
                    sumVector[i] += vector[i]
                }
                tokenCount += 1
                return true
            }
            
            print("      🧠 [Embedding: Contextual] Processed \(tokenCount) tokens. Averaging vector...")
            
            if tokenCount > 0 {
                // Return averaged vector as a sentence heuristic
                let finalVector = sumVector.map { $0 / Double(tokenCount) }
                print("      ✅ [Contextual] Vector averaging complete. Dim: \(finalVector.count)")
                return finalVector
            } else {
                print("      ⚠️ [Contextual] Token count is 0.")
            }
        } catch {
            print("   ⚠️ [Embedding] Contextual error for '\(text)': \(error.localizedDescription)")
            print("   ❌ [Contextual] Exception: \(error)")
        }
        
        return nil
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    private static func getContextualModel(for languageCode: String) -> NLContextualEmbedding? {
        print("      🔎 [ContextualLoader] Looking up model for '\(languageCode)'...")
        let code = normalizeCode(languageCode)
        
        if let wrapper = loadedContextualWrappers[code], let model = wrapper.model as? NLContextualEmbedding {
            print("      🟢 [ContextualLoader] Found in internal cache.")
            return model
        }
        
        let lang = NLLanguage(rawValue: code)
        print("      🆕 [ContextualLoader] Instantiating NLContextualEmbedding(language: \(code))...")
        if let model = NLContextualEmbedding(language: lang) {
            print("      🧠 [Embedding] Loaded/Cached Contextual Model for '\(code)'")
            loadedContextualWrappers[code] = ContextualWrapper(model: model)
            print("      ✅ [ContextualLoader] Saved to cache. Has Assets: \(model.hasAvailableAssets)")
            return model
        }
        print("      ❌ [ContextualLoader] Initialization failed.")
        return nil
    }

    // MARK: - Static Embedding (Legacy)
    
    private static func getStaticModel(for code: String) -> NLEmbedding? {
        print("      🔎 [StaticLoader] Looking up static model for '\(code)'...")
        if let cached = loadedStaticModels[code] {
             print("      🟢 [StaticLoader] Found in static cache.")
             return cached
        }
        
        let lang = NLLanguage(rawValue: code)
        
        // Try Sentence Embedding First
        print("      ❓ [StaticLoader] Checking sentenceEmbedding...")
        if let sentenceModel = NLEmbedding.sentenceEmbedding(for: lang) {
            print("      🧠 [Embedding] Loaded Static Sentence Model for '\(code)'")
            loadedStaticModels[code] = sentenceModel
            print("      ✅ [StaticLoader] Cached Sentence Model.")
            return sentenceModel
        }
        
        // Fallback to Word Embedding
        print("      ❓ [StaticLoader] Checking wordEmbedding...")
        if let wordModel = NLEmbedding.wordEmbedding(for: lang) {
            print("      🧠 [Embedding] Loaded Static Word Model for '\(code)'")
            loadedStaticModels[code] = wordModel
            print("      ✅ [StaticLoader] Cached Word Model.")
            return wordModel
        }
        
        print("      ❌ [StaticLoader] No static models found.")
        return nil
    }
    
    // MARK: - Utilities
    
    private static func normalizeCode(_ code: String) -> String {
        print("   🔍 [EmbeddingService] normalizeCode input: '\(code)'")
        if code.lowercased() == "zh" {
            print("   🔄 [EmbeddingService] Normalizing 'zh' -> 'zh-Hans'")
            return "zh-Hans"
        }
        print("   ✅ [EmbeddingService] Code normalized: '\(code)'")
        return code
    }
    
    static func resetCache() {
        print("🔄 [Embedding] Clearing internal model cache...")
        print("   🗑️ [Embedding] Removing \(loadedStaticModels.count) static models")
        loadedStaticModels.removeAll()
        print("   🗑️ [Embedding] Removing \(loadedContextualWrappers.count) contextual wrappers")
        loadedContextualWrappers.removeAll()
        print("   🗑️ [Embedding] Removing \(vectorCache.count) cached vectors")
        vectorCache.removeAll()
        print("   ✅ [Embedding] Cache reset complete.")
    }
    
    static func cosineSimilarity(v1: [Double], v2: [Double]) -> Double {
        print("   🧮 [Math] Starting Cosine Similarity Calculation...")
        print("   🧮 [Math] Vector 1 Dim: \(v1.count)")
        print("   🧮 [Math] Vector 2 Dim: \(v2.count)")
        
        // Ensure dimensions match roughly (or truncate/pad if needed, but ideally they match)
        // Comparison of mixed vectors (Contextual vs Static) is technically mathematically weak,
        // but for "Is this remotely similar?" it acts as a heuristic.
        // Ideally, we compare V1(Contextual) vs V2(Contextual) OR V1(Static) vs V2(Static).
        
        let count = min(v1.count, v2.count)
        print("   🧮 [Math] Processing \(count) dimensions...")
        
        var dot = 0.0
        var mag1 = 0.0
        var mag2 = 0.0
        
        // Loop optimization: Don't print inside the loop for performance, but print summary stats
        for i in 0..<count {
            dot += v1[i] * v2[i]
            mag1 += v1[i] * v1[i]
            mag2 += v2[i] * v2[i]
        }
        
        print("   🧮 [Math] Raw Dot Product Sum: \(dot)")
        print("   🧮 [Math] Raw Magnitude 1 Sum (Squared): \(mag1)")
        print("   🧮 [Math] Raw Magnitude 2 Sum (Squared): \(mag2)")
        
        if mag1 == 0 || mag2 == 0 {
            print("   ⚠️ [Math] Zero Magnitude Detected! (Mag1: \(mag1), Mag2: \(mag2)) -> Sim: 0.0")
            print("   ❌ [Math] Calculation aborted due to zero magnitude.")
            return 0.0
        }
        
        let sqrtMag1 = sqrt(mag1)
        let sqrtMag2 = sqrt(mag2)
        
        print("   🧮 [Math] Sqrt Magnitude 1: \(sqrtMag1)")
        print("   🧮 [Math] Sqrt Magnitude 2: \(sqrtMag2)")
        
        let denominator = sqrtMag1 * sqrtMag2
        print("   🧮 [Math] Denominator (Mag1 * Mag2): \(denominator)")
        
        let sim = dot / denominator
        print("   🧮 [Math] Final Division: \(dot) / \(denominator) = \(sim)")
        print("   ✅ [Math] Similarity Result: \(String(format: "%.4f", sim))")

        return sim
    }
    
    static func compare(textA: String, textB: String, languageCode: String) -> Double {
        print("\n⚖️ [EmbeddingService] compare() initiated")
        print("   📄 [Compare] Text A: '\(textA)'")
        print("   📄 [Compare] Text B: '\(textB)'")
        print("   🌍 [Compare] Language: '\(languageCode)'")
        
        let code = normalizeCode(languageCode)
        print("   🌍 [Compare] Normalized Language: '\(code)'")
        
        print("   🚀 [Compare] Fetching Vector A...")
        let v1Opt = getVector(for: textA, languageCode: code)
        if v1Opt == nil { print("   ❌ [Compare] Vector A fetch FAILED.") }
        
        print("   🚀 [Compare] Fetching Vector B...")
        let v2Opt = getVector(for: textB, languageCode: code)
        if v2Opt == nil { print("   ❌ [Compare] Vector B fetch FAILED.") }
        
        // 1 & 2: Try Neural Embeddings (Contextual or Static)
        if let v1 = v1Opt, let v2 = v2Opt {
            print("   ✅ [Compare] Both vectors retrieved. Proceeding to Cosine Similarity.")
            return cosineSimilarity(v1: v1, v2: v2)
        }
        
        print("   ⚠️ [Compare] Neural vectors missing. Fallback needed.")
        
        // 3. Tertiary Fallback: Normalized Levenshtein Distance
        // This ensures Locians have "brain activity" even without downloaded models.
        let s1 = textA.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let s2 = textB.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("   ✂️ [Compare] Prepared string 1: '\(s1)'")
        print("   ✂️ [Compare] Prepared string 2: '\(s2)'")
        
        guard !s1.isEmpty && !s2.isEmpty else {
            print("   ❌ [Compare] One or both strings are empty. Score: 0.0")
            return 0.0
        }
        
        print("   📏 [Compare] Calculating Levenshtein Distance...")
        let dist = Double(levenshteinDistance(s1, s2))
        print("   📏 [Compare] Raw Distance: \(dist)")
        
        let maxLen = Double(max(s1.count, s2.count))
        print("   📏 [Compare] Max Length: \(maxLen)")
        
        let score = 1.0 - (dist / maxLen)
        print("   🔢 [Compare] Levenshtein Score: 1.0 - (\(dist) / \(maxLen)) = \(score)")
        
        print("   ⚠️ [EmbeddingService] [FALLBACK] Using Levenshtein for '\(s1)' vs '\(s2)' -> Score: \(String(format: "%.3f", score))")
        
        return score
    }
    
    /// Utility for 3rd-tier fallback matching
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        // print("      🧮 [Levenshtein] Calculating distance...") // Too noisy even for granular
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
        // print("      🧮 [Levenshtein] Result: \(dist[a.count][b.count])")
        return dist[a.count][b.count]
    }
    
    static func isModelAvailable(for code: String) -> Bool {
        print("❓ [EmbeddingService] Checking model availability for '\(code)'...")
        let code = normalizeCode(code)
        
        // 1. Check Contextual (Preferred)
        if #available(macOS 14.0, iOS 17.0, *) {
            print("   🖥️ [Availability] System supports Contextual Embeddings (iOS 17+/macOS 14+)")
            let lang = NLLanguage(rawValue: code)
            
            // Note: Instantiating NLContextualEmbedding might print "Unsupported locale" if assets are missing.
            // This is a system log we cannot suppress, but we can verify the object is valid.
            if let model = NLContextualEmbedding(language: lang) {
                print("   🧩 [Availability] NLContextualEmbedding instance created.")
                // If assets are available, we are good.
                if model.hasAvailableAssets {
                    print("   🧠 [EmbeddingService] Status: CONTEXTUAL Model is ready for '\(code)'")
                    print("   ✅ [Availability] Contextual Assets: AVAILABLE")
                    return true
                } else {
                    // Valid model, but needs download.
                    print("   ⚠️ [EmbeddingService] Status: CONTEXTUAL assets missing for '\(code)'. Checking Legacy...")
                    print("   ❌ [Availability] Contextual Assets: MISSING")
                    // DO NOT return false here. Fall through to check static.
                }
            } else {
                print("   ❌ [Availability] NLContextualEmbedding init failed (nil).")
            }
        } else {
             print("   🖥️ [Availability] System DOES NOT support Contextual Embeddings.")
        }
        
        // 2. Check Static (Fallback)
        let lang = NLLanguage(rawValue: code)
        print("   🔍 [Availability] Checking Static Sentence Embedding...")
        if NLEmbedding.sentenceEmbedding(for: lang) != nil {
            print("   🧠 [EmbeddingService] Status: STATIC (Legacy) Model is ready for '\(code)'")
            print("   ✅ [Availability] Static Sentence Model: AVAILABLE")
            return true
        }
        print("   ❌ [Availability] Static Sentence Model: MISSING")
        
        print("   🔍 [Availability] Checking Static Word Embedding...")
        if NLEmbedding.wordEmbedding(for: lang) != nil {
            print("   🧠 [EmbeddingService] Status: STATIC (Legacy) Model is ready for '\(code)'")
             print("   ✅ [Availability] Static Word Model: AVAILABLE")
            return true
        }
        print("   ❌ [Availability] Static Word Model: MISSING")
        
        print("   ❌ [Availability] NO MODELS AVAILABLE for '\(code)'")
        return false
    }

    /// Returns the highest available model tier for a given language code.
    static func getAvailableMode(for code: String) -> String {
        print("❓ [EmbeddingService] Determining available mode for '\(code)'...")
        let code = normalizeCode(code)
        
        // 1. Contextual
        if #available(macOS 14.0, iOS 17.0, *) {
            let lang = NLLanguage(rawValue: code)
            if let model = NLContextualEmbedding(language: lang), model.hasAvailableAssets {
                print("   🏆 [Mode] Selected: CONTEXTUAL")
                return "CONTEXTUAL"
            }
        }
        
        // 2. Static
        let lang = NLLanguage(rawValue: code)
        if NLEmbedding.sentenceEmbedding(for: lang) != nil || NLEmbedding.wordEmbedding(for: lang) != nil {
            print("   🥈 [Mode] Selected: STATIC")
            return "STATIC"
        }
        
        // 3. Fallback
        print("   🥉 [Mode] Selected: LEVENSHTEIN (Fallback)")
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
                print("   ⏳ [Download] Starting Asset Request...")
                
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
                         print("   🔄 [Download] Triggering Static Fallback...")
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
        print("   ⬇️ [StaticDownload] Initiating for '\(code)'...")
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
        print("   ❓ [EmbeddingService] Checking if Contextual is available for '\(code)'")
        if #available(macOS 14.0, iOS 17.0, *) {
            // Check cache or capability
            if loadedContextualWrappers[code] != nil {
                print("   ✅ [Check] Found in loadedContextualWrappers")
                return true
            }
            let lang = NLLanguage(rawValue: code)
            if NLContextualEmbedding(language: lang) != nil {
                print("   ✅ [Check] NLContextualEmbedding can be instantiated")
                return true
            }
        }
        print("   ❌ [Check] Contextual NOT available")
        return false
    }
}
