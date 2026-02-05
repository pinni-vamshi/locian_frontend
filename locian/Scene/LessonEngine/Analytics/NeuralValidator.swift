//
//  NeuralValidator.swift
//  locian
//
//  The "Brain" of the Lesson Engine.
//  Encapsulates On-Device ML for:
//  1. Semantic Similarity (NLEmbedding) -> Did you mean 'forgot' or 'lost'?
//  2. Speech Recognition (SFSpeechRecognizer) -> Did you say it right?
//

import Foundation
import NaturalLanguage
import Combine


class NeuralValidator: ObservableObject {
    

    public private(set) var targetLocale: Locale
    
    // MARK: - Lifecycle
    init(targetLocale: Locale = Locale(identifier: "en-US")) {
        self.targetLocale = targetLocale
        // Models are JIT loaded by EmbeddingService now
    }
    
    func updateLocale(_ locale: Locale) {
        if self.targetLocale.identifier != locale.identifier {
            self.targetLocale = locale
            print("🧠 [Neural] Switched target locale to: \(locale.identifier)")
        }
    }
    
    // MARK: - JIT Access via Centralized Service
    
    /// Returns a pre-computed vector if available, or attempts to fetch one JIT via EmbeddingService
    func getVector(for text: String) -> [Double]? {
        let clean = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let cached = cachedEmbeddings[clean] {
            return cached
        }
        
        print("      🧠 [LessonFlow] [Neural] JIT Fetch for: '\(clean)'")
        
        let code = targetLocale.language.languageCode?.identifier ?? "en"
        if let vector = EmbeddingService.getVector(for: clean, languageCode: code) {
            cachedEmbeddings[clean] = vector
            return vector
        }
        return nil
    }
    
    // MARK: - Embedding Cache (Pre-computation)
    public private(set) var cachedEmbeddings: [String: [Double]] = [:]
    
    /// Pre-compute embeddings for a batch of sentences
    func precomputeTargets(_ targets: [String]) {
        let code = targetLocale.language.languageCode?.identifier ?? "en"
        print("🧠 [LessonFlow] [Neural] Pre-computing embeddings for \(targets.count) targets (\(code))...")
        
        let uniqueTargets = Set(targets)
        for target in uniqueTargets {
            let clean = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if cachedEmbeddings[clean] == nil {
                if let vector = EmbeddingService.getVector(for: clean, languageCode: code) {
                    cachedEmbeddings[clean] = vector
                }
            }
        }
        print("🧠 [LessonFlow] [Neural] Generated \(cachedEmbeddings.count) vectors (Memory Only).")
    }
    
    
    // MARK: - Diagnostics (User Request)
    static func runDiagnostics(for targetCode: String) {
        print("\n🔍 [LessonFlow] [Neural] --- Embedding Diagnostics ---")
        
        let targetLang = NLLanguage(rawValue: targetCode)
        if let targetModel = NLEmbedding.sentenceEmbedding(for: targetLang) {
            print("   👉 [LessonFlow] Target Lang (\(targetCode)): AVAILABLE ✅ (Dim: \(targetModel.dimension))")
        } else {
            print("   👉 [LessonFlow] Target Lang (\(targetCode)): MISSING ❌")
        }
        
        if let nativeModel = NLEmbedding.wordEmbedding(for: .english) {
            print("   👉 [LessonFlow] Native Lang (en): AVAILABLE ✅ (Dim: \(nativeModel.dimension))")
        } else {
            print("   👉 [LessonFlow] Native Lang (en): MISSING ❌")
        }
        print("   ---------------------------------------\n")
    }

    // Instance wrapper for convenience
    func printEmbeddingDiagnostics() {
        let code = targetLocale.language.languageCode?.identifier ?? "en"
        NeuralValidator.runDiagnostics(for: code)
    }

    // MARK: - Asset Management
    /// Proactively download assets for a language with retries
    static func downloadAssets(for languageCode: String, retryCount: Int = 3) {
        let nlLanguage = NLLanguage(rawValue: languageCode)
        print("   ⬇️ [LessonFlow] [Neural] Requesting assets for \(languageCode) (Retries left: \(retryCount))...")
        
        NLTagger.requestAssets(for: nlLanguage, tagScheme: .lemma) { result, error in
            if let error = error {
                print("   ❌ [LessonFlow] [Neural] Asset Request Failed: \(error.localizedDescription)")
                if retryCount > 0 {
                    print("   🔄 [LessonFlow] [Neural] Retrying download for \(languageCode) in 2 seconds...")
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                        downloadAssets(for: languageCode, retryCount: retryCount - 1)
                    }
                } else {
                    print("   ⛔️ [LessonFlow] [Neural] Asset Download GAVE UP for \(languageCode).")
                }
            } else {
                print("   ✅ [LessonFlow] [Neural] Assets Downloaded/Available for \(languageCode).")
            }
        }
    }

    // MARK: - Vector Math Helpers
    func cosineSimilarity(between v1: [Double], and v2: [Double]) -> Double {
        let dot = zip(v1, v2).map(*).reduce(0, +)
        let mag1 = sqrt(v1.map { $0 * $0 }.reduce(0, +))
        let mag2 = sqrt(v2.map { $0 * $0 }.reduce(0, +))
        
        if mag1 == 0 || mag2 == 0 {
             print("      ⚠️ [LessonFlow] [Neural] Zero magnitude vector detected (Mag1: \(mag1), Mag2: \(mag2))")
             return 0.0
        }
        
        let sim = dot / (mag1 * mag2)
        print("      🧮 [Neural: Cosine] Sim: \(String(format: "%.4f", sim)) | Vectors: [\(v1.count)] vs [\(v2.count)]")
        
        return sim
    }    
        // Clamp and Invert
        // Cosine Sim is -1 to 1. Distance is usually 1 - sim.
        // For standard embeddings (usually non-negative), it's 0 to 1.

    




    
}

    

