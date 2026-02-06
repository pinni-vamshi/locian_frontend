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
            // Find the BEST matching moment text within this place
            var bestMomentScore: Double = 0.0
            var bestMomentText: String = ""
            var bestMoment: UnifiedMoment? = nil
            var bestCategory: String? = nil
            
            if let sections = place.micro_situations {
                for section in sections {
                    for moment in section.moments {
                        if let momentVector = EmbeddingEngine.shared.generateEmbedding(for: moment.text) {
                            let similarity = cosineSimilarity(intentVector, momentVector)
                            
                            print("🧠 [ScoringEngine] Intent vs Moment '\(moment.text)' -> Sim: \(similarity)")
                            
                            if similarity > bestMomentScore {
                                bestMomentScore = similarity
                                bestMomentText = moment.text
                                bestMoment = moment
                                bestCategory = section.category
                            }
                        }
                    }
                }
            }
            
            // Also check Context Description as a fallback/boost
            let contextText = place.context_description ?? ""
            if !contextText.isEmpty, let contextVector = EmbeddingEngine.shared.generateEmbedding(for: contextText) {
                let contextSim = cosineSimilarity(intentVector, contextVector)
                if contextSim > bestMomentScore {
                    bestMomentScore = contextSim
                    bestMomentText = "Context: \(contextText)"
                }
            }
            
            totalScore += bestMomentScore * 10.0
            
            if bestMomentScore > 0.3 {
                matchReasons.append("Moment Match: '\(bestMomentText)'")
                
                // 🚀 CRITICAL: Filter the place to ONLY contain this best moment
                if let bestMoment = bestMoment, let bestCategory = bestCategory {
                    // Create a mutable copy (MicroSituationData is a value type, so var placeCopy = place works)
                    var placeCopy = place
                    
                    // Construct a single section with the single best moment
                    let filteredSection = UnifiedMomentSection(
                        category: bestCategory,
                        moments: [bestMoment]
                    )
                    
                    // Replace the list with just this one section
                    placeCopy.micro_situations = [filteredSection]
                    
                    // Use this modified place for the result
                    return ScoredPlace(
                        place: placeCopy,
                        score: totalScore,
                        matchReason: matchReasons.joined(separator: ", "),
                        extractedName: extractPlaceName(from: placeCopy)
                    )
                }
            }
        } else {
            print("⚠️ [ScoringEngine] No intent vector provided")
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
