
import Foundation

class TeachingAPIManager: BaseAPIManagerProtocol {
    static let shared = TeachingAPIManager()
    
    private init() {}
    
    func generateSentence(request: GenerateSentenceRequest, sessionToken: String, completion: @escaping (Result<GenerateSentenceResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/teaching/generate-sentence",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            timeoutInterval: 300.0,
            completion: completion
        )
    }
}
