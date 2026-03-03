//
//  UserIntentContextService.swift
//  locian
//
//  Service for GET /api/user/intent/context
//

import Foundation

class UserIntentContextService {
    static let shared = UserIntentContextService()
    private init() {}
    
    /// Unified Endpoint: POST /api/user/intent/context
    /// Handles both fetching context (empty overrides) and updating routine/geo data.
    func unifyIntentContext(
        lat: Double,
        lng: Double,
        time: String? = nil,
        overrides: [String: [String]]? = nil,
        geoUpdates: [String: GeoUpdateData]? = nil,
        completion: @escaping (Result<UserIntentContextResponse, Error>) -> Void
    ) {
        let requestPayload = UnifiedIntentRequest(
            latitude: lat,
            longitude: lng,
            time: time,
            overrides: overrides,
            geo_updates: geoUpdates
        )
        
        print("🚀 [UserIntentContextService] POST /api/user/intent/context (Unified)")
        
        // DEBUG: Print Raw Request
        if let requestData = try? JSONEncoder().encode(requestPayload),
           let requestString = String(data: requestData, encoding: .utf8) {
            print("📤 [UserIntentContext] Raw Request: \(requestString)")
        }
        
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/user/intent/context",
            method: "POST",
            body: requestPayload
        ) { result in
            switch result {
            case .success(let data):
                // DEBUG: Print Raw Response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 [UserIntentContext] Raw Response: \(jsonString)")
                }
                
                do {
                    let response = try JSONDecoder().decode(UserIntentContextResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("❌ [UserIntentContextService] Decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ [UserIntentContextService] Request error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
