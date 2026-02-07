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
    
    // Legacy support (computed from sections)
    var mostLikely: [ScoredPlace] { sections.first?.items ?? [] }
    var likely: [ScoredPlace] { sections.count > 1 ? sections[1].items : [] }
    
    init(sections: [RecommendationResultSection], suggestedPlaceName: String = "SUGGESTED MOMENTS") {
        self.sections = sections
        self.suggestedPlaceName = suggestedPlaceName
        print("\n🟢 [Model] LocalRecommendationResult initialized")
        print("   - Sections: \(sections.count)")
        print("   - Most Likely Items: \(sections.first?.items.count ?? 0)")
        print("   - Suggested Name: \(suggestedPlaceName)")
    }
}

struct RecommendationResultSection {
    let title: String // "Most Likely", "Likely"
    let items: [ScoredPlace]
    
    init(title: String, items: [ScoredPlace]) {
        self.title = title
        self.items = items
        print("   🔹 [Model] Section '\(title)' Created with \(items.count) items")
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
        // Commented out to avoid 1000s of lines per second, but can be enabled if user insists
        // print("      🔸 [Model] ScoredPlace Created: '\(extractedName)' (Score: \(score))")
    }
}
