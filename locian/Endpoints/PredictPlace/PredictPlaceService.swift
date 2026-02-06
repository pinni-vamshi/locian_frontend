//
//  PredictPlaceService.swift
//  locian
//
//  Service layer - gathers user context and makes API call
//

import Foundation
import CoreLocation

class PredictPlaceService {
    static let shared = PredictPlaceService()
    private init() {}
    
    /// Autonomous prediction - gathers GPS, History, and Profile internally
    func predictPlace(
        sessionToken: String,
        completion: @escaping (Result<PredictPlaceResponse, Error>) -> Void
    ) {
        // 1. Gather GPS Nearby Places
        LocationManager.shared.fetchNearbyPlaces { nearbyPlaces in
            
            // 2. Gather History from AppStateManager
            let history = AppStateManager.shared.timeline?.places ?? []
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            // Previous: Last 2 before/matching current hour
            let previous = history.filter { ($0.hour ?? -1) <= currentHour }
                .sorted { ($0.hour ?? -1) > ($1.hour ?? -1) }
                .prefix(2)
                .compactMap { h -> PlaceContext? in
                    guard let name = h.place_name, let time = h.time else { return nil }
                    return PlaceContext(place_name: name, time: time)
                }
            
            // Future: Next 1 after current hour
            let future = history.filter { ($0.hour ?? -1) > currentHour }
                .sorted { ($0.hour ?? -1) < ($1.hour ?? -1) }
                .prefix(1)
                .compactMap { h -> PlaceContext? in
                    guard let name = h.place_name, let time = h.time else { return nil }
                    return PlaceContext(place_name: name, time: time)
                }
            
            // 3. Perform the actual request
            self.performPredictRequest(
                places: nearbyPlaces,
                previousPlaces: Array(previous),
                futurePlaces: Array(future),
                sessionToken: sessionToken,
                completion: completion
            )
        }
    }
    
    /// Private implementation that performs the actual network request
    private func performPredictRequest(
        places: [String],
        previousPlaces: [PlaceContext]? = nil,
        futurePlaces: [PlaceContext]? = nil,
        sessionToken: String,
        completion: @escaping (Result<PredictPlaceResponse, Error>) -> Void
    ) {
        // Gather current time
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: currentDate)
        
        // Gather location
        let userLocation = LocationManager.shared.currentLocation
        
        // Gather user profile data from AppState
        let appState = AppStateManager.shared
        let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default })
        let targetLanguage = defaultPair?.target_language
        let userLanguage = appState.nativeLanguage
        let level = defaultPair?.user_level ?? "BEGINNER"
        
        // Build request
        let request = PredictPlaceRequest(
            places: places,
            time: timeString,
            previous_places: previousPlaces,
            future_places: futurePlaces,
            native_language: userLanguage,
            target_language: targetLanguage,
            level: level,
            latitude: userLocation?.coordinate.latitude,
            longitude: userLocation?.coordinate.longitude
        )
        
        let headers = ["Authorization": "Bearer \(sessionToken)"]
        
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/user/context/text",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 300.0,
            completion: { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    PredictPlaceLogic.shared.parseResponse(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
