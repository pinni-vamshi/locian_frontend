//
//  CameraPreviewView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    @Binding var isActive: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear // Clear background - preview layer will cover it
        
        // Check camera authorization
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .authorized {
            setupCameraSession(for: view, coordinator: context.coordinator)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame when view bounds change
        if let previewLayer = context.coordinator.previewLayer {
            previewLayer.frame = uiView.bounds
        }
        
        // If we don't have a session yet and permissions are granted, try to create one
        if context.coordinator.captureSession == nil && isActive {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authStatus == .authorized {
                setupCameraSession(for: uiView, coordinator: context.coordinator)
            }
        }
        
        if isActive {
            if let session = context.coordinator.captureSession, !session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                }
            }
        } else {
            if let session = context.coordinator.captureSession, session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    session.stopRunning()
                }
            }
        }
    }
    
    private func setupCameraSession(for view: UIView, coordinator: Coordinator) {
        // Don't create a new session if one already exists
        guard coordinator.captureSession == nil else { return }
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0) // Insert at bottom layer
        
        coordinator.captureSession = captureSession
        coordinator.previewLayer = previewLayer
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        deinit {
            captureSession?.stopRunning()
        }
    }
}

