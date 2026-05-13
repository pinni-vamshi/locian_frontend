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
        self.isLoading = true
        let overallStartTime = Date()
        
        Task {
            do {
                let response = try await performDiscoveryAsync(
                    explicitRequest: explicitRequest,
                    image: image,
                    overallStartTime: overallStartTime
                )
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Async Flow Pipeline
    
    private func performDiscoveryAsync(
        explicitRequest: String?,
        image: UIImage?,
        overallStartTime: Date
    ) async throws -> DiscoverMomentsResponse {
        // 1. Gather Locale & Time
        let (userLanguage, targetLanguage) = gatherLanguages()
        let (timeString, dateString) = gatherDateTime()

        // 2. Fetch fresh location so latitude/longitude are always available
        let location = try await fetchCurrentLocationAsync()
        let coordinate = location.coordinate

        // 3. Process Image
        let imageBase64 = processImage(image)

        // 4. Gather endpoint context concurrently
        async let nearbyResults = fetchNearbyPlacesAsync()
        async let velocity = fetchGPSVelocityAsync()
        async let weatherString = fetchWeatherAsync(location: location)
        async let altitude = fetchAltitudeAsync()

        // Wait for context
        let fetchedPlaces = await nearbyResults
        let structuredPlaces = fetchedPlaces.map { place in
            DiscoverPlaceInput(
                name: place.name,
                category: place.category ?? "unknown",
                place_latitude: place.latitude,
                place_longitude: place.longitude
            )
        }

        print("📍 [DiscoverMomentsService] Proceeding. Location: \(coordinate.latitude),\(coordinate.longitude). Nearby Places Found: \(structuredPlaces.count)")

        let fetchedVelocity = await velocity
        let fetchedWeather = await weatherString
        let fetchedAltitude = await altitude
        let ambientLight = AmbientLightService.shared.fetchLightLevel()
        let playback = await MainActor.run {
            VolumeRouteService.shared.snapshot()
        }

        // 5. Build Wi-Fi context payload
        let networkDetails = getNetworkDetails()
        var wifiDict = [String: String]()
        if let ssid = networkDetails.wifi {
            wifiDict["ssid"] = ssid
        }
        if let bssid = networkDetails.bssid {
            wifiDict["bssid"] = bssid
        }
        if let conn = networkDetails.connType {
            wifiDict["connection_type"] = conn
        }

        // 6. Build full Discover Moments payload expected by backend
        let request = DiscoverMomentsRequest(
            session_token: AppStateManager.shared.authToken,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            date: dateString,
            time: timeString,
            velocity: fetchedVelocity,
            weather: fetchedWeather,
            places: structuredPlaces,
            output_volume: playback.outputVolume,
            headphones_connected: playback.headphonesConnected,
            audio_db: nil,
            light_level: ambientLight,
            altitude: fetchedAltitude,
            wifi_info: wifiDict.isEmpty ? nil : wifiDict,
            explicit_request: explicitRequest,
            image_base64: imageBase64,
            user_language: userLanguage,
            target_language: targetLanguage
        )
        
        logRequestPayload(request)
        
        let contextTime = Date().timeIntervalSince(overallStartTime)
        print("⏱️ [DiscoverMomentsService] Context Gathering Finished in \(String(format: "%.2f", contextTime))s")
        
        // 7. Execute External API
        let apiStartTime = Date()
        let response = try await executeAPIRequestAsync(request: request)
        
        let apiDuration = Date().timeIntervalSince(apiStartTime)
        let totalTime = Date().timeIntervalSince(overallStartTime)
        
        print("✅ [DiscoverMomentsService] V3 Success. Recommendations: \(response.recommendations.count)")
        print("📥 [DiscoverMomentsService] API call took \(String(format: "%.2f", apiDuration))s")
        print("🏁 [DiscoverMomentsService] TOTAL DISCOVERY TIME: \(String(format: "%.2f", totalTime))s")
        
        return response
    }
    
    // MARK: - Synchronous Context Helpers

    private func gatherLanguages() -> (String, String) {
        let appState = AppStateManager.shared
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        return (activePair?.native_language ?? "en", activePair?.target_language ?? "es")
    }
    
    private func gatherDateTime() -> (String, String) {
        let currentDate = Date()
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        
        return (timeString, dateString)
    }

    private func processImage(_ image: UIImage?) -> String? {
        if let img = image, let items = img.jpegData(compressionQuality: 0.6) {
            return "data:image/jpeg;base64," + items.base64EncodedString()
        }
        return nil
    }

    private func getNetworkDetails() -> (wifi: String?, bssid: String?, connType: String?) {
        return (
            wifi: WiFiService.shared.currentSSID,
            bssid: WiFiService.shared.currentBSSID,
            connType: WiFiService.shared.connectionType
        )
    }
    
    private func logRequestPayload(_ request: DiscoverMomentsRequest) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(request), let jsonString = String(data: data, encoding: .utf8) {
            print("\n--------------------------------------------------")
            print("📤 [DiscoverMomentsService] V3 REQUEST PAYLOAD:")
            print(jsonString)
            print("--------------------------------------------------\n")
        }
    }
    
    // MARK: - Asynchronous Wrappers
    
    private func fetchNearbyPlacesAsync() async -> [LocationManager.NearbyAmbience] {
        await withCheckedContinuation { continuation in
            var didResume = false
            let lock = NSLock()
            
            print("🗺️ [DiscoverMomentsService] Fetching fresh MapKit data...")
            LocationManager.shared.fetchNearbyPlaces { results in
                lock.lock()
                guard !didResume else {
                    lock.unlock()
                    return
                }
                didResume = true
                lock.unlock()
                
                continuation.resume(returning: results)
            }
        }
    }

    private func fetchCurrentLocationAsync() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            let lock = NSLock()

            LocationManager.shared.getCurrentLocation { result in
                lock.lock()
                guard !didResume else {
                    lock.unlock()
                    return
                }
                didResume = true
                lock.unlock()

                switch result {
                case .success(let location):
                    continuation.resume(returning: location)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchGPSVelocityAsync() async -> String {
        await withCheckedContinuation { continuation in
            var didResume = false
            let lock = NSLock()

            MotionService.shared.fetchGPSVelocityKmh { velocity in
                lock.lock()
                guard !didResume else {
                    lock.unlock()
                    return
                }
                didResume = true
                lock.unlock()

                continuation.resume(returning: velocity)
            }
        }
    }
    
    private func fetchWeatherAsync(location: CLLocation?) async -> String {
        guard let loc = location else { return "unknown" }
        let result = await WeatherServiceManager.shared.fetchWeatherData(for: loc)
        return "\(Int(result.temp))*C|\(result.condition.uppercased())"
    }

    private func fetchAltitudeAsync() async -> Double? {
        await withCheckedContinuation { continuation in
            var didResume = false
            let lock = NSLock()

            AltitudeService.shared.fetchAltitude { altitude in
                lock.lock()
                guard !didResume else {
                    lock.unlock()
                    return
                }
                didResume = true
                lock.unlock()

                continuation.resume(returning: altitude)
            }
        }
    }
    
    private func executeAPIRequestAsync(request: DiscoverMomentsRequest) async throws -> DiscoverMomentsResponse {
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            let lock = NSLock()
            
            BaseAPIManager.shared.performRawRequest(
                endpoint: "/api/learning/discover-moments",
                method: "POST",
                body: request,
                timeoutInterval: 60.0
            ) { (result: Result<Data, Error>) in
                lock.lock()
                guard !didResume else {
                    lock.unlock()
                    return
                }
                didResume = true
                lock.unlock()
                
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(DiscoverMomentsResponse.self, from: data)
                        continuation.resume(returning: response)
                    } catch {
                        print("❌ [DiscoverMomentsService] V3 Decoding Error: \(error)")
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    print("❌ [DiscoverMomentsService] Network Error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
