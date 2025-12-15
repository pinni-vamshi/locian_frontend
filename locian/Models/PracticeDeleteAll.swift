import Foundation

// Flexible delete request: provide exactly one of the three
struct PracticeDeleteRequest: Codable {
    let delete_all: Bool?
    let clear_main: Bool?
    let session_id: String?
}

struct PracticeDeleteResponse: Codable {
    let status: String
    let message: String?
    let data: [String: String]?
}

