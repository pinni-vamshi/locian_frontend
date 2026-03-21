import Foundation
import CoreLocation
import Combine
import UIKit

class AltitudeService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = AltitudeService()
    
    private let locationManager = CLLocationManager()
    private var completion: ((CLLocationDistance?) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Autonomous Alert Bridge (UIKit)
    private func showSettingsAlert() {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }
            
            let alert = UIAlertController(title: "Location Access Required", message: "Please enable location access in Settings to measure altitude.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            topVC.present(alert, animated: true)
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
    
    private func ensureLocationAccess(completion: @escaping (Bool) -> Void) {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let newStatus = self.locationManager.authorizationStatus
                completion(newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways)
            }
        case .denied, .restricted:
            self.showSettingsAlert()
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    /// On-Demand: Starts GPS, captures one altitude reading, stops immediately.
    func fetchAltitude(completion: @escaping (CLLocationDistance?) -> Void) {
        self.ensureLocationAccess { granted in
            guard granted else {
                completion(nil)
                return
            }
            self.completion = completion
            self.locationManager.startUpdatingLocation()
        }
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
