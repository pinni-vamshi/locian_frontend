import Foundation
import Speech
import AVFoundation
import Combine
import UIKit
import SwiftUI

class SpeechRecognizer: ObservableObject {
    
    // MARK: - Published State
    @Published var recognizedText: String = ""
    @Published var isRecording: Bool = false
    @Published var speechPermissionGranted: Bool = false
    
    // MARK: - Private Core
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let locale: Locale
    private var isStopping: Bool = false
    
    // ✅ Silence Detection
    private var silenceTimer: Timer?
    private let silenceThreshold: TimeInterval = 1.5
    
    // ✅ Whisper Buffer & Session Tracking
    private var whisperSamples: [Float] = []
    private var currentSessionId = UUID()
    
    // MARK: - Singleton
    static let shared = SpeechRecognizer()
    
    // MARK: - Initialization
    init(locale: Locale = Locale(identifier: "en-US")) {
        self.locale = locale
        self.configure()
        
        // 🚀 PRE-LOAD: Trigger engines early so they are ready when needed
        _ = WhisperService.shared
    }
    
    private func configure() {
        self.speechRecognizer = SFSpeechRecognizer(locale: self.locale)
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.speechPermissionGranted = (status == .authorized)
            }
        }
    }
    
    // MARK: - Autonomous Alert Bridge (UIKit)
    private func showSettingsAlert() {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }
            
            let alert = UIAlertController(title: "Speech Recognition Required", message: "Please enable speech recognition in Settings for speaking drills.", preferredStyle: .alert)
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

    func ensureSpeechAccess(completion: @escaping (Bool) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async { completion(status == .authorized) }
            }
        case .denied, .restricted:
            self.showSettingsAlert()
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    func ensureVoiceAccess(completion: @escaping (Bool) -> Void) {
        AmbientSoundService.shared.ensureMicrophoneAccess { micGranted in
            guard micGranted else {
                completion(false)
                return
            }
            self.ensureSpeechAccess(completion: completion)
        }
    }

    // MARK: - Public Control
    
    func startRecording() throws {
        print("🎤 [SpeechRecognizer] startRecording() requested")
        
        // Ensure any previous work is stopped first
        self.internalReset()
        
        // 1. Request Mic from Traffic Controller
        AudioManager.shared.requestMic(owner: .speech, onDetach: { [weak self] in
            print("⚠️ [SpeechRecognizer] FORCED DETACH by AudioManager")
            self?.stopRecording()
        }) { [weak self] in
            guard let self = self else { return }
            
            // 2. Wait for Hardware Stabilization (Polling)
            self.waitForHardwareStabilization { [weak self] stabilizedFormat in
                guard let self = self, let recordingFormat = stabilizedFormat else {
                    print("❌ [SpeechRecognizer] Hardware stabilization failed. Aborting.")
                    self?.stopRecording()
                    return
                }
                
                print("🎙️ [SpeechRecognizer] Starting engine with stable format: \(recordingFormat.sampleRate)Hz")
                
                do {
                    // 3. Setup Recognition Request
                    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                    self.recognitionRequest = recognitionRequest
                    recognitionRequest.shouldReportPartialResults = true
                    
                    if #available(iOS 13, *) {
                        recognitionRequest.requiresOnDeviceRecognition = false
                    }
                    
                    // 4. Start Recognition Task
                    self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                        var isFinal = false
                        if let result = result {
                            DispatchQueue.main.async {
                                self?.recognizedText = result.bestTranscription.formattedString
                                self?.resetSilenceTimer()
                            }
                            isFinal = result.isFinal
                        }
                        if error != nil || isFinal {
                            // Only stop if we are still the recording owner
                            if self?.isRecording == true {
                                self?.stopRecording()
                            }
                        }
                    }
                    
                    // 5. Setup Audio Tap
                    let inputNode = self.audioEngine.inputNode
                    inputNode.removeTap(onBus: 0) // Final safety check
                    
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
                        guard buffer.frameLength > 0 else { return }
                        self?.recognitionRequest?.append(buffer)
                        if let downsampled = self?.convertTo16kHz(buffer: buffer) {
                            self?.whisperSamples.append(contentsOf: downsampled)
                        }
                    }
                    
                    self.audioEngine.prepare()
                    try self.audioEngine.start()
                    
                    DispatchQueue.main.async {
                        self.recognizedText = ""
                        self.isRecording = true
                        self.isStopping = false
                    }
                } catch {
                    print("❌ [SpeechRecognizer] Engine Start Error: \(error.localizedDescription)")
                    self.stopRecording()
                }
            }
        }
    }
    
    private func waitForHardwareStabilization(completion: @escaping (AVAudioFormat?) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let timeout = 1.0 // 1 second max wait
        
        func probe() {
            let inputNode = audioEngine.inputNode
            let format = inputNode.inputFormat(forBus: 0)
            
            if format.sampleRate > 0 {
                print("✅ [SpeechRecognizer] Hardware stabilized in \(CFAbsoluteTimeGetCurrent() - startTime)s")
                completion(format)
            } else if CFAbsoluteTimeGetCurrent() - startTime > timeout {
                print("🚨 [SpeechRecognizer] Hardware stabilization TIMED OUT.")
                completion(nil)
            } else {
                // Poll again in 50ms
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { probe() }
            }
        }
        
        probe()
    }
    
    /// Internal helper to purge all engine and request state before a fresh start
    private func internalReset() {
        print("🧹 [SpeechRecognizer] Purging Engine State...")
        stopSilenceTimer()
        
        audioEngine.stop()
        audioEngine.reset()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        whisperSamples.removeAll()
        currentSessionId = UUID()
    }
    
    func stopRecording() {
        // Kill timer immediately
        stopSilenceTimer()
        
        // Guard against rapid re-entry loops
        guard isRecording && !isStopping else { return }
        print("🎤 [SpeechRecognizer] stopRecording() execution started")
        isStopping = true
        
        // 1. Kill the engine and tap immediately
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // 2. Gracefully end the request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // 3. Final Transcription via Whisper (Local AI)
        print("🤖 [SpeechRecognizer] Checking Whisper: samples=\(whisperSamples.count), isReady=\(WhisperService.shared.isReady)")
        if !whisperSamples.isEmpty && WhisperService.shared.isReady {
            let sessionIdAtStop = currentSessionId
            let samplesToProcess = whisperSamples
            
            WhisperService.shared.transcribe(samples: samplesToProcess) { [weak self] result in
                guard let self = self, self.currentSessionId == sessionIdAtStop else { return }
                
                switch result {
                case .success(let text):
                    print("✨ [SpeechRecognizer] Whisper Result: \"\(text)\"")
                    if !text.isEmpty {
                        DispatchQueue.main.async {
                            self.recognizedText = text
                        }
                    }
                case .failure(let error):
                    print("⚠️ [SpeechRecognizer] Whisper Failed: \(error.localizedDescription)")
                }
            }
        }
        
        // 4. Release Mic and Revert Session
        AudioManager.shared.releaseMic(owner: .speech)
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.isStopping = false
            self.recognitionTask = nil
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.recognizedText = ""
        }
    }
    
    // MARK: - Private Helpers
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceThreshold, repeats: false) { [weak self] _ in
            print("🕒 [SpeechRecognizer] Silence timeout reached. Auto-stopping...")
            self?.stopRecording()
        }
    }
    
    private func stopSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
    
    // MARK: - Audio Utilities
    
    private func convertTo16kHz(buffer: AVAudioPCMBuffer) -> [Float]? {
        let targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false)!
        guard let converter = AVAudioConverter(from: buffer.format, to: targetFormat) else { return nil }
        
        let ratio = buffer.format.sampleRate / targetFormat.sampleRate
        let targetFrameCapacity = AVAudioFrameCount(Double(buffer.frameLength) / ratio) + 1
        
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: targetFrameCapacity) else { return nil }
        
        var error: NSError?
        let status = converter.convert(to: outputBuffer, error: &error) { (frameCount, outStatus) -> AVAudioBuffer? in
            outStatus.pointee = .haveData
            return buffer
        }
        
        if status == .error || error != nil {
            print("❌ [SpeechRecognizer] Conversion failed: \(error?.localizedDescription ?? "Unknown error")")
            return nil
        }
        
        guard let floatData = outputBuffer.floatChannelData else { return nil }
        return Array(UnsafeBufferPointer(start: floatData[0], count: Int(outputBuffer.frameLength)))
    }
}
