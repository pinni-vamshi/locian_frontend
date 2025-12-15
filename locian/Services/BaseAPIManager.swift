//
//  BaseAPIManager.swift
//  locian
//
//  Created for shared API logic to eliminate duplication
//

import Foundation

// MARK: - Base API Manager Protocol
protocol BaseAPIManagerProtocol {
    var baseURL: String { get }
}

extension BaseAPIManagerProtocol {
    var baseURL: String {
        return APIConfig.baseURL
    }
    
    /// Helper to encode any Encodable type to JSON Data
    func encodeEncodable(_ value: Encodable) throws -> Data {
        let encoder = JSONEncoder()
        // Use a wrapper approach to encode protocol-typed values
        return try encoder.encode(AnyEncodable(value))
    }
    
    /// Performs a standard API request with error handling and decoding
    func performRequest<T: Codable>(
        endpoint: String,
        method: String = "POST",
        body: Encodable? = nil,
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 8.0,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Encode body if provided
        if let body = body {
            do {
                // JSONEncoder requires a concrete type, not a protocol type
                // We use a helper function to encode any Encodable type
                request.httpBody = try encodeEncodable(body)
                
                // Request body encoding handled
                
            } catch {
                ErrorHandler.log(error, context: "Encoding request body for \(endpoint)")
                completion(.failure(error))
                return
            }
        }
        
        // Perform request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Handle network errors
                if let error = error {
                    ErrorHandler.log(error, context: "Network request for \(endpoint)")
                    completion(.failure(error))
                    return
                }
                
                // Check HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.networkError("Invalid response type")))
                    return
                }
                
                // Handle special status codes (401/403 for auth endpoints)
                // Note: AuthAPIManager needs special handling for 401/403, so we let it handle those
                // For other endpoints, we fail on any non-200 status
                
                // Check for success status code (200 OK or 201 Created)
                guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                    ErrorHandler.log(APIError.networkError("HTTP \(httpResponse.statusCode)"), context: endpoint)
                    completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                    return
                }
                
                // Check for data
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                // Log HTTP response details
                
                // Response data available
                
                // Decode response
                do {
                    // IMPORTANT: Store raw JSON for quiz endpoint to preserve question order
                    // Use file storage instead of UserDefaults for large JSON strings
                    if endpoint.contains("quiz") {
                        if let jsonString = String(data: data, encoding: .utf8) {
                            // Store raw JSON string in file system (not UserDefaults) for order preservation
                            // This allows AppStateManager to extract question IDs in exact JSON order
                            _ = FileStorageManager.shared.saveString(jsonString, forKey: "lastQuizResponseRawJSON")
                        }
                    }
                    
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    // Log raw response for debugging decoding errors (only for image analysis)
                    if endpoint.contains("image/analyze") {
                        // Error logging handled
                    }
                    ErrorHandler.log(error, context: "Decoding response for \(endpoint)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Type Erasure Helper for Encoding
/// Type-erased wrapper to encode any Encodable value
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    init<E: Encodable>(_ encodable: E) {
        _encode = { try encodable.encode(to: $0) }
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

