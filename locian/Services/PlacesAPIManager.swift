//
//  PlacesAPIManager.swift
//  locian
//
//  Created by AI Assistant
//

import Foundation

class PlacesAPIManager: BaseAPIManagerProtocol {
    static let shared = PlacesAPIManager()
    
    private init() {}
    
    // Infer interest endpoint - uses longer timeout since it's a slow endpoint
    // Note: session_token is now included in the request body, not in headers
    func inferInterest(request: InferInterestRequest, completion: @escaping (Result<InferInterestResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/places/infer-interest",
            method: "POST",
            body: request,
            headers: [:], // No Authorization header needed - session_token is in body
            timeoutInterval: 30.0, // Increased timeout to 30 seconds for slow inference endpoint
            completion: completion
        )
    }
}


