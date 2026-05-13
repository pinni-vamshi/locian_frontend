//
//  MainTabView.swift
//  locian
//
//  Custom bottom tab bar with 3 tabs: Learn, Progress, Settings
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab: TabItem = .learn
    @State private var isInitializing: Bool = true
    
    // Shared state for Tabs
    @StateObject private var learnTabState: LearnTabState
    @StateObject private var statsTabState: StatsTabState

    enum TabItem: Int, CaseIterable {
        case learn = 0
        case progress = 1
        case settings = 2

        var icon: String {
            switch self {
            case .learn: return "book.fill"
            case .progress: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }

    }

    init(appState: AppStateManager) {
        self.appState = appState
        let learnState = LearnTabState(appState: appState)
        self._learnTabState = StateObject(wrappedValue: learnState)
        self._statsTabState = StateObject(wrappedValue: StatsTabState(appState: appState))
    }

    var body: some View {
        ZStack {
            // Content Layer: Only render when NOT initializing to prevent Main Thread layout hits during branding
            if !isInitializing {
                VStack(spacing: 0) {
                    // Tab content
                    Group {
                        switch selectedTab {
                        case .learn:
                            LearnTabView(appState: appState, state: learnTabState, selectedTab: $selectedTab)
                        case .progress:
                            StatsTabView(appState: appState, state: statsTabState, selectedTab: $selectedTab)
                        case .settings:
                            SettingsView(appState: appState, selectedTab: $selectedTab)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Custom tab bar attached to bottom - hide when analyzing image OR in lesson
                    if !appState.isAnalyzingImage && !appState.isLessonActive {
                        customTabBar
                    }
                }
                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                .diagnosticBorder(.white.opacity(0.1), width: 3)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            
            // Initial Initialization Overlay (Always present during startup)
            if isInitializing {
                AppLaunchLoadingView(appState: appState)
                    .id("AppLaunchLoadingView") // Stable identity prevents "jumping" on state updates
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .opacity
                    ))
                    .zIndex(10)
            }
        }
        .diagnosticBorder(.cyan.opacity(0.2), width: 4)
        .onAppear {
            // Telemetry sensors are now strictly on-demand.
            // Each service triggers, reads, and stops independently when its endpoint is called.
            
            // Start the minimum animation timer (Match AppLaunchLoadingView duration exactly: 0.3s)
            // No extra settlement buffer - transition immediately.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("⏱️ [MainTabView] Branding Animation Timer Completed (0.3s).")
                appState.minAnimationIntervalCompleted = true
            }
            
            // 🚨 SAFETY TIMEOUT: Force unlock after 4 seconds if data hangs (Prevents "Stuck" Bug)
            // Reduced to 4s for the fastest possible launch experience
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                if isInitializing {
                    print("⚠️ [MainTabView] SAFETY TIMEOUT REACHED. Force-unlocking UI...")
                    withAnimation(.easeOut(duration: 0.3)) { isInitializing = false }
                }
            }
            
            // Initial routing set to Learn tab by default in V3
            performInitialRouting()
        }
        .onChange(of: appState.minAnimationIntervalCompleted) { oldValue, completed in
            if completed {
                performInitialRouting()
            }
        }
        .onChange(of: appState.startupMomentsStatus) { oldValue, status in
            if status == .succeeded || status == .failed {
                print("📡 [MainTabView] Discovery status changed: \(status). Re-evaluating routing.")
                performInitialRouting()
            }
        }
        .onChange(of: appState.shouldShowSettingsView) { old, shouldShow in
            if shouldShow {
                selectedTab = .settings
                // Reset the state immediately so it can be triggered again if needed
                appState.shouldShowSettingsView = false
            }
        }
        .onChange(of: appState.pendingDeepLinkPlace) { old, placeName in
            if let placeName = placeName, let hour = appState.pendingDeepLinkHour {
                print("📱 [MainTabView] Deep link detected: \(placeName). Switching to Learn tab.")
                selectedTab = .learn
                
                // Trigger the deep link handling
                learnTabState.handleDeepLink(placeName: placeName, hour: hour)
                
                // Clear the deep link so it doesn't trigger again
                appState.pendingDeepLinkPlace = nil
                appState.pendingDeepLinkHour = nil
            }
        }
    }
    
    private func performInitialRouting() {
        let animationReady = appState.minAnimationIntervalCompleted
        
        print("🧠 [Routing] Checking Readiness -> Animation: \(animationReady)")
        
        // 🚀 INSTANT LAUNCH: Dismiss the loading view as soon as branding animation is done (0.1s)
        // We no longer wait for background discovery data to avoid "hanging" the user
        if animationReady {
            print("✅ [Routing] Branding animation ready (0.3s). Dismissing loading view.")
            withAnimation(.easeOut(duration: 0.3)) {
                isInitializing = false
            }
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                customTabButton(for: tab)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 70) // Fixed container height
        .background(
            // Solid bar attached to screen bottom
            Color.black
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 0.5),
            alignment: .top
        )
        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: -2)
        .diagnosticBorder(Color.white.opacity(0.3), width: 1) // DEBUG: Global Tab Bar Frame
    }
    
    // Helper function to get localized tab title
    private func tabTitle(for tab: TabItem) -> String {
        switch tab {
        case .learn: return localizationManager.string(.learnTab)
        case .progress: return localizationManager.string(.progressTab)
        case .settings: return localizationManager.string(.settings)
        }
    }

    @ViewBuilder
    private func customTabButton(for tab: TabItem) -> some View {
        let isSelected = (tab == selectedTab)

        Button(action: {
            selectedTab = tab
        }) {
            HStack(spacing: 0) {
                // Mirror text on left (hidden) to keep icon centered
                if isSelected {
                    Text(tabTitle(for: tab))
                        .font(.system(size: 15, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .opacity(0)
                }

                // Icon: Pink if selected, Gray/White if not. No background.
                Image(systemName: tab.icon)
                    .font(.system(size: 24, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? ThemeColors.secondaryAccent : Color.white.opacity(0.4))

                // Text: Only show if selected
                if isSelected {
                    Text(tabTitle(for: tab))
                        .font(.system(size: 15, weight: .bold)) // Increased from 10
                        .foregroundColor(ThemeColors.secondaryAccent)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            SelectedTabBorder()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.8),
                                            Color.white.opacity(0.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // Ensure tap area covers the whole stack
            .diagnosticBorder(isSelected ? Color.pink.opacity(0.5) : Color.gray.opacity(0.2), width: 1) // DEBUG: Tab Button Frame
        }
        .frame(height: 50)
        .buttonStyle(.plain)
    }
    
}



// Border for selected tab text: Top, Bottom, and Right sides only
struct SelectedTabBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start Top-Left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
