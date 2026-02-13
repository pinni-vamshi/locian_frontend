//
//  GenerateSentenceService.swift
//  locian
//
//  Service layer - gathers data and makes API call
//

import Foundation

class GenerateSentenceService {
    static let shared = GenerateSentenceService()
    private init() {}
    
    /// Generate sentence - only requires minimal input (place name, moment)
    /// Gathers all other data (languages, profession) internally
    func generateSentence(
        placeName: String,
        microSituation: String,
        userIntent: String? = nil,
        previousPlaces: [String]? = nil,
        futurePlaces: [String]? = nil,
        nearbyPlaces: [NearbyPlaceData]? = nil,
        sessionToken: String,
        completion: @escaping (Result<GenerateSentenceResponse, Error>) -> Void
    ) {
        // 1. Gather user profile data from AppState
        let appState = AppStateManager.shared
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        
        let targetLanguage = activePair?.target_language ?? LocalizationManager.shared.currentLanguage.rawValue
        let userLanguage = activePair?.native_language ?? (!appState.nativeLanguage.isEmpty ? appState.nativeLanguage : appState.appLanguage)
        let profession = appState.profession
        let level = activePair?.user_level ?? "beginner"
        
        // 2. Gather current time
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let dateString = dateFormatter.string(from: currentDate)

        // 3. Define continuation logic with Lock for Thread Safety
        var didProceed = false
        let lock = NSLock()
        
        func proceed(location: CLLocation?, nearby: [NearbyPlaceData]?) {
            lock.lock()
            guard !didProceed else {
                lock.unlock()
                return
            }
            didProceed = true
            lock.unlock()
            
            // Build Request
            let request = GenerateSentenceRequest(
                target_language: targetLanguage,
                user_language: userLanguage,
                place_name: placeName,
                micro_situation: microSituation,
                user_intent: userIntent,
                profession: profession,
                level: level,
                time: timeString,
                date: dateString,
                nearby_places: nearby ?? nearbyPlaces, // Prioritize fresh fetch
                previous_places: previousPlaces,
                future_places: futurePlaces,
                bypass_cache: false 
            )
            
            // Make API Call
            let headers = ["Authorization": "Bearer \(sessionToken)"]
            
            BaseAPIManager.shared.performRawRequest(
                endpoint: "/api/teaching/generate-sentence",
                method: "POST",
                body: request,
                headers: headers,
                timeoutInterval: 300.0,
                completion: { (result: Result<Data, Error>) in
                    switch result {
                    case .success(let data):
                        GenerateSentenceLogic.shared.parseResponse(data: data, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            )
        }
        
        // 4. Start Timeout Timer (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // GPS Timeout (3s) reached. Proceeding without location.
            proceed(location: nil, nearby: nil)
        }
        
        // 5. Request Location & Nearby Places (JIT)
        LocationManager.shared.getCurrentLocation { result in
            switch result {
            case .success(let location):
                // Fetch nearby places to ground the generation before proceeding
                LocationManager.shared.fetchNearbyPlaces { _ in
                    let nearby = LocationManager.shared.getNearbyPlacesForAPI()
                    proceed(location: location, nearby: nearby)
                }
            case .failure:
                // Location fetch failed
                proceed(location: nil, nearby: nil)
            }
        }
    }
}
