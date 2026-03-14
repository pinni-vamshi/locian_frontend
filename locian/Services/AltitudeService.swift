import Foundation
import CoreLocation
import Combine

class AltitudeService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = AltitudeService()
    
    private let locationManager = CLLocationManager()
    private var completion: ((CLLocationDistance?) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// On-Demand: Starts GPS, captures one altitude reading, stops immediately.
    func fetchAltitude(completion: @escaping (CLLocationDistance?) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Got the reading — stop immediately
        locationManager.stopUpdatingLocation()
        let altitude = location.altitude
        DispatchQueue.main.async {
            self.completion?(altitude)
            self.completion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        DispatchQueue.main.async {
            self.completion?(nil)
            self.completion = nil
        }
    }
}

