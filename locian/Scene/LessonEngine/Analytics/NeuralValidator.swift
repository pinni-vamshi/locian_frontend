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
        }
    }
    
    // MARK: - JIT Access via Centralized Service
    
    /// Returns a pre-computed vector if available, or attempts to fetch one JIT via EmbeddingService
    func getVector(for text: String) -> [Double]? {
        let clean = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let cached = cachedEmbeddings[clean] {
            return cached
        }
        
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
        
        let uniqueTargets = Set(targets)
        for target in uniqueTargets {
            let clean = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if cachedEmbeddings[clean] == nil {
                if let vector = EmbeddingService.getVector(for: clean, languageCode: code) {
                    cachedEmbeddings[clean] = vector
                }
            }
        }
    }
    
    
    // MARK: - Asset Management
    /// Proactively download assets for a language with retries
    // MARK: - Asset Management
    /// Proactively download assets for a language with retries
    static func downloadAssets(for languageCode: String, retryCount: Int = 3) {
        let nlLanguage = NLLanguage(rawValue: languageCode)
        
        NLTagger.requestAssets(for: nlLanguage, tagScheme: .lemma) { _, error in
            if error != nil {
                if retryCount > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                        downloadAssets(for: languageCode, retryCount: retryCount - 1)
                    }
                }
            } else {
                // Done
            }
        }
    }

    // MARK: - Vector Math Helpers
    func cosineSimilarity(between v1: [Double], and v2: [Double]) -> Double {
        let dot = zip(v1, v2).map(*).reduce(0, +)
        let mag1 = sqrt(v1.map { $0 * $0 }.reduce(0, +))
        let mag2 = sqrt(v2.map { $0 * $0 }.reduce(0, +))
        
        if mag1 == 0 || mag2 == 0 {
             return 0.0
        }
        
        let sim = dot / (mag1 * mag2)
        return sim
    }    
        // Clamp and Invert
        // Cosine Sim is -1 to 1. Distance is usually 1 - sim.
        // For standard embeddings (usually non-negative), it's 0 to 1.

    




    
}

    

