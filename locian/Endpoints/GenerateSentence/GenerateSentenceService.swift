//
//  GenerateSentenceService.swift
//  locian
//
//  Service layer - gathers data and makes API call
//

import Foundation

class GenerateSentenceService {
    static let shared = GenerateSentenceService()
    private init() {}
    
    /// Generate sentence - only requires minimal input (place name, moment)
    /// Gathers all other data (languages, profession) internally
    func generateSentence(
        placeName: String,
        microSituation: String,
        sessionToken: String,
        completion: @escaping (Result<GenerateSentenceResponse, Error>) -> Void
    ) {
        // Gather user profile data from AppState
        let appState = AppStateManager.shared
        let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default })
        let targetLanguage = defaultPair?.target_language ?? "es"
        let userLanguage = appState.nativeLanguage
        let profession = appState.profession
        
        let request = GenerateSentenceRequest(
            target_language: targetLanguage,
            place_name: placeName,
            user_language: userLanguage,
            micro_situation: microSituation,
            profession: profession,
            time: nil
        )
        
        let headers = ["Authorization": "Bearer \(sessionToken)"]
        
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/teaching/generate-sentence",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 300.0,
            completion: { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    GenerateSentenceLogic.shared.parseResponse(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
