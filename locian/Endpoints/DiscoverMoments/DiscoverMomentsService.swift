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
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let userLanguage = activePair?.native_language ?? "en"
        let targetLanguage = activePair?.target_language ?? "es"
        
        
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
        
        func proceed(with nearbyResults: [LocationManager.NearbyAmbience] = []) {
            lock.lock()
            guard !didProceed else {
                lock.unlock()
                return
            }
            didProceed = true
            lock.unlock()
            
            // 5. Gather Location Data (Snapshot)
            let location = LocationManager.shared.currentLocation
            
            // Map results passed directly from the search (Stateless)
            let structuredPlaces: [DiscoverPlaceInput] = nearbyResults.prefix(10).map { place in
                return DiscoverPlaceInput(
                    name: place.name,
                    category: place.category ?? "unknown"
                )
            }
            
            print("📍 [DiscoverMomentsService] Proceeding. Location: \(location?.coordinate.latitude ?? 0),\(location?.coordinate.longitude ?? 0). Nearby Places Found: \(structuredPlaces.count)")
            
            // 6. Image Processing
            var imageBase64: String? = nil
            if let img = image, let items = img.jpegData(compressionQuality: 0.6) {
                imageBase64 = "data:image/jpeg;base64," + items.base64EncodedString()
            }
            
            
            // 7. Motion Data (Numeric Velocity via GPS)
            MotionService.shared.fetchCurrentMotionState { velocity in
                
                // 8. Weather Data (Raw Numeric Bridge)
                Task {
                    var weatherString = "unknown"
                    var currentTemp: Double = 0.0
                    var currentPressure: Double = 0.0
                    
                    if let loc = location {
                        let result = await WeatherServiceManager.shared.fetchWeatherData(for: loc)
                        weatherString = result.condition
                        currentTemp = result.temperature
                        currentPressure = result.pressure
                    }
                    
                // 9. Fetch Telemetry On-Demand
                let ambientDb = await AmbientSoundService.shared.fetchDecibels()
                let ambientLight = AmbientLightService.shared.fetchLightLevel()
                let wifi = WiFiService.shared.currentSSID
                
                AltitudeService.shared.fetchAltitude { altitude in
                    // 10. Build Request safely on Main Thread
                    DispatchQueue.main.async {
                        let request = DiscoverMomentsRequest(
                            time: timeString,
                            date: dateString,
                            latitude: location?.coordinate.latitude,
                            longitude: location?.coordinate.longitude,
                            places: structuredPlaces,
                            velocity: velocity,
                            audio_db: Double(ambientDb),
                            light_level: ambientLight,
                            altitude: altitude,
                            explicit_request: explicitRequest,
                            image_base64: imageBase64,
                            weather: "\(Int(currentTemp))C", // Send temperature as primary weather identifier
                            pressure: currentPressure,
                            user_language: userLanguage,
                            target_language: targetLanguage,
                            wifi_ssid: wifi
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
        }
        
        // 11. Location & Nearby Places Strategy (Wait for MapKit)
        print("🗺️ [DiscoverMomentsService] Fetching fresh MapKit data...")
        LocationManager.shared.fetchNearbyPlaces { results in
            proceed(with: results)
        }
        
        // Safety Timeout (5.0s max wait for GPS/MapKit)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if !didProceed {
                print("🚨 [DiscoverMomentsService] MapKit fetch TIMED OUT (5.0s). Stopping everything.")
                LocationManager.shared.cancelSearch() // KILL the search immediately
                
                self.isLoading = false
                let timeoutError = NSError(domain: "DiscoverMomentsService", code: 408, userInfo: [NSLocalizedDescriptionKey: "Location discovery timed out (5.0s). Please try again."])
                completion(.failure(timeoutError))
                
                // Ensure we don't proceed later
                lock.lock()
                didProceed = true
                lock.unlock()
            }
        }
    }
}
