//
//  PracticeAPIManager.swift
//  locian
//
//  Created for practice vocabulary event updates
//

import Foundation

class PracticeAPIManager {
    static let shared = PracticeAPIManager()
    private let baseURL = APIConfig.baseURL
    
    private init() {}
    
    // MARK: - Delete Practice Data for a Place
    func deletePracticeData(
        placeName: String,
        request: PracticeDeleteRequest,
        sessionToken: String,
        completion: @escaping (Result<PracticeDeleteResponse, Error>) -> Void
    ) {
        guard let encodedPlace = placeName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/api/practice/vocabulary/\(encodedPlace)/delete") else {
            completion(.failure(APIError.invalidURL)); return
        }
        var reqURL = URLRequest(url: url)
        reqURL.httpMethod = "POST"
        reqURL.setValue("application/json", forHTTPHeaderField: "Content-Type")
        reqURL.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        do { reqURL.httpBody = try JSONEncoder().encode(request) } catch { completion(.failure(error)); return }
        URLSession.shared.dataTask(with: reqURL) { data, response, err in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                    return
                }
                
                do {
                    let resp = try JSONDecoder().decode(PracticeDeleteResponse.self, from: data)
                    completion(.success(resp))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Update Category Clicked State
    func updateCategoryClicked(
        placeName: String,
        sessionId: String,
        category: String,
        clicked: Bool,
        sessionToken: String,
        completion: @escaping (Result<VocabularyEventBatchResponse, Error>) -> Void
    ) {
        let updates = VocabularyEventBatchUpdates(
            clicked: clicked,
            is_correct: nil,
            attempts: nil,
            time_taken_to_choose: nil,
            similar_words_clicked: nil,
            word_tenses_clicked: nil,
            breakdown_clicked: nil,
            rebuild: nil,
            breakdown: nil
        )

        let request = VocabularyEventBatchRequest(
            place_name: placeName,
            session_id: sessionId,
            events: [
                VocabularyEventBatchItem(
            category: category,
                    word: "",
                    updates: updates
            )
            ]
        )
        
        submitVocabularyEvents(request: request, sessionToken: sessionToken, completion: completion)
    }
    
    // MARK: - Update Word State
    func updateWordState(
        placeName: String,
        sessionId: String,
        category: String,
        word: String,
        clicked: Bool? = nil,
        isCorrect: Bool? = nil,
        attempts: Int? = nil,
        timeTakenToChoose: Double? = nil,
        sessionToken: String,
        completion: @escaping (Result<VocabularyEventBatchResponse, Error>) -> Void
    ) {
        let updates = VocabularyEventBatchUpdates(
            clicked: clicked,
            is_correct: isCorrect,
            attempts: attempts,
            time_taken_to_choose: timeTakenToChoose,
            similar_words_clicked: nil,
            word_tenses_clicked: nil,
            breakdown_clicked: nil,
            rebuild: nil,
            breakdown: nil
        )

        let request = VocabularyEventBatchRequest(
            place_name: placeName,
            session_id: sessionId,
            events: [
                VocabularyEventBatchItem(
            category: category,
            word: word,
                    updates: updates
            )
            ]
        )
        
        submitVocabularyEvents(request: request, sessionToken: sessionToken, completion: completion)
    }
    
    // MARK: - Private: Generic Update Method
    private func submitVocabularyEvents(
        request: VocabularyEventBatchRequest,
        sessionToken: String,
        completion: @escaping (Result<VocabularyEventBatchResponse, Error>) -> Void
    ) {
        VocabularyAPIManager.shared.submitVocabularyEvents(
            request: request,
            sessionToken: sessionToken,
            completion: { result in
                // Enhanced debug logging
                switch result {
                case .success(_):
                    ErrorHandler.debug("Practice Vocab Event - Success", context: "PracticeAPIManager")
                case .failure(let error):
                    ErrorHandler.log(error, context: "PracticeAPIManager.updateVocabularyEvent")
                }
                completion(result)
                }
        )
    }
    
    // MARK: - Get Clicked Words
    func getClickedWords(
        sessionToken: String,
        targetLanguage: String?,
        completion: @escaping (Result<ClickedWordsResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/practice/vocabulary/clicked-words") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        // Create request body with target_language
        let requestBody = ClickedWordsRequest(target_language: targetLanguage)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        
        // Encode request body
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            request.httpBody = try encoder.encode(requestBody)
            
            // Request prepared
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    // Response received
                    
                    if httpResponse.statusCode == 200 {
                        do {
                            let response = try JSONDecoder().decode(ClickedWordsResponse.self, from: data)
                            if response.data != nil {
                                // Handle both new nested format and old flat format
                                // Data processed
                            }
                            completion(.success(response))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        // Try to decode error response
                        do {
                            let errorResponse = try JSONDecoder().decode(ClickedWordsResponse.self, from: data)
                            completion(.failure(APIError.networkError(errorResponse.error ?? "HTTP \(httpResponse.statusCode)")))
                        } catch {
                            completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                        }
                    }
                } else {
                    completion(.failure(APIError.networkError("Invalid response")))
                }
            }
        }.resume()
    }
    
    // MARK: - Update Practice Dates
    func updatePracticeDates(
        targetLanguage: String,
        practiceDates: [String],
        sessionToken: String,
        completion: @escaping (Result<UpdatePracticeDatesResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/user/language-pair/update-practice-dates") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let requestBody = UpdatePracticeDatesRequest(
            target_language: targetLanguage,
            practice_dates: practiceDates
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            let response = try JSONDecoder().decode(UpdatePracticeDatesResponse.self, from: data)
                            completion(.success(response))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                            completion(.failure(APIError.networkError(errorResponse.error ?? "HTTP \(httpResponse.statusCode)")))
                        } else {
                            completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                        }
                    }
                } else {
                    completion(.failure(APIError.networkError("Invalid response")))
                }
            }
        }.resume()
    }
}

