import Foundation

class WordDecompositionAPIManager: BaseAPIManagerProtocol {
    static let shared = WordDecompositionAPIManager()
    
    private init() {}
    
    // MARK: - Word Decomposition
    func getWordDecomposition(request: WordDecompositionRequest, completion: @escaping (Result<WordDecompositionResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/conversation/word-decomposition",
            method: "POST",
            body: request,
            timeoutInterval: 60.0, // Increased timeout to 60 seconds
            completion: completion
        )
    }
}

