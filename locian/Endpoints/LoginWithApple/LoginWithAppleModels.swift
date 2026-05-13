//
//  AppleAuth.swift
//
//  Created for Apple authentication models
//

import Foundation
import Combine

// MARK: - Apple Full Name Payload
struct AppleFullNamePayload: Codable {
    let firstName: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

// MARK: - Apple Login Request
struct AppleLoginRequest: Codable {
    let code: String
    let id_token: String?
    let nonce: String?
    let username: String?
    let selected_places: [String]?
    let native_language: String?
    let target_languages: [String]?
    let email: String?
    let full_name: AppleFullNamePayload?
    let first_name: String?
    let last_name: String?
}

// MARK: - Apple Login Data
struct AppleLoginData: Codable {
    let user_id: String
    let session_token: String
    let username: String?
    let email: String?
    let is_new_user: Bool?
    let native_language: String?
    let target_languages: [String]?
}

// MARK: - Apple Login Response
struct AppleLoginResponse: Codable {
    let success: Bool
    let message: String?
    let data: AppleLoginData?
    let error: String?
    let status_code: Int?
    let request_id: String?
    let timestamp: String?
}

