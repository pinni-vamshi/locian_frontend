//
//  LocationManager.swift
//  locian
//
//  Manages device location and provides latitude/longitude
//

import Foundation
import CoreLocation
import Combine
import MapKit
import UIKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    static let intentRegionDidEnterNotification = Notification.Name("intentRegionDidEnterNotification")
    static let intentSignificantChangeNotification = Notification.Name("intentSignificantChangeNotification")
    
    let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    enum LocationStatus: String {
        case idle = "IDLE"
        case searching = "SEARCHING"
        case found = "LOCATION_FOUND"
        case denied = "PERMISSION_DENIED"
        case timeout = "TIMEOUT_EXCEEDED"
        case error = "SIGNAL_ERROR"
    }
    @Published var locationStatus: LocationStatus = .idle
    @Published var currentLocation: CLLocation?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var altitude: Double?
    @Published var speed: Double?
    @Published var locationError: Error?
    
    private var locationCompletions: [((Result<CLLocation, Error>) -> Void)] = []
    private let locationLock = NSLock()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Autonomous Alert Bridge (UIKit)
    private func showSettingsAlert() {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }
            
            let alert = UIAlertController(title: "Location Access Required", message: "Please enable location access in Settings to find nearby places.", preferredStyle: .alert)
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

    // MARK: - Permissions
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func ensureLocationAccess(completion: @escaping (Bool) -> Void) {
        let status = self.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let newStatus = self.authorizationStatus
                completion(newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways)
            }
        case .denied, .restricted:
            self.showSettingsAlert()
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Get Current Location
    func getCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        guard AppStateManager.shared.isLocationTrackingEnabled else {
            locationStatus = .denied
            let error = NSError(domain: "LocationManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location tracking is disabled in Settings"])
            print("⚠️ [LOCATION] Location tracking is DISABLED in Settings. Blocking location access.")
            completion(.failure(error))
            return
        }
        
        locationStatus = .searching
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            let error = NSError(domain: "LocationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location permission not granted"])
            completion(.failure(error))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard CLLocationManager.locationServicesEnabled() else {
                let error = NSError(domain: "LocationManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Location services are disabled"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            DispatchQueue.main.async {
                self.locationLock.lock()
                self.locationCompletions.append(completion)
                self.locationLock.unlock()
                
                self.locationManager.startUpdatingLocation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    self.locationLock.lock()
                    if !self.locationCompletions.isEmpty {
                        let completions = self.locationCompletions
                        self.locationCompletions.removeAll()
                        self.locationLock.unlock()
                        
                        self.locationManager.stopUpdatingLocation()
                        let error = NSError(domain: "LocationManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location request timed out"])
                        completions.forEach { $0(.failure(error)) }
                    } else {
                        self.locationLock.unlock()
                    }
                }
            }
        }
    }
    
    // MARK: - Continuous Tracking
    func startContinuousTracking() {
        locationManager.startUpdatingLocation()
    }

    // MARK: - Stop Updating Location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - MEMORY WIPE (Zero Persistence)
    func clearLocationMemory() {
        print("🚮 [LOCATION] Wiping all coordinates from memory.")
        self.currentLocation = nil
        self.latitude = nil
        self.longitude = nil
        self.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        altitude = location.altitude
        speed = location.speed
        
        locationLock.lock()
        let completions = locationCompletions
        locationCompletions.removeAll()
        locationLock.unlock()
        
        if !completions.isEmpty {
            completions.forEach { $0(.success(location)) }
            locationManager.stopUpdatingLocation()
        }
        
        guard isIntentMonitoringEnabled else { return }
        let now = Date()
        if let last = lastSignificantBroadcastAt, now.timeIntervalSince(last) < 120 {
            return
        }
        lastSignificantBroadcastAt = now
        NotificationCenter.default.post(
            name: Self.intentSignificantChangeNotification,
            object: nil,
            userInfo: [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "speed": location.speed,
                "course": location.course,
                "horizontalAccuracy": location.horizontalAccuracy
            ]
        )
        print("📍 [LocationManager] Significant location event broadcast.")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        
        locationLock.lock()
        let completions = locationCompletions
        locationCompletions.removeAll()
        locationLock.unlock()
        
        completions.forEach { $0(.failure(error)) }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = .idle
        case .denied, .restricted:
            locationStatus = .denied
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard isIntentMonitoringEnabled else { return }
        guard region.identifier.hasPrefix(intentRegionPrefix) else { return }
        
        var userInfo: [String: Any] = ["regionId": region.identifier]
        if let circular = region as? CLCircularRegion {
            userInfo["latitude"] = circular.center.latitude
            userInfo["longitude"] = circular.center.longitude
            userInfo["radius"] = circular.radius
        }
        
        NotificationCenter.default.post(
            name: Self.intentRegionDidEnterNotification,
            object: nil,
            userInfo: userInfo
        )
        print("📍 [LocationManager] Entered monitored intent region: \(region.identifier)")
    }
    
    // MARK: - Nearby Places
    struct NearbyAmbience: Codable, Hashable, Identifiable {
        let id: String
        let name: String
        let category: String?
        let latitude: Double
        let longitude: Double
        let distance: Double
        let vector: [Double]?
        let url: String?
        let tags: [String]?
    }
    
    private var activeSearch: MKLocalSearch?
    private let searchLock = NSLock()
    private let intentRegionPrefix = "intent_geo_"
    private var isIntentMonitoringEnabled = false
    private var lastSignificantBroadcastAt: Date?
    
    private var currentLanguageCode: String {
        let nativeName = AppStateManager.shared.nativeLanguage
        return NativeLanguageMapping.shared.getCode(for: nativeName) ?? "en"
    }
    
    struct IntentMonitoringRegion {
        let id: String
        let latitude: Double
        let longitude: Double
        let radiusMeters: Double
    }
    
    func enableIntentEventMonitoring(regions: [IntentMonitoringRegion]) {
        guard AppStateManager.shared.isLocationTrackingEnabled else {
            print("⚠️ [LocationManager] Intent monitoring skipped: location tracking disabled.")
            return
        }
        
        isIntentMonitoringEnabled = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        
        if authorizationStatus == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        clearIntentRegions()
        
        // Use a wider "approach ring" so notifications can fire *before* arrival.
        // The NotificationManager computes distance inside the ring to bucket
        // the event into pre-arrival (outer band) vs in-place (inner band).
        let boundedRegions = Array(regions.prefix(20))
        for region in boundedRegions {
            let center = CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude)
            let monitored = CLCircularRegion(
                center: center,
                radius: max(150, min(region.radiusMeters, 400)),
                identifier: "\(intentRegionPrefix)\(region.id)"
            )
            monitored.notifyOnEntry = true
            monitored.notifyOnExit = false
            locationManager.startMonitoring(for: monitored)
        }
        
        locationManager.startMonitoringSignificantLocationChanges()
        print("📍 [LocationManager] Intent monitoring enabled. regions=\(boundedRegions.count)")
    }
    
    func disableIntentEventMonitoring() {
        isIntentMonitoringEnabled = false
        locationManager.stopMonitoringSignificantLocationChanges()
        clearIntentRegions()
        print("📍 [LocationManager] Intent monitoring disabled.")
    }
    
    private func clearIntentRegions() {
        for region in locationManager.monitoredRegions where region.identifier.hasPrefix(intentRegionPrefix) {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func fetchNearbyPlaces(completion: @escaping ([NearbyAmbience]) -> Void) {
        print("📍 [NEARBY] Starting fresh fetchNearbyPlaces (on-demand)...")
        locationStatus = .searching
        
        guard AppStateManager.shared.isLocationTrackingEnabled else {
            locationStatus = .denied
            print("⚠️ [NEARBY] Location tracking is DISABLED. Blocking access.")
            completion([])
            return
        }
        
        print("📍 [NEARBY] Requesting dynamic GPS update...")
        self.ensureLocationAccess { [weak self] granted in
            guard granted else {
                print("⚠️ [NEARBY] Location permission denied. Cannot fetch nearby places.")
                completion([])
                return
            }
            self?.getCurrentLocation { result in
                switch result {
                case .success(let loc):
                    print("📍 [NEARBY] Success getting fresh location: \(loc.coordinate)")
                    self?.performLocalSearch(location: loc, completion: completion)
                case .failure(let error):
                    print("❌ [NEARBY] Failed to get fresh location: \(error.localizedDescription)")
                    self?.locationStatus = .error
                    completion([])
                }
            }
        }
    }
    
    func cancelSearch() {
        searchLock.lock()
        defer { searchLock.unlock() }
        
        if let search = activeSearch {
            print("🛑 [NEARBY] Explicitly canceling active MapKit search.")
            search.cancel()
            activeSearch = nil
        }
    }
    
    private func performLocalSearch(location: CLLocation, completion: @escaping ([NearbyAmbience]) -> Void) {
        print("📍 [NEARBY] Performing MKLocalPointsOfInterestRequest...")
        
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: 100)
        request.pointOfInterestFilter = .includingAll
        
        searchLock.lock()
        let search = MKLocalSearch(request: request)
        self.activeSearch = search
        searchLock.unlock()
        
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            self.searchLock.lock()
            self.activeSearch = nil
            self.searchLock.unlock()
            
            if let error = error {
                print("❌ [NEARBY] MapKit Search Error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let response = response, !response.mapItems.isEmpty else {
                completion([])
                return
            }
            
            let sortedItems = response.mapItems.sorted { item1, item2 in
                let dist1 = item1.placemark.location?.distance(from: location) ?? Double.greatestFiniteMagnitude
                let dist2 = item2.placemark.location?.distance(from: location) ?? Double.greatestFiniteMagnitude
                return dist1 < dist2
            }

            let languageCode = self.currentLanguageCode

            // ─────────────────────────────────────────────────────────────
            // FIX: Process all places CONCURRENTLY instead of one-by-one.
            // resolveSemanticCategory and EmbeddingService have no shared
            // mutable state, so parallel calls are safe.
            // ─────────────────────────────────────────────────────────────
            var ambience: [NearbyAmbience?] = Array(repeating: nil, count: sortedItems.count)

            DispatchQueue.concurrentPerform(iterations: sortedItems.count) { i in
                let item = sortedItems[i]
                guard let name = item.name, let loc = item.placemark.location else { return }

                let rawCat  = item.pointOfInterestCategory?.rawValue
                let itemURL = item.url?.absoluteString
                let itemTags = item.placemark.areasOfInterest

                print("🌾 [LocationManager] Harvested for '\(name)': URL: \(itemURL != nil), Tags: \(itemTags?.count ?? 0)")

                let snappedCategory = SemanticSnappingService.shared.resolveSemanticCategory(
                    name: name,
                    rawCategory: rawCat,
                    url: itemURL,
                    tags: itemTags
                )

                let vector   = EmbeddingService.getVector(for: name, languageCode: languageCode)
                let distance = loc.distance(from: location)
                let stableID = "\(loc.coordinate.latitude)_\(loc.coordinate.longitude)"

                // Writing to a unique index — no race condition
                ambience[i] = NearbyAmbience(
                    id: stableID,
                    name: name,
                    category: snappedCategory,
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude,
                    distance: distance,
                    vector: vector,
                    url: itemURL,
                    tags: itemTags
                )
            }

            let finalAmbience = ambience.compactMap { $0 }

            DispatchQueue.main.async {
                self.locationStatus = .found
                print("🎨 [NEARBY] Generated ambience for \(finalAmbience.count) places.")
                completion(finalAmbience)
            }
        }
    }
    
    private func performGeocoderFallback(location: CLLocation, completion: @escaping ([NearbyAmbience]) -> Void) {
        print("📍 [NEARBY] Starting Geocoder fallback...")
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let place = placemarks?.first, error == nil else {
                print("❌ [NEARBY] Geocoder failed: \(error?.localizedDescription ?? "Unknown")")
                completion([])
                return
            }
            
            var results: [String] = []
            
            if let name = place.name              { results.append(name) }
            if let thoro = place.thoroughfare     { results.append(thoro) }
            if let subLoc = place.subLocality     { results.append(subLoc) }
            if let loc = place.locality           { results.append(loc) }
            if let inlandWater = place.inlandWater { results.append(inlandWater) }
            if let interest = place.areasOfInterest?.first { results.append(interest) }
            
            let languageCode = self.currentLanguageCode
            let uniqueResults = Array(Set(results)).prefix(8)
            var ambience: [NearbyAmbience?] = Array(repeating: nil, count: uniqueResults.count)

            // ─────────────────────────────────────────────────────────────
            // FIX: Same concurrent pattern applied to geocoder fallback
            // ─────────────────────────────────────────────────────────────
            let resultArray = Array(uniqueResults)
            DispatchQueue.concurrentPerform(iterations: resultArray.count) { i in
                let name = resultArray[i]
                let snappedCategory = SemanticSnappingService.shared.resolveSemanticCategory(
                    name: name, rawCategory: nil, url: nil, tags: nil
                )
                if let vector = EmbeddingService.getVector(for: name, languageCode: languageCode) {
                    ambience[i] = NearbyAmbience(
                        id: "\(location.coordinate.latitude)_\(location.coordinate.longitude)_\(name)",
                        name: name,
                        category: snappedCategory,
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        distance: 0,
                        vector: vector,
                        url: nil,
                        tags: nil
                    )
                }
            }

            completion(ambience.compactMap { $0 })
        }
    }
}