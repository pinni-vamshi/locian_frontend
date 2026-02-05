//
//  GetTargetLanguagesService.swift
//  locian
//

import Foundation

class GetTargetLanguagesService {
    static let shared = GetTargetLanguagesService()
    private init() {}
    
    func getTargetLanguages(
        sessionToken: String,
        action: String? = "GET",
        targetLanguage: String? = nil,
        nativeLanguage: String? = nil,
        completion: @escaping (Result<GetTargetLanguagesResponse, Error>) -> Void
    ) {
        let request = GetTargetLanguagesRequest(
            session_token: sessionToken,
            action: action,
            target_language: targetLanguage,
            native_language: nativeLanguage
        )
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/user/language-pair/get-targets",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
