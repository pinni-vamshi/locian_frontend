import Foundation

class LanguageAPIManager: BaseAPIManagerProtocol {
    static let shared = LanguageAPIManager()
    
    private init() {}
    
    // Get native language
    func getNativeLanguage(request: GetNativeLanguageRequest, completion: @escaping (Result<GetNativeLanguageResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/get-native",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Get target languages
    func getTargetLanguages(request: GetTargetLanguagesRequest, completion: @escaping (Result<GetTargetLanguagesResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/get-targets",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Add language pair
    func addLanguagePair(request: AddLanguagePairRequest, completion: @escaping (Result<AddLanguagePairResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/add",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Set default language pair
    func setDefaultLanguagePair(request: SetDefaultLanguagePairRequest, completion: @escaping (Result<SetDefaultLanguagePairResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/set-default",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Delete language pair
    func deleteLanguagePair(request: DeleteLanguagePairRequest, completion: @escaping (Result<DeleteLanguagePairResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/delete",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Update native language (dedicated endpoint)
    func updateNativeLanguage(request: UpdateNativeLanguageRequest, completion: @escaping (Result<UpdateNativeLanguageResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/update-native",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Update language level or native language
    func updateLanguageLevel(request: UpdateLanguageLevelRequest, completion: @escaping (Result<UpdateLanguageLevelResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/language-pair/update-level",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Add studied place
    func addStudiedPlace(request: AddStudiedPlaceRequest, sessionToken: String, completion: @escaping (Result<AddStudiedPlaceResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/studied-places/add",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            completion: completion
        )
    }
    
    // Get studied places (GET endpoint - no request body)
    func getStudiedPlaces(sessionToken: String, completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/user/studied-places/get") else {
            completion(.failure(NSError(domain: "LanguageAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 8.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "LanguageAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            Self.decodeStudiedPlacesResponse(data: data, completion: completion)
        }.resume()
    }
    
    // Legacy method for backward compatibility
    func updateLanguagePairLevel(request: UpdateLanguagePairLevelRequest, completion: @escaping (Result<UpdateLanguagePairLevelResponse, Error>) -> Void) {
        let newRequest = UpdateLanguageLevelRequest(
            session_token: request.session_token,
            target_language: request.target_language,
            native_language: request.native_language,
            new_level: request.new_level,
            new_native_language: nil
        )
        updateLanguageLevel(request: newRequest) { result in
            switch result {
            case .success(let response):
                // Convert new response to old format
                if let levelData = response.data?.level {
                    let oldData = UpdateLanguagePairLevelData(
                        native_language: levelData.native_language,
                        target_language: levelData.target_language,
                        new_level: levelData.new_level
                    )
                    let oldResponse = UpdateLanguagePairLevelResponse(
                        success: response.success,
                        data: oldData,
                        message: response.message,
                        error: response.error,
                        error_code: response.error_code,
                        request_id: response.request_id,
                        timestamp: response.timestamp
                    )
                    completion(.success(oldResponse))
                } else {
                    let oldResponse = UpdateLanguagePairLevelResponse(
                        success: response.success,
                        data: nil,
                        message: response.message,
                        error: response.error,
                        error_code: response.error_code,
                        request_id: response.request_id,
                        timestamp: response.timestamp
                    )
                    completion(.success(oldResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helper function for decoding in nonisolated context
    nonisolated private static func decodeStudiedPlacesResponse(
        data: Data,
        completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void
    ) {
        // Decode in a background task to avoid main actor isolation
        Task.detached { @Sendable in
            do {
                // Use JSONSerialization to decode manually and avoid Codable main actor isolation
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw NSError(domain: "DecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
                }
                
                // Manually decode to avoid main actor isolation
                let success = jsonObject["success"] as? Bool ?? false
                let message = jsonObject["message"] as? String
                let error = jsonObject["error"] as? String
                let errorCode = jsonObject["error_code"] as? String
                let timestamp = jsonObject["timestamp"] as? String
                let requestId = jsonObject["request_id"] as? String
                
                var dataDict: GetStudiedPlacesData? = nil
                if let dataObj = jsonObject["data"] as? [String: Any] {
                    if let studiedPlacesArray = dataObj["studied_places"] as? [[String: Any]] {
                        let studiedPlaces = studiedPlacesArray.compactMap { placeDict -> StudiedPlaceData? in
                            guard let placeName = placeDict["place_name"] as? String,
                                  let createdAt = placeDict["created_at"] as? String,
                                  let time = placeDict["time"] as? String,
                                  let date = placeDict["date"] as? String else {
                                return nil
                            }
                            return StudiedPlaceData(
                                place_name: placeName,
                                place_detail: placeDict["place_detail"] as? String,
                                latitude: placeDict["latitude"] as? Double,
                                longitude: placeDict["longitude"] as? Double,
                                time: time,
                                date: date,
                                created_at: createdAt
                            )
                        }
                        dataDict = GetStudiedPlacesData(studied_places: studiedPlaces)
                    }
                }
                
                // Create response using struct initializer (nonisolated)
                let decodedResponse = GetStudiedPlacesResponse(
                    success: success,
                    data: dataDict,
                    message: message,
                    error: error,
                    error_code: errorCode,
                    timestamp: timestamp,
                    request_id: requestId
                )
                
                // Dispatch completion back to main actor
                await MainActor.run {
                    completion(.success(decodedResponse))
                }
            } catch {
                // Dispatch completion back to main actor
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
