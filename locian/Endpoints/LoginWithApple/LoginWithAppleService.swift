//
//  LoginWithAppleService.swift
//  locian
//

import Foundation

class LoginWithAppleService {
    static let shared = LoginWithAppleService()
    private init() {}
    
    func loginWithApple(request: AppleLoginRequest, completion: @escaping (Result<AppleLoginResponse, Error>) -> Void) {
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/auth/apple",
            method: "POST",
            body: request,
            timeoutInterval: 60.0,
            completion: completion
        )
    }
}
