//
//  AnalyzeImageService.swift
//  locian
//
//  Service layer for Analyze Image Endpoint
//  Gathers required data and makes the API call
//

import Foundation
import UIKit
import CoreLocation

class AnalyzeImageService {
    static let shared = AnalyzeImageService()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Analyze image with automatic data gathering
    func analyzeImage(
        image: UIImage,
        sessionToken: String,
        completion: @escaping (Result<AnalyzeImageResponse, Error>) -> Void
    ) {
        PermissionsService.ensureCameraAccess { granted in
            guard granted else {
                completion(.failure(NSError(domain: "PermissionError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Camera permission denied"])))
                return
            }
            
            // Convert image to base64
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
                return
            }
            let base64String = imageData.base64EncodedString()
            
            // Gather current time
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let timeString = formatter.string(from: currentDate)
            
            // Gather location
            let userLocation = LocationManager.shared.currentLocation
            
            // Gather user profile data
            let appState = AppStateManager.shared
            let level = appState.userLanguagePairs.first(where: { $0.is_default })?.user_level ?? "BEGINNER"
            let userLanguage = appState.nativeLanguage
            let targetLanguage = appState.userLanguagePairs.first(where: { $0.is_default })?.target_language
            
            // Build request
            let request = AnalyzeImageRequest(
                image_base64: base64String,
                time: timeString,
                level: level,
                latitude: userLocation?.coordinate.latitude,
                longitude: userLocation?.coordinate.longitude,
                user_language: userLanguage,
                target_language: targetLanguage,
                previous_places: nil,
                future_places: nil
            )
            
            // Make API call
            self.performRequest(request: request, sessionToken: sessionToken, completion: completion)
        }
    }
    
    // MARK: - Private API Call
    
    private func performRequest(
        request: AnalyzeImageRequest,
        sessionToken: String,
        completion: @escaping (Result<AnalyzeImageResponse, Error>) -> Void
    ) {
        let headers = ["Authorization": "Bearer \(sessionToken)"]
        
        BaseAPIManager.shared.performRawRequest(
            endpoint: "/api/image/analyze",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 300.0,
            completion: { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    AnalyzeImageLogic.shared.parseResponse(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
