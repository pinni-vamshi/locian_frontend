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
        // 1. Gather GPS Nearby Places with 2.0s Timeout
        var didProceed = false
        let lock = NSLock()
        
        func proceed(with fetchedPlaces: [String]) {
            lock.lock()
            guard !didProceed else { 
                lock.unlock()
                print("🛑 [PredictPlaceService] 'proceed' blocked - already proceeded.")
                return 
            }
            didProceed = true
            lock.unlock()
            
            print("🚀 [PredictPlaceService] 'proceed' executing with \(fetchedPlaces.count) places.")

            // 2. Gather History from AppStateManager
            let history = AppStateManager.shared.timeline?.places ?? []
            print("   -> History Count: \(history.count)")
            
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            // Previous: Last 2 before/matching current hour
            let previous = history.filter { ($0.hour ?? -1) <= currentHour }
                .sorted { ($0.hour ?? -1) > ($1.hour ?? -1) }
                .prefix(2)
                .compactMap { h -> PlaceContext? in
                    guard let name = h.place_name, let time = h.time else { return nil }
                    return PlaceContext(place_name: name, time: time)
                }
            print("   -> Previous Places: \(previous.count)")
            
            // Future: Next 1 after current hour
            let future = history.filter { ($0.hour ?? -1) > currentHour }
                .sorted { ($0.hour ?? -1) < ($1.hour ?? -1) }
                .prefix(1)
                .compactMap { h -> PlaceContext? in
                    guard let name = h.place_name, let time = h.time else { return nil }
                    return PlaceContext(place_name: name, time: time)
                }
            print("   -> Future Places: \(future.count)")
            
            // 3. Perform the actual request
            print("   -> Calling performPredictRequest...")
            self.performPredictRequest(
                places: fetchedPlaces,
                previousPlaces: Array(previous),
                futurePlaces: Array(future),
                sessionToken: sessionToken,
                completion: completion
            )
        }
        
        // Start Timeout Timer (2.0s) // Changed from 10s to 2.0s as per requirement
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("⏳ [PredictPlaceService] GPS Timeout (2s) reached. Proceeding without places.")
            proceed(with: [])
        }
        
        // Start GPS Fetch
        print("📍 [PredictPlaceService] requesting fetchNearbyPlaces...")
        LocationManager.shared.fetchNearbyPlaces { nearbyPlaces in
            print("📍 [PredictPlaceService] GPS Fetch returned \(nearbyPlaces.count) places.")
            proceed(with: nearbyPlaces)
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
        print("🕒 [PredictPlaceService] Current Time: \(timeString)")
        
        // Gather location
        let userLocation = LocationManager.shared.currentLocation
        print("📍 [PredictPlaceService] User Coords: \(String(describing: userLocation?.coordinate))")
        
        // Gather user profile data from AppState
        let appState = AppStateManager.shared
        let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default })
        let targetLanguage = defaultPair?.target_language
        let userLanguage = appState.nativeLanguage
        let level = defaultPair?.user_level ?? "BEGINNER"
        
        print("👤 [PredictPlaceService] Profile: \(userLanguage) -> \(String(describing: targetLanguage)) [\(level)]")
        
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
        
        print("📦 [PredictPlaceService] Request Body Prepared. Places Count: \(places.count)")
        
        let headers = ["Authorization": "Bearer \(sessionToken)"]
        
        print("🚀 [PredictPlaceService] Sending Raw Request to /api/user/context/text...")
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/user/context/text",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 300.0,
            completion: { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    print("✅ [PredictPlaceService] Raw Response Received: \(data.count) bytes")
                    PredictPlaceLogic.shared.parseResponse(data: data, completion: completion)
                case .failure(let error):
                    print("❌ [PredictPlaceService] Raw Request Failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        )
    }
}
