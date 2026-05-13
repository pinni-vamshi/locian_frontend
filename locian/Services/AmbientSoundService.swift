import AVFoundation
import UIKit

/// Mic **permission** helper for voice features (speaking drills, speech recognition).  
/// No ambient recording — Discover Moments uses ``VolumeRouteService`` instead.
final class AmbientSoundService {
    static let shared = AmbientSoundService()

    private init() {}

    private func showSettingsAlert() {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }

            let alert = UIAlertController(
                title: "Microphone Access Required",
                message: "Please enable microphone access in Settings for speaking drills.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            topVC.present(alert, animated: true)
        }
    }

    private func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    func ensureMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                completion(true)
            case .undetermined:
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied:
                showSettingsAlert()
                completion(false)
            @unknown default:
                completion(false)
            }
        } else {
            let session = AVAudioSession.sharedInstance()
            switch session.recordPermission {
            case .granted:
                completion(true)
            case .undetermined:
                session.requestRecordPermission { granted in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied:
                showSettingsAlert()
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
}
