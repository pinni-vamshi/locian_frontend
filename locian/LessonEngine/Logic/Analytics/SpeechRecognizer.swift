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
    @Published var isStarting: Bool = false
    @Published var speechPermissionGranted: Bool = false
    
    // MARK: - Private Core
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var locale: Locale
    private var isStopping: Bool = false
    private var isTaskActive: Bool = false // ✅ Safety Guard: Prevents rate-limit issues
    private var isTaskFinalized: Bool = false // ✅ Safety Guard: Prevents 'already stopped' errors
    
    // ✅ Silence Detection
    private var silenceTimer: Timer?
    private let silenceThreshold: TimeInterval = 3.0
    
    // MARK: - Singleton
    static let shared = SpeechRecognizer()
    
    // MARK: - Initialization
    init(locale: Locale = Locale(identifier: "en-US")) {
        self.locale = locale
        self.configure()
    }
    
    private func configure() {
        self.speechRecognizer = SFSpeechRecognizer(locale: self.locale)
        self.speechRecognizer?.defaultTaskHint = .dictation
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.speechPermissionGranted = (status == .authorized)
            }
        }
    }
    
    func setLocale(_ newLocale: Locale) {
        if self.locale.identifier != newLocale.identifier {
            print("🎙️ [SpeechRecognizer] Updating locale to: \(newLocale.identifier)")
            self.locale = newLocale
            self.configure()
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
        
        guard !isRecording && !isStarting && !isStopping else { 
            print("⚠️ [SpeechRecognizer] startRecording skipped: state is already busy (rec=\(isRecording), start=\(isStarting), stop=\(isStopping))")
            return 
        }
        
        DispatchQueue.main.async { self.isStarting = true }
        
        // Ensure any previous work is stopped first
        self.internalReset()
        
        // 1. Request Mic from Traffic Controller
        AudioManager.shared.requestMic(owner: .speech, onDetach: { completion in
            print("⚠️ [SpeechRecognizer] FORCED DETACH by AudioManager")
            self.stopRecording()
            completion()
        }) { [weak self] in
            guard let self = self else { return }
            
            // 2. Small Delay for session settling to avoid -10851 (Invalid Format)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 3. Wait for Hardware Stabilization (Polling)
                self.waitForHardwareStabilization { [weak self] stabilizedFormat in
                    guard let self = self else { return }
                    
                    guard let recordingFormat = stabilizedFormat else {
                        print("🚨 [SpeechRecognizer] Aborting start: Hardware stabilization failed.")
                        DispatchQueue.main.async {
                            self.isStarting = false
                            self.stopRecording()
                        }
                        return
                    }
                    
                    print("🎙️ [SpeechRecognizer] Starting engine with stable format: \(recordingFormat.sampleRate)Hz")
                    
                    do {
                        // 3. Setup Recognition Request
                        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                        self.recognitionRequest = recognitionRequest
                        recognitionRequest.shouldReportPartialResults = true
                        
                        // Prefer on-device recognition for lower latency and reliability
                        if #available(iOS 13, *) {
                            recognitionRequest.requiresOnDeviceRecognition = self.speechRecognizer?.supportsOnDeviceRecognition ?? false
                        }
                        
                        // 4. Start Recognition Task
                        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                            var isFinal = false
                            if let result = result {
                                DispatchQueue.main.async {
                                    // Guard: Only update text if this task is still active.
                                    // Prevents stale results from leaking into the next drill.
                                    guard self?.isTaskActive == true else { return }
                                    self?.recognizedText = result.bestTranscription.formattedString
                                    self?.resetSilenceTimer()
                                }
                                isFinal = result.isFinal
                                if isFinal { self?.isTaskFinalized = true }
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
                        
                        // ✅ ACTIVATE GUARD BEFORE TAP
                        self.isTaskActive = true
                        self.isTaskFinalized = false 

                        // Use the stabilized input format explicitly.
                        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
                            guard let self = self, self.isTaskActive, buffer.frameLength > 0 else { return }
                            self.recognitionRequest?.append(buffer)
                        }
                        
                        self.audioEngine.prepare()
                        try self.audioEngine.start()
                        
                        DispatchQueue.main.async {
                            self.recognizedText = ""
                            self.isRecording = true
                            self.isStarting = false
                            self.isStopping = false
                        }
                    } catch {
                        print("❌ [SpeechRecognizer] Engine Start Error: \(error.localizedDescription)")
                        self.isStarting = false
                        self.stopRecording()
                    }
                }
            }
        }
    }
    
    private func waitForHardwareStabilization(completion: @escaping (AVAudioFormat?) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let timeout = 2.0 // 2 second max wait
        
        func probe() {
            let inputNode = audioEngine.inputNode
            let format = inputNode.inputFormat(forBus: 0)
            
            if format.sampleRate > 0 && format.channelCount > 0 {
                print("✅ [SpeechRecognizer] Hardware stabilized in \(CFAbsoluteTimeGetCurrent() - startTime)s")
                completion(format)
            } else if CFAbsoluteTimeGetCurrent() - startTime > timeout {
                print("🚨 [SpeechRecognizer] Hardware stabilization TIMED OUT.")
                completion(nil)
            } else {
                // Poll again in 100ms
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { probe() }
            }
        }
        
        probe()
    }
    
    /// Internal helper to purge all engine and request state before a fresh start
    private func internalReset() {
        print("🧹 [SpeechRecognizer] Purging Engine State...")
        
        // 1. Thread-safe cleanup
        self.stopSilenceTimer()
        self.isTaskActive = false // ✅ DEACTIVATE GUARD IMMEDIATELY
        self.recognizedText = "" // ✅ ENSURE TEXT IS CLEARED BEFORE ANY FRESH START
        
        // 2. Task Finalization (Finish BEFORE engine stop to avoid Reporter disconnect)
        if let task = recognitionTask {
            print("🎙️ [SpeechRecognizer] Purging active task...")
            if !isTaskFinalized {
                task.cancel() 
            }
            recognitionTask = nil
        }
        
        // 3. Engine operations (Safe checks)
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.reset()
        
        recognitionRequest = nil
    }
    
    func stopRecording() {
        // Guard against rapid re-entry loops
        guard (isRecording || isStarting) && !isStopping else { return }
        
        DispatchQueue.main.async {
            // Kill timer immediately
            self.stopSilenceTimer()
            self.isTaskActive = false // ✅ SHUT DOWN PIPE IMMEDIATELY
            
            print("🎤 [SpeechRecognizer] stopRecording() execution started")
            self.isStopping = true
            
            // 1. Finalize the request (Finish BEFORE hardware stop)
            if let task = self.recognitionTask {
                if !self.isTaskFinalized {
                    print("🎙️ [SpeechRecognizer] Manually finishing task...")
                    task.finish()
                }
                self.recognitionTask = nil
            }
            self.isTaskFinalized = true 
            self.recognitionRequest?.endAudio()
            self.recognitionRequest = nil
            
            // 2. Remove tap and stop engine
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.audioEngine.stop()
            
            // 3. Release Mic and Revert Session
            AudioManager.shared.releaseMic(owner: .speech)
            
            self.isRecording = false
            self.isStarting = false
            self.isStopping = false
        }
    }
    
    func reset() {
        // Clear text immediately to prevent "leakage" to the next drill
        self.recognizedText = ""
        self.isRecording = false
        self.isStarting = false
        self.isStopping = false
        
        // Also ensure any timers or engine state are purged
        self.internalReset()
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
}
