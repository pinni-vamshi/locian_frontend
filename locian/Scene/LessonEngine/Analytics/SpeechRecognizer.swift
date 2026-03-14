import Foundation
import Speech
import AVFoundation
import Combine

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
    
    // MARK: - Public Control
    
    func startRecording() throws {
        print("🎤 [SpeechRecognizer] startRecording() called")
        isStopping = false
        if isRecording {
            stopRecording()
        }
        
        recognitionTask?.cancel()
        self.recognitionTask = nil
        whisperSamples.removeAll()
        currentSessionId = UUID()
        
        // LOGIC CORRECT: Use central traffic controller for session
        AudioManager.shared.configureSession(for: .recording)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false // Allow network for accuracy
        }
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false
            
            if let result = result {
                DispatchQueue.main.async {
                    // Update UI with partial results from Apple STT (fast)
                    let text = result.bestTranscription.formattedString
                    print("🍏 [SpeechRecognizer] Apple STT Partial: \"\(text)\"")
                    self?.recognizedText = text
                    
                    // 🕒 AUTO-STOP: Reset silence timer whenever we get a new result
                    self?.resetSilenceTimer()
                }
                isFinal = result.isFinal
            }
            
            // LOGIC CORRECT: Stop if error or final, but don't force cancel here
            if error != nil || isFinal {
                self?.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
            // FIX: Robust guard against empty or zero-size buffers to satisfy AVAudioBuffer requirement
            guard buffer.frameLength > 0, buffer.audioBufferList.pointee.mBuffers.mDataByteSize > 0 else { return }
            
            // 1. Feed Apple STT (Network/On-Device hybrid)
            self?.recognitionRequest?.append(buffer)
            
            // 2. Accumulate for Whisper (Offline High-Accuracy)
            if let downsampled = AudioDownsampler.convertTo16kHz(buffer: buffer) {
                self?.whisperSamples.append(contentsOf: downsampled)
                if (self?.whisperSamples.count ?? 0) % 50000 == 0 {
                    print("🎙️ [SpeechRecognizer] Captured \(self?.whisperSamples.count ?? 0) samples...")
                }
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        DispatchQueue.main.async {
            self.recognizedText = ""
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        // Kill timer immediately to prevent recursive calls
        stopSilenceTimer()
        
        // LOGIC CORRECT: Idempotent guard to prevent recursive disconnect calls
        guard !isStopping else { return }
        print("🎤 [SpeechRecognizer] stopRecording() execution started")
        isStopping = true
        
        // 1. Kill the engine immediately (Stops buffer warnings)
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioEngine.reset() // DEEP RESET: Hardware cleanup
        
        // 2. Gracefully end the request (Signals server cleanly)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // 3. Final Transcription via Whisper (Local AI)
        print("🤖 [SpeechRecognizer] Checking Whisper: samples=\(whisperSamples.count), isReady=\(WhisperService.shared.isReady)")
        if !whisperSamples.isEmpty && WhisperService.shared.isReady {
            let sessionIdAtStop = currentSessionId
            print("🤖 [SpeechRecognizer] Finalizing with Whisper Engine (\(whisperSamples.count) samples) for session \(sessionIdAtStop)")
            
            let samplesToProcess = whisperSamples
            WhisperService.shared.transcribe(samples: samplesToProcess) { [weak self] result in
                guard let self = self, self.currentSessionId == sessionIdAtStop else {
                    print("🚫 [SpeechRecognizer] Ignoring stale Whisper result for session \(sessionIdAtStop)")
                    return
                }
                
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
        
        // 4. Revert session with 100ms grace period for "Reporter" wind-down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            AudioManager.shared.configureSession(for: .playback)
            
            self?.isRecording = false
            self?.isStopping = false
            self?.recognitionTask = nil
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
}
