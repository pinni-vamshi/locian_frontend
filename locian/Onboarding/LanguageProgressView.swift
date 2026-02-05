//
//  LanguageProgressView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

import UserNotifications
import AVFoundation
import CoreLocation

import Combine

struct LanguageProgressView: View {
    @Binding var isReady: Bool
    
    @State private var itemsVisible = false
    @State private var notificationsGranted = false
    @State private var microphoneGranted = false
    @State private var locationGranted = false
    @StateObject private var locationManager = LocationManager.shared
    
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    // Neon Colors
    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent
    private let neonGreen = Color(red: 53/255, green: 242/255, blue: 28/255) // #35F21C
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // FIXED HEADER SECTION
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.string(.quickSetup))
                                .font(.system(size: 36, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                }
                
                // SCROLLABLE CONTENT SECTION
                ScrollView {
                    VStack(spacing: 16) {
                        // Notifications
                        infoCard(
                            id: "01",
                            icon: "bell.fill",
                            title: localizationManager.string(.notificationsPermission),
                            desc: localizationManager.string(.notificationsDesc),
                            borderColor: neonCyan,
                            primaryAction: notificationsGranted ? localizationManager.string(.granted) : localizationManager.string(.allow),
                            secondaryAction: localizationManager.string(.skip),
                            isGranted: notificationsGranted,
                            delay: 0.2,
                            action: requestNotifications
                        )
                        
                        // Microphone
                        infoCard(
                            id: "02",
                            icon: "mic.fill",
                            title: localizationManager.string(.microphonePermission),
                            desc: localizationManager.string(.microphoneDesc),
                            borderColor: neonPink,
                            primaryAction: microphoneGranted ? localizationManager.string(.granted) : localizationManager.string(.allow),
                            secondaryAction: localizationManager.string(.skip),
                            isGranted: microphoneGranted,
                            delay: 0.4,
                            action: requestMicrophone
                        )
                        
                        // Geolocation
                        infoCard(
                            id: "03",
                            icon: "location.fill",
                            title: localizationManager.string(.geolocationPermission),
                            desc: localizationManager.string(.geolocationDesc),
                            borderColor: neonGreen,
                            primaryAction: locationGranted ? localizationManager.string(.granted) : localizationManager.string(.allow),
                            secondaryAction: localizationManager.string(.skip),
                            isGranted: locationGranted,
                            delay: 0.6,
                            action: requestLocation
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    Spacer().frame(height: 120) // Bottom padding for global footer
                }
            }
        }
        .onAppear {
            itemsVisible = true
            checkPermissions()
        }
        .onChange(of: notificationsGranted) { _, _ in checkAllGranted() }
        .onChange(of: microphoneGranted) { _, _ in checkAllGranted() }
        .onChange(of: locationGranted) { _, _ in checkAllGranted() }
        .onReceive(locationManager.$authorizationStatus) { status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationGranted = true
            }
        }
    }
    
    private func checkPermissions() {
        // Check initial states
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsGranted = settings.authorizationStatus == .authorized
            }
        }
        
        microphoneGranted = AVAudioApplication.shared.recordPermission == .granted
        
        let status = LocationManager.shared.authorizationStatus
        locationGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        
        checkAllGranted()
    }
    
    private func requestNotifications() {
        PermissionsService.ensureNotificationAccess { granted in
            self.notificationsGranted = granted
        }
    }
    
    private func requestMicrophone() {
        PermissionsService.ensureMicrophoneAccess { granted in
            self.microphoneGranted = granted
        }
    }
    
    private func requestLocation() {
        PermissionsService.ensureLocationAccess { granted in
            self.locationGranted = granted
        }
    }
    
    private func checkAllGranted() {
        isReady = notificationsGranted && microphoneGranted && locationGranted
    }
    
    @ViewBuilder
    func infoCard(id: String, icon: String, title: String, desc: String, borderColor: Color, primaryAction: String, secondaryAction: String, isGranted: Bool = false, delay: Double, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top) {
                // Icon box
                ZStack {
                    Rectangle().fill(Color(white: 0.15)).frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(borderColor)
                }
                
                Spacer()
                
                Text("REQ_\(id)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(4)
                    .background(Color(white: 0.15))
            }
            .padding(16)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(2)
                
                Text(desc)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Actions
            HStack(spacing: 12) {
                Button(action: action) {
                    Text(primaryAction)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(isGranted ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isGranted ? Color(white: 0.25) : borderColor)
                }
                .disabled(isGranted)
                
                Button(action: {}) { // Skip button Logic could be added here
                    Text(secondaryAction)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .padding(.vertical, 12)
                        .border(Color.white.opacity(0.2), width: 1)
                }
                .opacity(isGranted ? 0.0 : 1.0) // Hide skip if granted? Or disable. User said "allow it".
            }
            .padding(16)
        }
        .background(Color(white: 0.08))
        .overlay(
            Rectangle()
                .frame(width: 2)
                .foregroundColor(borderColor),
            alignment: .leading
        )
        .overlay(
            Rectangle()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .opacity(itemsVisible ? 1.0 : 0.0)
        .offset(y: itemsVisible ? 0 : 20)
        .animation(.spring(dampingFraction: 0.8).delay(delay), value: itemsVisible)
    }
}


#Preview {
    LanguageProgressView(isReady: .constant(false))
        .preferredColorScheme(.dark)
}
