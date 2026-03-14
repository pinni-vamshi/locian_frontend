import Foundation
import WeatherKit
import CoreLocation

/// Service to handle retrieving the current weather conditions using Apple's WeatherKit.
/// Note: This requires the WeatherKit capability to be enabled in the Apple Developer portal and Xcode.
class WeatherServiceManager {
    static let shared = WeatherServiceManager()
    
    private init() {}
    
    /// Fetches the current raw temperature (Celsius) for a given location.
    func fetchCurrentTemperature(for location: CLLocation) async -> Double {
        print("🌤️ [WeatherService] Initiating request for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            let temp = weather.currentWeather.temperature.converted(to: .celsius).value
            print("✅ [WeatherService] Temperature received: \(temp)°C")
            return temp
        } catch {
            print("❌ [WeatherService] Error fetching weather: \(error)")
            return 0.0
        }
    }
}
