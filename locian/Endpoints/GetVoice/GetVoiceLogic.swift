//
//  GetVoiceLogic.swift
//  locian
//
//  Refactored to Actor for Swift 6 Concurrency
//

import Foundation

actor GetVoiceService {
    static let shared = GetVoiceService()
    
    private var activeDownloads: [String: Task<URL, Error>] = [:]

    private init() {}
    
    /// Downloads or retrieves a cached voice file
    /// Note: Actors handle state serialization automatically, replacing the need for NSLock.
    func downloadVoice(request: GetVoiceRequest) async throws -> URL {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError(.badURL)
        }
        
        // Cache File URL (e.g., Documents/pattern_123.wav)
        let destinationURL = documentsURL.appendingPathComponent("\(request.fileId).wav")
        
        // 1. Check if it already exists locally
        if fileManager.fileExists(atPath: destinationURL.path) {
            return destinationURL
        }
        
        // 2. Prevent redundant concurrent downloads (Serialized via Actor)
        if let existingTask = activeDownloads[request.fileId] {
            return try await existingTask.value
        }
        
        // 3. Construct Network URL
        let cleanPath = request.relativeUrlPath.hasPrefix("/") ? request.relativeUrlPath : "/\(request.relativeUrlPath)"
        let fullPath = APIConfig.baseURL + cleanPath
        guard let url = URL(string: fullPath) else {
            throw URLError(.badURL)
        }
        
        // 4. Create single active download task
        let downloadTask = Task<URL, Error> {
            do {
                print("⏬ [GetVoiceService] Downloading: \(fullPath)")
                let (tempURL, response) = try await URLSession.shared.download(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                // Move safely to documents directory
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.moveItem(at: tempURL, to: destinationURL)
                
                print("✅ [GetVoiceService] Cached: \(request.fileId).wav")
                return destinationURL
                
            } catch {
                print("❌ [GetVoiceService] Download failed for \(fullPath): \(error)")
                throw error
            }
        }
        
        activeDownloads[request.fileId] = downloadTask
        
        // Clean up active task upon completion (async)
        _ = Task {
            _ = try? await downloadTask.value
            self.removeActiveDownload(forKey: request.fileId)
        }
        
        return try await downloadTask.value
    }

    private func removeActiveDownload(forKey key: String) {
        activeDownloads.removeValue(forKey: key)
    }
}
