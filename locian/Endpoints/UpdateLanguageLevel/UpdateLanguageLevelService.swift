//
//  UpdateLanguageLevelService.swift
//  locian
//

import Foundation

class UpdateLanguageLevelService {
    static let shared = UpdateLanguageLevelService()
    private init() {}
    
    func updateLanguageLevel(sessionToken: String, targetLanguage: String, nativeLanguage: String, userLevel: String, completion: @escaping (Result<UpdateLanguageLevelResponse, Error>) -> Void) {
        let request = UpdateLanguageLevelRequest(
            session_token: sessionToken,
            target_language: targetLanguage,
            native_language: nativeLanguage,
            new_level: userLevel,
            new_native_language: nil
        )
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/user/language-pair/update-level",
            method: "POST",
            body: request,
            completion: completion
        )
    }
}
