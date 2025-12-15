//
//  ErrorHandler.swift
//  locian
//
//  Created for centralized error handling and logging
//

import Foundation

/// Centralized error handling and logging
struct ErrorHandler {
    enum LogLevel {
        case info
        case warning
        case error
        case debug
    }
    
    /// Log an error with context
    static func log(_ error: Error, context: String = "", level: LogLevel = .error) {
        // Logging removed
    }
    
    /// Get user-friendly error message
    static func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection. Please check your network."
            case .networkConnectionLost:
                return "Network connection lost. Please try again."
            case .timedOut:
                return "Request timed out. Please try again."
            case .cannotConnectToHost:
                return "Cannot connect to server. Please try again later."
            default:
                return urlError.localizedDescription
            }
        } else if let apiError = error as? APIError {
            return apiError.localizedDescription
        } else {
            return "Something went wrong. Please try again."
        }
    }
    
    /// Log info message
    static func info(_ message: String, context: String = "") {
        // Logging removed
    }
    
    /// Log warning message
    static func warning(_ message: String, context: String = "") {
        // Logging removed
    }
    
    /// Log debug message
    static func debug(_ message: String, context: String = "") {
        // Logging removed
    }
}

