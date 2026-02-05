//
//  LogoutService.swift
//  locian
//

import Foundation

class LogoutService {
    static let shared = LogoutService()
    private init() {}
    
    func logout(sessionToken: String, completion: @escaping (Result<LogoutResponse, Error>) -> Void) {
        let request = LogoutRequest(session_token: sessionToken)
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/user/logout",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
