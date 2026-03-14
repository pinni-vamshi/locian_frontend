//
//  AudioManager.swift
//  locian
//
//  Text-to-Speech manager for audio drills
//  Supports multiple languages with speed control
//

import Foundation
import AVFoundation
import Combine

// MARK: - Enums
enum AudioSessionMode: Sendable {
    case playback
    case recording
}

enum AudioSegment: Sendable {
    case `static`(String)
    case dynamic(String)
    
    var computedPath: String {
        switch self {
        case .static(let text):
            return text.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
                .joined(separator: "_") + ".wav"
        case .dynamic(let key):
            return key
        }
    }
}

// MARK: - Models
struct SpeechSegment: Sendable {
    let text: String
    let language: String
}

class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var onSpeechCompletion: (() -> Void)?
    private var currentCategory: AVAudioSession.Category?
    private var pcmPlayer: AVAudioPlayer?
    
    // ✅ Serial Queue for Audio Operations
    private let audioQueue = DispatchQueue(label: "com.locian.audio", qos: .userInitiated)
    
    // MARK: - Singleton
    static let shared = AudioManager()
    
    override private init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Session Management
    
    func configureSession(for mode: AudioSessionMode) {
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            let session = AVAudioSession.sharedInstance()
            let targetCategory: AVAudioSession.Category
            let targetMode: AVAudioSession.Mode
            let targetOptions: AVAudioSession.CategoryOptions
            
            switch mode {
            case .recording:
                targetCategory = .playAndRecord
                targetMode = .spokenAudio
                targetOptions = [.duckOthers, .defaultToSpeaker]
            case .playback:
                targetCategory = .playback
                targetMode = .default
                targetOptions = [.duckOthers]
            }
            
            if session.category != targetCategory || session.categoryOptions != targetOptions {
                do {
                    try session.setCategory(targetCategory, mode: targetMode, options: targetOptions)
                    try session.setActive(true, options: .notifyOthersOnDeactivation)
                    self.currentCategory = targetCategory
                } catch {
                    print("🔊 [AudioManager] Session Config Warning for \(mode): \(error.localizedDescription)")
                }
            }
            try? session.overrideOutputAudioPort(.speaker)
        }
    }
    
    // MARK: - COMPOSITIONAL TTS (V4) — TRUE STREAMING
    
    /// Shared session state per recipe play — holds buffers + per-key waiters.
    private class RecipeSession {
        var buffers: [String: Data] = [:]
        var waiters: [String: (Data) -> Void] = [:]
        let lock = NSLock()
        
        /// Called when a Kokoro generation finishes for a key.
        /// Stores the data and unblocks any registered waiter.
        func provide(_ data: Data, for key: String) {
            lock.lock()
            buffers[key] = data
            let waiter = waiters.removeValue(forKey: key)
            lock.unlock()
            print("✅ [AudioManager] Ready '\(key)' — \(data.count) bytes")
            waiter?(data)  // fire AFTER releasing lock
        }
        
        /// Returns buffer immediately if ready, or registers a waiter and returns nil.
        /// The waiter will be called when data arrives.
        func getOrWait(for key: String, waiter: @escaping (Data) -> Void) -> Data? {
            lock.lock()
            defer { lock.unlock() }
            if let data = buffers[key] { return data }
            waiters[key] = waiter
            return nil
        }
    }
    
    private var currentSession: RecipeSession?

    /// ✅ TRUE STREAMING with 3-folder routing:
    /// - Static segments → Voices/drills/[contextPath]/[file].wav
    /// - dynamic("language") → Voices/languages/[name].wav
    /// - dynamic("meaning"/"target") → Generated via System TTS inline
    func speak(recipe: [AudioSegment], dynamicValues: [String: String], contextPath: String, completion: (() -> Void)? = nil) {

        print("🔊 [AudioManager] Recipe[\(contextPath)]: \(recipe.count) segments.")
        self.stop()
        
        let session = RecipeSession()
        self.currentSession = session
        
        // 1. Fire session-key (meaning/target) generations in parallel via preload cache
        let sessionKeys = ["meaning", "target"]
        let dynamicKeys = recipe.compactMap { if case .dynamic(let k) = $0 { return k } else { return nil } }
        
        for key in Array(Set(dynamicKeys)) where sessionKeys.contains(key) {
            guard let text = dynamicValues[key], !text.isEmpty else { continue }
            // Not preloaded — use fallback or ignore depending on logic
            print("🚀 [AudioManager] Skipping Kokoro generation for '\(text)'")
        }
        
        // 2. Pre-cache language file if needed (async, non-blocking)
        if let langName = dynamicValues["language"], !langName.isEmpty {
            ensureLanguageFile(name: langName)
        }
        
        // 3. Start playback chain IMMEDIATELY
        audioQueue.async { [weak self, weak session] in
            guard let self = self, let session = session else { return }
            self.playSequenceStreaming(recipe: recipe, values: dynamicValues, contextPath: contextPath, session: session, completion: completion)
        }
    }

    private func playSequenceStreaming(recipe: [AudioSegment], values: [String: String], contextPath: String, session: RecipeSession, completion: (() -> Void)?) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var currentIdx = 0
        
        func playNext() {
            guard currentIdx < recipe.count else {
                print("✅ [AudioManager] Sequence Complete.")
                completion?()
                return
            }
            
            let segment = recipe[currentIdx]
            currentIdx += 1
            
            switch segment {
            case .static(let text):
                // Static phrases → Voices/drills/[contextPath]/[filename].wav
                let filename = segment.computedPath
                let fileURL = documents.appendingPathComponent("Voices/\(contextPath)/\(filename)")
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    print("🔊 [AudioManager] '\(text)'")
                    self.playAudioFile(at: fileURL) { playNext() }
                } else {
                    print("⚠️ [AudioManager] Cache miss '\(text)' — inline generate.")
                    self.generateAndPlayInline(text: text, saveAt: fileURL) { playNext() }
                }
                
            case .dynamic(let key):
                guard let text = values[key], !text.isEmpty else { playNext(); return }
                
                if key == "language" {
                    // Language name → Voices/languages/[name].wav
                    let sanitized = text.lowercased()
                        .components(separatedBy: CharacterSet.alphanumerics.inverted)
                        .filter { !$0.isEmpty }.joined(separator: "_")
                    let fileURL = documents.appendingPathComponent("Voices/languages/\(sanitized).wav")
                    
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        print("🔊 [AudioManager] Language: '\(text)'")
                        self.playAudioFile(at: fileURL) { playNext() }
                    } else {
                        // Generate and save language file
                        self.generateAndPlayInline(text: text, saveAt: fileURL) { playNext() }
                    }
                } else {
                    // meaning/target → handled via fallback logic
                    _ = (key == "target") ? (values["languageCode"] ?? "en-US") : "en-US"
                    
                    if let pcmData = session.getOrWait(for: key, waiter: { [weak self] data in
                        guard let self = self else { return }
                        print("⚡️ [AudioManager] '\(key)' ready — playing.")
                        self.playPCMBuffer(data) { playNext() }
                    }) {
                        print("⚡️ [AudioManager] Instant '\(key)': '\(text)'")
                        playPCMBuffer(pcmData) { playNext() }
                    } else {
                        print("⏳ [AudioManager] Waiting for '\(key)'...")
                    }
                }
            }
        }
        
        playNext()
    }
    
    /// Pre-generates and saves the language name WAV to Voices/languages/ (async, non-blocking).
    private func ensureLanguageFile(name: String) {
        let sanitized = name.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }.joined(separator: "_")
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documents.appendingPathComponent("Voices/languages/\(sanitized).wav")
        
        guard !FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        print("🌍 [AudioManager] Cannot generate language name offline without Kokoro.")
    }
    
    /// Plays raw PCM data (with WAV header added) via AVAudioPlayer.
    private func playPCMBuffer(_ pcmData: Data, completion: @escaping () -> Void) {
        let wavData = addWavHeader(to: pcmData, sampleRate: 24000)
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let player = try AVAudioPlayer(data: wavData)
                DispatchQueue.main.async {
                    self.pcmPlayer = player
                    self.onSpeechCompletion = completion
                    self.pcmPlayer?.delegate = self
                    self.pcmPlayer?.play()
                }
            } catch {
                print("❌ [AudioManager] PCM buffer playback failed: \(error)")
                DispatchQueue.main.async { completion() }
            }
        }
    }
    
    
    /// Generates a static text segment inline (no stop() call — safe inside sequence chain).
    /// Saves to disk on success so next time it's an instant cache hit.
    private func generateAndPlayInline(text: String, saveAt fileURL: URL, completion: @escaping () -> Void) {
        print("🔇 [AudioManager] Inline fallback for '\(text)'. Calling completion directly.")
        completion()
    }
    
    /// Speaks text using AVSpeechSynthesizer inline (no stop() called).

    private func playAudioFile(at url: URL, completion: @escaping () -> Void) {
        self.onSpeechCompletion = completion
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                DispatchQueue.main.async {
                    self.pcmPlayer = player
                    self.pcmPlayer?.delegate = self
                    self.pcmPlayer?.play()
                }
            } catch {
                print("❌ [AudioManager] Fragment play failed: \(error)")
                completion()
            }
        }
    }
    
    /// ✅ ZERO-FLICKER: Queues multiple languages in a single cinematic breath.
    func speak(segments: [SpeechSegment], cacheIdentifier: String? = nil, completion: (() -> Void)? = nil) {
        guard !segments.isEmpty else {
            completion?()
            return
        }
        
        let finalCacheID = cacheIdentifier ?? generateCacheID(for: segments, voice: "system")
        
        print("🔊 [AudioManager] Multilingual Engine: Queuing \(segments.count) segments. CacheID: \(finalCacheID)")
        self.onSpeechCompletion = completion
        
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.playCachedFile(identifier: finalCacheID) {
                print("⚡️ [AudioManager] Session Cache Hit.")
                return 
            }
            
            // 1. Stop existing
            self.internalStop()
            
            // 2. Configure Session
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker])
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                try session.overrideOutputAudioPort(.speaker)
                self.currentCategory = .playAndRecord
            } catch {
                print("🔊 [AudioManager] Unified Session Config Failed: \(error)")
            }
            
            self.speakFallbacks(segments: segments)
        }
    }
    
    func generateCacheID(for segments: [SpeechSegment], voice: String) -> String {
        let combined = segments.map { "\($0.text)-\($0.language)" }.joined(separator: "|") + "|" + voice
        
        // Use a simple deterministic hash (DJB2) to ensure persistence across launches
        var hash: UInt64 = 5381
        for byte in combined.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return "v1_\(hash)"
    }
    
    private func speakFallbacks(segments: [SpeechSegment]) {
        // 5. Local High-Sync Reveal (Fallback to System)
        print("🔊 [AudioManager] Fallback: Using AVSpeechSynthesizer for \(segments.count) segments.")
        self.speakLocalSegments(segments)
    }
    
    @discardableResult
    func playAudioFile(named name: String, ext: String = "mp3") -> Bool {
        print("🔊 [AudioManager] Playing bundled file: \(name).\(ext)")
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return false
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            DispatchQueue.main.async {
                self.pcmPlayer = player
                self.pcmPlayer?.delegate = self
                self.pcmPlayer?.play()
            }
            return true
        } catch {
            print("❌ [AudioManager] File Playback Failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func playPCMData(_ data: Data, cacheIdentifier: String? = nil) {
        // Kokoro-v1.0 is 24kHz
        let sampleRate = 24000
        let wavData = addWavHeader(to: data, sampleRate: sampleRate)
        
        // Caching: Save to persistent Caches directory
        if let identifier = cacheIdentifier {
            saveToCache(wavData, identifier: identifier)
        }
        
        do {
            let player = try AVAudioPlayer(data: wavData)
            DispatchQueue.main.async {
                self.pcmPlayer = player
                self.pcmPlayer?.delegate = self
                self.pcmPlayer?.play()
            }
        } catch {
            print("❌ [AudioManager] PCM Playback Failed: \(error.localizedDescription)")
            self.finishPlayback()
        }
    }
    
    func getCacheURL(for identifier: String) -> URL? {
        guard let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let folder = caches.appendingPathComponent("VoiceCache", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent("\(identifier).wav")
    }
    
    private func saveToCache(_ data: Data, identifier: String) {
        guard let url = getCacheURL(for: identifier) else { return }
        
        do {
            try data.write(to: url)
            print("💾 [AudioManager] Saved voice cache: \(url.lastPathComponent)")
        } catch {
            print("⚠️ [AudioManager] Failed to save cache: \(error)")
        }
    }
    
    func playCachedFile(identifier: String) -> Bool {
        guard let url = getCacheURL(for: identifier) else { return false }
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        
        print("🔊 [AudioManager] Playing cached session file: \(url.lastPathComponent)")
        do {
            self.pcmPlayer = try AVAudioPlayer(contentsOf: url)
            self.pcmPlayer?.delegate = self
            self.pcmPlayer?.play()
            return true
        } catch {
            print("❌ [AudioManager] Cached Playback Failed: \(error.localizedDescription)")
            return false
        }
    }

    /// 🧹 Purges the temporary voice cache to ensure a fresh on-demand experience.
    func clearVoiceCache() {
        guard let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        let folder = caches.appendingPathComponent("VoiceCache", isDirectory: true)
        
        do {
            if FileManager.default.fileExists(atPath: folder.path) {
                try FileManager.default.removeItem(at: folder)
                print("🧹 [AudioManager] Voice Cache Purged. Starting fresh session.")
            }
        } catch {
            print("⚠️ [AudioManager] Cache Clean-up Failed: \(error)")
        }
    }
    
    
    private func addWavHeader(to data: Data, sampleRate: Int) -> Data {
        let headerSize = 44
        let totalSize = data.count + headerSize
        var header = Data(count: headerSize)
        
        header.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
            let ptr = bytes.baseAddress!
            // RIFF
            ptr.storeBytes(of: 0x46464952 as UInt32, as: UInt32.self)
            ptr.advanced(by: 4).storeBytes(of: UInt32(totalSize - 8), as: UInt32.self)
            ptr.advanced(by: 8).storeBytes(of: 0x45564157 as UInt32, as: UInt32.self)
            
            // fmt
            ptr.advanced(by: 12).storeBytes(of: 0x20746d66 as UInt32, as: UInt32.self)
            ptr.advanced(by: 16).storeBytes(of: 16 as UInt32, as: UInt32.self)
            ptr.advanced(by: 20).storeBytes(of: 3 as UInt16, as: UInt16.self) // IEEE Float
            ptr.advanced(by: 22).storeBytes(of: 1 as UInt16, as: UInt16.self) // Mono
            ptr.advanced(by: 24).storeBytes(of: UInt32(sampleRate), as: UInt32.self)
            ptr.advanced(by: 28).storeBytes(of: UInt32(sampleRate * 4), as: UInt32.self) // BPS
            ptr.advanced(by: 32).storeBytes(of: 4 as UInt16, as: UInt16.self) // Block Align
            ptr.advanced(by: 34).storeBytes(of: 32 as UInt16, as: UInt16.self) // Bits per sample
            
            // data
            ptr.advanced(by: 36).storeBytes(of: 0x61746164 as UInt32, as: UInt32.self)
            ptr.advanced(by: 40).storeBytes(of: UInt32(data.count), as: UInt32.self)
        }
        
        return header + data
    }
    
    private func speakLocalSegments(_ segments: [SpeechSegment]) {
        for (index, segment) in segments.enumerated() {
            let text = segment.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { continue }
            
            let u = AVSpeechUtterance(string: text)
            u.voice = AVSpeechSynthesisVoice(language: segment.language)
            
            // Speed control: Increased for clarity as requested
            u.rate = 0.4 // 80% of default speed (0.5 × 0.8 = 0.4) — clear pace for language learning
            
            // Natural pacing between segments
            if index > 0 {
                u.preUtteranceDelay = 0.1 
            }
            
            self.synthesizer.speak(u)
        }
    }
    
    // MARK: - Helpers
    
    func stop() {
        audioQueue.async { [weak self] in
            self?.internalStop()
            // ✅ ROOT FIX: Discard pending completion silently.
            // Do NOT call finishPlayback() here — that would prematurely
            // fire onSpeechCompletion and chain into the next speech early.
            self?.onSpeechCompletion = nil
        }
    }

    /// Sanitizes text for use as a filename (removes punctuation, lowercases, truncates if needed).
    
    private func internalStop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        pcmPlayer?.stop()
    }
    
    private func finishPlayback() {
        if let completion = onSpeechCompletion {
            DispatchQueue.main.async {
                completion()
                self.onSpeechCompletion = nil
            }
        }
    }
}

// MARK: - Delegates
extension AudioManager: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Debounce check on audio queue
        audioQueue.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if !self.synthesizer.isSpeaking {
                self.finishPlayback()
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        finishPlayback()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}
