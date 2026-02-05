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
    func generateMoments(
        placeName: String,
        placeDetail: String? = nil,
        sessionToken: String,
        completion: @escaping (Result<GenerateMomentsResponse, Error>) -> Void
    ) {
        // Gather current time
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: currentDate)
        
        // Gather location
        let userLocation = LocationManager.shared.currentLocation
        
        // Gather user profile data
        let appState = AppStateManager.shared
        let level = appState.userLanguagePairs.first(where: { $0.is_default })?.user_level ?? "BEGINNER"
        let userLanguage = appState.nativeLanguage
        let profession = appState.profession
        
        // Build request
        let request = GenerateMomentsRequest(
            place_name: placeName,
            place_detail: placeDetail,
            time: timeString,
            profession: profession,
            previous_places: nil,
            future_places: nil,
            weather: nil,
            activity_duration: nil,
            latitude: userLocation?.coordinate.latitude,
            longitude: userLocation?.coordinate.longitude,
            user_language: userLanguage,
            level: level,
            remember: false
        )
        
        // Make API call
        performRequest(request: request, sessionToken: sessionToken, completion: completion)
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
