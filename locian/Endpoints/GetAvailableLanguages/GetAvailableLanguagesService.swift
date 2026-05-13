import Foundation
import Combine

class GetAvailableLanguagesService: ObservableObject {
    static let shared = GetAvailableLanguagesService()
    
    @Published var availableCombinations: [LanguageCombination] = []
    @Published var isLoading: Bool = false
    
    private init() {}
    
    /// Fetches the global supported combinations catalog from the backend.
    func fetch(completion: ((Bool) -> Void)? = nil) {
        self.isLoading = true
        
        let endpoint = "/api/system/languages/available"
        print("🌐 [GetAvailableLanguagesService] Fetching catalog from \(endpoint)")
        
        BaseAPIManager.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil
        ) { [weak self] (result: Result<AvailableLanguagesResponse, Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    if let combinations = response.data?.supported_combinations {
                        self?.availableCombinations = combinations
                        
                        // Push immediately into the existing mappings to hydrate the rest of the app dynamically.
                        TargetLanguageMapping.shared.update(with: combinations)
                        NativeLanguageMapping.shared.update(with: combinations)
                        
                        print("✅ [GetAvailableLanguagesService] Loaded \(combinations.count) Native structures.")
                        completion?(true)
                    } else {
                        print("⚠️ [GetAvailableLanguagesService] Success response but nil supported_combinations.")
                        completion?(false)
                    }
                    
                case .failure(let error):
                    print("❌ [GetAvailableLanguagesService] Failed to load catalog: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }
}
