import Foundation

final class QuizAPIManager: BaseAPIManagerProtocol {
    static let shared = QuizAPIManager()
    
    private init() {}

    func generateQuiz(request: QuizGenerateRequest, sessionToken: String, completion: @escaping (Result<QuizGenerateResponse, Error>) -> Void) {
        // Create a wrapper completion that adds logging
        let loggingCompletion: (Result<QuizGenerateResponse, Error>) -> Void = { result in
            // Enhanced logging for quiz responses
            switch result {
            case .success(let response):
                let questionCount = response.data?.questions.count ?? 0
                let successValue = response.success ?? false
                ErrorHandler.debug("Quiz API Response - Success: \(successValue), Questions: \(questionCount)", context: "QuizAPIManager")
            case .failure(let error):
                ErrorHandler.log(error, context: "QuizAPIManager.generateQuiz")
            }
            completion(result)
        }

        performRequest(
            endpoint: "/api/practice/quiz",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            timeoutInterval: 60.0, // Increased timeout for slow quiz generation
            completion: { (result: Result<QuizGenerateResponse, Error>) in
                // Error handling in completion
                loggingCompletion(result)
            }
        )
    }

    func submitQuizUpdates(request: QuizUpdateBatchRequest, sessionToken: String, completion: @escaping (Result<QuizUpdateBatchResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/practice/quiz/update",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            completion: completion
        )
    }
}



