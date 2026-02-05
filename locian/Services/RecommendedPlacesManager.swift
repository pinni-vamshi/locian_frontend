//
//  RecommendedPlacesManager.swift
//  locian
//
//  Created by AI Assistant
//

import Foundation
import CoreLocation

class RecommendedPlacesManager {
    static let shared = RecommendedPlacesManager()

    private init() {}

    // MARK: - Deprecated
    // Logic moved to Scene/LearnTabLogic/LearnTabService.swift
    // and LearnDataParser.swift
    
    // MARK: - Build Recommendations from API Data
    
    /// Build recommended places list from API data (studied places)
    /// API now returns data pre-sorted by priority, so no client-side sorting needed
    func buildRecommendedHistoryFromAPI(
        studiedPlaces: [StudiedPlaceData],
        currentTime: Date = Date()
    ) -> [(placeName: String, time: String)] {
        
        // API returns data already sorted by priority
        // Just deduplicate by place name, keeping the first occurrence (highest priority)
        var seenPlaces: Set<String> = []
        var result: [(placeName: String, time: String)] = []
        
        for place in studiedPlaces {
            let normalized = place.place_name.lowercased()
            if !seenPlaces.contains(normalized) {
                seenPlaces.insert(normalized)
                result.append((placeName: place.place_name, time: place.time))
            }
        }
        
        // Return top 10 places (already sorted by API priority)
        return Array(result.prefix(10))
    }
}
