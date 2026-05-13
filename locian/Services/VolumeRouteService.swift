import Foundation
import AVFoundation

/// Playback volume + output route — **no microphone**. Uses `AVAudioSession` only.
@MainActor
final class VolumeRouteService {
    static let shared = VolumeRouteService()

    private init() {}

    struct Snapshot {
        /// System **output** (media) volume, `0.0 ... 1.0`.
        let outputVolume: Double
        /// `true` if audio is routed to headphones / earbuds / Bluetooth audio (not built-in speaker).
        let headphonesConnected: Bool
    }

    /// Current output volume and whether headphones-like route is active.
    func snapshot() -> Snapshot {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ [VolumeRouteService] AVAudioSession: \(error.localizedDescription)")
        }

        let vol = Double(session.outputVolume)
        let hp = Self.routeIsHeadphones(session.currentRoute)
        print(
            "🔊 [VolumeRouteService] outputVolume=\(String(format: "%.2f", vol)) headphones=\(hp)"
        )
        return Snapshot(outputVolume: vol, headphonesConnected: hp)
    }

    private static func routeIsHeadphones(_ route: AVAudioSessionRouteDescription) -> Bool {
        for output in route.outputs {
            switch output.portType {
            case .headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
                return true
            default:
                continue
            }
        }
        return false
    }
}
