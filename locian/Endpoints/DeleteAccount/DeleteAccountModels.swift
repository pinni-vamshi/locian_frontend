//
//  DeleteAccount.swift
//  locian
//
//  Created by vamshi krishna pinni on 28/10/25.
//

import Foundation

// MARK: - Delete Account Request
struct DeleteAccountRequest: Codable {
    let session_token: String
    let confirm_deletion: Bool
}

// MARK: - Delete Account Response
struct DeleteAccountResponse: Codable {
    let success: Bool
    let message: String?
    let data: DeleteAccountData?
    let error: String?
}

// MARK: - Delete Account Data
struct DeleteAccountData: Codable {
    let deleted_user_id: String
    let deleted_sessions: Int
    let deleted_scores: Int
}

