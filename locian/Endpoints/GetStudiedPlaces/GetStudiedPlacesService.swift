//
//  GetStudiedPlacesService.swift
//  locian
//
//  Service layer for Get Studied Places Endpoint
//  Gathers required data (location, time) and makes the API call
//

import Foundation
import CoreLocation

class GetStudiedPlacesService {
    static let shared = GetStudiedPlacesService()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Fetch studied places with automatic data gathering
    func fetchStudiedPlaces(
        sessionToken: String,
        completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void
    ) {
        PermissionsService.ensureLocationAccess { granted in
            // Proceed anyway as per 'self-ensuring' but gathered pattern
            
            // Gather current time
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = formatter.string(from: currentDate)
            
            // Gather current location
            let userLocation = LocationManager.shared.currentLocation
            
            // Build request
            let request = GetStudiedPlacesRequest(
                time: timestamp,
                latitude: userLocation?.coordinate.latitude,
                longitude: userLocation?.coordinate.longitude,
                limit: 50
            )
            
            // Make API call
            self.performRequest(request: request, sessionToken: sessionToken, completion: completion)
        }
    }
    
    /// Fetch studied places with custom request parameters
    func fetchStudiedPlaces(
        request: GetStudiedPlacesRequest,
        sessionToken: String,
        extraHeaders: [String: String] = [:],
        completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void
    ) {
        performRequest(request: request, sessionToken: sessionToken, extraHeaders: extraHeaders, completion: completion)
    }
    
    // MARK: - Private API Call
    
    private func performRequest(
        request: GetStudiedPlacesRequest,
        sessionToken: String,
        extraHeaders: [String: String] = [:],
        completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void
    ) {
        var headers = ["Authorization": "Bearer \(sessionToken)"]
        
        // Merge extra headers
        for (key, value) in extraHeaders {
            headers[key] = value
        }
        
        // Use BaseAPIManager to perform the raw request
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/user/studied-places/get",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 300.0,
            completion: { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    // Pass raw data to Logic layer for parsing
                    GetStudiedPlacesLogic.shared.parseResponse(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
