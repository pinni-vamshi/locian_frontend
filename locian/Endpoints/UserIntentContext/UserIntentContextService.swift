//
//  UserIntentContextService.swift
//  locian
//
//  Service for GET /api/user/intent/context
//

import Foundation
import Combine

class UserIntentContextService {
    static let shared = UserIntentContextService()
    private init() {}
    
    /// Unified Endpoint: POST /api/user/intent/context
    /// Fetch habitual context (timeline/routine).
    func unifyIntentContext(
        lat: Double,
        lng: Double,
        time: String? = nil,
        date: String? = nil,
        completion: @escaping (Result<UserIntentContextResponse, Error>) -> Void
    ) {
        // 1. Capture Time/Date if not provided
        let currentDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = time ?? timeFormatter.string(from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = date ?? dateFormatter.string(from: currentDate)
        
        let requestPayload = UnifiedIntentRequest(
            lat: lat,
            lng: lng,
            time: timeString,
            date: dateString
        )
        
        print("🚀 [UserIntentContextService] POST /api/user/intent/context (V2 Unified)")
        
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
