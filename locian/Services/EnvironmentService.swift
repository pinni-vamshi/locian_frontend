import Foundation
import Combine
import CoreLocation

enum SensorType: String, CaseIterable {
    case gps = "GPS"
    case motion = "MOTION"
    case light = "LIGHT"
    case sound = "SOUND"
}

struct EnvironmentTelemetry {
    var latitude: Double?
    var longitude: Double?
    var motionState: String = "OFF"
    var lightLevel: String = "OFF"
    var decibels: Float = -160.0
    
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
            // LocationManager is already active or triggered by demand
            // We just let the observer catch it.
            break
        case .motion:
            startMotionTimer()
        case .light:
            startLightTimer()
        case .sound:
            AmbientSoundService.shared.startListening()
        }
    }
    
    private func stopSensorInternal(_ sensor: SensorType) {
        timers[sensor]?.invalidate()
        timers[sensor] = nil
        
        switch sensor {
        case .gps:
            telemetry.latitude = nil
            telemetry.longitude = nil
        case .motion:
            telemetry.motionState = "OFF"
        case .light:
            telemetry.lightLevel = "OFF"
        case .sound:
            AmbientSoundService.shared.stopListening()
            telemetry.decibels = -160.0
        }
    }
    
    private func startMotionTimer() {
        timers[.motion]?.invalidate()
        timers[.motion] = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            MotionService.shared.fetchCurrentMotionState { motion in
                DispatchQueue.main.async {
                    self?.telemetry.motionState = motion.uppercased()
                }
            }
        }
    }
    
    private func startLightTimer() {
        timers[.light]?.invalidate()
        timers[.light] = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            let level = AmbientLightService.shared.fetchLightLevel()
            let status = level < 2 ? "DARK" : (level < 8 ? "INDOOR" : "BRIGHT")
            DispatchQueue.main.async {
                self?.telemetry.lightLevel = status
            }
        }
    }
}
