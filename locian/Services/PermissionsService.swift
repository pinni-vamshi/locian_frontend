//
//  PermissionsService.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import AVFoundation
import Photos
import CoreLocation

struct PermissionsService {
    static func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    static func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoStatus {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        completion(true)
                    case .denied, .restricted:
                        completion(false)
                    case .notDetermined:
                        completion(false)
                    @unknown default:
                        completion(false)
                    }
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    static func requestLocationAccess(completion: @escaping (Bool) -> Void) {
        // Use the shared LocationManager instance
        let status = LocationManager.shared.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            LocationManager.shared.requestPermission()
            // Check status after a brief delay to allow system dialog to appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let newStatus = LocationManager.shared.authorizationStatus
                completion(newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}

