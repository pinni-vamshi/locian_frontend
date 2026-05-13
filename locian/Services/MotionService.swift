import Foundation
import CoreLocation

/// GPS-only speed for Discover Moments (no Core Motion / no extra motion permission).
/// Sends speed as **kilometres per hour** in a string; backend `VelocityCleaner` converts to m/s.
final class MotionService {
    static let shared = MotionService()

    private init() {}

    /// `CLLocation.speed` is m/s (negative when invalid). We expose **km/h** for the API.
    func fetchGPSVelocityKmh(completion: @escaping (String) -> Void) {
        let speedMS = max(0, LocationManager.shared.currentLocation?.speed ?? 0)
        let kmh = speedMS * 3.6
        let velocityString = String(format: "%.2f km/h", kmh)
        print(
            "🚲 [MotionService] GPS speed: \(String(format: "%.2f", speedMS)) m/s → \(String(format: "%.2f", kmh)) km/h → sending \(velocityString)"
        )
        completion(velocityString)
    }
}
