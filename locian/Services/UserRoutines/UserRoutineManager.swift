import Foundation
import Combine

struct UserRoutineManager {
    /// Returns generic routine places for any profession
    /// All professions now use the same universal routine with generic places
    static func getPlaces(for profession: String, hour: Int) -> [String] {
        return UniversalRoutine.data[hour] ?? []
    }
}
