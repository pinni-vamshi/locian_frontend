//
//  DiscoverMomentsService.swift
//  locian
//
//  Service Layer for Discover Moments Endpoint
//  Gathers Context (GPS, Time, Places, Image) -> Calls API
//

import Foundation
import UIKit
import CoreLocation
import Combine

class DiscoverMomentsService: ObservableObject {
    static let shared = DiscoverMomentsService()
    
    // Published state for loading UI
    @Published var isLoading: Bool = false
    
    private init() {}
    
    /// Main Entry Point: Discover moments with minimal input
    /// Automatically gathers GPS, Time, Nearby Places internally
    func discoverMoments(
        explicitRequest: String? = nil,
        image: UIImage? = nil,
        completion: @escaping (Result<DiscoverMomentsResponse, Error>) -> Void
    ) {
        // 1. Set Loading State
        self.isLoading = true
        
        // 2. Gather App Data
        let appState = AppStateManager.shared
        // Use active pair or fallback
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let userLanguage = activePair?.native_language ?? "en" // Default to 'en'
        
        // 3. Gather Time
        let currentDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        
        // 4. Thread-Safe Execution Block
        var didProceed = false
        let lock = NSLock()
        
        func proceed() {
            lock.lock()
            guard !didProceed else {
                lock.unlock()
                return
            }
            didProceed = true
            lock.unlock()
            
            // 5. Gather Location Data (Snapshot)
            let location = LocationManager.shared.currentLocation
            
            // Get nearby places for context (Structured for V3)
            let nearbyData = LocationManager.shared.getNearbyPlacesForAPI()
            let structuredPlaces: [DiscoverPlaceInput] = nearbyData.map { place in
                return DiscoverPlaceInput(
                    name: place.place_name,
                    category: place.type ?? "unknown",
                    distance: place.distance
                )
            }
            
            print("📍 [DiscoverMomentsService] Proceeding. Location: \(location?.coordinate.latitude ?? 0),\(location?.coordinate.longitude ?? 0). Nearby Places Found: \(structuredPlaces.count)")
            
            // 6. Image Processing
            var imageBase64: String? = nil
            if let img = image, let items = img.jpegData(compressionQuality: 0.6) {
                imageBase64 = "data:image/jpeg;base64," + items.base64EncodedString()
            }
            
            // 7. Motion Data (Mapped to V3 Standard)
            MotionService.shared.fetchCurrentMotionState { motionString in
                let velocity = motionString.lowercased().contains("walk") ? "walking" : 
                              (motionString.lowercased().contains("auto") ? "automotive" : "stationary")
                
                // 8. Weather Data (Async/Await bridge)
                Task {
                    var weatherString = "clear" // Fallback to clear as per requirement
                    if let loc = location {
                        weatherString = await WeatherServiceManager.shared.fetchCurrentWeather(for: loc)
                    }
                    
                    // 9. Build Request safely on Main Thread
                    DispatchQueue.main.async {
                        let request = DiscoverMomentsRequest(
                            user_id: appState.username, // Ensure user identity is sent
                            latitude: location?.coordinate.latitude,
                            longitude: location?.coordinate.longitude,
                            user_language: userLanguage,
                            target_language: activePair?.target_language,
                            time: timeString,
                            date: dateString,
                            places: structuredPlaces,
                            image_base64: imageBase64,
                            explicit_request: explicitRequest,
                            session_token: appState.authToken,
                            current_velocity: velocity,
                            weather: weatherString
                        )
                        
                        // 📡 [DEBUG] Log exact JSON Payload
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        if let data = try? encoder.encode(request), let jsonString = String(data: data, encoding: .utf8) {
                            print("\n--------------------------------------------------")
                            print("📤 [DiscoverMomentsService] V3 REQUEST PAYLOAD:")
                            print(jsonString)
                            print("--------------------------------------------------\n")
                        }
                        
                        // 10. API Call
                        BaseAPIManager.shared.performRawRequest(
                            endpoint: "/api/learning/discover-moments",
                            method: "POST",
                            body: request,
                            timeoutInterval: 60.0
                        ) { [weak self] (result: Result<Data, Error>) in
                            
                            DispatchQueue.main.async {
                                self?.isLoading = false
                                
                                switch result {
                                case .success(let data):
                                    // DEBUG: Print Raw Response
                                    if let jsonString = String(data: data, encoding: .utf8) {
                                        print("\n--------------------------------------------------")
                                        print("📥 [DiscoverMomentsService] V3 RESPONSE PAYLOAD:")
                                        print(jsonString)
                                        print("--------------------------------------------------\n")
                                    }
                                    
                                    do {
                                        let response = try JSONDecoder().decode(DiscoverMomentsResponse.self, from: data)
                                        print("✅ [DiscoverMomentsService] V3 Success. Recommendations: \(response.data?.recommendations?.count ?? 0)")
                                        completion(.success(response))
                                    } catch {
                                        print("❌ [DiscoverMomentsService] V3 Decoding Error: \(error)")
                                        completion(.failure(error))
                                    }
                                case .failure(let error):
                                    print("❌ [DiscoverMomentsService] Network Error: \(error)")
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 11. Location & Nearby Places Strategy (Wait for MapKit)
        let group = DispatchGroup()
        group.enter()
        
        print("🗺️ [DiscoverMomentsService] Fetching fresh MapKit data...")
        LocationManager.shared.fetchNearbyPlaces { _ in
            group.leave()
        }
        
        // Trigger proceed on group completion
        group.notify(queue: .main) {
            proceed()
        }
        
        // Safety Timeout (5.0s max wait for GPS/MapKit)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if !didProceed {
                print("⚠️ [DiscoverMomentsService] MapKit fetch timed out. Proceeding with available data.")
                proceed()
            }
        }
    }
}
