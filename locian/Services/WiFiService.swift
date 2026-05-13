import Foundation
import NetworkExtension
import CoreLocation
import Combine
import Network

// For IP and Gateway retrieval
import Darwin

class WiFiService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = WiFiService()
    static let wifiIdentityChangedNotification = Notification.Name("wifiIdentityChangedNotification")
    
    @Published var currentSSID: String? = nil {
        didSet { if oldValue != currentSSID { broadcastWifiIdentity() } }
    }
    @Published var currentBSSID: String? = nil {
        didSet { if oldValue != currentBSSID { broadcastWifiIdentity() } }
    }
    @Published var connectionType: String = "unknown"
    @Published var internalIP: String? = nil
    @Published var gatewayIP: String? = nil
    
    private func broadcastWifiIdentity() {
        var info: [String: String] = [:]
        if let s = currentSSID { info["ssid"] = s }
        if let b = currentBSSID { info["bssid"] = b }
        info["connection_type"] = connectionType
        NotificationCenter.default.post(
            name: Self.wifiIdentityChangedNotification,
            object: nil,
            userInfo: info
        )
    }
    
    private let locationManager = CLLocationManager()
    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private override init() {
        super.init()
        locationManager.delegate = self
        setupPathMonitor()
    }
    
    private func setupPathMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = "WiFi"
                    self?.fetchWiFiDetails()
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = "Cellular"
                    self?.clearWiFiDetails()
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = "Wired"
                } else {
                    self?.connectionType = "Other"
                }
                
                self?.internalIP = self?.getIPAddress()
                self?.gatewayIP = self?.getGatewayAddress()
            }
        }
        pathMonitor.start(queue: queue)
    }
    
    private func clearWiFiDetails() {
        self.currentSSID = nil
        self.currentBSSID = nil
    }
    
    func fetchWiFiDetails() {
        // iOS 14+ requires Precise Location to view SSIDs/BSSIDs
        // Never request permission here — let onboarding handle it
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            NEHotspotNetwork.fetchCurrent { network in
                DispatchQueue.main.async {
                    self.currentSSID = network?.ssid
                    self.currentBSSID = network?.bssid
                }
            }
        }
    }
    
    // MARK: - IP Retrieval
    private func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface!.ifa_name)
                    if name == "en0" || name == "pdp_ip0" { // en0 is wifi, pdp_ip0 is cellular
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface!.ifa_addr, socklen_t(interface!.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    // MARK: - Gateway Retrieval (Best Effort)
    private func getGatewayAddress() -> String? {
        // Since <net/route.h> is not exposed in Swift natively without a bridging header,
        // and sysctl with NET_RT_DUMP relies on complex routing socket structures, 
        // we safely bypass gateway fetching to maintain Swift 6 build compatibility.
        return nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            fetchWiFiDetails()
        }
    }
}
