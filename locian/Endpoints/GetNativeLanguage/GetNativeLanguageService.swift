//
//  GetNativeLanguageService.swift
//  locian
//

import Foundation

class GetNativeLanguageService {
    static let shared = GetNativeLanguageService()
    private init() {}
    
    func getNativeLanguage(sessionToken: String, nativeLanguage: String? = nil, completion: @escaping (Result<GetNativeLanguageResponse, Error>) -> Void) {
        let request = GetNativeLanguageRequest(session_token: sessionToken, native_language: nativeLanguage)
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/user/language-pair/get-native",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
