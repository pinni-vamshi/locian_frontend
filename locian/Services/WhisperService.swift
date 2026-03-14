import SwiftWhisper
import AVFoundation
import Combine

class WhisperService: ObservableObject {
    static let shared = WhisperService()
    
    private var whisper: Whisper?
    @Published var isReady = false
    private init() {
        print("🎙️ [WhisperService] Singleton initialized")
        setup()
    }
    
    private func tearDown() {
        print("🛑 [WhisperService] Voice disabled. Tearing down engine to free resources.")
        self.whisper = nil
        self.isReady = false
        self.isInitializing = false
    }
    
    func setup() {
        guard !isInitializing && !isReady else { return }
        isInitializing = true
        
        print("🎙️ [WhisperService] Starting setup...")
        let setupStartTime = CFAbsoluteTimeGetCurrent()
        
        // Run in background to avoid blocking UI during model load
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 1. Find the model files in the bundle
            var modelURL = Bundle.main.url(forResource: "ggml-base.en", withExtension: "bin", subdirectory: "WhisperModels")
            
            if modelURL == nil {
                print("⚠️ [WhisperService] Model ggml-base.en.bin not found in subdirectory, checking root...")
                modelURL = Bundle.main.url(forResource: "ggml-base.en", withExtension: "bin")
            }
            
            guard let modelURL = modelURL else {
                print("❌ [WhisperService] CRITICAL: Could not find ggml-base.en.bin anywhere in bundle.")
                return
            }
            
            // 2. Find the CoreML encoder
            var coreMLURL = Bundle.main.url(forResource: "ggml-base.en-encoder", withExtension: "mlmodelc", subdirectory: "WhisperModels")
            
            if coreMLURL == nil {
                print("⚠️ [WhisperService] CoreML encoder not found in subdirectory, checking root...")
                coreMLURL = Bundle.main.url(forResource: "ggml-base.en-encoder", withExtension: "mlmodelc")
            }
            
            if coreMLURL == nil {
                print("⚠️ [WhisperService] CoreML encoder (.mlmodelc) NOT found. TRANSCRIPTION WILL BE SLOW (CPU ONLY).")
            } else {
                print("🚀 [WhisperService] CoreML encoder detected at: \(coreMLURL!.lastPathComponent)")
                print("🚀 [WhisperService] Neural Engine (ANE) will be prioritized by SwiftWhisper.")
            }
            
            print("🎙️ [WhisperService] Initializing model from: \(modelURL.lastPathComponent)")
            
            // 3. Initialize Whisper
            self.whisper = Whisper(fromFileURL: modelURL)
            
            let setupDuration = CFAbsoluteTimeGetCurrent() - setupStartTime
            DispatchQueue.main.async {
                self.isReady = true
                self.isInitializing = false
                print("✨ [WhisperService] Engine Ready. Setup took \(String(format: "%.2f", setupDuration))s. Starting warm-up...")
                self.warmUp()
            }
        }
    }
    
    private func warmUp() {
        // Transcribe a tiny bit of silence (0.2s) to wake up the CoreML encoder
        let silence = [Float](repeating: 0, count: 3200)
        self.transcribe(samples: silence) { result in
            switch result {
            case .success:
                print("☕️ [WhisperService] Warm-up complete. ANE is ready.")
            case .failure(let error):
                print("⚠️ [WhisperService] Warm-up failed: \(error.localizedDescription)")
            }
        }
    }
    
    func transcribe(samples: [Float], completion: @escaping (Result<String, Error>) -> Void) {
        let transcribeStartTime = CFAbsoluteTimeGetCurrent()
        print("🎙️ [WhisperService] Transcription started. Buffer size: \(samples.count) samples (~\(String(format: "%.1f", Double(samples.count)/16000.0))s audio).")
        
        guard let whisper = whisper, isReady else {
            print("⚠️ [WhisperService] Aborting: Service not ready.")
            completion(.failure(NSError(domain: "WhisperService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not ready"])))
            return
        }
        
        Task {
            do {
                // Whisper expects [Float] at 16,000Hz
                print("🎙️ [WhisperService] Sending \(samples.count) frames to Whisper engine...")
                let segments = try await whisper.transcribe(audioFrames: samples)
                print("🎙️ [WhisperService] Engine returned \(segments.count) segments.")
                let text = segments.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
                
                let duration = CFAbsoluteTimeGetCurrent() - transcribeStartTime
                print("✨ [WhisperService] Done! Latency: \(String(format: "%.2f", duration))s. Result: \"\(text)\"")
                
                await MainActor.run {
                    completion(.success(text))
                }
            } catch {
                print("❌ [WhisperService] Transcription Error: \(error.localizedDescription)")
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
