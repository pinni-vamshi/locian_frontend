//
//  ImageAPIManager.swift
//  locian
//
//  Created by vamshi krishna pinni on 24/10/25.
//

import Foundation
import UIKit

class ImageAPIManager: BaseAPIManagerProtocol {
    static let shared = ImageAPIManager()
    
    private init() {}
    
    // MARK: - Image Analysis
    func analyzeImage(image: UIImage, sessionToken: String, completion: @escaping (Result<ImageAnalysisData, Error>) -> Void) {
        let base64 = image.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
        let request = ImageAnalysisRequest(session_token: sessionToken, image_base64: base64, level: nil, previous_places: nil, future_places: nil, user_language: nil, target_language: nil, time: nil, latitude: nil, longitude: nil)
        
        analyzeImage(request: request) { result in
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "ImageAnalysis", code: 1, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Analysis failed"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func analyzeImage(request: ImageAnalysisRequest, completion: @escaping (Result<ImageAnalysisResponse, Error>) -> Void) {
        
        // Pass through completion
        let loggingCompletion: (Result<ImageAnalysisResponse, Error>) -> Void = { result in
            completion(result)
        }
        
        performRequest(
            endpoint: "/api/image/analyze",
            method: "POST",
            body: request,
            timeoutInterval: 60.0,
            completion: loggingCompletion
        )
    }
}
