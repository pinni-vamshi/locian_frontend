//
//  CheckSessionService.swift
//  locian
//

import Foundation

class CheckSessionService {
    static let shared = CheckSessionService()
    private init() {}
    
    func checkSession(sessionToken: String, completion: @escaping (Result<SessionCheckResponse, Error>) -> Void) {
        let request = SessionCheckRequest(session_token: sessionToken)
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/auth/session",
            method: "POST",
            body: request,
            timeoutInterval: 60.0,
            completion: completion
        )
    }
}
