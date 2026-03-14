import Foundation
import AVFoundation
import Combine

class AmbientSoundService: ObservableObject {
    static let shared = AmbientSoundService()
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    @Published var currentDecibels: Float = -160.0
    
    private init() {}
    
    func startListening() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                guard granted else {
                    print("⚠️ [AmbientSound] Microphone permission denied.")
                    return
                }
                DispatchQueue.main.async {
                    self?.setupRecording(audioSession: AVAudioSession.sharedInstance())
                }
            }
        } else {
            // Fallback for older iOS versions
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard granted else {
                    print("⚠️ [AmbientSound] Microphone permission denied.")
                    return
                }
                DispatchQueue.main.async {
                    self?.setupRecording(audioSession: AVAudioSession.sharedInstance())
                }
            }
        }
    }
    
    private func setupRecording(audioSession: AVAudioSession) {
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
            
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
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ [AmbientSound] Failed to deactivate audio session: \(error)")
        }
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
