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

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
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
    @Published var locationError: Error?
    
    private var locationCompletions: [((Result<CLLocation, Error>) -> Void)] = []
    private let locationLock = NSLock()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Don't access authorizationStatus directly in init to avoid UI blocking
        // Initialize with actual status from the manager instance
        // This prevents race conditions where checking status immediately after init returns .notDetermined
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Permissions
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Get Current Location
    func getCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        // CRITICAL: Check if user has enabled location tracking in Settings
        guard AppStateManager.shared.isLocationTrackingEnabled else {
            locationStatus = .denied
            let error = NSError(domain: "LocationManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location tracking is disabled in Settings"])
            print("⚠️ [LOCATION] Location tracking is DISABLED in Settings. Blocking location access.")
            completion(.failure(error))
            return
        }
        
        locationStatus = .searching
        // Check authorization using published property (safe, no main thread blocking)
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            let error = NSError(domain: "LocationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location permission not granted"])
            completion(.failure(error))
            return
        }
        
        // Check if location services are enabled (move to background thread to avoid UI blocking)
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
                
                // Start updating location
                self.locationManager.startUpdatingLocation()
                
                // Set timeout (10 seconds)
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
        
        
        // Call completions if waiting
        locationLock.lock()
        let completions = locationCompletions
        locationCompletions.removeAll()
        locationLock.unlock()
        
        if !completions.isEmpty {
            completions.forEach { $0(.success(location)) }
            locationManager.stopUpdatingLocation()
        }
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
            break
        case .denied, .restricted:
            locationStatus = .denied
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
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
    
    private var currentLanguageCode: String {
        let nativeName = AppStateManager.shared.nativeLanguage
        return NativeLanguageMapping.shared.getCode(for: nativeName) ?? "en"
    }
    
    func fetchNearbyPlaces(completion: @escaping ([NearbyAmbience]) -> Void) {
        print("📍 [NEARBY] Starting fresh fetchNearbyPlaces (on-demand)...")
        locationStatus = .searching
        
        // CRITICAL: Check if user has enabled location tracking in Settings
        guard AppStateManager.shared.isLocationTrackingEnabled else {
            locationStatus = .denied
            print("⚠️ [NEARBY] Location tracking is DISABLED. Blocking access.")
            completion([])
            return
        }
        
        // ALWAYS trigger a fresh fetch to ensure zero staleness/persistence
        print("📍 [NEARBY] Requesting dynamic GPS update...")
        getCurrentLocation { [weak self] result in
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
        
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: 10000) // Increased to 10km
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
                completion([]) // Skip fallback for now to focus on MKPOI structure
                return
            }
            
            guard let response = response else {
                completion([])
                return
            }
            
            if response.mapItems.isEmpty {
                 completion([])
                 return
            }
            
            // Sort and uniquely name
            let sortedItems = response.mapItems.sorted { item1, item2 in
                let dist1 = item1.placemark.location?.distance(from: location) ?? Double.greatestFiniteMagnitude
                let dist2 = item2.placemark.location?.distance(from: location) ?? Double.greatestFiniteMagnitude
                return dist1 < dist2
            }
            
            var ambience: [NearbyAmbience] = []
            for item in sortedItems {
                guard let name = item.name, let loc = item.placemark.location else { continue }
                
                // 🧠 Semantic Snapping: Harvest URL and Tags for anchoring
                let rawCat = item.pointOfInterestCategory?.rawValue
                let itemURL = item.url?.absoluteString
                let itemTags = item.placemark.areasOfInterest
                
                let snappedCategory = SemanticSnappingService.shared.resolveSemanticCategory(
                    name: name,
                    rawCategory: rawCat,
                    url: itemURL,
                    tags: itemTags
                )
                
                let vector = EmbeddingService.getVector(for: name, languageCode: self.currentLanguageCode)
                
                // Use coordinate hash as stable identifier
                let distance = loc.distance(from: location)
                let stableID = "\(loc.coordinate.latitude)_\(loc.coordinate.longitude)"
                ambience.append(NearbyAmbience(
                    id: stableID,
                    name: name,
                    category: snappedCategory,
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude,
                    distance: distance,
                    vector: vector,
                    url: itemURL,
                    tags: itemTags
                ))
            }
            
            DispatchQueue.main.async {
                self.locationStatus = .found
                print("🎨 [NEARBY] Generated ambience for \(ambience.count) places.")
                completion(ambience)
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
            
            // Extract meaningful location names
            if let name = place.name { results.append(name) }
            if let thoro = place.thoroughfare { results.append(thoro) }
            if let subLoc = place.subLocality { results.append(subLoc) }
            if let loc = place.locality { results.append(loc) }
            if let inlandWater = place.inlandWater { results.append(inlandWater) }
            if let interest = place.areasOfInterest?.first { results.append(interest) }
            
            var ambience: [NearbyAmbience] = []
            for name in Array(Set(results)).prefix(8) {
                let snappedCategory = SemanticSnappingService.shared.resolveSemanticCategory(name: name, rawCategory: nil, url: nil, tags: nil)
                if let vector = EmbeddingService.getVector(for: name, languageCode: self.currentLanguageCode) {
                    ambience.append(NearbyAmbience(
                        id: "\(location.coordinate.latitude)_\(location.coordinate.longitude)_\(name)",
                        name: name,
                        category: snappedCategory,
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        distance: 0,
                        vector: vector,
                        url: nil,
                        tags: nil
                    ))
                }
            }
            completion(ambience)
        }
    }
    
}
