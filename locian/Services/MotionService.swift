import Foundation
import CoreMotion

/// Service to handle retrieving the user's current motion state.
/// This utilizes the device's pedometer to determine whether the user is stationary or moving.
class MotionService {
    static let shared = MotionService()
    
    // Pedometer gives much better instantaneous data than ActivityManager
    private let pedometer = CMPedometer()
    
    private init() {}
    
    /// Determines the current motion activity of the user as a string matching the backend API requirements.
    /// Possible return values: "stationary", "walking", "running", or "unknown".
    func fetchCurrentMotionState(completion: @escaping (String) -> Void) {
        
        guard CMPedometer.isPedometerEventTrackingAvailable() else {
            completion("unknown")
            return
        }
        
        let toDate = Date()
        let fromDate = toDate.addingTimeInterval(-10) // Look at the last 10 seconds
        
        pedometer.queryPedometerData(from: fromDate, to: toDate) { data, error in
            guard error == nil, let pedometerData = data else {
                completion("unknown")
                return
            }
            
            // If they have taken more than 2 steps in the last 10 seconds, they are moving.
            let steps = pedometerData.numberOfSteps.intValue
            
            if steps > 15 {
                completion("running")
            } else if steps > 2 {
                completion("walking")
            } else {
                completion("stationary")
            }
        }
    }
}
