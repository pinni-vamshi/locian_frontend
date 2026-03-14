import Foundation
import UIKit

class AmbientLightService {
    static let shared = AmbientLightService()
    
    private init() {}
    
    /// On-Demand: Reads current screen brightness and maps it to the AI expected range.
    /// No background listener. Returns immediately.
    func fetchLightLevel() -> Double {
        let screenLevel = UIScreen.main.brightness
        // ⚖️ MAPPING: Input 0.0–1.0 (Screen) -> Output -5.0–14.0 (AI Expected Range)
        return -5.0 + (Double(screenLevel) * 19.0)
    }
}

