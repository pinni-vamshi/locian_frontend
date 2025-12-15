import Foundation

final class PracticeCategoryAPIManager: BaseAPIManagerProtocol {
    static let shared = PracticeCategoryAPIManager()
    
    private init() {}
    
    func updateCategory(
        request: PracticeCategoryEventUpdateRequest,
        sessionToken: String,
        completion: @escaping (Result<VocabularyEventUpdateResponse, Error>) -> Void
    ) {
        // Convert to VocabularyEventUpdateRequest format
        let vocabRequest = VocabularyEventUpdateRequest(
            place_name: request.place_name,
            session_id: request.session_id,
            session_token: request.session_token,
            category: request.category,
            word: nil,
            updates: request.updates
        )
        
        // Create a wrapper completion that adds logging
        let loggingCompletion: (Result<VocabularyEventUpdateResponse, Error>) -> Void = { result in
            // Enhanced debug logging
            switch result {
            case .success:
                ErrorHandler.debug("Category Event - Success", context: "PracticeCategoryAPIManager")
            case .failure(let error):
                ErrorHandler.log(error, context: "PracticeCategoryAPIManager.updateCategory")
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


