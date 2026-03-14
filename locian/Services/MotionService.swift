import Foundation
import CoreLocation

/// Service to handle retrieving the user's current motion state.
/// This utilizes GPS speed from LocationManager to avoid requiring Motion & Fitness permissions.
class MotionService {
    static let shared = MotionService()
    
    private init() {}
    
    /// Determines the current velocity of the user as a numeric string for the backend.
    /// Returns a string like "0 m/s", "5 m/s", etc.
    func fetchCurrentMotionState(completion: @escaping (String) -> Void) {
        // Use the instantaneous speed from LocationManager
        // Speed is already in m/s
        let speedMS = max(0, LocationManager.shared.currentLocation?.speed ?? 0.0)
        
        let velocityString = "\(Int(speedMS)) m/s"
        
        print("🚲 [MotionService] GPS Velocity: \(velocityString)")
        completion(velocityString)
    }
}
