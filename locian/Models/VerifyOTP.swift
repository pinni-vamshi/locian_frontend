//
//  VerifyOTP.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import Foundation

// MARK: - Verify OTP Request
struct VerifyOTPRequest: Codable {
    let phone_number: String
    let verification_code: String
    let username: String
    let otp_id: String
    let profession: String?  // Optional - NEW
    
    // Custom encoding to omit profession if nil (instead of sending null)
    enum CodingKeys: String, CodingKey {
        case phone_number
        case verification_code
        case username
        case otp_id
        case profession
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(phone_number, forKey: .phone_number)
        try container.encode(verification_code, forKey: .verification_code)
        try container.encode(username, forKey: .username)
        try container.encode(otp_id, forKey: .otp_id)
        // Only encode profession if it has a value (omit if nil)
        try container.encodeIfPresent(profession, forKey: .profession)
    }
}

// MARK: - Verify OTP Response
struct VerifyOTPResponse: Codable {
    let success: Bool
    let message: String
    let data: VerifyOTPData?
    let error: String?
    let error_code: String?
    let request_id: String
    let timestamp: String?
}

// MARK: - Verify OTP Data
struct VerifyOTPData: Codable {
    let action: String  // "registration" or "login"
    let user_id: String
    let session_token: String
    let phone_number: String
    let username: String
    let profession: String?  // Optional - NEW
}
