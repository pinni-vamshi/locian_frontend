//
//  GenerateMomentsService.swift
//  locian
//
//  Service layer for Generate Moments Endpoint
//  Gathers required data and makes the API call
//

import Foundation
import CoreLocation

class GenerateMomentsService {
    static let shared = GenerateMomentsService()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Generate moments with automatic data gathering
    /// Generate moments with automatic data gathering
    func generateMoments(
        placeName: String,
        placeDetail: String? = nil,
        sessionToken: String,
        completion: @escaping (Result<GenerateMomentsResponse, Error>) -> Void
    ) {
        // 1. Define continuation logic with Lock for Thread Safety
        var didProceed = false
        let lock = NSLock()
        
        func proceed(location: CLLocation?) {
            lock.lock()
            guard !didProceed else {
                lock.unlock()
                return
            }
            didProceed = true
            lock.unlock()
            
            // Gather current time
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let timeString = formatter.string(from: currentDate)
            
            // Gather user profile data
            let appState = AppStateManager.shared
            let level = appState.userLanguagePairs.first(where: { $0.is_default })?.user_level ?? "BEGINNER"
            let userLanguage = appState.nativeLanguage
            let profession = appState.profession
            
            // Gather history context
            let history = AppStateManager.shared.timeline?.places ?? []
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            let previous = history.filter { ($0.hour ?? -1) <= currentHour }
                .sorted { ($0.hour ?? -1) > ($1.hour ?? -1) }
                .prefix(2)
                .compactMap { h -> TimelinePlaceContext? in
                    guard let name = h.place_name, let time = h.time else { return nil }
                    return TimelinePlaceContext(place_name: name, time: time)
                }
            
            let future = history.filter { ($0.hour ?? -1) > currentHour }
                .sorted { ($0.hour ?? -1) < ($1.hour ?? -1) }
                .prefix(1)
                .compactMap { h -> TimelinePlaceContext? in
                    guard let name = h.place_name, let time = h.time else { return nil }
                    return TimelinePlaceContext(place_name: name, time: time)
                }
            
            // Build request
            var lat: Double? = nil
            var long: Double? = nil
            
            if let loc = location {
                lat = loc.coordinate.latitude
                long = loc.coordinate.longitude
            }
            
            let request = GenerateMomentsRequest(
                place_name: placeName,
                place_detail: placeDetail,
                time: timeString,
                profession: profession,
                previous_places: Array(previous),
                future_places: Array(future),
                weather: nil,
                activity_duration: nil,
                latitude: lat,
                longitude: long,
                user_language: userLanguage,
                level: level,
                remember: false
            )
            
            // Make API call
            self.performRequest(request: request, sessionToken: sessionToken, completion: completion)
        }
        
        // 2. Start Timeout Timer (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("⏳ [GenerateMomentsService] GPS Timeout (3s) reached. Proceeding without location.")
            proceed(location: nil)
        }
        
        // 3. Request Location
        print("📍 [GenerateMomentsService] Requesting current location...")
        LocationManager.shared.getCurrentLocation { result in
            switch result {
            case .success(let location):
                print("📍 [GenerateMomentsService] Location fetched: \(location.coordinate)")
                proceed(location: location)
            case .failure(let error):
                print("⚠️ [GenerateMomentsService] Location fetch failed: \(error.localizedDescription)")
                proceed(location: nil)
            }
        }
    }
    
    /// Generate moments with custom request parameters
    func generateMoments(
        request: GenerateMomentsRequest,
        sessionToken: String,
        completion: @escaping (Result<GenerateMomentsResponse, Error>) -> Void
    ) {
        performRequest(request: request, sessionToken: sessionToken, completion: completion)
    }
    
    // MARK: - Private API Call
    
    private func performRequest(
        request: GenerateMomentsRequest,
        sessionToken: String,
        completion: @escaping (Result<GenerateMomentsResponse, Error>) -> Void
    ) {
        let headers = ["Authorization": "Bearer \(sessionToken)"]
        
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/conversation/generate-moments",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 300.0,
            completion: { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    GenerateMomentsLogic.shared.parseResponse(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
