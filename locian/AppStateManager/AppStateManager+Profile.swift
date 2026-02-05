//
//  AppStateManager+Profile.swift
//  locian
//
//  Created by GPT-5 Codex on 12/11/25.
//

import Foundation

extension AppStateManager {
    /// Updates the user's profession via the backend and refreshes cached user details.
    func updateProfession(to newProfession: String, completion: @escaping (Bool, String?) -> Void) {
        guard let token = authToken, !token.isEmpty else {
            completion(false, "No active session found.")
            return
        }
        
        let request = UserDetailsRequest(session_token: token, profession: newProfession)
        
        AuthAPIManager.shared.fetchUserDetails(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success, let data = response.data else {
                        let errorMessage = response.errorMessage ?? "Failed to update profession."
                        completion(false, errorMessage)
                        return
                    }
                    
                    // Update cached session token if backend returns a refreshed token
                    if self.authToken != data.session_token {
                        self.authToken = data.session_token
                    }
                    
                    // Update user data
                    self.username = data.username
                    self.profession = data.profession ?? newProfession
                    
                    let successMessage = response.message ?? "Profession updated successfully."
                    completion(true, successMessage)
                    
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    /// Fetches the latest user details without changing the profession.
    func refreshUserDetails(completion: @escaping (Bool, String?) -> Void) {
        guard let token = authToken, !token.isEmpty else {
            completion(false, "No active session found.")
            return
        }
        
        let request = UserDetailsRequest(session_token: token, profession: nil)
        
        AuthAPIManager.shared.fetchUserDetails(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.success, let data = response.data else {
                        let errorMessage = response.errorMessage ?? "Failed to fetch user details."
                        completion(false, errorMessage)
                        return
                    }
                    
                    if self.authToken != data.session_token {
                        self.authToken = data.session_token
                    }
                    
                    self.username = data.username
                    self.profession = data.profession ?? ""
                    
                    let successMessage = response.message ?? "User details refreshed."
                    completion(true, successMessage)
                    
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}

