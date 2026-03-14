import Foundation
import NetworkExtension
import CoreLocation
import Combine

class WiFiService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = WiFiService()
    
    @Published var currentSSID: String? = nil
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func fetchWiFiName() {
        // iOS 14+ STRICTLY requires Location Permissions to view WiFi SSIDs (to prevent silent location tracking)
        // You also MUST add the "Access WiFi Information" capability in Xcode Signing & Capabilities
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            NEHotspotNetwork.fetchCurrent { network in
                DispatchQueue.main.async {
                    self.currentSSID = network?.ssid
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            fetchWiFiName()
        }
    }
}
