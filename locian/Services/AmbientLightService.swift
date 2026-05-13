import Foundation
import UIKit

/// Screen brightness only (no ambient light sensor — avoids extra permissions).
/// Backend expects `light_level` in **0.0…1.0** (see `cleaning.py` clamp).
final class AmbientLightService {
    static let shared = AmbientLightService()

    private init() {}

    func fetchLightLevel() -> Double {
        Double(UIScreen.main.brightness)
    }
}
