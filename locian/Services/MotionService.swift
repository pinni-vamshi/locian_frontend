import Foundation
import CoreLocation

/// Service to handle retrieving the user's current motion state.
/// This utilizes GPS speed from LocationManager to avoid requiring Motion & Fitness permissions.
class MotionService {
    static let shared = MotionService()
    
    private init() {}
    
    /// Determines the current velocity of the user as a numeric string for the backend.
    /// Returns a string like "0 km/h", "5 km/h", etc.
    func fetchCurrentMotionState(completion: @escaping (String) -> Void) {
        // Use the instantaneous speed from LocationManager
        // Speed is in m/s, convert to km/h
        let speedMS = LocationManager.shared.currentLocation?.speed ?? 0.0
        let speedKMH = max(0, speedMS * 3.6)
        
        let velocityString = "\(Int(speedKMH)) km/h"
        
        print("🚲 [MotionService] GPS Velocity: \(velocityString)")
        completion(velocityString)
    }
}
