//
//  ScoringEngine.swift
//  locian
//
//  Handles similarity matching, GPS boosting, and Place Name extraction.
//

import Foundation
import CoreLocation
import NaturalLanguage

class ScoringEngine {
    static let shared = ScoringEngine()
    private init() {}
    
    // MARK: - Core Scoring
    
    func score(place: MicroSituationData, intentVector: [Double]?, userLocation: CLLocation?) -> ScoredPlace {
        var totalScore: Double = 0.0
        var matchReasons: [String] = []
        
        // 1. Semantic Similarity (Intent vs History)
        // We compare the intent vector against the place name + context description
        if let intentVector = intentVector {
            let placeText = "\(place.place_name ?? "") \(place.context_description ?? "")"
            if let placeVector = EmbeddingEngine.shared.generateEmbedding(for: placeText) {
                let similarity = cosineSimilarity(intentVector, placeVector)
                totalScore += similarity * 10.0 // Weight: 10
                if similarity > 0.3 {
                    matchReasons.append("Intent Match")
                }
            }
        }
        
        // 2. GPS Proximity Boost
        if let userLoc = userLocation,
           let placeLat = place.latitude,
           let placeLon = place.longitude,
           placeLat != 0, placeLon != 0 {
            
            let placeLoc = CLLocation(latitude: placeLat, longitude: placeLon)
            let distance = userLoc.distance(from: placeLoc)
            
            if distance < 100 { // Within 100m
                totalScore += 5.0
                matchReasons.append("Nearby (<100m)")
            } else if distance < 500 { // Within 500m
                totalScore += 2.0
                matchReasons.append("Nearby (<500m)")
            }
        }
        
        // 3. Time Relevance (Optional, but good for context)
        // (Could add logic here if needed, keeping it simple for now as requested)
        
        return ScoredPlace(
            place: place,
            score: totalScore,
            matchReason: matchReasons.joined(separator: ", "),
            extractedName: extractPlaceName(from: place)
        )
    }
    
    // MARK: - Helpers
    
    private func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count else { return 0.0 }
        
        let dotProduct = zip(a, b).map(*).reduce(0, +)
        let magnitudeA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        
        guard magnitudeA > 0, magnitudeB > 0 else { return 0.0 }
        
        return dotProduct / (magnitudeA * magnitudeB)
    }
    
    private func extractPlaceName(from place: MicroSituationData) -> String {
        // Use NLTagger to find a cleaner name if possible, or fallback
        // For now, we mainly rely on the stored name, but if we had raw text, we'd use NLTagger here.
        // User requested NLTagger usage for place names.
        // Let's try to tag the place_name itself to see if we can refine it (e.g. remove noise)
        // OR act on the Context Description if name is "Unknown".
        
        let rawName = place.place_name ?? "Unknown Place"
        if rawName != "Unknown Place" && rawName != "Unknown" {
            return rawName
        }
        
        // Try to extract from context if name is unknown
        if let context = place.context_description {
            let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
            tagger.string = context
            var foundName: String?
            
            tagger.enumerateTags(in: context.startIndex..<context.endIndex, unit: .word, scheme: .nameType, options: [.omitPunctuation, .omitWhitespace]) { tag, range in
                if tag == .placeName || tag == .organizationName {
                    foundName = String(context[range])
                    return false // Stop at first found
                }
                return true
            }
            
            if let name = foundName {
                return name.capitalized
            }
        }
        
        return rawName
    }
}
