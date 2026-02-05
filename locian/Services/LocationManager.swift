//
//  LocationManager.swift
//  locian
//
//  Manages device location and provides latitude/longitude
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
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
    
    // MARK: - Request Permission
    func requestPermission() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Get Current Location
    func getCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
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
}

