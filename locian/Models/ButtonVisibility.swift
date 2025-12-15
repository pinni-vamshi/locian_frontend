//
//  ButtonVisibility.swift
//  locian
//
//  Created for button visibility API endpoint
//

import Foundation

// MARK: - Button Visibility Request
struct ButtonVisibilityRequest: Codable {
    let visibility: String // "check", "on", or "off"
}

// MARK: - Button Visibility Response
// Response format: {"visibility": "on"} or {"visibility": "off"}
struct ButtonVisibilityResponse: Codable {
    let visibility: String // "on" or "off"
}

// MARK: - Button Visibility Error Response
struct ButtonVisibilityErrorResponse: Codable {
    let error: String
}

