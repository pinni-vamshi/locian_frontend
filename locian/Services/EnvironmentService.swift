import Foundation
import Combine
import CoreLocation
import CoreMotion

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
    var stepCount: Int = 0
    var lightLevel: String = "OFF"
    var lightValue: Double = 0.0
    var decibels: Float = -160.0
    
    var activeSensors: Set<SensorType> = []
}

class EnvironmentService: ObservableObject {
    static let shared = EnvironmentService()
    
    @Published var telemetry = EnvironmentTelemetry()
    
    private var cancellables = Set<AnyCancellable>()
    private var timers: [SensorType: Timer] = [:]
    private let pedometer = CMPedometer()
    
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
            telemetry.stepCount = 0
        case .light:
            telemetry.lightLevel = "OFF"
            telemetry.lightValue = 0.0
        case .sound:
            AmbientSoundService.shared.stopListening()
            telemetry.decibels = -160.0
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
}
