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
    @Published var currentLocation: CLLocation?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var locationError: Error?
    
    private var locationCompletion: ((Result<CLLocation, Error>) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Don't access authorizationStatus directly in init to avoid UI blocking
        // Initialize with actual status from the manager instance
        // This prevents race conditions where checking status immediately after init returns .notDetermined
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Get Current Location
    func getCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        // CRITICAL: Check if user has enabled location tracking in Settings
        guard AppStateManager.shared.isLocationTrackingEnabled else {
            let error = NSError(domain: "LocationManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location tracking is disabled in Settings"])
            print("⚠️ [LOCATION] Location tracking is DISABLED in Settings. Blocking location access.")
            completion(.failure(error))
            return
        }
        
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
                self.locationCompletion = completion
                
                // Start updating location
                self.locationManager.startUpdatingLocation()
                
                // Set timeout (10 seconds)
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    if self.locationCompletion != nil {
                        self.locationManager.stopUpdatingLocation()
                        let error = NSError(domain: "LocationManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location request timed out"])
                        self.locationCompletion?(.failure(error))
                        self.locationCompletion = nil
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
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        
        // Call completion if waiting
        if let completion = locationCompletion {
            completion(.success(location))
            locationCompletion = nil
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        
        if let completion = locationCompletion {
            completion(.failure(error))
            locationCompletion = nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .denied, .restricted:
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Nearby Places
    func fetchNearbyPlaces(completion: @escaping ([String]) -> Void) {
        print("📍 [NEARBY] Starting fetchNearbyPlaces...")
        
        // CRITICAL: Check if user has enabled location tracking in Settings
        guard AppStateManager.shared.isLocationTrackingEnabled else {
            print("⚠️ [NEARBY] Location tracking is DISABLED in Settings. Skipping location access.")
            completion([])
            return
        }
        
        guard let location = currentLocation else {
            print("📍 [NEARBY] Current location is NIL. Attempting to request location...")
            // Try to get location first if not available
            getCurrentLocation { [weak self] result in
                switch result {
                case .success(let loc):
                    print("📍 [NEARBY] Success getting location: \(loc.coordinate)")
                    self?.performLocalSearch(location: loc, completion: completion)
                case .failure(let error):
                    print("❌ [NEARBY] Failed to get location: \(error.localizedDescription)")
                    completion([])
                }
            }
            return
        }
        print("📍 [NEARBY] Using existing location: \(location.coordinate)")
        performLocalSearch(location: location, completion: completion)
    }
    
    private func performLocalSearch(location: CLLocation, completion: @escaping ([String]) -> Void) {
        print("📍 [NEARBY] Performing MKLocalPointsOfInterestRequest...")
        
        // Use MKLocalPointsOfInterestRequest (iOS 14+) which finds ALL POIs without a text query
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: 5000) // 5km radius
        request.pointOfInterestFilter = .includingAll // Get everything
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.domain == MKErrorDomain && nsError.code == 4 {
                    print("⚠️ [NEARBY] MapKit Error 4: Placemark not found. Triggering fallback...")
                } else if nsError.domain == NSURLErrorDomain && nsError.code == -1009 {
                     print("❌ [NEARBY] Network Error: The Internet connection appears to be offline.")
                } else {
                    print("❌ [NEARBY] MapKit Search Error: \(error.localizedDescription)")
                }
                
                // On ANY error (including Code 4), try the fallback
                self.performGeocoderFallback(location: location, completion: completion)
                return
            }
            
            guard let response = response else {
                print("❌ [NEARBY] MapKit response was NIL. Triggering fallback...")
                self.performGeocoderFallback(location: location, completion: completion)
                return
            }
            
            if response.mapItems.isEmpty {
                 print("ℹ️ [NEARBY] Search succeeded but found 0 places nearby. Triggering fallback...")
                 self.performGeocoderFallback(location: location, completion: completion)
                 return
            }
            
            print("✅ [NEARBY] Got \(response.mapItems.count) items from MapKit")
            
            // Sort by distance
            let sortedItems = response.mapItems.sorted { item1, item2 in
                let dist1 = item1.placemark.location?.distance(from: location) ?? Double.greatestFiniteMagnitude
                let dist2 = item2.placemark.location?.distance(from: location) ?? Double.greatestFiniteMagnitude
                return dist1 < dist2
            }
            
            let places = sortedItems.compactMap { $0.name }
            // Let's take up to 30 since we are filtering duplicates
            let uniquePlaces = Array(Set(places)).prefix(20)
            completion(Array(uniquePlaces))
        }
    }
    
    private func performGeocoderFallback(location: CLLocation, completion: @escaping ([String]) -> Void) {
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
            
            print("✅ [NEARBY] Geocoder found: \(results)")
            let unique = Array(Set(results)).prefix(8)
            completion(Array(unique))
        }
    }
}
