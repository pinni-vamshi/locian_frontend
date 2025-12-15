//
//  ImageAnalysis.swift
//  locian
//
//  Created by vamshi krishna pinni on 24/10/25.
//

import Foundation

// MARK: - Image Analysis Request
struct ImageAnalysisRequest: Codable {
    let session_token: String
    let image_base64: String
    let user_language: String?
    let target_language: String?
}

// MARK: - Image Analysis Response
struct ImageAnalysisResponse: Codable {
    let success: Bool
    let message: String?
    let data: ImageAnalysisData?
    let error: String?
    let timestamp: String?
}

// MARK: - Image Analysis Data
struct ImageAnalysisData: Codable {
    let place_name: String
}
