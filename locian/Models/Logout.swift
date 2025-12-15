//
//  Logout.swift
//  locian
//
//  Created by vamshi krishna pinni on 28/10/25.
//

import Foundation

// MARK: - Logout Request
struct LogoutRequest: Codable {
    let session_token: String
}

// MARK: - Logout Response
struct LogoutResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
}

