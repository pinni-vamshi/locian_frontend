//
//  GetUserDetailsService.swift
//  locian
//

import Foundation

class GetUserDetailsService {
    static let shared = GetUserDetailsService()
    private init() {}
    
    func getUserDetails(sessionToken: String, profession: String? = nil, completion: @escaping (Result<UserDetailsResponse, Error>) -> Void) {
        let request = UserDetailsRequest(session_token: sessionToken, profession: profession)
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/auth/user-details",
            method: "POST",
            body: request,
            timeoutInterval: 60.0,
            completion: completion
        )
    }
}
