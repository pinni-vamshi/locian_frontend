import Foundation
import CoreLocation

class LanguageAPIManager: BaseAPIManagerProtocol {
    static let shared = LanguageAPIManager()
    
    private init() {}
    
    // Get native language
    func getNativeLanguage(request: GetNativeLanguageRequest, completion: @escaping (Result<GetNativeLanguageResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/get-native",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Get target languages
    func getTargetLanguages(request: GetTargetLanguagesRequest, completion: @escaping (Result<GetTargetLanguagesResponse, Error>) -> Void) {
        // Encapsulate request construction if needed, but here we perform request directly
        // Ensure action is set to GET if not present (handled by caller or server default)
        performRequest(
            endpoint: "/api/user/language-pair/get-targets",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Add language pair (Unified Endpoint)
    func addLanguagePair(request: GetTargetLanguagesRequest, completion: @escaping (Result<GetTargetLanguagesResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/get-targets",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Set default language pair (Unified Endpoint)
    func setDefaultLanguagePair(request: GetTargetLanguagesRequest, completion: @escaping (Result<GetTargetLanguagesResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/get-targets",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Delete language pair (Unified Endpoint)
    func deleteLanguagePair(request: GetTargetLanguagesRequest, completion: @escaping (Result<GetTargetLanguagesResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/get-targets",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Update native language (dedicated endpoint)
    func updateNativeLanguage(request: UpdateNativeLanguageRequest, completion: @escaping (Result<UpdateNativeLanguageResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/update-native",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Update language level or native language
    func updateLanguageLevel(request: UpdateLanguageLevelRequest, completion: @escaping (Result<UpdateLanguageLevelResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/update-level",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Update practice dates (streak)
    func updatePracticeDates(request: UpdatePracticeDatesRequest, completion: @escaping (Result<UpdatePracticeDatesResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/update-practice-dates",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    

    
    // MARK: - Infer Interest
    

    
    // Get Similar Words
    func getSimilarWords(request: GetSimilarWordsRequest, sessionToken: String, completion: @escaping (Result<GetSimilarWordsResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/vocabulary/similar-words",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            completion: completion
        )
    }

    // MARK: - Moment Generation (New Spec)
    func generateMoments(request: GenerateMomentsRequest, sessionToken: String, completion: @escaping (Result<GenerateMomentsResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/conversation/generate-moments",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            timeoutInterval: 300.0,
            completion: completion
        )
    }
}
