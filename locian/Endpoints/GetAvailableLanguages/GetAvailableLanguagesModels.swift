import Foundation

// MARK: - Models for GET /api/system/languages/available

struct AvailableLanguagesResponse: Codable {
    let success: Bool?
    let message: String?
    let data: AvailableLanguagesData?
}

struct AvailableLanguagesData: Codable {
    let supported_combinations: [LanguageCombination]?
}

struct LanguageCombination: Codable {
    let native: CatalogLanguage
    let targets: [CatalogLanguage]
}

struct CatalogLanguage: Codable, Equatable {
    let code: String
    let english_name: String
    let native_name: String
    
    // Fallback dictionary map generator
    var toTuple: (english: String, native: String) {
        return (english_name, native_name)
    }
}
