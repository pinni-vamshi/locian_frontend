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
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(GenerateSentenceResponse.self, from: data)
            
            DispatchQueue.main.async { completion(.success(response)) }
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }
}
