import Foundation

class VocabularyAPIManager: BaseAPIManagerProtocol {
    static let shared = VocabularyAPIManager()
    
    private init() {}
    
    // MARK: - Vocabulary Generation
    func generateVocabulary(request: VocabularyRequest, sessionToken: String, completion: @escaping (Result<VocabularyResponse, Error>) -> Void) {
        // Request encoding handled by performRequest
        
        
        // Use helper method for type inference
        // Increased timeout to 300 seconds since vocabulary generation can be slow
        performRequestHelper(
            endpoint: "/api/conversation/generate-environment-vocabulary",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            timeoutInterval: 300.0, // Increased timeout to 300 seconds for slow vocabulary generation
            completion: completion
        )
    }
    
    // Helper method to work around Swift's generic type inference limitations in protocol extensions
    private func performRequestHelper<T: Codable>(
        endpoint: String,
        method: String = "POST",
        body: Encodable? = nil,
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 8.0,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        performRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            headers: headers,
            timeoutInterval: timeoutInterval,
            completion: completion
        )
    }
    
    // MARK: - Update Vocabulary Event (tracking fields)
    func submitVocabularyEvents(request: VocabularyEventBatchRequest, sessionToken: String, completion: @escaping (Result<VocabularyEventBatchResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/practice/vocabulary/event",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            completion: completion
        )
    }
    
    // MARK: - Bulk Update Vocabulary
    func updateVocabularyBulk(request: VocabularyBulkUpdateRequest, sessionToken: String, completion: @escaping (Result<VocabularyBulkUpdateResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/practice/vocabulary/update-bulk",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            timeoutInterval: 60.0,
            completion: completion
        )
    }
}
