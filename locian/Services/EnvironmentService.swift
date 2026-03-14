import Foundation
import Combine
import CoreLocation
import UIKit
import WeatherKit

enum SensorType: String, CaseIterable {
    case gps = "GPS"
    case motion = "MOTION"
    case light = "LIGHT"
    case sound = "SOUND"
    case weather = "WEATHER"
}

struct EnvironmentTelemetry {
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var speed: Double?
    var velocity: Double = 0.0
    var lightLevel: String = "OFF"
    var lightValue: Double = 0.0
    var decibels: Float = -160.0
    var weather: String = "OFF"
    var temperature: Double?
    var pressure: Double?
    var envScore: Double?
    
    var activeSensors: Set<SensorType> = []
}

class EnvironmentService: ObservableObject {
    static let shared = EnvironmentService()
    
    @Published var telemetry = EnvironmentTelemetry()
    
    private var cancellables = Set<AnyCancellable>()
    private var timers: [SensorType: Timer] = [:]
    
    private init() {
        setupLocationObserver()
        setupSoundObserver()
    }
    
    private func setupLocationObserver() {
        LocationManager.shared.$latitude
            .combineLatest(LocationManager.shared.$longitude, LocationManager.shared.$altitude, LocationManager.shared.$speed)
            .sink { [weak self] lat, lng, alt, spd in
                guard let self = self else { return }
                
                // Update GPS Telemetry
                if self.telemetry.activeSensors.contains(.gps) {
                    self.telemetry.latitude = lat
                    self.telemetry.longitude = lng
                    self.telemetry.altitude = alt
                    self.telemetry.speed = spd
                }
                
                // Update Velocity (Bridged from GPS Speed)
                // Always update velocity if motion sensor is "active" (even though it's just GPS)
                if self.telemetry.activeSensors.contains(.motion) {
                    let currentSpeedKMH = max(0, (spd ?? 0) * 3.6)
                    self.telemetry.velocity = currentSpeedKMH
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSoundObserver() {
        AmbientSoundService.shared.$currentDecibels
            .sink { [weak self] db in
                guard let self = self, self.telemetry.activeSensors.contains(.sound) else { return }
                self.telemetry.decibels = db
            }
            .store(in: &cancellables)
    }
    
    func toggleSensor(_ sensor: SensorType) {
        if telemetry.activeSensors.contains(sensor) {
            telemetry.activeSensors.remove(sensor)
            stopSensorInternal(sensor)
        } else {
            telemetry.activeSensors.insert(sensor)
            startSensorInternal(sensor)
        }
    }
    
    private func startSensorInternal(_ sensor: SensorType) {
        switch sensor {
        case .gps, .motion:
            // Both now rely on LocationManager continuous tracking
            LocationManager.shared.startContinuousTracking()
        case .light:
            startLightTimer()
        case .sound:
            AmbientSoundService.shared.startListening()
        case .weather:
            startWeatherTimer()
        }
    }
    
    private func stopSensorInternal(_ sensor: SensorType) {
        timers[sensor]?.invalidate()
        timers[sensor] = nil
        
        switch sensor {
        case .gps:
            // Only stop coordinates if Motion is ALSO off
            if !telemetry.activeSensors.contains(.motion) {
                LocationManager.shared.stopUpdatingLocation()
            }
            telemetry.latitude = nil
            telemetry.longitude = nil
        case .motion:
            // Only stop speed tracking if GPS is ALSO off
            if !telemetry.activeSensors.contains(.gps) {
                LocationManager.shared.stopUpdatingLocation()
            }
            telemetry.velocity = 0.0
        case .light:
            telemetry.lightLevel = "OFF"
            telemetry.lightValue = 0.0
        case .sound:
            AmbientSoundService.shared.stopListening()
            telemetry.decibels = -160.0
        case .weather:
            telemetry.weather = "OFF"
            telemetry.temperature = nil
            telemetry.humidity = nil
            telemetry.envScore = nil
        }
    }
    
    private func startLightTimer() {
        timers[.light]?.invalidate()
        timers[.light] = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            let rawBrightness = UIScreen.main.brightness
            let mappedValue = -5.0 + (Double(rawBrightness) * 19.0)
            let status = mappedValue < 2 ? "DARK" : (mappedValue < 8 ? "INDOOR" : "BRIGHT")
            DispatchQueue.main.async {
                self?.telemetry.lightValue = mappedValue
                self?.telemetry.lightLevel = status
            }
        }
    }
    
    private func startWeatherTimer() {
        timers[.weather]?.invalidate()
        timers[.weather] = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.fetchWeatherInternal()
        }
        fetchWeatherInternal()
    }
    
    private func fetchWeatherInternal() {
        guard let location = LocationManager.shared.currentLocation else { return }
        Task {
            let (condition, temp, pressure) = await WeatherServiceManager.shared.fetchWeatherData(for: location)
            
            // MULTI-FACTOR SCORE (V5.3)
            // Combine Temperature (°C) and Barometric Pressure (hPa)
            // Formula: temp + (pressure / 100) -> Custom Environmental Value
            let score = temp + (pressure / 100.0)
            
            DispatchQueue.main.async {
                self.telemetry.weather = condition.uppercased()
                self.telemetry.temperature = temp
                self.telemetry.pressure = pressure
                self.telemetry.envScore = score
            }
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
