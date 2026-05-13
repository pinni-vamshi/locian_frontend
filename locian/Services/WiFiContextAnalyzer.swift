//
//  WiFiContextAnalyzer.swift
//  locian
//
//  Analyzer combining SSID, Profile (Name/Profession), and GPS Semantic Snapshot
//  to deduce physical category logic.
//

import Foundation

class WiFiContextAnalyzer {
    
    struct WiFiInferenceResult {
        let category: String
        let matchMethod: String
        let confidence: String
        let metadata: [String: String]
    }
    
    /// Analyzes the WiFi SSID against User Profile and GPS places to infer the physical category
    static func analyzeContext(
        ssid: String,
        username: String,
        profession: String,
        nearbyPlaces: [LocationManager.NearbyAmbience],
        languageCode: String
    ) -> WiFiInferenceResult? {
        
        let cleanSsid = ssid.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanSsid.isEmpty else { return nil }
        
        // Prepare lowercased versions for aggressive string matching
        let lowerSsid = cleanSsid.lowercased()
        let lowerUsername = username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerProfession = profession.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ---------------------------------------------------------------------
        // 1. HOME MATCH (Username Regex / Substring Match)
        // ---------------------------------------------------------------------
        if !lowerUsername.isEmpty {
            let nameTokens = lowerUsername.split(separator: " ").map { String($0) }.filter { $0.count > 2 }
            for token in nameTokens {
                // e.g. "Vamshi" in "Vamshi's_5G"
                if lowerSsid.contains(token) {
                    return WiFiInferenceResult(category: "home", matchMethod: "username_regex_match", confidence: "0.95", metadata: ["matched_token": token])
                }
            }
        }
        
        // ---------------------------------------------------------------------
        // 2. WORK MATCH (Profession Substring Match)
        // ---------------------------------------------------------------------
        if !lowerProfession.isEmpty {
            let profTokens = lowerProfession.split(separator: " ").map { String($0) }.filter { $0.count > 3 }
            for token in profTokens {
                // e.g. "Studio" in "DesignStudio_WiFi"
                if lowerSsid.contains(token) {
                    return WiFiInferenceResult(category: "work", matchMethod: "profession_regex_match", confidence: "0.85", metadata: ["matched_token": token])
                }
            }
        }
        
        // ---------------------------------------------------------------------
        // 3. SEMANTIC SNAPSHOT MATCH (Neural Similarity over GPS Places)
        // ---------------------------------------------------------------------
        if !nearbyPlaces.isEmpty {
            
            // Strip out networking noise to get pure semantic tokens
            let noiseWords = ["wifi", "guest", "network", "5g", "2.4g", "free", "public", "-", "_", "'s"]
            var semanticSsid = lowerSsid
            for word in noiseWords {
                semanticSsid = semanticSsid.replacingOccurrences(of: word, with: " ")
            }
            semanticSsid = semanticSsid.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for explicit lexical overlaps first (extremely high confidence)
            for place in nearbyPlaces {
                let placeName = place.name.lowercased()
                if semanticSsid.count > 3 && (placeName.contains(semanticSsid) || semanticSsid.contains(placeName)) {
                    return WiFiInferenceResult(category: place.category ?? "unknown", matchMethod: "exact_semantic_bypass", confidence: "1.0", metadata: ["matched_place": place.name])
                }
            }
            
            // Execute Neural Similarity
            if semanticSsid.count > 2 {
                if let ssidVector = EmbeddingService.getVector(for: semanticSsid, languageCode: languageCode) {
                    
                    var bestMatch: LocationManager.NearbyAmbience?
                    var highestScore: Double = 0.0
                    
                    for place in nearbyPlaces {
                        let placeName = place.name.lowercased()
                        if let placeVector = EmbeddingService.getVector(for: placeName, languageCode: languageCode) {
                            let score = EmbeddingService.cosineSimilarity(v1: ssidVector, v2: placeVector)
                            
                            if score > highestScore {
                                highestScore = score
                                bestMatch = place
                            }
                        }
                    }
                    
                    // Transformation threshold (0.65 threshold confirms robust semantic link)
                    if highestScore >= 0.65, let match = bestMatch, let matchCategory = match.category {
                        return WiFiInferenceResult(
                            category: matchCategory,
                            matchMethod: "neural_embedding_match",
                            confidence: String(format: "%.3f", highestScore),
                            metadata: ["matched_place": match.name]
                        )
                    }
                }
            }
        }
        
        // ---------------------------------------------------------------------
        // 4. FALLBACK LEXICAL CHECK (e.g. Basic Categorization)
        // ---------------------------------------------------------------------
        if lowerSsid.contains("cafe") || lowerSsid.contains("coffee") || lowerSsid.contains("starbucks") {
            return WiFiInferenceResult(category: "cafe", matchMethod: "lexical_fallback", confidence: "0.60", metadata: [:])
        }
        if lowerSsid.contains("hotel") || lowerSsid.contains("guest") || lowerSsid.contains("motel") {
            return WiFiInferenceResult(category: "hotel", matchMethod: "lexical_fallback", confidence: "0.60", metadata: [:])
        }
        if lowerSsid.contains("gym") || lowerSsid.contains("fitness") {
            return WiFiInferenceResult(category: "gym", matchMethod: "lexical_fallback", confidence: "0.60", metadata: [:])
        }
        if lowerSsid.contains("airport") || lowerSsid.contains("lounge") {
            return WiFiInferenceResult(category: "airport", matchMethod: "lexical_fallback", confidence: "0.80", metadata: [:])
        }
        
        // No logical inference matched
        return nil
    }
}
