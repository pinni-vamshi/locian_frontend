import Foundation

struct RecentFocusItem: Codable, Identifiable {
    let id: UUID
    let text: String
    let imageName: String?
    let imageData: Data?
    let timestamp: Date
}
