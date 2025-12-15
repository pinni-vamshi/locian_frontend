//
//  Response.swift
//  locian
//
//  Created for generic API response wrapper
//

import Foundation

/// Generic API response wrapper
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

/// Helper extension for response handling
extension APIResponse {
    /// Returns true if response indicates success
    var isSuccess: Bool {
        return success && data != nil
    }
    
    /// Gets error message from response
    var errorMessage: String? {
        return error ?? message
    }
}

