import SwiftUI
import Combine

extension AppStateManager {
    // MARK: - Image Analysis Methods
    func analyzeImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        
        // Check if we have a valid session token
        guard let sessionToken = authToken, !sessionToken.isEmpty else {
            completion(false)
            return
        }
        
        isAnalyzingImage = true
        
        // Convert to JPEG and remove metadata (keep original size)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            isAnalyzingImage = false
            completion(false)
            return
        }
        
        // Recreate UIImage from JPEG data to ensure metadata is removed
        guard let cleanedImage = UIImage(data: imageData) else {
            isAnalyzingImage = false
            completion(false)
            return
        }
        
        // Convert cleaned image back to JPEG data (ensures no metadata)
        guard let finalImageData = cleanedImage.jpegData(compressionQuality: 0.8) else {
            isAnalyzingImage = false
            completion(false)
            return
        }
        
        let base64String = finalImageData.base64EncodedString()
        let imageBase64 = "data:image/jpeg;base64,\(base64String)"
        
        // Get language codes from default language pair
        let userLanguage: String?
        let targetLanguage: String?
        
        if let defaultPair = userLanguagePairs.first(where: { $0.is_default }) {
            userLanguage = self.getLanguageCode(for: defaultPair.native_language)
            targetLanguage = self.getLanguageCode(for: defaultPair.target_language)
        } else {
            userLanguage = nil
            targetLanguage = nil
        }
        
        // Get current time for the request
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"  // e.g., "2:30 PM"
        let currentTime = timeFormatter.string(from: Date())
        
        // Get location coordinates
        let latitude = LocationManager.shared.latitude
        let longitude = LocationManager.shared.longitude
        
        let level = userLanguagePairs.first(where: { $0.is_default })?.user_level ?? "BEGINNER"
        
        // Create analysis request
        let request = ImageAnalysisRequest(
            session_token: sessionToken,
            image_base64: imageBase64,
            level: level,
            previous_places: nil,
            future_places: nil,
            user_language: userLanguage,
            target_language: targetLanguage,
            time: currentTime,
            latitude: latitude,
            longitude: longitude
        )
        
        
        // Call the image analysis API
        print("🔍 [IMAGE ANALYSIS] Starting request for place detection...")
        ImageAPIManager.shared.analyzeImage(request: request) { result in
            DispatchQueue.main.async {
                self.isAnalyzingImage = false
                
                switch result {
                case .success(let response):
                    if response.success {
                        print("✅ [IMAGE ANALYSIS] Success response received. RequestID: \(response.request_id ?? "N/A")")
                        
                        // Get place name and situations from response
                        if let analysisData = response.data, !analysisData.place_name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let trimmedPlaceName = analysisData.place_name.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            print("🚀 [API] FINAL HANDSHAKE: Decoding successful.")
                            print("   - Place: \(trimmedPlaceName)")
                            print("   - Moments Count: \(analysisData.moments_count)")
                            if let firstSection = analysisData.situations.first {
                                print("   - First 2 Moments (\(firstSection.category)): \(firstSection.moments.prefix(2).map { $0.text }.joined(separator: ", "))...")
                            }
                            
                            self.imageAnalysisResult = trimmedPlaceName
                            self.imageAnalysisSituations = analysisData.situations
                            completion(true)
                        } else {
                            print("⚠️ [IMAGE ANALYSIS] Response marked success but data/place_name is missing or empty.")
                            self.imageAnalysisResult = nil
                            self.imageAnalysisSituations = nil
                            completion(false)
                        }
                    } else {
                        print("❌ [IMAGE ANALYSIS] API Error: \(response.message ?? "Unknown error")")
                        self.imageAnalysisResult = nil
                        self.imageAnalysisSituations = nil
                        completion(false)
                    }
                case .failure(let error):
                    print("❌ [IMAGE ANALYSIS] Network/Decoding Failure: \(error.localizedDescription)")
                    // Error handled
                    self.imageAnalysisResult = nil
                    self.imageAnalysisSituations = nil
                    completion(false)
                }
            }
        }
    }
    
}
