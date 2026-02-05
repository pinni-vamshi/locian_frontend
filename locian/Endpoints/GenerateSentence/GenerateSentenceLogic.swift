//
//  GenerateSentenceLogic.swift
//  locian
//
//  Logic layer for Generate Sentence Endpoint
//  Parses raw response data
//

import Foundation

class GenerateSentenceLogic {
    static let shared = GenerateSentenceLogic()
    
    private init() {}
    
    // MARK: - Response Parsing
    
    /// Parse raw JSON data into structured response
    nonisolated func parseResponse(
        data: Data,
        completion: @escaping (Result<GenerateSentenceResponse, Error>) -> Void
    ) {
        Task.detached { @Sendable in
            do {
                // For GenerateSentence, the response follows standard JSON structure
                // so we can use JSONDecoder directly
                let decoder = JSONDecoder()
                let response = try decoder.decode(GenerateSentenceResponse.self, from: data)
                
                await MainActor.run { completion(.success(response)) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }
}
