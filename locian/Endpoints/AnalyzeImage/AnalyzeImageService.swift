//
//  AnalyzeImageService.swift
//  locian
//
//  Service layer for Analyze Image Endpoint
//  Gathers required data and makes the API call
//

import Foundation
import Combine
import UIKit
import CoreLocation

class AnalyzeImageService {
    static let shared = AnalyzeImageService()
    
    @Published var isLoading: Bool = false
    
    private init() {}
    
    // MARK: - Public API
    
    /// Analyze image with automatic data gathering
    /// Analyze image with automatic data gathering
    func analyzeImage(
        image: UIImage,
        sessionToken: String,
        completion: @escaping (Result<AnalyzeImageResponse, Error>) -> Void
    ) {
        isLoading = true
        
        PermissionsService.shared.ensureCameraAccess { [weak self] granted in
            guard let self = self else { return }
            
            guard granted else {
                self.isLoading = false
                completion(.failure(NSError(domain: "PermissionError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Camera permission denied"])))
                return
            }
            
            // Convert image to base64
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                self.isLoading = false
                completion(.failure(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
                return
            }
            let base64String = imageData.base64EncodedString()
            
            // 1. Define continuation logic with Lock for Thread Safety
            var didProceed = false
            let lock = NSLock()
            
            func proceed(location: CLLocation?) {
                lock.lock()
                guard !didProceed else {
                    lock.unlock()
                    return
                }
                didProceed = true
                lock.unlock()
                
                // Gather current time
                let currentDate = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                let timeString = formatter.string(from: currentDate)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM d, yyyy"
                let dateString = dateFormatter.string(from: currentDate)
                
                // Gather user profile data
                let appState = AppStateManager.shared
                let level = appState.userLanguagePairs.first(where: { $0.is_default })?.user_level ?? "BEGINNER"
                let userLanguage = appState.nativeLanguage
                let targetLanguage = appState.userLanguagePairs.first(where: { $0.is_default })?.target_language
                
                // Gather history context via TimelineContextService
                let timeline = AppStateManager.shared.timeline
                let history = timeline?.places ?? []
                let context = TimelineContextService.shared.getContext(places: history, inputTime: timeline?.inputTime)
                
                let previous = context.pastPlaces.map { $0.toContext }
                let future = context.futurePlaces.map { $0.toContext }
                
                // Build request
                var lat: Double? = nil
                var long: Double? = nil
                
                if let loc = location {
                    lat = loc.coordinate.latitude
                    long = loc.coordinate.longitude
                }
                
                let request = AnalyzeImageRequest(
                    image_base64: base64String,
                    time: timeString,
                    level: level,
                    latitude: lat,
                    longitude: long,
                    user_language: userLanguage,
                    target_language: targetLanguage,
                    previous_places: Array(previous),
                    future_places: Array(future),
                    date: dateString
                )
                
                // Make API call
                self.performRequest(request: request, sessionToken: sessionToken, completion: completion)
            }
            
            // 2. Start Timeout Timer (3.0s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // GPS Timeout (3s) reached. Proceeding without location.
                proceed(location: nil)
            }
            
            // 3. Request Location
            // Requesting current location via LocationManager...
            LocationManager.shared.getCurrentLocation { result in
                switch result {
                case .success(let location):
                    // Location fetched
                    proceed(location: location)
                case .failure:
                    // Location fetch failed
                    proceed(location: nil)
                }
            }
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
            completion: { [weak self] (result: Result<Data, Error>) in
                defer { self?.isLoading = false }
                
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
