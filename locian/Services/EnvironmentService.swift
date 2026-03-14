import Foundation
import Combine
import CoreLocation
import CoreMotion
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
    var motionState: String = "OFF"
    var activityType: String = "OFF"
    var stepCount: Int = 0
    var lightLevel: String = "OFF"
    var lightValue: Double = 0.0
    var decibels: Float = -160.0
    var weather: String = "OFF"
    var temperature: Double?
    
    var activeSensors: Set<SensorType> = []
}

class EnvironmentService: ObservableObject {
    static let shared = EnvironmentService()
    
    @Published var telemetry = EnvironmentTelemetry()
    
    private var cancellables = Set<AnyCancellable>()
    private var timers: [SensorType: Timer] = [:]
    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()
    
    private init() {
        setupLocationObserver()
        setupSoundObserver()
    }
    
    private func setupLocationObserver() {
        LocationManager.shared.$latitude
            .combineLatest(LocationManager.shared.$longitude)
            .sink { [weak self] lat, lng in
                guard let self = self, self.telemetry.activeSensors.contains(.gps) else { return }
                self.telemetry.latitude = lat
                self.telemetry.longitude = lng
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
        case .gps:
            LocationManager.shared.startContinuousTracking()
        case .motion:
            startMotionTimer()
            startActivityMonitoring()
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
            LocationManager.shared.stopUpdatingLocation()
            telemetry.latitude = nil
            telemetry.longitude = nil
        case .motion:
            activityManager.stopActivityUpdates()
            telemetry.motionState = "OFF"
            telemetry.activityType = "OFF"
            telemetry.stepCount = 0
        case .light:
            telemetry.lightLevel = "OFF"
            telemetry.lightValue = 0.0
        case .sound:
            AmbientSoundService.shared.stopListening()
            telemetry.decibels = -160.0
        case .weather:
            telemetry.weather = "OFF"
            telemetry.temperature = nil
        }
    }
    
    private func startMotionTimer() {
        timers[.motion]?.invalidate()
        timers[.motion] = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            let toDate = Date()
            let fromDate = toDate.addingTimeInterval(-10)
            
            self?.pedometer.queryPedometerData(from: fromDate, to: toDate) { data, error in
                guard let pedData = data else { return }
                let steps = pedData.numberOfSteps.intValue
                
                DispatchQueue.main.async {
                    self?.telemetry.stepCount = steps
                    if steps > 15 {
                        self?.telemetry.motionState = "RUNNING"
                    } else if steps > 2 {
                        self?.telemetry.motionState = "WALKING"
                    } else {
                        self?.telemetry.motionState = "STATIONARY"
                    }
                }
            }
        }
    }
    
    private func startLightTimer() {
        timers[.light]?.invalidate()
        timers[.light] = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            // DUPLICATED FORMULA (V4.2 EXP)
            let rawBrightness = UIScreen.main.brightness
            let mappedValue = -5.0 + (Double(rawBrightness) * 19.0)
            
            let status = mappedValue < 2 ? "DARK" : (mappedValue < 8 ? "INDOOR" : "BRIGHT")
            DispatchQueue.main.async {
                self?.telemetry.lightValue = mappedValue
                self?.telemetry.lightLevel = status
            }
        }
    }
    
    private func startActivityMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            var type = "STATIONARY"
            if activity.walking { type = "WALKING" }
            else if activity.running { type = "RUNNING" }
            else if activity.automotive { type = "DRIVING" }
            else if activity.cycling { type = "CYCLING" }
            
            DispatchQueue.main.async {
                self?.telemetry.activityType = type
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
            do {
                let weather = try await WeatherService.shared.weather(for: location)
                let condition = mapConditionToString(condition: weather.currentWeather.condition)
                let temp = weather.currentWeather.temperature.converted(to: .celsius).value
                
                DispatchQueue.main.async {
                    self.telemetry.weather = condition.uppercased()
                    self.telemetry.temperature = temp
                }
            } catch {
                print("❌ [EnvironmentService] Weather error: \(error)")
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
