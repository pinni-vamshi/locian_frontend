import Foundation

class WordTensesAPIManager: BaseAPIManagerProtocol {
    static let shared = WordTensesAPIManager()
    
    private init() {}
    
    // MARK: - Word Tenses
    func getWordTenses(request: WordTensesRequest, completion: @escaping (Result<WordTensesResponse, Error>) -> Void) {
        print("⏰ [WORD TENSES API] Starting word tenses request")
        print("⏰ [WORD TENSES API] Endpoint: /api/conversation/word-tenses")
        print("⏰ [WORD TENSES API] Timeout: 60.0 seconds")
        print("⏰ [WORD TENSES API] Word: \(request.word)")
        print("⏰ [WORD TENSES API] User language: \(request.user_language)")
        print("⏰ [WORD TENSES API] Target language: \(request.target_language)")
        
        // Create a wrapper completion that adds logging
        let loggingCompletion: (Result<WordTensesResponse, Error>) -> Void = { result in
            switch result {
            case .success(let response):
                print("✅ [WORD TENSES API] Word tenses request succeeded")
                print("✅ [WORD TENSES API] Success: \(response.success)")
                print("✅ [WORD TENSES API] Message: \(response.message ?? "nil")")
                if let tenses = response.data?.tenses {
                    print("✅ [WORD TENSES API] Number of tenses: \(tenses.count)")
                    for (tenseName, _) in tenses {
                        print("✅ [WORD TENSES API] Tense: \(tenseName)")
                    }
                } else {
                    print("⚠️ [WORD TENSES API] Tenses data is nil")
                }
            case .failure(let error):
                print("❌ [WORD TENSES API] Word tenses request failed")
                print("❌ [WORD TENSES API] Error: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("❌ [WORD TENSES API] Error code: \(nsError.code)")
                    print("❌ [WORD TENSES API] Error domain: \(nsError.domain)")
                }
            }
            completion(result)
        }
        
        performRequest(
            endpoint: "/api/conversation/word-tenses",
            method: "POST",
            body: request,
            timeoutInterval: 60.0, // Increased timeout to 60 seconds
            completion: loggingCompletion
        )
    }
}

