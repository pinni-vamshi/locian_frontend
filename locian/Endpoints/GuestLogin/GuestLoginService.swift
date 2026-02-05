//
//  GuestLoginService.swift
//  locian
//

import Foundation

class GuestLoginService {
    static let shared = GuestLoginService()
    private init() {}
    
    func guestLogin(request: GuestLoginRequest, completion: @escaping (Result<GuestLoginResponse, Error>) -> Void) {
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/auth/guest-login",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
