//
//  UpdateNativeLanguageService.swift
//  locian
//

import Foundation

class UpdateNativeLanguageService {
    static let shared = UpdateNativeLanguageService()
    private init() {}
    
    func updateNativeLanguage(sessionToken: String, nativeLanguage: String, completion: @escaping (Result<UpdateNativeLanguageResponse, Error>) -> Void) {
        let request = UpdateNativeLanguageRequest(
            session_token: sessionToken,
            new_native_language: nativeLanguage
        )
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/user/language-pair/update-native",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
