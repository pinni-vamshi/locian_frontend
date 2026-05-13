//
//  SettingsView.swift
//  locian
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    // Voice management removed (VoiceDownloadManager deleted)
    @StateObject var state: SettingsTabState
    @Binding var selectedTab: MainTabView.TabItem
    @State private var animateIn = false
    
    init(appState: AppStateManager, selectedTab: Binding<MainTabView.TabItem>) {
        self.appState = appState
        self._selectedTab = selectedTab
        self._state = StateObject(wrappedValue: SettingsTabState(appState: appState))
    }

    var body: some View {
        settingsRoot
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

    /// Split from `body` so the compiler does not infer `some View` in terms of itself (large VStack + modifiers).
    private var settingsRoot: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 28))
                .background(Color.black)
                .zIndex(2)
                .diagnosticBorder(.pink.opacity(0.5))
            
            // STRETCHED DIVIDER: End of the fixed stack
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, learnScaled(5, hSizeClass: horizontalSizeClass, min: 5, max: 8))
                .zIndex(2)
            
            scrollableContent.zIndex(1)
                .diagnosticBorder(.blue.opacity(0.3), width: 1.5)
        }
    }

    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 1. Username
            Text(appState.username.isEmpty ? "USER" : appState.username.lowercased())
                .font(learnFont(size: 20, weight: .bold, hSizeClass: horizontalSizeClass))
                .foregroundColor(.white)
                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                .padding(.vertical, learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12))
                .background(ThemeColors.secondaryAccent)
                .diagnosticBorder(.white, width: 0.5)
            
            // 2. Giant Language Display
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 12)))
                    Text(languageManager.settings.selectTargetLanguage.uppercased())
                        .font(learnFont(size: 10, weight: .bold, hSizeClass: horizontalSizeClass))
                    
                    // Target Neural Status
                    if let code = state.defaultPair?.target_language {
                        let status = state.neuralStatuses[code]?.state ?? "WAITING"
                        let color = state.statusColor(status)
                        Text("[NEURAL ENGINE: \(status)]")
                            .font(learnFont(size: 10, weight: .bold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(color)
                    }
                }
                .foregroundColor(.gray)
                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                .diagnosticBorder(.blue.opacity(0.2))
                
                let targetName = state.defaultTargetLanguageName
                
                Group {
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
                                    .diagnosticBorder(.green.opacity(0.1))
                                }
                            }
                            
                            Divider()
                            
                            Button(action: { appState.shouldShowTargetLanguageModal = true }) {
                                Label(languageManager.settings.addLanguagePair, systemImage: "plus")
                            }
                        } label: {
                            languageLabel(targetName)
                        }
                        .buttonStyle(.plain)
                        .diagnosticBorder(.orange.opacity(0.3))
                    } else {
                        Button(action: { appState.shouldShowTargetLanguageModal = true }) {
                            languageLabel(targetName)
                        }
                        .buttonStyle(.plain)
                        .diagnosticBorder(.orange.opacity(0.3))
                    }
                }
            }
            .diagnosticBorder(.green.opacity(0.2))
        }
        .padding(.bottom, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateIn)
        .diagnosticBorder(.white, width: 1)
    }

    private func languageLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: learnScaled(90, hSizeClass: horizontalSizeClass, min: 78, max: 110), weight: .black))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var scrollableContent: some View {
        ZStack(alignment: .top) {
            if state.pullRefreshState != .idle {
                CyberRefreshIndicator(state: state.pullRefreshState, height: max(60, state.scrollOffset), accentColor: ThemeColors.primaryAccent).zIndex(0)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 60) {
                    languageSection
                    interfaceLanguageSection
                    notificationSection
                    locationSection
                    accountSection
                    Spacer(minLength: 100)
                }
                .padding(.top, learnScaled(40, hSizeClass: horizontalSizeClass, min: 34, max: 52))
                .background(Color.black)
                .overlay(scrollOffsetTracker, alignment: .top)
                .diagnosticBorder(.pink.opacity(0.1))
            }
            .coordinateSpace(name: "settingsPullToRefresh")
            .onPreferenceChange(SettingsViewOffsetKey.self) { state.handleRefresh(offset: $0) }
            .diagnosticBorder(.blue.opacity(0.1))
        }
    }
    
    private var scrollOffsetTracker: some View {
        GeometryReader { geo in
            Color.clear.preference(key: SettingsViewOffsetKey.self, value: geo.frame(in: .named("settingsPullToRefresh")).minY)
        }.frame(height: 0)
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
                    width: learnScaled(24, hSizeClass: horizontalSizeClass, min: 24, max: 30),
                    height: learnScaled(120, hSizeClass: horizontalSizeClass, min: 120, max: 150)
                )
                .diagnosticBorder(.cyan, width: 0.5)

                VStack(alignment: .leading, spacing: 4) {
                    Text(NativeLanguageMapping.shared.getDisplayNames(for: appState.nativeLanguage).english.uppercased())
                        .font(.system(size: learnScaled(50, hSizeClass: horizontalSizeClass, min: 44, max: 62), weight: .black))
                        .foregroundColor(ThemeColors.secondaryAccent)
                    
                    HStack(spacing: 8) {
                        Text("\(NativeLanguageMapping.shared.getDisplayNames(for: appState.nativeLanguage).english)")
                            .font(learnFont(size: 14, weight: .bold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(.gray)
                        Text("/").foregroundColor(.gray)
                        
                        Button(action: { appState.shouldShowNativeLanguageModal = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                Text(languageManager.ui.edit.uppercased())
                            }
                            .font(learnFont(size: 14, weight: .bold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(.white)
                            .diagnosticBorder(.white.opacity(0.2))
                        }
                    }
                    .diagnosticBorder(.blue.opacity(0.1))
                    
                    // Native Neural Status
                    let nativeCode = appState.nativeLanguage
                    let status = state.neuralStatuses[nativeCode]?.state ?? "WAITING"
                    let color = state.statusColor(status)
                    
                    Text("NEURAL ENGINE: \(status)")
                        .font(learnFont(size: 10, weight: .bold, hSizeClass: horizontalSizeClass))
                        .foregroundColor(color)
                        .padding(.top, learnScaled(4, hSizeClass: horizontalSizeClass, min: 4, max: 6))
                }
                .diagnosticBorder(.pink.opacity(0.2))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .diagnosticBorder(.blue.opacity(0.3), width: 1)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.1), value: animateIn)
        .diagnosticBorder(.cyan, width: 1)
    }

    private var interfaceLanguageSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.system(size: learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 26)))
                Text(languageManager.settings.systemLanguage.uppercased()).font(learnFont(size: 24, weight: .black, hSizeClass: horizontalSizeClass))
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            .diagnosticBorder(.blue.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(languageManager.currentLanguage.displayName)
                        .font(learnFont(size: 20, weight: .regular, hSizeClass: horizontalSizeClass))
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
                                .diagnosticBorder(.green.opacity(0.1))
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text(languageManager.ui.edit.uppercased())
                        }
                        .font(learnFont(size: 14, weight: .bold, hSizeClass: horizontalSizeClass))
                        .foregroundColor(ThemeColors.neonCyan)
                        .diagnosticBorder(.cyan.opacity(0.2))
                    }
                }
                .padding(.horizontal, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
                .padding(.vertical, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
                .background(
                    ZStack {
                        Color.black.opacity(0.6)
                        GridPattern()
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    }
                    .diagnosticBorder(.green.opacity(0.1))
                )
                .overlay(TechFrameBorder(isSelected: false))
                .diagnosticBorder(.blue.opacity(0.2))
            }
            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            .diagnosticBorder(.pink.opacity(0.1))
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.2), value: animateIn)
        .frame(maxWidth: .infinity, alignment: .leading)
        .diagnosticBorder(.orange.opacity(0.2))
    }

    // MARK: - Neural Engine status
    
    // MARK: - Neural Engine status (Integrated into Headers)
    // Legacy section removed.

    
    // MARK: - Personalization Refresh
    
    

    


    // MARK: - Location
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 26)))
                Text(languageManager.settings.location.uppercased()).font(learnFont(size: 24, weight: .black, hSizeClass: horizontalSizeClass))
                Spacer()
                Toggle("", isOn: Binding(
                    get: { appState.isLocationTrackingEnabled },
                    set: { newValue in
                        if newValue {
                            LocationManager.shared.ensureLocationAccess { granted in
                                DispatchQueue.main.async {
                                    appState.isLocationTrackingEnabled = granted
                                }
                            }
                        } else {
                            appState.isLocationTrackingEnabled = false
                        }
                    }
                ))
                    .labelsHidden()
                    .diagnosticBorder(.green.opacity(0.2))
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            .diagnosticBorder(.blue.opacity(0.1))
            
            Text("Identify nearby \"Lesson Zones\" like coffee shops or libraries for immersive practice.")
                .font(learnFont(size: 14, hSizeClass: horizontalSizeClass))
                .foregroundColor(ThemeColors.textGray)
                .lineSpacing(4)
                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                .diagnosticBorder(.orange.opacity(0.1))
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.3), value: animateIn)
        .frame(maxWidth: .infinity, alignment: .leading)
        .diagnosticBorder(ThemeColors.secondaryAccent, width: 1)
    }

    // MARK: - Notifications
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 26)))
                Text(languageManager.settings.notifications.uppercased()).font(learnFont(size: 24, weight: .black, hSizeClass: horizontalSizeClass))
                Spacer()
                Toggle("", isOn: Binding(
                    get: { NotificationManager.shared.isNotificationsEnabled },
                    set: { newValue in
                        if newValue {
                            NotificationManager.shared.ensureNotificationAccess { granted in
                                DispatchQueue.main.async {
                                    NotificationManager.shared.isNotificationsEnabled = granted
                                }
                            }
                        } else {
                            NotificationManager.shared.isNotificationsEnabled = false
                        }
                    }
                ))
                .labelsHidden()
                .diagnosticBorder(.green.opacity(0.2))
            }
            .foregroundColor(.white.opacity(0.3))
            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            .diagnosticBorder(.blue.opacity(0.1))
            
            Text("Get real-time updates on nearby practice opportunities and streak alerts.")
                .font(learnFont(size: 14, hSizeClass: horizontalSizeClass))
                .foregroundColor(ThemeColors.textGray)
                .lineSpacing(4)
                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                .diagnosticBorder(.orange.opacity(0.1))
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.25), value: animateIn)
        .frame(maxWidth: .infinity, alignment: .leading)
        .diagnosticBorder(.blue.opacity(0.3), width: 1)
    }

    // MARK: - Account
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                // Vertical White Label (Simplified like Native Language bar)
                VerticalHeading(
                    text: languageManager.settings.account.uppercased(),
                    textColor: .black,
                    backgroundColor: .white,
                    width: learnScaled(24, hSizeClass: horizontalSizeClass, min: 24, max: 30),
                    height: learnScaled(132, hSizeClass: horizontalSizeClass, min: 132, max: 164)
                )
                .diagnosticBorder(.white, width: 0.5)

                HStack(spacing: 20) {
                    accountBox(title: languageManager.settings.logout, icon: "arrow.right.square", color: ThemeColors.neonCyan, isLoading: state.isLoggingOut) { state.showingLogoutAlert = true }
                        .diagnosticBorder(ThemeColors.neonCyan.opacity(0.2))
                    accountBox(title: languageManager.ui.delete, icon: "trash", color: ThemeColors.secondaryAccent, isLoading: state.isDeletingAccount) { state.showingDeleteAlert = true }
                        .diagnosticBorder(ThemeColors.secondaryAccent.opacity(0.2))
                }
                .diagnosticBorder(.blue.opacity(0.1))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .diagnosticBorder(.green.opacity(0.2))
            
            Text(languageManager.settings.systemConfig.uppercased())
                .font(learnFont(size: 10, weight: .bold, hSizeClass: horizontalSizeClass))
                .foregroundColor(.white.opacity(0.3))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 26))
                .diagnosticBorder(.white.opacity(0.1))
            
            // DIAGNOSTIC BORDERS TOGGLE
            HStack {
                Text("DIAGNOSTIC BORDERS")
                    .font(learnFont(size: 14, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Toggle("", isOn: $appState.showDiagnosticBorders)
                    .labelsHidden()
                    .diagnosticBorder(.green.opacity(0.2))
            }
            .padding(.horizontal, learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 28))
            .padding(.top, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
            .diagnosticBorder(.blue.opacity(0.1))

            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                appState.requestLearnCoachTourFromSettings()
            }) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: learnScaled(4, hSizeClass: horizontalSizeClass, min: 3, max: 6)) {
                        Text("SEE LEARN TAB TOUR")
                            .font(learnFont(size: 14, weight: .bold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Replay the guided walkthrough on the Learn screen (place cards, sentence, graph, start).")
                            .font(learnFont(size: 13, weight: .regular, hSizeClass: horizontalSizeClass))
                            .foregroundColor(ThemeColors.textGray)
                            .lineSpacing(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: learnScaled(14, hSizeClass: horizontalSizeClass, min: 13, max: 16), weight: .bold))
                        .foregroundColor(ThemeColors.neonCyan)
                }
                .padding(.horizontal, learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 28))
                .padding(.vertical, learnScaled(12, hSizeClass: horizontalSizeClass, min: 10, max: 16))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .diagnosticBorder(.green.opacity(0.15))
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.35), value: animateIn)
        .frame(maxWidth: .infinity, alignment: .leading)
        .diagnosticBorder(ThemeColors.success.opacity(0.3), width: 1)
        .diagnosticBorder(.white.opacity(0.1), width: 2)
    }
    
    private func accountBox(title: String, icon: String, color: Color, isLoading: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(learnFont(size: 20, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(.white.opacity(0.5)) // Opacity 0.5
                
                ZStack {
                    Rectangle().fill(Color.white.opacity(0.05))
                    
                    if isLoading {
                        ProgressView()
                            .tint(color)
                            .scaleEffect(1.5)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: learnScaled(40, hSizeClass: horizontalSizeClass, min: 40, max: 50)))
                            .foregroundColor(color)
                    }
                    
                    VStack {
                        HStack {
                            Text("..").font(learnFont(size: 8, hSizeClass: horizontalSizeClass)).foregroundColor(ThemeColors.textGray)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Text("..").font(learnFont(size: 8, hSizeClass: horizontalSizeClass)).foregroundColor(ThemeColors.textGray)
                        }
                    }.padding(learnScaled(4, hSizeClass: horizontalSizeClass, min: 4, max: 6))
                }
                .frame(width: learnScaled(100, hSizeClass: horizontalSizeClass, min: 100, max: 124), height: learnScaled(100, hSizeClass: horizontalSizeClass, min: 100, max: 124))
                .overlay(Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                .diagnosticBorder(color.opacity(0.5), width: 1)
            }
            .diagnosticBorder(.white.opacity(0.1), width: 1)
        }
    }
}

struct SettingsViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


