//
//  SessionCheck.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import Foundation

// MARK: - Session Check Request
struct SessionCheckRequest: Codable {
    let session_token: String
}

// MARK: - Session Check Response (Handles both success and error)
struct SessionCheckResponse: Codable {
    let success: Bool
    let message: String?
    let data: SessionData?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Session Data
struct SessionData: Codable {
    let user_id: String
    let valid: Bool
}
