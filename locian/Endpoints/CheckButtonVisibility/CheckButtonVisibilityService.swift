//
//  CheckButtonVisibilityService.swift
//  locian
//

import Foundation

class CheckButtonVisibilityService {
    static let shared = CheckButtonVisibilityService()
    private init() {}
    
    func checkButtonVisibility(completion: @escaping (Result<ButtonVisibilityResponse, Error>) -> Void) {
        let request = ButtonVisibilityRequest(visibility: "check")
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/ui/button-visibility",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
