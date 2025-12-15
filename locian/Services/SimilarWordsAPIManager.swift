import Foundation

class SimilarWordsAPIManager: BaseAPIManagerProtocol {
    static let shared = SimilarWordsAPIManager()
    
    private init() {}
    
    // MARK: - Similar Words
    func getSimilarWords(request: SimilarWordsRequest, completion: @escaping (Result<SimilarWordsResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/conversation/similar-words",
            method: "POST",
            body: request,
            timeoutInterval: 60.0, // Increased timeout to 60 seconds
            completion: completion
        )
    }
}

