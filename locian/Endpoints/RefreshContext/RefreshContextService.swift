//
//  RefreshContextService.swift
//  locian
//
//  Service to handle user context refresh.
//

import Foundation

class RefreshContextService {
    
    /// Triggers a background refresh of the user's personalization context.
    /// POST /api/user/context/refresh
    static func refreshContext(completion: @escaping (Result<RefreshContextResponse, Error>) -> Void) {
        let endpoint = "/api/user/context/refresh"
        
        print("🔄 [RefreshContextService] Requesting Context Refresh...")
        
        if let token = AppStateManager.shared.authToken {
            let headers = ["Authorization": "Bearer \(token)"]
            
            BaseAPIManager.shared.performRequest(endpoint: endpoint, method: "POST", body: nil, headers: headers) { (result: Result<RefreshContextResponse, Error>) in
                switch result {
                case .success(let response):
                    // Decoding is already done by performRequest<T>
                    completion(.success(response))
                case .failure(let error):
                    print("❌ [RefreshContextService] Request Failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } else {
            print("⚠️ [RefreshContextService] No Auth Token Available")
            completion(.failure(APIError.networkError("No Auth Token")))
        }
    }
}
