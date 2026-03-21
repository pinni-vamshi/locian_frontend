import Foundation
import AVFoundation
import Combine
import UIKit
import SwiftUI

class AmbientSoundService: ObservableObject {
    static let shared = AmbientSoundService()
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    @Published var currentDecibels: Float = -160.0
    
    private init() {}
    
    // MARK: - Autonomous Alert Bridge (UIKit)
    private func showSettingsAlert() {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }
            
            let alert = UIAlertController(title: "Microphone Access Required", message: "Please enable microphone access in Settings for speaking drills.", preferredStyle: .alert)
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
        let status = AVAudioApplication.shared.recordPermission
        switch status {
        case .granted:
            completion(true)
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .denied:
            self.showSettingsAlert()
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    func startListening() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                guard granted else {
                    print("⚠️ [AmbientSound] Microphone permission denied.")
                    self?.showSettingsAlert()
                    return
                }
                DispatchQueue.main.async {
                    self?.requestMicAccess()
                }
            }
        } else {
            // Fallback for older iOS versions
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard granted else {
                    print("⚠️ [AmbientSound] Microphone permission denied.")
                    self?.showSettingsAlert()
                    return
                }
                DispatchQueue.main.async {
                    self?.requestMicAccess()
                }
            }
        }
    }
    
    private func requestMicAccess() {
        AudioManager.shared.requestMic(owner: .ambient, onDetach: { [weak self] in
            print("⚠️ [AmbientSound] FORCED DETACH by AudioManager")
            self?.stopListening()
        }) { [weak self] in
            self?.setupRecording()
        }
    }
    
    private func setupRecording() {
        do {
            let url = URL(fileURLWithPath: "/dev/null")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.audioRecorder?.updateMeters()
                if let db = self?.audioRecorder?.averagePower(forChannel: 0) {
                    self?.currentDecibels = db // Range is generally -160dB to 0dB
                }
            }
        } catch {
            print("Failed to start Ambient Sound Service: \(error)")
        }
    }
    
    
    func stopListening() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        
        AudioManager.shared.releaseMic(owner: .ambient)
    }
    
    /// 🎙️ On-Demand Sampling: Starts mic, waits 800ms for a stable reading, then stops.
    func fetchDecibels() async -> Float {
        await withCheckedContinuation { continuation in
            startListening()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let db = self.currentDecibels
                self.stopListening()
                continuation.resume(returning: db)
            }
        }
    }
}
