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
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        
        let targetLanguage = activePair?.target_language ?? LocalizationManager.shared.currentLanguage.rawValue
        let userLanguage = activePair?.native_language ?? (!appState.nativeLanguage.isEmpty ? appState.nativeLanguage : appState.appLanguage)
        let profession = appState.profession
        
        // Gather current time
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: currentDate)
        
        let request = GenerateSentenceRequest(
            target_language: targetLanguage,
            place_name: placeName,
            user_language: userLanguage,
            micro_situation: microSituation,
            profession: profession,
            time: timeString
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
