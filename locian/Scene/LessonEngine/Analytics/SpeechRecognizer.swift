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
    
    // MARK: - Singleton
    static let shared = SpeechRecognizer()
    
    // MARK: - Initialization
    init(locale: Locale = Locale(identifier: "en-US")) {
        self.locale = locale
        self.configure()
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
        isStopping = false
        if isRecording {
            stopRecording()
        }
        
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
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
                    self?.recognizedText = result.bestTranscription.formattedString
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
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        DispatchQueue.main.async {
            self.recognizedText = ""
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        // LOGIC CORRECT: Idempotent guard to prevent recursive disconnect calls
        guard !isStopping else { return }
        isStopping = true
        
        // 1. Kill the engine immediately (Stops buffer warnings)
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioEngine.reset() // DEEP RESET: Hardware cleanup
        
        // 2. Gracefully end the request (Signals server cleanly)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // NO: recognitionTask?.cancel() 
        // We let it finish via endAudio() to avoid "Reporter disconnected"
        
        // 3. Revert session with 100ms grace period for "Reporter" wind-down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            AudioManager.shared.configureSession(for: .playback)
            
            self?.recognizedText = ""
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
}
