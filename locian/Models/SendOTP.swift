//
//  SendOTP.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import Foundation

// MARK: - Send OTP Request
struct SendOTPRequest: Codable {
    let phone_number: String
}

// MARK: - Send OTP Response
struct SendOTPResponse: Codable {
    let success: Bool
    let message: String
    let data: OTPData?
    let error: String?
    let error_code: String?
    let request_id: String
    let timestamp: String?
}

// MARK: - OTP Data
struct OTPData: Codable {
    let otp_id: String
    let phone_number: String
    let expires_in_minutes: Int
    let provider: String
}
