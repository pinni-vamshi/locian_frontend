//
//  AppleAuth.swift
//
//  Created for Apple authentication models
//

import Foundation

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
    let profession: String?
    let email: String?
    let phone_number: String?
    let full_name: AppleFullNamePayload?
    let first_name: String?
    let last_name: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case id_token
        case nonce
        case username
        case profession
        case email
        case phone_number
        case full_name
        case first_name
        case last_name
    }
}

// MARK: - Apple Login Data
struct AppleLoginData: Codable {
    let user_id: String
    let session_token: String
    let username: String?
    let profession: String?
    let phone_number: String?
    let email: String?
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

