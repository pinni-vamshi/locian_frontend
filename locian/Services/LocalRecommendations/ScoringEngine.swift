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
    
    func score(place: MicroSituationData, intentVectors: [String: [Double]], userLocation: CLLocation?, languageCode: String) -> [ScoredPlace] {
        // print("\n🟢 [ScoringEngine] score() called for Place: '\(place.place_name ?? "Unknown")'")
        var scoredMoments: [ScoredPlace] = []
        
        // 1. Semantic Similarity (Max-Sim Strategy)
        // matches = For every moment, compare against EVERY intent vector, picking the MAX.
        if let sections = place.micro_situations {
            for section in sections {
                for moment in section.moments {
                    // Generate vector for the MOMENT
                    if let momentVector = EmbeddingService.getVector(for: moment.text, languageCode: languageCode) {
                        
                        // --- MAX SIMILARITY LOGIC ---
                        var maxSim = 0.0
                        var bestField = "None"
                        
                        for (fieldName, intentVec) in intentVectors {
                            let sim = cosineSimilarity(intentVec, momentVector)
                            if sim > maxSim {
                                maxSim = sim
                                bestField = fieldName
                            }
                        }
                        
                        let baseScore = maxSim // Raw Cosine Similarity (0.0 to 1.0)
                        
                        if maxSim > 0.05 {
                             print("      🧠 [Score] '\(moment.text)' -> Max Sim: \(String(format: "%.3f", maxSim)) (via \(bestField))")
                        }
                        
                        // Only include relevant matches
                        if maxSim > 0.1 {
                            var matchReasons: [String] = []
                            matchReasons.append("Matches '\(bestField)': \(moment.text)")
                            
                            // Time Boost
                            // Prioritize moments that happened around the current time (+/- 2 hours)
                            let timeBoost = 0.0
                            /* DISABLED BY USER REQUEST - Semantic Only for ranking
                            let currentHour = Calendar.current.component(.hour, from: Date())
                            
                            if let placeHour = place.hour {
                                let hourDiff = abs(currentHour - placeHour)
                                // Handle wrap-around (e.g. 23:00 vs 01:00 is 2 hours diff)
                                let normalizedDiff = min(hourDiff, 24 - hourDiff)
                                
                                if normalizedDiff <= 2 {
                                    timeBoost = 0.15 // Significant boost for very close time
                                    matchReasons.append("Time Match (<2h)")
                                } else if normalizedDiff <= 4 {
                                    timeBoost = 0.08 // Minor boost for reasonably close time
                                    matchReasons.append("Time Match (<4h)")
                                }
                            }
                            */
                            
                            // GPS Boost Check (Per Moment, though it's place-level data)
                            var gpsBoost = 0.0
                            if let userLoc = userLocation,
                               let placeLat = place.latitude,
                               let placeLon = place.longitude,
                               placeLat != 0, placeLon != 0 {
                                
                                let placeLoc = CLLocation(latitude: placeLat, longitude: placeLon)
                                let distance = userLoc.distance(from: placeLoc)
                                
                                if distance < 100 {
                                    gpsBoost = 0.2 // Boost logic scaled down found to fit [0,1] range roughly or just add on top
                                    matchReasons.append("Nearby (<100m)")
                                    print("         📍 GPS Boost (+0.2) Applied")
                                } else if distance < 500 {
                                    gpsBoost = 0.1
                                    matchReasons.append("Nearby (<500m)")
                                    print("         📍 GPS Boost (+0.1) Applied")
                                }
                            }
                            
                            // Final Score Calculation
                            // Base (0-1) + Time (0-0.15) + GPS (0-0.2)
                            // Max possible ~ 1.35, but ranks consistently
                            let finalScore = baseScore + timeBoost + gpsBoost

                            // Create specific place wrapper for this ONE moment
                            var placeCopy = place
                            let filteredSection = UnifiedMomentSection(
                                category: section.category,
                                moments: [moment]
                            )
                            placeCopy.micro_situations = [filteredSection]
                            
                            // Ensure unique ID for SwiftUI
                            if let originalId = place.document_id {
                                placeCopy.document_id = "\(originalId)_\(moment.text.hashValue)"
                            } else {
                                placeCopy.document_id = UUID().uuidString
                            }
                            
                            let scoredPlace = ScoredPlace(
                                place: placeCopy,
                                score: finalScore,
                                matchReason: matchReasons.joined(separator: ", "),
                                extractedName: extractPlaceName(from: placeCopy)
                            )
                            scoredMoments.append(scoredPlace)
                        }
                    }
                }
            }
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
        // print("\n🟢 [ScoringEngine] extractPlaceName called for Place ID: \(place.id)")
        let rawName = place.place_name ?? "Unknown Place"
        
        if rawName != "Unknown Place" && rawName != "Unknown" {
            // print("   ✅ Using Raw Name: '\(rawName)'")
            return rawName
        }
        
       // print("   ⚠️ Raw Name is Unknown. Attempting NLTagger extraction...")
        
        // Try to extract from context if name is unknown
        if let context = place.context_description {
            // print("   🔹 Context available: '\(context)'")
            let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
            tagger.string = context
            var foundName: String?
            
            tagger.enumerateTags(in: context.startIndex..<context.endIndex, unit: .word, scheme: .nameType, options: [.omitPunctuation, .omitWhitespace]) { tag, range in
                if tag == .placeName || tag == .organizationName {
                    foundName = String(context[range])
                    // print("      ✅ NLTagger Found: '\(foundName ?? "")' (Tag: \(tag?.rawValue ?? "nil"))")
                    return false // Stop at first found
                }
                return true
            }
            
            if let name = foundName {
                return name.capitalized
            } else {
                // print("      ❌ NLTagger found nothing valid.")
            }
        } else {
            // print("      ❌ No Context Description available.")
        }
        
        return rawName
    }
}
