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
import Speech

struct PermissionsService {
    
    // MARK: - Camera
    static func ensureCameraAccess(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }
    
    // MARK: - Photos
    static func ensurePhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
        default:
            completion(false)
        }
    }
    
    // MARK: - Location
    static func ensureLocationAccess(completion: @escaping (Bool) -> Void) {
        let status = LocationManager.shared.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            LocationManager.shared.requestPermission()
            // Poll for a few seconds or wait for delegate (using a simpler delay for now as per user pattern)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let newStatus = LocationManager.shared.authorizationStatus
                completion(newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways)
            }
        default:
            completion(false)
        }
    }
    
    // MARK: - Notifications
    static func ensureNotificationAccess(completion: @escaping (Bool) -> Void) {
        NotificationManager.shared.requestPermission(completion: completion)
    }
    
    // MARK: - Microphone (AVAudioApplication)
    static func ensureMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        let status = AVAudioApplication.shared.recordPermission
        switch status {
        case .granted:
            completion(true)
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }

    // MARK: - Speech Recognition
    static func ensureSpeechAccess(completion: @escaping (Bool) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async { completion(status == .authorized) }
            }
        default:
            completion(false)
        }
    }
}

