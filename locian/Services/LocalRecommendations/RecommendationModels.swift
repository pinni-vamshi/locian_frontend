//
//  RecommendationModels.swift
//  locian
//
//  Models for the Local Recommendation Engine
//

import Foundation
import CoreLocation

// MARK: - Result Models

struct LocalRecommendationResult {
    let sections: [RecommendationResultSection]
    let suggestedPlaceName: String
    let hasHighQualityMatches: Bool // NEW: Indicates if any matches meet the 0.6 threshold
    
    // Legacy support (computed from sections)
    var mostLikely: [ScoredPlace] { sections.first?.items ?? [] }
    var likely: [ScoredPlace] { sections.count > 1 ? sections[1].items : [] }
    
    init(sections: [RecommendationResultSection], suggestedPlaceName: String = "SUGGESTED MOMENTS", hasHighQualityMatches: Bool = false) {
        self.sections = sections
        self.suggestedPlaceName = suggestedPlaceName
        self.hasHighQualityMatches = hasHighQualityMatches
    }
}

struct RecommendationResultSection {
    let title: String // "Most Likely", "Likely"
    let items: [ScoredPlace]
    
    init(title: String, items: [ScoredPlace]) {
        self.title = title
        self.items = items
    }
}

struct ScoredPlace: Identifiable {
    let place: MicroSituationData
    let score: Double
    let matchReason: String // For debugging: "Intent Similarity", "GPS Boost", etc.
    let extractedName: String // Refined name from NLTagger if available, else original
    
    var id: String { place.id }
    
    init(place: MicroSituationData, score: Double, matchReason: String, extractedName: String) {
        self.place = place
        self.score = score
        self.matchReason = matchReason
        self.extractedName = extractedName
    }
}

// MARK: - Helper Extension for UI Mapping

extension LocalRecommendationResult {
    /// Converts LocalRecommendationResult to MicroSituationData array for UI consumption
    func toMicroSituationData() -> [MicroSituationData] {
        guard !sections.isEmpty else { return [] }
        
        var unifiedSections: [UnifiedMomentSection] = []
        
        for section in sections {
            let moments = section.items.compactMap { scoredPlace -> UnifiedMoment? in
                guard let firstMoment = scoredPlace.place.micro_situations?.first?.moments.first else {
                    return nil
                }
                return UnifiedMoment(
                    text: firstMoment.text,
                    keywords: nil,
                    embedding: firstMoment.embedding
                )
            }
            
            if !moments.isEmpty {
                unifiedSections.append(UnifiedMomentSection(
                    category: section.title.uppercased(),
                    moments: moments
                ))
            }
        }
        
        let syntheticPlace = MicroSituationData(
            place_name: suggestedPlaceName,
            latitude: 0,
            longitude: 0,
            time: "LIVE",
            hour: 0,
            created_at: "",
            context_description: nil,
            micro_situations: unifiedSections,
            priority_score: 10.0,
            distance_meters: 0,
            time_span: "",
            type: "synthetic",
            profession: AppStateManager.shared.profession,
            updated_at: "",
            target_language: nil,
            document_id: "synthetic_local_match"
        )
        
        return [syntheticPlace]
    }
}
