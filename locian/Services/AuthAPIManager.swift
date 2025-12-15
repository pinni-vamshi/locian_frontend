//
//  AuthAPIManager.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import Foundation

class AuthAPIManager {
    static let shared = AuthAPIManager()
    private let baseURL = APIConfig.baseURL
    
    private init() {}
    
    // MARK: - Session Validation
    func checkSession(request: SessionCheckRequest, completion: @escaping (Result<SessionCheckResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/api/auth/session"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 60.0
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
            if let error = error {
                        completion(.failure(error))
                return
            }
            
            guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 200 {
                        completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                return
            }
            
                do {
                    let sessionResponse = try JSONDecoder().decode(SessionCheckResponse.self, from: data)
                    completion(.success(sessionResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
        return
    }
    
    // MARK: - User Details
    func fetchUserDetails(request: UserDetailsRequest, completion: @escaping (Result<UserDetailsResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/api/auth/user-details"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 60.0
        
        do {
            let body = try JSONEncoder().encode(request)
            urlRequest.httpBody = body
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 200 {
                    completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(UserDetailsResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Sign in with Apple
    func loginWithApple(request: AppleLoginRequest, completion: @escaping (Result<AppleLoginResponse, Error>) -> Void) {
        let endpoint = "\(self.baseURL)/api/auth/apple"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 60.0
        
        do {
            let encoded = try JSONEncoder().encode(request)
            urlRequest.httpBody = encoded
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.networkError("Invalid response")))
                    return
                }
                
                    if httpResponse.statusCode != 200 {
                            completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                        return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(AppleLoginResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Guest Login
    func guestLogin(request: GuestLoginRequest, completion: @escaping (Result<GuestLoginResponse, Error>) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/api/auth/guest-login") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
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
                            let guestResponse = try JSONDecoder().decode(GuestLoginResponse.self, from: data)
                            completion(.success(guestResponse))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        // Try to decode error response
                        do {
                            let errorResponse = try JSONDecoder().decode(GuestLoginResponse.self, from: data)
                            completion(.success(errorResponse)) // Return response even if error - let AppStateManager handle it
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
    
    // MARK: - Logout
    func logout(request: LogoutRequest, completion: @escaping (Result<LogoutResponse, Error>) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/api/user/logout") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
            if let error = error {
                    completion(.failure(error))
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
                    let logoutResponse = try JSONDecoder().decode(LogoutResponse.self, from: data)
                    completion(.success(logoutResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Button Visibility
    func checkButtonVisibility(completion: @escaping (Result<ButtonVisibilityResponse, Error>) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/api/ui/button-visibility") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let request = ButtonVisibilityRequest(visibility: "check")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
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
                            let visibilityResponse = try JSONDecoder().decode(ButtonVisibilityResponse.self, from: data)
                            completion(.success(visibilityResponse))
                        } catch {
                            completion(.failure(error))
                        }
                    } else if httpResponse.statusCode == 422 {
                        do {
                            let errorResponse = try JSONDecoder().decode(ButtonVisibilityErrorResponse.self, from: data)
                            completion(.failure(APIError.networkError(errorResponse.error)))
                        } catch {
                            completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                        }
                    } else {
                        completion(.failure(APIError.networkError("HTTP \(httpResponse.statusCode)")))
                    }
                } else {
                    completion(.failure(APIError.networkError("Invalid response")))
                }
            }
        }.resume()
    }
    
    // MARK: - Delete Account
    func deleteAccount(request: DeleteAccountRequest, completion: @escaping (Result<DeleteAccountResponse, Error>) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/api/user/delete") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
            if let error = error {
                    completion(.failure(error))
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
                    let deleteResponse = try JSONDecoder().decode(DeleteAccountResponse.self, from: data)
                    completion(.success(deleteResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Helpers
}

// MARK: - API Errors
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
