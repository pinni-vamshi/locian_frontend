import Foundation

final class PracticeWordAPIManager: BaseAPIManagerProtocol {
    static let shared = PracticeWordAPIManager()
    
    private init() {}
    
    func updateWord(
        request: PracticeWordEventUpdateRequest,
        sessionToken: String,
        completion: @escaping (Result<VocabularyEventUpdateResponse, Error>) -> Void
    ) {
        // Convert to VocabularyEventUpdateRequest format
        let vocabRequest = VocabularyEventUpdateRequest(
            place_name: request.place_name,
            session_id: request.session_id,
            session_token: request.session_token,
            category: request.category,
            word: request.word,
            updates: request.updates
        )
        
        // Create a wrapper completion that adds logging
        let loggingCompletion: (Result<VocabularyEventUpdateResponse, Error>) -> Void = { result in
            // Enhanced debug logging
            switch result {
            case .success:
                ErrorHandler.debug("Word Event - Success", context: "PracticeWordAPIManager")
            case .failure(let error):
                ErrorHandler.log(error, context: "PracticeWordAPIManager.updateWord")
            }
            completion(result)
                }
        
        performRequest(
            endpoint: "/api/practice/vocabulary/event",
            method: "POST",
            body: vocabRequest,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            completion: loggingCompletion
        )
    }
}


