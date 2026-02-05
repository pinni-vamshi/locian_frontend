//
//  GuestLogin.swift
//  locian
//
//  Created for guest login functionality
//

import Foundation

// MARK: - Guest Login Request
struct GuestLoginRequest: Codable {
    let username: String?
    let phone_number: String?
    let profession: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case phone_number
        case profession
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(phone_number, forKey: .phone_number)
        try container.encodeIfPresent(profession, forKey: .profession)
    }
}

// MARK: - Guest Login Response
struct GuestLoginResponse: Codable {
    let success: Bool
    let message: String
    let data: GuestLoginData?
    let error: String?
    let status_code: Int?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Guest Login Data
struct GuestLoginData: Codable {
    let action: String
    let user_id: String
    let session_token: String
    let username: String
    let profession: String?
    let is_guest: Bool
}

