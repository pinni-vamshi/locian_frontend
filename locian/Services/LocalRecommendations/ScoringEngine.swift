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
    
    func score(place: MicroSituationData, intentVector: [Double]?, userLocation: CLLocation?) -> [ScoredPlace] {
        // print("\n🟢 [ScoringEngine] score() called for Place: '\(place.place_name ?? "Unknown")'") // Too spammy if 100s of places
        var scoredMoments: [ScoredPlace] = []
        
        // 1. Semantic Similarity (Intent vs History)
        if let intentVector = intentVector {
            if let sections = place.micro_situations {
                for section in sections {
                    for moment in section.moments {
                        if let momentVector = EmbeddingEngine.shared.generateEmbedding(for: moment.text) {
                            let similarity = cosineSimilarity(intentVector, momentVector)
                            let finalScore = similarity * 10.0
                            
                            if similarity > 0.05 { // Lower threshold for logging check
                                 print("      🧠 [Score] '\(moment.text)' -> Sim: \(String(format: "%.3f", similarity))")
                            }
                            
                            // Only include relevant matches (threshold > 0.1 to allow "Likely" candidates)
                            // User wants Top 10, so we should be generous here and filter later
                            if similarity > 0.1 {
                                var matchReasons: [String] = []
                                matchReasons.append("Moment Match: '\(moment.text)'")
                                
                                // GPS Boost Check (Per Moment, though it's place-level data)
                                var boostedScore = finalScore
                                if let userLoc = userLocation,
                                   let placeLat = place.latitude,
                                   let placeLon = place.longitude,
                                   placeLat != 0, placeLon != 0 {
                                    
                                    let placeLoc = CLLocation(latitude: placeLat, longitude: placeLon)
                                    let distance = userLoc.distance(from: placeLoc)
                                    
                                    if distance < 100 {
                                        boostedScore += 5.0
                                        matchReasons.append("Nearby (<100m)")
                                        print("         📍 GPS Boost (+5.0) Applied")
                                    } else if distance < 500 {
                                        boostedScore += 2.0
                                        matchReasons.append("Nearby (<500m)")
                                        print("         📍 GPS Boost (+2.0) Applied")
                                    }
                                }

                                // Create specific place wrapper for this ONE moment
                                var placeCopy = place
                                let filteredSection = UnifiedMomentSection(
                                    category: section.category,
                                    moments: [moment]
                                )
                                placeCopy.micro_situations = [filteredSection]
                                
                                // CRITICAL FIX: Ensure unique ID for SwiftUI
                                // If multiple moments match from same place, they need unique IDs
                                if let originalId = place.document_id {
                                    placeCopy.document_id = "\(originalId)_\(moment.text.hashValue)"
                                } else {
                                    placeCopy.document_id = UUID().uuidString
                                }
                                
                                let scoredPlace = ScoredPlace(
                                    place: placeCopy,
                                    score: boostedScore,
                                    matchReason: matchReasons.joined(separator: ", "),
                                    extractedName: extractPlaceName(from: placeCopy)
                                )
                                scoredMoments.append(scoredPlace)
                            }
                        }
                    }
                }
            }
        } else {
            print("⚠️ [ScoringEngine] No intent vector provided")
        }
        
        return scoredMoments
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
