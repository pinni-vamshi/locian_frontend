//
//  MainTabView.swift
//  locian
//
//  Custom bottom tab bar with 3 tabs: Learn, Progress, Settings
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab: TabItem = .learn
    @State private var isInitializing: Bool = true
    
    // Shared state for Tabs
    @StateObject private var learnTabState: LearnTabState
    @StateObject private var addTabState: AddTabState
    @StateObject private var statsTabState: StatsTabState

    enum TabItem: Int, CaseIterable {
        case learn = 0
        case add = 1
        case progress = 2
        case settings = 3

        var icon: String {
            switch self {
            case .learn: return "book.fill"
            case .add: return "plus.square.fill"
            case .progress: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }

        var color: Color {
            switch self {
            case .learn: return Color(red: 0.6, green: 0.4, blue: 1.0)    // purple
            case .add: return ThemeColors.primaryAccent
            case .progress: return Color(red: 1.0, green: 0.6, blue: 0.4) // orange
            case .settings: return Color(red: 0.7, green: 0.7, blue: 0.7) // grey
            }
        }
    }

    init(appState: AppStateManager) {
        self.appState = appState
        let learnState = LearnTabState(appState: appState)
        self._learnTabState = StateObject(wrappedValue: learnState)
        self._addTabState = StateObject(wrappedValue: AddTabState(appState: appState, learnState: learnState))
        self._statsTabState = StateObject(wrappedValue: StatsTabState(appState: appState))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Tab content
                Group {
                    switch selectedTab {
                    case .learn:
                        LearnTabView(appState: appState, state: learnTabState)
                    case .add:
                        AddTabView(appState: appState, state: addTabState, selectedTab: $selectedTab)
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
            .diagnosticBorder(.white.opacity(0.1), width: 3)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            // Initial Initialization Overlay
            if isInitializing {
                AppLaunchLoadingView(appState: appState)
                    .transition(.opacity)
                    .zIndex(10)
                    .diagnosticBorder(.purple.opacity(0.3), width: 2)
            }
        }
        .diagnosticBorder(.cyan.opacity(0.2), width: 4)
        .onAppear {
            // Trigger fetch if not already done
            if !appState.hasInitialHistoryLoaded && !appState.isLoadingTimeline {
                learnTabState.fetchFirstRecommendedPlace()
            } else if appState.hasInitialHistoryLoaded {
                performInitialRouting()
            }
        }
        .onChange(of: appState.hasInitialHistoryLoaded) { _, loaded in
            if loaded {
                performInitialRouting()
            }
        }
        .onChange(of: appState.shouldShowSettingsView) { _, shouldShow in
            if shouldShow {
                selectedTab = .settings
                // Reset the state immediately so it can be triggered again if needed
                appState.shouldShowSettingsView = false
            }
        }
        .onChange(of: appState.pendingDeepLinkPlace) { _, placeName in
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
        print("🧠 [Routing] Starting initial routing decision...")
        
        // Logic: If no place is found for current time span, go to Add tab
        // firstRecommendedPlace is nil if processTimeline finds no match for Current section
        if let currentPlace = learnTabState.firstRecommendedPlace {
            print("✅ [Routing] Optimal match found: '\(currentPlace)'. Navigating to LEARN tab.")
            selectedTab = .learn
        } else {
            print("⚠️ [Routing] No optimal match for current time. Navigating to ADD tab.")
            selectedTab = .add
        }
        
        withAnimation(.easeOut(duration: 0.5)) {
            print("🎬 [Routing] Initializing overlay dismissed.")
            isInitializing = false
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
        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: -2)
        .diagnosticBorder(Color.white.opacity(0.3), width: 1) // DEBUG: Global Tab Bar Frame
    }
    
    // Helper function to get localized tab title
    private func tabTitle(for tab: TabItem) -> String {
        switch tab {
        case .learn: return localizationManager.string(.learnTab)
        case .add: return localizationManager.string(.addTab)
        case .progress: return localizationManager.string(.progressTab)
        case .settings: return localizationManager.string(.settings)
        }
    }

    @ViewBuilder
    private func customTabButton(for tab: TabItem) -> some View {
        let isSelected = (tab == selectedTab)

        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.48)) {
                selectedTab = tab
            }
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
    
    // Helper for Non-Slanted Tag Style
    private func nonSlantedTagBackground(color: Color) -> some View {
        ZStack {
            // Shadow (Offset)
            Rectangle()
                .fill(Color.white)
                .offset(x: 3, y: 3)
            
            // Main Body
            Rectangle()
                .fill(color)
        }
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
