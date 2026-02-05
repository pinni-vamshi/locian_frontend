//
//  LoginView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var profession: String = ""
    @State private var viewOpacity: Double = 0
    
    // Neon Colors
    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent
    private let neonRed = Color(red: 1.0, green: 0.2, blue: 0.2)
    
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
        "nurse",
        "designer",
        "engineer_manager",
        "photographer",
        "content_creator",
        "entrepreneur",
        "other"
    ]
    
    // Helper to localize professions
    private func getLocalizedProfession(_ profession: String) -> String {
        let key = profession.lowercased().replacingOccurrences(of: "_", with: "")
        switch key {
        case "student": return localizationManager.string(.student)
        case "softwareengineer": return localizationManager.string(.softwareEngineer)
        case "teacher": return localizationManager.string(.teacher)
        case "doctor": return localizationManager.string(.doctor)
        case "artist": return localizationManager.string(.artist)
        case "businessprofessional": return localizationManager.string(.businessProfessional)
        case "salesormarketing": return localizationManager.string(.salesOrMarketing)
        case "traveler": return localizationManager.string(.traveler)
        case "homemaker": return localizationManager.string(.homemaker)
        case "chef": return localizationManager.string(.chef)
        case "police": return localizationManager.string(.police)
        case "bankemployee": return localizationManager.string(.bankEmployee)
        case "nurse": return localizationManager.string(.nurse)
        case "designer": return localizationManager.string(.designer)
        case "engineermanager": return localizationManager.string(.engineerManager)
        case "photographer": return localizationManager.string(.photographer)
        case "contentcreator": return localizationManager.string(.contentCreator)
        case "entrepreneur": return localizationManager.string(.entrepreneur)
        case "other": return localizationManager.string(.other)
        default: return profession.split(separator: "_").map { $0.capitalized }.joined(separator: " ")
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            
            // Vertical Background Text Removed
            
            
            VStack(spacing: 0) {
                // Top spacing buffer
                Spacer()
                    .frame(height: 40)
                
                // MARK: Title Section
                VStack(alignment: .leading, spacing: -15) {
                    Text("REGISTER")
                        .font(.system(size: 60, weight: .black))
                        .foregroundColor(neonPink)
                        .offset(x: -5)
                    
                    Text("LOGIN")
                        .font(.system(size: 52, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 15, x: 0, y: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                // MARK: Divider
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(neonPink)
                        .frame(width: 40, height: 4)
                    
                    Text(localizationManager.string(.selectUserProfession))
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.9))
                        .tracking(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                // MARK: Profession Grid
                ScrollView(showsIndicators: false) {
                    FlowLayout(data: professions, spacing: 10) { prof in
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            profession = prof
                        } label: {
                            Text(getLocalizedProfession(prof))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(profession == prof ? .white : .gray)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(minWidth: 80)
                                .background(
                                    Rectangle()
                                        .fill(profession == prof ? neonPink : Color.white.opacity(0.03))
                                )
                                .overlay(
                                    Rectangle()
                                        .stroke(profession == prof ? neonPink : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 25)
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // MARK: Footer
                VStack(spacing: 20) {
                    // Apple Sign In
                    SignInWithAppleButton(.signIn) { request in
                        appState.configureAppleSignIn(request, username: nil, profession: profession.isEmpty ? nil : profession, phoneNumber: nil, emailOverride: nil)
                    } onCompletion: { result in
                        appState.handleAppleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Rectangle()
                            .stroke(LinearGradient(colors: [neonPink, neonCyan], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                            .shadow(color: neonPink.opacity(0.3), radius: 10, x: 0, y: 0)
                    )
                    .padding(.horizontal, 24)
                        .opacity(profession.isEmpty ? 0.4 : 1.0)
                        .disabled(profession.isEmpty || appState.isAuthenticating)
                }
                .padding(.bottom, 40)
            }
            .blur(radius: appState.isAuthenticating ? 10 : 0)
            .animation(.spring(), value: appState.isAuthenticating)
            
            // MARK: - Authentication Overlay
            if appState.isAuthenticating {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Text(">")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(neonCyan)
                            
                            Text(localizationManager.string(.authenticatingUser))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .tracking(1)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .stroke(neonCyan, lineWidth: 1)
                                .background(neonCyan.opacity(0.1))
                        )
                        .shadow(color: neonCyan.opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        Text("LOCIAN_CORE_AUTH_SERVICE")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation {
                viewOpacity = 1.0
            }
        }
        .opacity(viewOpacity)
    }
    
}

#Preview {
    LoginView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}
