//
//  LoginView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @FocusState private var focusedField: Field?
    @State private var username: String = ""
    @State private var profession: String = ""
    @State private var phoneNumber: String = ""
    @State private var countryCode: String = "+1"
    @State private var otp: String = ""
    @State private var otpEnabled: Bool = false
    @State private var showResendButton: Bool = false
    @State private var timeRemaining: Int = 300 // 5 minutes in seconds
    @State private var timer: Timer?
    @State private var viewOpacity: Double = 0
    @State private var viewScale: CGFloat = 0.9
    
    enum Field {
        case username, countryCode, phoneNumber, otp
    }
    
    let professions = [
        "student",
        "software_engineer",
        "teacher",
        "doctor",
        "artist",
        "business_professional",
        "sales_or_marketing",
        "traveler",
        "homemaker",
        "chef",
        "police",
        "bank_employee",
        "other"
    ]
    
    private func formatProfessionDisplay(_ profession: String) -> String {
        // Convert snake_case to Title Case for display
        return profession.split(separator: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    private func getLocalizedProfession(_ profession: String) -> String {
        let key = profession.lowercased().replacingOccurrences(of: "_", with: "")
        switch key {
        case "student": return LocalizationManager.shared.string(.student)
        case "softwareengineer": return LocalizationManager.shared.string(.softwareEngineer)
        case "teacher": return LocalizationManager.shared.string(.teacher)
        case "doctor": return LocalizationManager.shared.string(.doctor)
        case "artist": return LocalizationManager.shared.string(.artist)
        case "businessprofessional": return LocalizationManager.shared.string(.businessProfessional)
        case "salesormarketing": return LocalizationManager.shared.string(.salesOrMarketing)
        case "traveler": return LocalizationManager.shared.string(.traveler)
        case "homemaker": return LocalizationManager.shared.string(.homemaker)
        case "chef": return LocalizationManager.shared.string(.chef)
        case "police": return LocalizationManager.shared.string(.police)
        case "bankemployee": return LocalizationManager.shared.string(.bankEmployee)
        case "other": return LocalizationManager.shared.string(.other)
        default: return formatProfessionDisplay(profession)
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // First Stack - 30% Height
                VStack {
                    Text(localizationManager.string(.login))
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(localizationManager.string(.register))
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.30)
                
                // Second Stack - 50% Height
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Username field
                    TextField(languageManager.login.username, text: $username)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity((!appState.otpSent && !appState.isSendingOTP) ? 0.1 : 0.05))
                        .cornerRadius(12)
                        .frame(width: 350)
                        .disabled(appState.otpSent || appState.isSendingOTP)
                        .opacity((appState.otpSent || appState.isSendingOTP) ? 0.5 : 1.0)
                        .focused($focusedField, equals: .username)
                        .onSubmit {
                            dismissKeyboard()
                        }
                        .submitLabel(.next)
                    
                    // Profession picker
                    Menu {
                        ForEach(professions, id: \.self) { prof in
                            Button(action: {
                                profession = prof
                            }) {
                                HStack {
                                    Text(getLocalizedProfession(prof))
                                    if profession == prof {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(profession.isEmpty ? languageManager.login.selectProfession : getLocalizedProfession(profession))
                                .font(.system(size: 18))
                                .foregroundColor(profession.isEmpty ? .white.opacity(0.6) : .white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding()
                        .background(Color.white.opacity((!appState.otpSent && !appState.isSendingOTP) ? 0.1 : 0.05))
                        .cornerRadius(12)
                        .frame(width: 350)
                    }
                        .disabled(appState.otpSent || appState.isSendingOTP)
                        .opacity((appState.otpSent || appState.isSendingOTP) ? 0.5 : 1.0)
                    
                    // Phone number field with country code
                    HStack(spacing: 10) {
                        // Country code dropdown
                        TextField("+1", text: $countryCode)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity((!appState.otpSent && !appState.isSendingOTP) ? 0.1 : 0.05))
                            .cornerRadius(12)
                            .frame(width: 80)
                            .disabled(appState.otpSent || appState.isSendingOTP)
                            .opacity((appState.otpSent || appState.isSendingOTP) ? 0.5 : 1.0)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .countryCode)
                        
                        // Phone number field
                        TextField(languageManager.login.phoneNumber, text: $phoneNumber)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity((!appState.otpSent && !appState.isSendingOTP) ? 0.1 : 0.05))
                            .cornerRadius(12)
                            .frame(width: 260)
                            .disabled(appState.otpSent || appState.isSendingOTP)
                            .opacity((appState.otpSent || appState.isSendingOTP) ? 0.5 : 1.0)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phoneNumber)
                    }
                    .frame(width:320)
                    
                    // OTP input field (disabled initially)
                    TextField(languageManager.login.enterOTP, text: $otp)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity((appState.otpSent && !appState.isVerifyingOTP) ? 0.1 : 0.05))
                        .cornerRadius(12)
                        .keyboardType(.numberPad)
                        .disabled(!appState.otpSent || appState.isVerifyingOTP)
                        .opacity((appState.otpSent && !appState.isVerifyingOTP) ? 1.0 : 0.5)
                        .frame(width: 350)
                        .focused($focusedField, equals: .otp)
                    
                    // Send OTP / Verify OTP button and Guest Login button side-by-side
                    if !appState.otpSent {
                        HStack(spacing: 15) {
                            // Send OTP button in its own HStack
                            HStack {
                    Button(action: {
                            if !appState.isSendingOTP {
                                let fullPhoneNumber = countryCode + phoneNumber
                                appState.sendOTP(phone: fullPhoneNumber)
                        }
                    }) {
                        HStack(spacing: 8) {
                            if appState.isSendingOTP {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                                            Text(languageManager.login.sending)
                            } else {
                                            Text(languageManager.login.sendOTP)
                            }
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .cornerRadius(25)
                    }
                                .buttonPressAnimation() // Centralized animation
                                .disabled(appState.isSendingOTP || appState.isVerifyingOTP)
                                .opacity((appState.isSendingOTP || appState.isVerifyingOTP) ? 0.7 : 1.0)
                            }
                            
                            // Guest Login button in its own HStack (only show if visibility is "on")
                            if appState.showGuestLoginButton {
                                HStack {
                                    VStack(spacing: 4) {
                                        Button(action: {
                                            if !appState.isGuestLoginLoading {
                                                appState.guestLogin(
                                                    username: username.isEmpty ? nil : username,
                                                    phoneNumber: phoneNumber.isEmpty ? nil : (countryCode + phoneNumber),
                                                    profession: profession.isEmpty ? nil : profession
                                                )
                                            }
                                        }) {
                                            VStack(spacing: 2) {
                                                HStack(spacing: 8) {
                                                    if appState.isGuestLoginLoading {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                            .scaleEffect(0.8)
                                                    }
                                                    Text(languageManager.login.guestLogin)
                                                }
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                                
                                                Text("[For Review]")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            .padding(.horizontal, 30)
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(20)
                                        }
                                        .buttonPressAnimation() // Centralized animation
                                        .disabled(appState.isGuestLoginLoading)
                                        .opacity(appState.isGuestLoginLoading ? 0.7 : 1.0)
                                    }
                                }
                            }
                        }
                        .frame(width: 350)
                    } else {
                        // Verify OTP button (when OTP is sent, show only this button)
                        Button(action: {
                            // Verify OTP - include profession if selected
                            appState.verifyOTP(
                                otpCode: otp,
                                username: username,
                                profession: profession.isEmpty ? nil : profession
                            )
                        }) {
                            HStack(spacing: 8) {
                                if appState.isVerifyingOTP {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .scaleEffect(0.8)
                                    Text(languageManager.login.verifying)
                                } else {
                                    Text(languageManager.login.verifyOTP)
                                }
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .cornerRadius(25)
                        }
                        .buttonPressAnimation() // Centralized animation
                    .disabled(appState.isSendingOTP || appState.isVerifyingOTP)
                    .opacity((appState.isSendingOTP || appState.isVerifyingOTP) ? 0.7 : 1.0)
                    }
                    
                    // Timer display
                    if otpEnabled && !showResendButton {
                        Text("\(languageManager.login.resendOTPIn) \(formatTime(timeRemaining))")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Change Phone Number button (only show after OTP sent)
                    if appState.otpSent {
                        Button(action: {
                            // Reset states
                            otpEnabled = false
                            showResendButton = false
                            timeRemaining = 300
                            otp = ""
                            stopTimer()
                            appState.otpSent = false
                        }) {
                            Text(languageManager.login.changePhoneNumber)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                        .buttonPressAnimation() // Centralized animation
                    }
                    
                     // Resend OTP button
                     if showResendButton {
                         Button(action: {
                             // Resend OTP functionality
                             let fullPhoneNumber = countryCode + phoneNumber
                             appState.sendOTP(phone: fullPhoneNumber)
                             timeRemaining = 300
                             showResendButton = false
                             startTimer()
                         }) {
                             Text(languageManager.login.resendOTP)
                                 .font(.system(size: 16))
                                 .foregroundColor(.white)
                         }
                         .buttonPressAnimation() // Centralized animation
                     }
                     
                     Spacer()
                         .frame(height: 20)
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.50)
                
                // Third Stack - 20% Height
                VStack(spacing: 12) {
                    Text(languageManager.login.loginOrRegisterDescription)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Guest login description (only show when OTP not sent and button is visible)
                    if !appState.otpSent && appState.showGuestLoginButton {
                        Text(languageManager.login.guestLoginDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(3)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.20)
            }
            .opacity(viewOpacity)
            .scaleEffect(viewScale)
        }
        .ignoresSafeArea()
        .onAppear {
            // Check button visibility when login view appears
            appState.checkButtonVisibility()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                viewOpacity = 1.0
                viewScale = 1.0
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if focusedField == .countryCode || focusedField == .phoneNumber || focusedField == .otp {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
        }
        .onChange(of: appState.otpSent) { _, newValue in
            if newValue {
                // OTP was sent successfully
                otpEnabled = true
                timeRemaining = 300
                showResendButton = false
                startTimer()
            } else {
                // OTP state reset - stop timer and reset UI
                otpEnabled = false
                showResendButton = false
                timeRemaining = 300
                otp = ""
                stopTimer()
            }
        }
        .alert(LocalizationManager.shared.string(.error), isPresented: $appState.showOTPError) {
            Button(LocalizationManager.shared.string(.ok), role: .cancel) {
                appState.otpError = nil
            }
        } message: {
            Text(appState.otpError ?? "An error occurred")
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                showResendButton = true
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    LoginView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}
