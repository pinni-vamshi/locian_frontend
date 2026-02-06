//
//  LocalRecommendationService.swift
//  locian
//
//  Orchestrator for Local Recommendations.
//  Matches User Intent + GPS to Historical Data to provide instant suggestions.
//

import Foundation
import CoreLocation

class LocalRecommendationService {
    static let shared = LocalRecommendationService()
    
    private init() {}
    
    // MARK: - Main API
    
    func recommend(intent: UserIntent, location: CLLocation?, history: [MicroSituationData]) -> LocalRecommendationResult {
        // 1. Convert Intent to Text for Embedding
        let intentText = intentToText(intent)
        
        // 2. Generate Embedding for Intent
        let intentVector = EmbeddingEngine.shared.generateEmbedding(for: intentText)
        
        // 3. Score all historical places (Returns list of Scored Moments per Place)
        // flatMap ensures we get a single list of all matched moments across all history
        let scoredPlaces = history.flatMap { place in
            ScoringEngine.shared.score(place: place, intentVector: intentVector, userLocation: location)
        }
        
        // 4. Sort by Score (High to Low)
        let sortedPlaces = scoredPlaces.sorted { $0.score > $1.score }
        
        // 5. Categorize (Just Top 10 as requested - No split)
        let topMatches = Array(sortedPlaces.prefix(10))
        
        // Logging for Debug/Verification
        print("🔍 [LocalRec] Intent: \(intentText.prefix(30))...")
        print("\n🏆 --- FINAL STAND (TOP 10 MOMENTS - NO ORDER) ---")
        
        for (i, item) in topMatches.enumerated() {
             guard let moment = item.place.micro_situations?.first?.moments.first?.text else { continue }
             print("   \(i+1). [\(String(format: "%.2f", item.score))] \(moment) (\(item.place.place_name ?? ""))")
        }
        print("----------------------------------------\n")
        
        return LocalRecommendationResult(
            mostLikely: topMatches,
            likely: [] // Empty as user requested no split
        )
    }
    
    // MARK: - Helpers
    
    private func intentToText(_ intent: UserIntent) -> String {
        // Combine non-nil intent fields into a single descriptive string for vectorization
        let fields = [
            intent.movement,
            intent.waiting,
            intent.consume_fast,
            intent.consume_slow,
            intent.errands,
            intent.browsing,
            intent.rest,
            intent.social,
            intent.emergency,
            intent.suggested_needs
        ]
        return fields.compactMap { $0 }.joined(separator: " ")
    }
}
