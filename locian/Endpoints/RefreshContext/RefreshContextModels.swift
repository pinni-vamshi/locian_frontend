//
//  RefreshContextModels.swift
//  locian
//
//  Created for Context Refresh Endpoint
//

import Foundation

// MARK: - Request
// No body required for refresh
struct RefreshContextRequest: Codable {}

// MARK: - Response
struct RefreshContextResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
    let data: RefreshContextData?
}

// MARK: - Response Data
struct RefreshContextData: Codable {
    let message: String?
    let time_slice: String?
}
