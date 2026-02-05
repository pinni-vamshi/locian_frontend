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
    
    /// Predict place from list - gathers user profile data internally
    func predictPlace(
        places: [String],
        previousPlaces: [PlaceContext]? = nil,
        futurePlaces: [PlaceContext]? = nil,
        sessionToken: String,
        completion: @escaping (Result<PredictPlaceResponse, Error>) -> Void
    ) {
        PermissionsService.ensureLocationAccess { granted in
            // Proceed anyway even if location is false, but gather what we can
            // (The user pattern says 'proceeds', so we continue with nil location if denied)
            
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
}
