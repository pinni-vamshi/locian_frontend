//
//  UserIntentContextService.swift
//  locian
//
//  Service for POST /api/user/intent/context
//

import Foundation

class UserIntentContextService {
    static let shared = UserIntentContextService()
    private init() {}
    
    /// Unified Endpoint: POST /api/user/intent/context
    /// Reads timeline + geo + user_interests. Optionally writes a pin in the same request.
    func unifyIntentContext(
        timelineLimit: Int? = nil,
        pin: IntentPinRequest? = nil,
        completion: @escaping (Result<UserIntentContextResponse, Error>) -> Void
    ) {
        let requestPayload = UnifiedIntentRequest(timeline_limit: timelineLimit, pin: pin)
        
        print("🚀 [UserIntentContextService] POST /api/user/intent/context pin=\(pin == nil ? "no" : "yes")")
        
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
