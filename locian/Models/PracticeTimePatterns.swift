//
//  PracticeTimePatterns.swift
//  locian
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Practice Time Patterns Request
struct PracticeTimePatternsRequest: Codable {
    let session_token: String
}

// MARK: - Practice Time Patterns Response
struct PracticeTimePatternsResponse: Codable {
    let success: Bool
    let message: String?
    let data: PracticeTimePatternsData?
    let error: String?
    let error_code: String?
    let timestamp: String?
    let request_id: String?
}

// MARK: - Practice Time Patterns Data
struct PracticeTimePatternsData: Codable {
    let total_sessions: Int?
    let daily_patterns: [String: [String]]? // Day name -> [morning, afternoon, evening] times in "HH:MM AM/PM" format
    let message: String? // Optional message when no data
}
