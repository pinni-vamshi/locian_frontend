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
    // Legacy support (computed from sections)
    var mostLikely: [ScoredPlace] { sections.first?.items ?? [] }
    var likely: [ScoredPlace] { sections.count > 1 ? sections[1].items : [] }
}

struct RecommendationResultSection {
    let title: String // "Most Likely", "Likely"
    let items: [ScoredPlace]
}

struct ScoredPlace: Identifiable {
    let place: MicroSituationData
    let score: Double
    let matchReason: String // For debugging: "Intent Similarity", "GPS Boost", etc.
    let extractedName: String // Refined name from NLTagger if available, else original
    
    var id: String { place.id }
}
