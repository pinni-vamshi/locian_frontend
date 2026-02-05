//
//  SettingsView.swift
//  locian
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    @StateObject var state: SettingsTabState
    @Binding var selectedTab: MainTabView.TabItem
    
    @State private var showingLanguageModal = false
    @State private var showingTimePicker = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    
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
        .onAppear { state.animateIn = true }
        .fullScreenCover(isPresented: $showingLanguageModal) { LanguageSelectionModal(appState: appState, mode: .addLearning) }
        .sheet(isPresented: $showingTimePicker) { timePicker }
        .alert(languageManager.settings.areYouSureLogout, isPresented: $showingLogoutAlert) {
            Button(languageManager.ui.cancel, role: .cancel) { }
            Button(languageManager.settings.logout, role: .destructive) { state.performLogout() }
        }
        .alert(languageManager.settings.areYouSureDeleteAccount, isPresented: $showingDeleteAlert) {
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
                    .padding(.horizontal, 5) // Reduced from 16
                    .padding(.vertical, 8)
                    .background(ThemeColors.secondaryAccent)
                    .diagnosticBorder(.white, width: 0.5, label: "P:H5")
                
                Text(appState.profession.isEmpty ? "LEARNING" : appState.profession.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(ThemeColors.secondaryAccent)
                    .padding(.horizontal, 5) // Reduced from 12
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .diagnosticBorder(.blue, width: 0.5, label: "P:H5")
            }
            .diagnosticBorder(.gray.opacity(0.3), width: 1)

            // 2. Giant Language Display
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 10))
                    Text(languageManager.settings.selectTargetLanguage.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.gray)
                
                let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
                let targetName = LanguageMapping.shared.getDisplayNames(for: pair?.target_language ?? "es").english.uppercased()
                
                if appState.userLanguagePairs.count > 1 {
                    Menu {
                        ForEach(appState.userLanguagePairs) { pair in
                            Button(action: {
                                withAnimation {
                                    state.language.setDefault(pair: pair) { }
                                }
                            }) {
                                HStack {
                                    Text(LanguageMapping.shared.getDisplayNames(for: pair.target_language).english.uppercased())
                                    if pair.is_default {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button(action: { showingLanguageModal = true }) {
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
                    Button(action: { showingLanguageModal = true }) {
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
                            Button(action: { state.language.updateLevel(pair: pair, to: level) }) {
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
        .diagnosticBorder(.white, width: 1, label: "SETT_HDR_P:H5,B24")
    }



    private var scrollableContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 60) {
                languageSection
                neuralEngineSection
                interfaceLanguageSection
                notificationSection // RESTORED
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
                HStack(alignment: .top, spacing: 2) {
                    VStack(alignment: .center, spacing: -1) {
                        ForEach(Array(languageManager.settings.nativeLanguage.uppercased()), id: \.self) { char in 
                            Text(String(char))
                                .font(.system(size: 7, weight: .black, design: .monospaced))
                                .foregroundColor(.black) 
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(Color.cyan)
                .diagnosticBorder(.cyan, width: 0.5, label: "LBL_P:H4,V8")

                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.nativeLanguage.getLanguageDisplayName().uppercased())
                        .font(.system(size: 50, weight: .black))
                        .foregroundColor(ThemeColors.secondaryAccent)
                    
                    HStack(spacing: 8) {
                        Text("\(appState.nativeLanguage.getLanguageDisplayName())")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                        Text("/").foregroundColor(.gray)
                        
                        Menu {
                            ForEach(LanguageMapping.shared.availableLanguageCodes.filter { $0.lowercased() != "hi" }, id: \.self) { code in
                                Button(LanguageMapping.shared.getDisplayNames(for: code).english) {
                                    appState.nativeLanguage = code
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                Text(languageManager.ui.edit.uppercased())
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        }
                    }
                }
            }
            .diagnosticBorder(.blue.opacity(0.3), width: 1, label: "NAT_HS_S:20")
            .padding(.horizontal, 5)
                .diagnosticBorder(.blue.opacity(0.5), width: 1, label: "NAT_P:H5")
        }
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
        .padding(.horizontal, 5)
    }


    // MARK: - Neural Engine status
    
    private var neuralEngineSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // 1. Vertical Heading Group (Now Stretches to Content Height)
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                        VStack(alignment: .center, spacing: -1) {
                            ForEach(Array(languageManager.settings.neuralEngine.uppercased()), id: \.self) { char in
                                Text(String(char)).font(.system(size: 8, weight: .black, design: .monospaced))
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 20) // Fixed width for vertical text area
                    .background(Color.white)
                    .foregroundColor(.black)
                    .diagnosticBorder(.white, width: 0.5, label: "V:NEURAL")
                    
                    // Cyan accent line (Nuclear Style) - Also Stretches
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(width: 4)
                        .diagnosticBorder(.cyan, width: 0.5, label: "BAR")
                }
                .frame(maxHeight: .infinity) // STRETCH
                .fixedSize(horizontal: true, vertical: false)
                
                // 2. Status Data (Beside Heading)
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(languageManager.settings.neuralEngine.uppercased()) // COMPUTE_GRID")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                        .diagnosticBorder(.gray.opacity(0.3), width: 0.5, label: "SUB")

                    let statuses = state.language.neuralStatuses
                    let nativeCode = appState.nativeLanguage
                    let targetPairs = appState.userLanguagePairs.filter { $0.target_language.lowercased() != nativeCode.lowercased() }
                    
                    var allLanguages: [String] {
                        var langs = [String]()
                        if !nativeCode.isEmpty { langs.append(nativeCode) }
                        langs.append(contentsOf: targetPairs.map { $0.target_language })
                        return langs
                    }
                    
                    FlowLayout(data: allLanguages, spacing: 10) { code in
                        diagRow(code: code, status: statuses[code])
                    }
                    .diagnosticBorder(.purple.opacity(0.3), width: 1, label: "FLOW")
                }
                .padding(.leading, 20) // Aligned to Native Section (20pt)
                .padding(.vertical, 10)
                .diagnosticBorder(.white.opacity(0.1), width: 0.5, label: "DATA_P:L20,V10")
            }
            .fixedSize(horizontal: false, vertical: true) // Determination of height
            .diagnosticBorder(.white.opacity(0.1), width: 1, label: "NEURAL_HS")
        }
        .padding(.horizontal, 5) // TIGHTENED to 5pt
        .onAppear { state.language.checkNeuralStatus() }
        .diagnosticBorder(.white.opacity(0.3), width: 1, label: "NEURAL_SEC_P:H5")
    }
    
    @ViewBuilder
    private func diagRow(code: String, status: LanguageLogic.NeuralStatus?) -> some View {
        let fullName = LanguageMapping.shared.getDisplayNames(for: code).english.uppercased()
        let color = statusColor(status?.state)
        
        HStack(spacing: 8) {
            // Status Indicator Dot (Square in Nuclear Style)
            Rectangle()
                .fill(color)
                .frame(width: 8, height: 8) // Slightly larger
                .shadow(color: color.opacity(0.5), radius: 4) // Glow
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fullName)
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(status?.state ?? "WAITING")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            .diagnosticBorder(.white.opacity(0.1), width: 0.5, label: "INFO")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.02))
        .diagnosticBorder(color.opacity(0.3), width: 1, label: code)
    }
    
    private func modeColor(_ mode: String) -> Color {
        switch mode {
        case "CONTEXTUAL": return .cyan
        case "STATIC": return Color(white: 0.6)
        default: return .yellow
        }
    }

    // MARK: - Location
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                Text(languageManager.settings.location.uppercased()).font(.system(size: 24, weight: .black))
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(languageManager.ui.loading.uppercased()).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(.gray)
                        .diagnosticBorder(.gray.opacity(0.5), width: 0.5)
                    Spacer()
                    Toggle("", isOn: $appState.isLocationTrackingEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: ThemeColors.secondaryAccent))
                        .labelsHidden()
                        .diagnosticBorder(.pink.opacity(0.5), width: 0.5)
                }
                .diagnosticBorder(.white.opacity(0.1), width: 1)
                
                Text(languageManager.onboarding.geolocationDesc)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 5)
        }
        .diagnosticBorder(.pink, width: 1)
    }


    // MARK: - Notifications
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                Text(languageManager.settings.notifications.uppercased()).font(.system(size: 24, weight: .black))
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(languageManager.ui.loading.uppercased()).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(.gray)
                    Spacer()
                    Toggle("", isOn: $appState.isNotificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: ThemeColors.secondaryAccent))
                        .labelsHidden()
                }
                
                Text(languageManager.onboarding.notificationsDesc)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 5)
        }
        .diagnosticBorder(.blue.opacity(0.3), width: 1)
    }


    // MARK: - Account
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 0) {
                // Vertical Label Group (Now Stretches)
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                        VStack(alignment: .center, spacing: -1) {
                            ForEach(Array(languageManager.settings.account.uppercased()), id: \.self) { char in 
                                Text(String(char))
                                    .font(.system(size: 8, weight: .black, design: .monospaced))
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 20)
                    .background(Color.white)
                    
                    // Pink accent line
                    Rectangle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(width: 4)
                }
                .frame(maxHeight: .infinity)
                .fixedSize(horizontal: true, vertical: false)

                // Action Buttons
                HStack(spacing: 20) {
                    accountBox(title: languageManager.settings.logout, icon: "arrow.right.square", color: .cyan) { showingLogoutAlert = true }
                    accountBox(title: languageManager.ui.delete, icon: "trash", color: ThemeColors.secondaryAccent) { showingDeleteAlert = true }
                }
                .padding(.leading, 20) // Aligned to Native Section (20pt)
                .padding(.vertical, 10)
            }
            .fixedSize(horizontal: false, vertical: true)
            
            // SYSTEM CONFIG (Debug Toggles)
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
        .padding(.horizontal, 5) // TIGHTENED to 5pt
        .diagnosticBorder(.green.opacity(0.3), width: 1, label: "ACC_SEC_P:H5")
        .diagnosticBorder(.white.opacity(0.1), width: 2)
    }
    
    private func accountBox(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                ZStack {
                    Rectangle().fill(Color.white.opacity(0.05))
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(color)
                    
                    // Corner decoration
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

    // MARK: - Subviews & Helpers
    
    private func statusColor(_ status: String?) -> Color {
        switch status { case "LOADED": return .green; case "FAILED": return .red; case "DOWN": return .blue; default: return .gray }
    }

    private var timePicker: some View { TimeSelectionModal { state.notifications.addTime($0); showingTimePicker = false } }
}
