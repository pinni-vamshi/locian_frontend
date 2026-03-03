//
//  BaseAPIManager.swift
//  locian
//
//  Created for shared API logic to eliminate duplication
//

import Foundation

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case networkError(String)
    case noData
}

// MARK: - Base API Manager Protocol
protocol BaseAPIManagerProtocol {
    var baseURL: String { get }
}

// MARK: - Base API Manager Implementation
class BaseAPIManager: BaseAPIManagerProtocol {
    static let shared = BaseAPIManager()
    private init() {}
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
        timeoutInterval: TimeInterval = 30.0,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        performRawRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            headers: headers,
            timeoutInterval: timeoutInterval
        ) { result in
            switch result {
            case .success(let data):
                do {

                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    print("✅ [API-PARSING-SUCCESS] \(endpoint)")
                    completion(.success(decoded))
                } catch let decodingError as DecodingError {
                    print("❌ [API-DECODING-FAILURE] \(endpoint):")
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   - Key not found: \(key.stringValue) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .typeMismatch(let type, let context):
                        print("   - Type mismatch: expected \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .valueNotFound(let type, let context):
                        print("   - Value not found: expected \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .dataCorrupted(let context):
                        print("   - Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    @unknown default:
                        print("   - Unknown decoding error")
                    }
                    ErrorHandler.log(decodingError, context: "Decoding response for \(endpoint)")
                    completion(.failure(decodingError))
                } catch {
                    print("❌ [API-UNKNOWN-ERROR] \(endpoint): \(error.localizedDescription)")
                    ErrorHandler.log(error, context: "Decoding response for \(endpoint)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Performs a standard API request and returns raw Data (Bypasses JSONDecoder)
    func performRawRequest(
        endpoint: String,
        method: String = "POST",
        body: Encodable? = nil,
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 60.0,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // FORCED DYNAMIC: Bypass any systemic URL caches for studied places
        if endpoint.contains("studied-places") || endpoint.contains("generate-sentence") {
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 🚀 CENTRALIZED AUTH: Inject session token into headers
        let token = AppStateManager.shared.authToken ?? ""
        if !token.isEmpty {
            if request.value(forHTTPHeaderField: "Authorization") == nil {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            if request.value(forHTTPHeaderField: "session_token") == nil {
                request.setValue(token, forHTTPHeaderField: "session_token")
            }
        }
        
        // Encode body if provided
        if let body = body {
            do {
                let encoder = JSONEncoder()
                let initialData = try encoder.encode(AnyEncodable(body))
                
                // 🚀 BODY INJECTION: Attempt to add session_token to JSON body automatically
                var finalData = initialData
                if !token.isEmpty {
                    if var jsonObject = try? JSONSerialization.jsonObject(with: initialData, options: .mutableContainers) as? [String: Any] {
                        // Only inject if missing or empty to avoid overwriting intentional overrides
                        if jsonObject["session_token"] == nil || (jsonObject["session_token"] as? String)?.isEmpty == true {
                            jsonObject["session_token"] = token
                            if let modifiedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
                                finalData = modifiedData
                            }
                        }
                    }
                }
                
                request.httpBody = finalData
                
                // 🚀 DEBUG TRACE: Log Request Details
                print("\n--------------------------------------------------")
                print("📤 [API-OUT] \(method) \(url.absoluteString)")
                print("   Headers: \(request.allHTTPHeaderFields ?? [:])")
                if let bodyString = String(data: finalData, encoding: .utf8) {
                    print("   Body: \(bodyString)")
                }
                print("--------------------------------------------------")
            } catch {
                print("❌ [API-ENCODING-ERROR] \(endpoint): \(error.localizedDescription)")
                ErrorHandler.log(error, context: "Encoding request body for \(endpoint)")
                completion(.failure(error))
                return
            }
        } else {
            print("\n📤 [API-REQUEST] \(method) \(endpoint) (No Body)")
        }
        
        // Perform request
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("\n🚨 [ROOT_API_CAPTURE] \(endpoint)")
            print("   - Data: \(data?.count ?? 0) bytes")
            print("   - Error: \(error?.localizedDescription ?? "None")")
            if let http = response as? HTTPURLResponse {
                print("   - HTTP Status: \(http.statusCode)")
            }
            
            DispatchQueue.main.async {
                // Handle network errors
                if let error = error {
                    print("❌ [API-NETWORK-ERROR] \(endpoint): \(error.localizedDescription)")
                    ErrorHandler.log(error, context: "Network request for \(endpoint)")
                    completion(.failure(error))
                    return
                }
                
                // Check HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ [API-RESPONSE-ERROR] \(endpoint): Invalid response type")
                    completion(.failure(APIError.networkError("Invalid response type")))
                    return
                }
                
                print("📥 [API-RESPONSE] \(endpoint) [Status: \(httpResponse.statusCode)]")
                
                // Handle special status codes
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    print("⚠️ [API-AUTH-ERROR] \(endpoint): Session expired (401/403)")
                    NotificationCenter.default.post(name: NSNotification.Name("SessionExpired"), object: nil)
                    completion(.failure(APIError.networkError("Session expired")))
                    return
                }
                
                guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                    print("❌ [API-HTTP-ERROR] \(endpoint): Status \(httpResponse.statusCode)")
                    completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                    return
                }
                
                guard let data = data else {
                    print("❌ [API-DATA-ERROR] \(endpoint): No data received")
                    completion(.failure(APIError.noData))
                    return
                }

                // Log Raw Response
                if let str = String(data: data, encoding: .utf8) {
                    print("📦 [API-RAW-PAYLOAD] \(endpoint):")
                    print(str)
                    print("--------------------------------------------------")
                }

                completion(.success(data))
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

