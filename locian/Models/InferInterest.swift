//
//  InferInterest.swift
//  locian
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Infer Interest Request
struct InferInterestRequest: Codable {
    let session_token: String // Required
    let time: String? // Optional: "07:45 PM"
    let user_language: String? // Optional: "hi", "en", "es"
    let target_language: String? // Optional: "ja", "zh", "fr"
}

// MARK: - Infer Interest Response
struct InferInterestResponse: Codable {
    let success: Bool?
    let message: String?
    let data: InferInterestData?
    let error: String?
    let error_code: String?
}

// MARK: - Infer Interest Data
struct InferInterestData: Codable {
    let category: String // Category name in user's native language (e.g., "कैफे" for Hindi, "café" for Spanish)
    let context: InferInterestContext?
}

// MARK: - Infer Interest Context
struct InferInterestContext: Codable {
    let time: String?
    let recent_sessions_count: Int?
    let unique_places_in_recent: Int?
    let total_sessions: Int?
}

