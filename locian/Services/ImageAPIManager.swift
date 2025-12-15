//
//  ImageAPIManager.swift
//  locian
//
//  Created by vamshi krishna pinni on 24/10/25.
//

import Foundation

class ImageAPIManager: BaseAPIManagerProtocol {
    static let shared = ImageAPIManager()
    
    private init() {}
    
    // MARK: - Image Analysis
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
