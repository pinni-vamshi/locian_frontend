import Foundation
import WeatherKit
import CoreLocation

/// Service to handle retrieving the current weather conditions using Apple's WeatherKit.
/// Note: This requires the WeatherKit capability to be enabled in the Apple Developer portal and Xcode.
class WeatherServiceManager {
    static let shared = WeatherServiceManager()
    
    private init() {}
    
    /// Fetches the current weather condition for a given location.
    /// Returns a string corresponding to the backend API requirements (e.g., "rain", "clear", "cloudy").
    func fetchCurrentWeather(for location: CLLocation) async -> String {
        print("🌤️ [WeatherService] Initiating request for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            let condition = weather.currentWeather.condition
            let mappedString = mapConditionToString(condition: condition)
            print("✅ [WeatherService] Response received. Condition: \(condition), Mapped: \(mappedString)")
            return mappedString
        } catch {
            print("❌ [WeatherService] Error fetching weather: \(error)")
            return "unknown"
        }
    }
    
    /// Maps WeatherKit's exact condition enum to a normalized string for the backend payload
    private func mapConditionToString(condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear, .hot:
            return "clear"
            
        case .cloudy, .mostlyCloudy, .partlyCloudy:
            return "cloudy"
            
        case .drizzle, .rain, .sunShowers, .heavyRain, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms, .thunderstorms:
            return "rain"
            
        case .snow, .flurries, .heavySnow, .blizzard, .freezingDrizzle, .freezingRain, .sleet, .sunFlurries, .wintryMix:
            return "snow"
            
        case .hail:
            return "hail"
            
        case .foggy, .haze, .smoky, .breezy, .windy, .hurricane, .tropicalStorm:
            return "adverse"
            
        default:
            return "unknown"
        }
    }
}
