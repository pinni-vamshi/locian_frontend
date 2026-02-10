//
//  AnalyzeImageModels.swift
//  locian
//
//  Models for Analyze Image Endpoint
//  Pure data structures - no parsing logic
//

import Foundation

// MARK: - Request Model

struct AnalyzeImageRequest: Codable {
    let image_base64: String
    let time: String?
    let level: String?
    let latitude: Double?
    let longitude: Double?
    let user_language: String?
    let target_language: String?
    let previous_places: [TimelinePlaceContext]?
    let future_places: [TimelinePlaceContext]?
    let date: String?
}



// MARK: - Response Models

struct AnalyzeImageResponse: Codable {
    let success: Bool
    let message: String?
    let data: AnalyzeImageData?
    let error: String?
}

struct AnalyzeImageData: Codable {
    let place_name: String
    let document_id: String?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    let time_span: String?      // Hierarchy Bucket
    let type: String?
    let created_at: String?
    let micro_situations: [UnifiedMomentSection]
    let moments_count: Int
}

// MARK: - Handover Extension
extension AnalyzeImageData {
    /// Converts analyzed image data into the common MicroSituationData format for UI consumption.
    func toMicroSituationData() -> MicroSituationData {
        return MicroSituationData(
            place_name: self.place_name,
            latitude: self.latitude,
            longitude: self.longitude,
            time: self.time,
            hour: self.hour,
            created_at: self.created_at,
            context_description: nil,
            micro_situations: self.micro_situations,
            priority_score: 1.5, // High priority for analyzed images
            distance_meters: nil,
            time_span: self.time_span,
            type: self.type ?? "image_analysis",
            profession: nil,
            updated_at: nil,
            target_language: nil,
            document_id: self.document_id
        )
    }
}
