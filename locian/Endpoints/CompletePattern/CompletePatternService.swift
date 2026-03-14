//
//  CompletePatternService.swift
//  locian
//
//  Service Layer for Pattern Completion.
//  Collects all necessary data (GPS, token) and performs the network call.
//

import Foundation

class CompletePatternService {
    static let shared = CompletePatternService()
    private init() {}
    
    /// Collects context and hits the completion endpoint
    func completePattern(
        patternId: String? = nil,
        placeId: String,
        places: [DiscoverPlaceInput]? = nil,
        completion: @escaping (Result<CompletePatternResponse, Error>) -> Void
    ) {
        // 1. Capture Time (Local Context)
        let currentDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        
        let locationManager = LocationManager.shared
        
        // 2. Collect Context
        let lat = locationManager.latitude
        let lon = locationManager.longitude
        
        let request = CompletePatternRequest(
            place_id: placeId,
            pattern_id: patternId,
            time: timeString,
            date: dateString,
            latitude: lat,
            longitude: lon,
            places: places
        )
        
        let idLabel = patternId ?? "INTEREST-TAP"
        print("📡 [CompletePatternService] Reporting Mastery for '\(idLabel)' @ '\(placeId)'")
        
        // 3. Perform Request
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/learning/complete-pattern",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
