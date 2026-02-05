//
//  UserDetails.swift
//  locian
//
//  Created by GPT-5 Codex on 12/11/25.
//

import Foundation

// MARK: - User Details Request
struct UserDetailsRequest: Codable {
    let session_token: String
    let profession: String?
    
    init(session_token: String, profession: String? = nil) {
        self.session_token = session_token
        self.profession = profession
    }
}

// MARK: - User Details Data
struct UserDetailsData: Codable {
    let user_id: String
    let username: String
    let profession: String?
    let session_token: String
}

// MARK: - User Details Response
typealias UserDetailsResponse = APIResponse<UserDetailsData>

