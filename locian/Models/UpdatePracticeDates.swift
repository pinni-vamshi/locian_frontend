import Foundation

struct UpdatePracticeDatesRequest: Codable {
    let target_language: String
    let practice_dates: [String]
    let session_token: String? // Assuming session token might be needed in body or header
}

struct UpdatePracticeDatesResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
    let error_code: String?
    let timestamp: String?
    let request_id: String?
}
