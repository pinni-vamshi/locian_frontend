//
//  SettingsView.swift
//  locian
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    @StateObject var state: SettingsTabState
    @Binding var selectedTab: MainTabView.TabItem
    @State private var animateIn = false
    
    init(appState: AppStateManager, selectedTab: Binding<MainTabView.TabItem>) {
        self.appState = appState
        self._selectedTab = selectedTab
        self._state = StateObject(wrappedValue: SettingsTabState(appState: appState))
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 20)
                .background(Color.black)
                .zIndex(2)
            
            // STRETCHED DIVIDER: End of the fixed stack
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 5)
                .zIndex(2)
            
            scrollableContent.zIndex(1)
                .diagnosticBorder(.blue.opacity(0.3), width: 1.5)
        }
        .diagnosticBorder(.white, width: 2)
        .background(Color.black.ignoresSafeArea())
        .onAppear { 
            animateIn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
            }
        }
        .onDisappear { 
            withAnimation(.none) { animateIn = false }
        }
        .alert(languageManager.settings.areYouSureLogout, isPresented: $state.showingLogoutAlert) {
            Button(languageManager.ui.cancel, role: .cancel) { }
            Button(languageManager.settings.logout, role: .destructive) { state.performLogout() }
        }
        .alert(languageManager.settings.areYouSureDeleteAccount, isPresented: $state.showingDeleteAlert) {
            Button(languageManager.ui.cancel, role: .cancel) { }
            Button(languageManager.ui.delete, role: .destructive) { state.performDeleteAccount() }
        }
    }

    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 1. Username and Status Badges
            VStack(alignment: .leading, spacing: 4) {
                Text(appState.username.isEmpty ? "USER" : appState.username.lowercased())
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .background(ThemeColors.secondaryAccent)
                    .diagnosticBorder(.white, width: 0.5, label: "P:H5")
                
                Text(appState.profession.isEmpty ? "LEARNING" : localizationManager.getLocalizedProfession(appState.profession))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(ThemeColors.secondaryAccent)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .diagnosticBorder(.blue, width: 0.5, label: "P:H5")
            }
            .animation(.spring(), value: localizationManager.getLocalizedProfession(appState.profession))
            .diagnosticBorder(.gray.opacity(0.3), width: 1)

            // 2. Giant Language Display
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 10))
                    Text(languageManager.settings.selectTargetLanguage.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                    
                    // Target Neural Status
                    if let code = state.defaultPair?.target_language {
                        let status = state.neuralStatuses[code]?.state ?? "WAITING"
                        let color = state.statusColor(status)
                        Text("[NEURAL ENGINE: \(status)]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(color)
                    }
                }
                .foregroundColor(.gray)
                
                let pair = state.defaultPair
                let targetName = state.defaultTargetLanguageName
                
                if appState.userLanguagePairs.count > 1 {
                    Menu {
                        ForEach(appState.userLanguagePairs) { pair in
                            Button(action: {
                                withAnimation {
                                    state.setDefault(pair: pair) { }
                                }
                            }) {
                                HStack {
                                    let names = TargetLanguageMapping.shared.getDisplayNames(for: pair.target_language).english.uppercased()
                                    Text(names)
                                    if pair.is_default {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button(action: { appState.shouldShowTargetLanguageModal = true }) {
                            Label(languageManager.settings.addLanguagePair, systemImage: "plus")
                        }
                    } label: {
                        Text(targetName)
                            .font(.system(size: 90, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: { appState.shouldShowTargetLanguageModal = true }) {
                        Text(targetName)
                            .font(.system(size: 90, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                    .buttonStyle(.plain)
                }
                
                // 3. Level Indicator & Selector
                if let pair = pair {
                    Menu {
                        ForEach(["BEGINNER", "INTERMEDIATE", "ADVANCED"], id: \.self) { level in
                            Button(action: { state.updateLevel(pair: pair, to: level) }) {
                                HStack {
                                    Text(level)
                                    if pair.user_level.uppercased() == level {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(languageManager.settings.currentLevel.uppercased())
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white)
                            
                            HStack(spacing: 4) {
                                Text(pair.user_level.uppercased())
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(ThemeColors.secondaryAccent)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }.padding(.horizontal, 5).padding(.bottom, 24)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateIn)
        .diagnosticBorder(.white, width: 1, label: "SETT_HDR_P:H5,B24")
    }

    private var scrollableContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 60) {
                languageSection
                personalizationSection
                interfaceLanguageSection
                notificationSection
                locationSection
                accountSection
                Spacer(minLength: 100)
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Language Pair Section
    
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Native Language Display
            HStack(alignment: .top, spacing: 20) {
                // Vertical Cyan Label
                VerticalHeading(
                    text: languageManager.settings.nativeLanguage.uppercased(),
                    textColor: .black,
                    backgroundColor: .cyan,
                    width: 24,
                    height: 120
                )
                .diagnosticBorder(.cyan, width: 0.5, label: "LBL_ROT")

                VStack(alignment: .leading, spacing: 4) {
                    Text(NativeLanguageMapping.shared.getDisplayNames(for: appState.nativeLanguage).english.uppercased())
                        .font(.system(size: 50, weight: .black))
                        .foregroundColor(ThemeColors.secondaryAccent)
                    
                    HStack(spacing: 8) {
                        Text("\(NativeLanguageMapping.shared.getDisplayNames(for: appState.nativeLanguage).english)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                        Text("/").foregroundColor(.gray)
                        
                        Button(action: { appState.shouldShowNativeLanguageModal = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                Text(languageManager.ui.edit.uppercased())
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        }
                    }
                    
                    // Native Neural Status
                    let nativeCode = appState.nativeLanguage
                    let status = state.neuralStatuses[nativeCode]?.state ?? "WAITING"
                    let color = state.statusColor(status)
                    
                    Text("NEURAL ENGINE: \(status)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                        .padding(.top, 4)
                }
            }
            .diagnosticBorder(.blue.opacity(0.3), width: 1, label: "NAT_HS_S:20")
            .padding(.horizontal, 5)
            .diagnosticBorder(.blue.opacity(0.5), width: 1, label: "NAT_P:H5")
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.1), value: animateIn)
        .diagnosticBorder(.cyan, width: 1, label: "LANG_SEC_V_S:24")
    }

    private var interfaceLanguageSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.system(size: 20))
                Text(languageManager.settings.systemLanguage.uppercased()).font(.system(size: 24, weight: .black))
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(languageManager.currentLanguage.displayName)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Button(action: {
                                withAnimation {
                                    languageManager.currentLanguage = lang
                                    appState.appLanguage = lang.rawValue
                                }
                            }) {
                                HStack {
                                    Text(lang.displayName)
                                    if languageManager.currentLanguage == lang {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text(languageManager.ui.edit.uppercased())
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.cyan)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        Color.black.opacity(0.6)
                        GridPattern()
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    }
                )
                .overlay(TechFrameBorder(isSelected: false))
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.2), value: animateIn)
        .padding(.horizontal, 5)
    }

    // MARK: - Neural Engine status
    
    // MARK: - Neural Engine status (Integrated into Headers)
    // Legacy section removed.

    
    // MARK: - Personalization Refresh
    
    private var personalizationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // 1. Vertical Heading
                HStack(alignment: .top, spacing: 0) {
                    VerticalHeading(
                        text: languageManager.settings.refreshHeading.uppercased(),
                        textColor: .black,
                        backgroundColor: .white,
                        width: 24,
                        height: 140
                    )
                    
                    Rectangle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(width: 4, height: 140)
                }
                .fixedSize()
                
                // 2. Content
                VStack(alignment: .leading, spacing: 12) {
                    Text(languageManager.settings.refreshSubheading.uppercased())
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)

                    Text(languageManager.settings.refreshDescription)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        state.refreshPersonalization { success in
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(success ? .success : .error)
                        }
                    }) {
                        HStack(spacing: 8) {
                            if state.isRefreshingPersonalization {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(.black)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            
                            Text(languageManager.settings.refreshButton.uppercased())
                            
                            if state.showRefreshSuccess {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(0)
                    }
                    .padding(.top, 4)
                }
                .padding(.leading, 20)
                .padding(.vertical, 10)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 5)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.18), value: animateIn)
        .diagnosticBorder(.white.opacity(0.3), width: 1, label: "PERS_SEC")
    }
    


    // MARK: - Location
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                Text(languageManager.settings.location.uppercased()).font(.system(size: 24, weight: .black))
                Spacer()
                Toggle("", isOn: Binding(
                    get: { appState.isLocationTrackingEnabled },
                    set: { newValue in
                        if newValue {
                            PermissionsService.shared.ensureLocationAccess { granted in
                                DispatchQueue.main.async {
                                    appState.isLocationTrackingEnabled = granted
                                }
                            }
                        } else {
                            appState.isLocationTrackingEnabled = false
                        }
                    }
                ))
                    .toggleStyle(SwitchToggleStyle(tint: ThemeColors.secondaryAccent))
                    .labelsHidden()
                    .diagnosticBorder(.pink.opacity(0.5), width: 0.5)
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, 5)
            
            Text(languageManager.onboarding.geolocationDesc)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .padding(.horizontal, 5)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.3), value: animateIn)
        .diagnosticBorder(.pink, width: 1)
    }

    // MARK: - Notifications
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                Text(languageManager.settings.notifications.uppercased()).font(.system(size: 24, weight: .black))
                Spacer()
                Toggle("", isOn: Binding(
                    get: { NotificationManager.shared.isNotificationsEnabled },
                    set: { newValue in
                        if newValue {
                            PermissionsService.shared.ensureNotificationAccess { granted in
                                DispatchQueue.main.async {
                                    NotificationManager.shared.isNotificationsEnabled = granted
                                }
                            }
                        } else {
                            NotificationManager.shared.isNotificationsEnabled = false
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: ThemeColors.secondaryAccent))
                .labelsHidden()
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, 5)
            
            Text(languageManager.onboarding.notificationsDesc)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .padding(.horizontal, 5)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.25), value: animateIn)
        .diagnosticBorder(.blue.opacity(0.3), width: 1)
    }

    // MARK: - Account
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    VerticalHeading(
                        text: languageManager.settings.account.uppercased(),
                        textColor: .black,
                        backgroundColor: .white,
                        width: 24,
                        height: 132 // Increased to match content
                    )
                    
                    Rectangle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(width: 4, height: 132) // Increased to match content
                }
                .fixedSize()

                HStack(spacing: 20) {
                    accountBox(title: languageManager.settings.logout, icon: "arrow.right.square", color: .cyan) { state.showingLogoutAlert = true }
                    accountBox(title: languageManager.ui.delete, icon: "trash", color: ThemeColors.secondaryAccent) { state.showingDeleteAlert = true }
                }
                .padding(.leading, 20)
                // Removed .padding(.vertical, 10) to align tops with VerticalHeading
            }
            .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageManager.settings.diagnosticBorders.uppercased())
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text(languageManager.getString("Visualize UI layout frames for debugging.").uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Toggle("", isOn: $appState.showDiagnosticBorders)
                        .toggleStyle(SwitchToggleStyle(tint: ThemeColors.secondaryAccent))
                        .labelsHidden()
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.05))
                .overlay(Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .padding(.top, 40)
            
            Text(languageManager.settings.systemConfig.uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.35), value: animateIn)
        .padding(.horizontal, 5)
        .diagnosticBorder(.green.opacity(0.3), width: 1, label: "ACC_SEC_P:H5")
        .diagnosticBorder(.white.opacity(0.1), width: 2)
    }
    
    private func accountBox(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 20 , weight: .bold)) // 5% bigger (16->17)
                    .foregroundColor(.white.opacity(0.5)) // Opacity 0.5
                
                ZStack {
                    Rectangle().fill(Color.white.opacity(0.05))
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(color)
                    
                    VStack {
                        HStack {
                            Text("..").font(.system(size: 8)).foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Text("..").font(.system(size: 8)).foregroundColor(.gray)
                        }
                    }.padding(4)
                }
                .frame(width: 100, height: 100)
                .overlay(Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                .diagnosticBorder(color.opacity(0.5), width: 1)
            }
            .diagnosticBorder(.white.opacity(0.1), width: 1)
        }
    }
}


