import Foundation
import WeatherKit
import CoreLocation

/// Service to handle retrieving the current weather conditions using Apple's WeatherKit.
/// Note: This requires the WeatherKit capability to be enabled in the Apple Developer portal and Xcode.
class WeatherServiceManager {
    static let shared = WeatherServiceManager()
    
    private init() {}
    
    /// Fetches the current raw temperature and condition for a given location.
    func fetchWeatherData(for location: CLLocation) async -> (temp: Double, condition: String) {
        print("🌤️ [WeatherService] Initiating request for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            let temp = weather.currentWeather.temperature.converted(to: .celsius).value
            let condition = mapConditionToString(condition: weather.currentWeather.condition)
            print("✅ [WeatherService] Temperature received: \(temp)°C, Condition: \(condition)")
            return (temp, condition)
        } catch {
            print("❌ [WeatherService] Error fetching weather: \(error)")
            return (0.0, "unknown")
        }
    }
    
    private func mapConditionToString(condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear, .hot: return "clear"
        case .cloudy, .mostlyCloudy, .partlyCloudy: return "cloudy"
        case .drizzle, .rain, .sunShowers, .heavyRain, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms, .thunderstorms: return "rain"
        case .snow, .flurries, .heavySnow, .blizzard, .freezingDrizzle, .freezingRain, .sleet, .sunFlurries, .wintryMix: return "snow"
        case .hail: return "hail"
        case .foggy, .haze, .smoky, .breezy, .windy, .hurricane, .tropicalStorm: return "adverse"
        default: return "unknown"
        }
    }
}
