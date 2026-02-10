import Foundation
import NaturalLanguage

/// Centralized factory for creating text embeddings.
/// Pure input (Text + Language) -> Output (Vector).
/// Location: locian/Services/EmbeddingService.swift
class EmbeddingService {
    
    // Cache models to avoid reloading
    private static var loadedStaticModels: [String: NLEmbedding] = [:]
    
    struct ContextualWrapper {
        let model: Any
    }
    private static var loadedContextualWrappers: [String: ContextualWrapper] = [:]
    
    /// Proactively prepares neural assets for a language.
    static func downloadModel(for languageCode: String, completion: @escaping (Bool) -> Void) {
        let code = normalizeCode(languageCode)
        
        if #available(macOS 14.0, iOS 17.0, *) {
            let lang = NLLanguage(rawValue: code)
            guard let model = NLContextualEmbedding(language: lang) else {
                print("   ⚠️ [Embedding: Download] Contextual embedding not supported for '\(code)'.")
                completion(false)
                return
            }
            
            model.requestAssets { status, error in
                if let error = error {
                    print("   ❌ [Embedding: Download] Asset request failed for '\(code)': \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("   🧠 [Embedding: Download] Status for '\(code)': \(status == .available ? "AVAILABLE" : "NOT YET AVAILABLE")")
                completion(status == .available)
            }
        } else {
            // Check if static model is available
            let success = getStaticModel(for: code) != nil
            completion(success)
        }
    }
    
    /// Prepares a batch of languages.
    static func prepareModels(for codes: Set<String>) {
        for code in codes where !code.isEmpty {
            downloadModel(for: code) { _ in }
        }
    }
    
    /// Checks if a model (either contextual or static) is ready to use immediately.
    static func isModelAvailable(for languageCode: String) -> Bool {
        let code = normalizeCode(languageCode)
        if #available(macOS 14.0, iOS 17.0, *) {
            if let model = NLContextualEmbedding(language: NLLanguage(rawValue: code)) {
                return model.hasAvailableAssets
            }
        }
        return getStaticModel(for: code) != nil
    }
    
    /// Returns the descriptive mode for a language.
    static func getAvailableMode(for languageCode: String) -> String {
        let code = normalizeCode(languageCode)
        if #available(macOS 14.0, iOS 17.0, *) {
            if let model = NLContextualEmbedding(language: NLLanguage(rawValue: code)), model.hasAvailableAssets {
                return "CONTEXTUAL"
            }
        }
        if getStaticModel(for: code) != nil {
            return "STATIC"
        }
        return "NONE"
    }
    
    // Cache vectors to avoid redundant computations (Text_LangCode -> Vector)
    private static var vectorCache: [String: [Double]] = [:]
    
    /// Converts any text (Brick or Pattern) into a vector for the specified language.
    static func getVector(for text: String, languageCode: String) -> [Double]? {
        print("\n🆔 [Embedding] getVector: '\(text)' (Lang: \(languageCode))")
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { 
            print("   ❌ [Embedding] Text is empty. Returning nil.")
            return nil 
        }
        
        let code = normalizeCode(languageCode)
        let cacheKey = "\(cleanText)_\(code)"
        
        if let cached = vectorCache[cacheKey] {
            print("   🟢 [Embedding] Cache HIT for '\(cleanText)'")
            return cached
        }
        print("   🟠 [Embedding] Cache MISS. Generating vector...")
        
        // 1. Try Contextual Embedding (iOS 17+)
        if #available(macOS 14.0, iOS 17.0, *) {
            print("   🔍 [Embedding] Attempting Contextual...")
            if let vector = getContextualVector(for: cleanText, languageCode: code) {
                print("   ✅ [Embedding] Contextual SUCCESS (Dim: \(vector.count))")
                vectorCache[cacheKey] = vector
                return vector
            }
        }
        
        // 2. Fallback to Static Embedding
        print("   🔍 [Embedding] Attempting Static Fallback...")
        if let staticModel = getStaticModel(for: code) {
            if let vector = staticModel.vector(for: cleanText) {
                print("   ✅ [Embedding] Static SUCCESS (Dim: \(vector.count))")
                vectorCache[cacheKey] = vector
                return vector
            }
            print("   ❌ [Embedding] Static vector() returned nil.")
        } else {
            print("   ❌ [Embedding] No models available for '\(code)'.")
        }

        return nil
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    private static func getContextualVector(for text: String, languageCode: String) -> [Double]? {
        let code = normalizeCode(languageCode)
        guard let model = getContextualModel(for: code) else { 
            print("      ❌ [Contextual] Model assets not missing for '\(code)'")
            return nil 
        }
        let lang = NLLanguage(rawValue: code)
        
        do {
            let result = try model.embeddingResult(for: text, language: lang)
            var sumVector = [Double](repeating: 0.0, count: model.dimension)
            var tokenCount = 0
            
            result.enumerateTokenVectors(in: text.startIndex..<text.endIndex) { vector, range in
                for i in 0..<min(vector.count, sumVector.count) {
                    sumVector[i] += vector[i]
                }
                tokenCount += 1
                return true
            }
            
            if tokenCount > 0 {
                let final = sumVector.map { $0 / Double(tokenCount) }
                // print("      ✅ [Contextual] Averaged \(tokenCount) tokens.")
                return final
            }
        } catch {
            print("      ⚠️ [Contextual] Error in embeddingResult: \(error.localizedDescription)")
        }
        return nil
    }
    
    @available(macOS 14.0, iOS 17.0, *)
    private static func getContextualModel(for languageCode: String) -> NLContextualEmbedding? {
        let code = normalizeCode(languageCode)
        if let wrapper = loadedContextualWrappers[code], let model = wrapper.model as? NLContextualEmbedding {
            return model
        }
        
        let lang = NLLanguage(rawValue: code)
        if let model = NLContextualEmbedding(language: lang) {
            loadedContextualWrappers[code] = ContextualWrapper(model: model)
            return model
        }
        return nil
    }
    
    private static func getStaticModel(for code: String) -> NLEmbedding? {
        if let cached = loadedStaticModels[code] { return cached }
        let lang = NLLanguage(rawValue: code)
        
        if let sentenceModel = NLEmbedding.sentenceEmbedding(for: lang) {
            loadedStaticModels[code] = sentenceModel
            return sentenceModel
        }
        
        if let wordModel = NLEmbedding.wordEmbedding(for: lang) {
            loadedStaticModels[code] = wordModel
            return wordModel
        }
        return nil
    }
    
    private static func normalizeCode(_ code: String) -> String {
        if code.lowercased() == "zh" { return "zh-Hans" }
        return code
    }
    
    static func cosineSimilarity(v1: [Double], v2: [Double]) -> Double {
        let count = min(v1.count, v2.count)
        if count == 0 { return 0.0 }
        
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
    
    /// Public helper to compare two strings in a given language.
    static func compare(textA: String, textB: String, languageCode: String) -> Double {
        guard let v1 = getVector(for: textA, languageCode: languageCode),
              let v2 = getVector(for: textB, languageCode: languageCode) else {
            return 0.0
        }
        return cosineSimilarity(v1: v1, v2: v2)
    }
    
    /// Checks if a contextual model is available for the given language.
    static func isContextualAvailable(for languageCode: String) -> Bool {
        return getAvailableMode(for: languageCode) == "CONTEXTUAL"
    }
}
