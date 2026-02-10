import SwiftUI
import AVFoundation
import Photos
import CoreLocation
import Speech

class PermissionsService: NSObject {
    static let shared = PermissionsService()
    
    private override init() {}
    
    enum PermissionType {
        case camera
        case photos
        case location
        case notifications
        case microphone
        case speech
        
        var title: String {
            switch self {
            case .camera: return "Camera Access Required"
            case .photos: return "Photo Library Access Required"
            case .location: return "Location Access Required"
            case .notifications: return "Notifications Required"
            case .microphone: return "Microphone Access Required"
            case .speech: return "Speech Recognition Required"
            }
        }
        
        var message: String {
            switch self {
            case .camera: return "Please enable camera access in Settings to take photos."
            case .photos: return "Please enable photo library access in Settings to select images."
            case .location: return "Please enable location access in Settings to find nearby places."
            case .notifications: return "Please enable notifications in Settings to receive study reminders."
            case .microphone: return "Please enable microphone access in Settings for speaking drills."
            case .speech: return "Please enable speech recognition in Settings for speaking drills."
            }
        }
    }

    // MARK: - Autonomous Alert Bridge (UIKit)
    private func showSettingsAlert(for type: PermissionType) {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }
            
            let alert = UIAlertController(title: type.title, message: type.message, preferredStyle: .alert)
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

    // MARK: - Access Methods
    
    func ensureCameraAccess(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .denied, .restricted:
            showSettingsAlert(for: .camera)
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func ensurePhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
        case .denied, .restricted:
            showSettingsAlert(for: .photos)
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func ensureLocationAccess(completion: @escaping (Bool) -> Void) {
        let status = LocationManager.shared.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            LocationManager.shared.locationManager.requestWhenInUseAuthorization()
            // Polling for a brief moment to catch the sync update if user clicks "Allow" immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let newStatus = LocationManager.shared.authorizationStatus
                completion(newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways)
            }
        case .denied, .restricted:
            showSettingsAlert(for: .location)
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func ensureNotificationAccess(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    completion(true)
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async { 
                            NotificationManager.shared.isNotificationsEnabled = granted
                            completion(granted) 
                        }
                    }
                case .denied:
                    self.showSettingsAlert(for: .notifications)
                    completion(false)
                @unknown default:
                    completion(false)
                }
            }
        }
    }
    
    /// Unified Speking Access (Handles both Mic and Speech sequentially)
    func ensureVoiceAccess(completion: @escaping (Bool) -> Void) {
        self.ensureMicrophoneAccess { micGranted in
            guard micGranted else {
                completion(false)
                return
            }
            
            self.ensureSpeechAccess { speechGranted in
                completion(speechGranted)
            }
        }
    }
    
    func ensureMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        let status = AVAudioApplication.shared.recordPermission
        switch status {
        case .granted:
            completion(true)
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .denied:
            showSettingsAlert(for: .microphone)
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func ensureSpeechAccess(completion: @escaping (Bool) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async { completion(status == .authorized) }
            }
        case .denied, .restricted:
            showSettingsAlert(for: .speech)
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}

