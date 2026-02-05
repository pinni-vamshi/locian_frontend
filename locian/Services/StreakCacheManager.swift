//
//  StreakCacheManager.swift
//  locian
//
//  Created for caching streak data
//

import Foundation

struct StreakData: Codable {
    let target_language: String
    let practice_dates: [String]
    let cached_at: Date
}

class StreakCacheManager {
    static let shared = StreakCacheManager()
    private let cacheKeyPrefix = "streak_data_"
    
    private init() {}
    
    // Save streak data for a target language
    func saveStreakData(targetLanguage: String, practiceDates: [String]) {
        let data = StreakData(
            target_language: targetLanguage,
            practice_dates: practiceDates,
            cached_at: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            let key = "\(cacheKeyPrefix)\(targetLanguage)"
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // Load streak data for a target language
    func loadStreakData(targetLanguage: String) -> StreakData? {
        let key = "\(cacheKeyPrefix)\(targetLanguage)"
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        if let decoded = try? JSONDecoder().decode(StreakData.self, from: data) {
            return decoded
        }
        
        return nil
    }
    
    // Check if cached data exists
    func hasCachedData(targetLanguage: String) -> Bool {
        return loadStreakData(targetLanguage: targetLanguage) != nil
    }
    
    // Clear cache for a target language
    func clearCache(targetLanguage: String) {
        let key = "\(cacheKeyPrefix)\(targetLanguage)"
        UserDefaults.standard.removeObject(forKey: key)
    }
}

