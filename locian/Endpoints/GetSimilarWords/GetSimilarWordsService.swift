//
//  GetSimilarWordsService.swift
//  locian
//
//  Service layer - gathers data and makes API call
//

import Foundation

class GetSimilarWordsService {
    static let shared = GetSimilarWordsService()
    private init() {}
    
    /// Get similar words - only requires word, situation, and sentence
    /// Gathers language data from the lesson session context
    func getSimilarWords(
        word: String,
        targetLanguage: String,
        userLanguage: String,
        situation: String?,
        sentence: String?,
        sessionToken: String,
        completion: @escaping (Result<GetSimilarWordsResponse, Error>) -> Void
    ) {
        let request = GetSimilarWordsRequest(
            word: word,
            target_language: targetLanguage,
            user_language: userLanguage,
            situation: situation,
            sentence: sentence
        )
        
        let headers = ["Authorization": "Bearer \(sessionToken)"]
        
        BaseAPIManager.shared.performRequest(
            endpoint: "/api/vocabulary/similar-words",
            method: "POST",
            body: request,
            headers: headers,
            completion: completion
        )
    }
}
