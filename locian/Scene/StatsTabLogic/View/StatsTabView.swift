//
//  StatsTabView.swift
//  locian
//
//  Consolidated Stats Tab UI (Single File UI)
//

import SwiftUI

struct StatsTabView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var state: StatsTabState
    @Binding var selectedTab: MainTabView.TabItem
    @State private var showingStreakModal = false
    @State private var animateIn = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                if let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                    mainContent(pair: pair, geometry: geometry)
                        .diagnosticBorder(.purple, width: 2, label: "MAIN")
                } else {
                    noProgressPlaceholder
                        .diagnosticBorder(.gray, width: 1, label: "EMPTY")
                }
            }
            .diagnosticBorder(.white, width: 2, label: "ROOT_ZSTACK")
        }
        .onAppear { 
            animateIn = false
            state.onAppear()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
            }
        }
        .onDisappear { 
            withAnimation(.none) { animateIn = false }
        }
        .fullScreenCover(isPresented: $showingStreakModal) { streakModal }
    }

    @ViewBuilder
    private func mainContent(pair: LanguagePair, geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            StatsHeaderView(appState: appState, state: state, pair: pair, geometry: geometry, scrollOffset: state.scrollOffset)
                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 10)
                .diagnosticBorder(.orange, width: 1, label: "HEADER")
            
            Divider().background(Color.white.opacity(0.1))
            
            ZStack(alignment: .top) {
                if state.pullRefreshState != .idle {
                    CyberRefreshIndicator(state: state.pullRefreshState, height: max(60, state.scrollOffset), accentColor: ThemeColors.primaryAccent).zIndex(0)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        StatsCalendarSection(appState: appState, pair: pair, practiceSet: state.practiceDatesSet, cachedSortedMonths: $state.sortedMonths)
                            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                            .animation(.spring().delay(0.1), value: animateIn)
                            .diagnosticBorder(.pink, width: 1, label: "CALENDAR")
                        
                        StatsChronotypeSection(appState: appState, pair: pair, chronotype: state.chronotype, cachedStudiedHours: $state.studiedHours)
                            .padding(.top, 20)
                            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                            .animation(.spring().delay(0.15), value: animateIn)
                            .diagnosticBorder(.blue, width: 1, label: "CHRONO_P:20")
                    }
                    .diagnosticBorder(.white.opacity(0.1), width: 1.5, label: "SCROLL_V_S:0")
                    .background(Color.black).padding(.bottom, 100).overlay(scrollOffsetTracker, alignment: .top)
                }
                .diagnosticBorder(.cyan, width: 2, label: "SCROLL")
                .coordinateSpace(name: "statsPullToRefresh")
                .onPreferenceChange(StatsViewOffsetKey.self) { state.handleRefresh(offset: $0) }
            }.zIndex(1)
            .diagnosticBorder(.blue.opacity(0.5), width: 1)
        }
        .diagnosticBorder(.white, width: 1)
    }

    private var noProgressPlaceholder: some View {
        VStack(spacing: 24) {
            Text(LocalizationManager.shared.string(.progressTab)).font(.system(size: 32, weight: .bold)).foregroundColor(.white)
            Text(LocalizationManager.shared.string(.addLanguagePairToSeeProgress)).font(.system(size: 16, weight: .regular)).foregroundColor(.white.opacity(0.7)).multilineTextAlignment(.center).padding(.horizontal, 24)
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var streakModal: some View {
        Group {
            if let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                EditStreakModal(appState: appState, pair: pair, streak: state.currentStreak, onDismiss: { showingStreakModal = false })
            } else { Color.black }
        }
    }

    private var scrollOffsetTracker: some View {
        GeometryReader { geo in Color.clear.preference(key: StatsViewOffsetKey.self, value: geo.frame(in: .named("statsPullToRefresh")).minY) }.frame(height: 0)
    }
}

// MARK: - Subviews
struct StatsHeaderView: View {
    @ObservedObject var appState: AppStateManager; @ObservedObject var state: StatsTabState; let pair: LanguagePair; let geometry: GeometryProxy; var scrollOffset: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Streak Status Badge
            HStack(spacing: 6) {
                Image(systemName: "flame.fill").font(.system(size: 10))
                Text(LocalizationManager.shared.string(.streakStatus).uppercased()).font(.system(size: 15, weight: .bold, design: .monospaced))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(red: 1.0, green: 0.1, blue: 0.4))
            .padding(.bottom, 12)

            // 2. Giant Language Name
            let names = TargetLanguageMapping.shared.getDisplayNames(for: pair.target_language)
            Text(names.native.uppercased())
                .font(.system(size: 80, weight: .black)) // Reduced from 90 to 80
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.bottom, -12) // Pushed slightly closer to streaks
                .diagnosticBorder(.white.opacity(0.3), width: 1, label: "HDR_80PT")

            // 3. Streak Numbers
            HStack(alignment: .center, spacing: 12) { // Tightened from 24 to 12
                // Current Streak
                HStack(alignment: .center, spacing: 10) {
                    // Two Parallel Vertical Lines
                    HStack(alignment: .center, spacing: 2) {
                        Text(LocalizationManager.shared.string(.currentLabel))
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.gray)
                            .fixedSize()
                            .rotationEffect(.degrees(-90))
                            .frame(width: 14)
                        
                        Text(LocalizationManager.shared.string(.streakLabel))
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.gray)
                            .fixedSize()
                            .rotationEffect(.degrees(-90))
                            .frame(width: 14)
                    }
                    .frame(height: 40) // Constrain height to prevent expansion
                    .diagnosticBorder(.white.opacity(0.1), width: 0.5, label: "V_LABEL_HS")
                    
                    ZStack {
                        Text("\(state.currentStreak)")
                            .font(.system(size: 120, weight: .black))
                            .foregroundColor(Color(red: 1.0, green: 0.1, blue: 0.4))
                            .offset(x: 4, y: 4)
                            .diagnosticBorder(.red.opacity(0.3), width: 0.5, label: "BG_SHADOW")
                        Text("\(state.currentStreak)")
                            .font(.system(size: 120, weight: .black))
                            .foregroundColor(.cyan)
                            .diagnosticBorder(.cyan.opacity(0.3), width: 0.5, label: "FG")
                    }
                    .diagnosticBorder(.white.opacity(0.2), width: 1, label: "STREAK_NUM")
                }
                .diagnosticBorder(.purple.opacity(0.3), width: 1, label: "CUR_HS_S:10")

                // Longest Streak
                HStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 2) {
                        Text(LocalizationManager.shared.string(.longestLabel))
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.gray)
                            .fixedSize()
                            .rotationEffect(.degrees(-90))
                            .frame(width: 14)
                        
                        Text(LocalizationManager.shared.string(.streakLabel))
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.gray)
                            .fixedSize()
                            .rotationEffect(.degrees(-90))
                            .frame(width: 14)
                    }
                    .frame(height: 40) // Constrain height
                    .diagnosticBorder(.white.opacity(0.1), width: 0.5, label: "V_LABEL_HS")
                    Text("\(state.longestStreak)")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(.white)
                        // Removed .italic()
                        .overlay(Rectangle().fill(Color.white).frame(height: 4).rotationEffect(.degrees(-45)).opacity(state.longestStreak == 0 ? 1 : 0))
                        .diagnosticBorder(.white.opacity(0.5), width: 1, label: "LNG_NUM")
                }
            }
            .diagnosticBorder(.blue.opacity(0.5), width: 1, label: "STREAK_HS_S:12") // Updated Label
        }.padding(.horizontal, 5).padding(.top, 20).padding(.bottom, 10) // Reduced top from 24 to 20
            .diagnosticBorder(.white.opacity(0.1), width: 1.5, label: "HDR_P:H20,T20,B10")
        .diagnosticBorder(.cyan, width: 1, label: "STATS_HDR")
    }
}

struct StatsCalendarSection: View {
    @ObservedObject var appState: AppStateManager; let pair: LanguagePair; let practiceSet: Set<Date>; @Binding var cachedSortedMonths: [Date]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // FIXED HEADER REMOVED - NOW SCROLLS INSIDE
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(cachedSortedMonths, id: \.self) { monthStart in
                        // Pass isFirst to render the header in the first block
                        monthBlock(for: monthStart, isFirst: monthStart == cachedSortedMonths.first)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20) // Match ZStack top alignment
            }
            .diagnosticBorder(.cyan.opacity(0.2), width: 1, label: "MONTH_SCROLL")
        }
        .diagnosticBorder(.white.opacity(0.3), width: 1, label: "CAL_SEC_Z")
    }
    
    @ViewBuilder
    private func monthBlock(for monthStart: Date, isFirst: Bool) -> some View {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: monthStart)!
        let daysInMonth = range.count
        
        let monthName = monthFormatter.string(from: monthStart).uppercased()
        
        VStack(alignment: .leading, spacing: 12) {
            // SCROLLING HEADER: Month Name (Parallel to History Log)
            HStack {
                if isFirst {
                    // HISTORY LOG Heading - Now Scrolls with First Month
                    Text(LocalizationManager.shared.string(.historyLog).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .diagnosticBorder(.purple.opacity(0.3), width: 0.5, label: "SCROLL_HDR")
                    Spacer() // Pushes Month Name to right
                } else {
                    Spacer(minLength: 110) // Push month name past the virtual "HISTORY LOG" space (for alignment consistency)
                }
                
                Text(monthName)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .diagnosticBorder(.gray.opacity(0.3), width: 0.5, label: monthName)
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 4) {
                // Days Header (M T W T F S S)
                HStack(spacing: 0) {
                    ForEach([
                        LocalizationManager.shared.string(.monShort),
                        LocalizationManager.shared.string(.tueShort),
                        LocalizationManager.shared.string(.wedShort),
                        LocalizationManager.shared.string(.thuShort),
                        LocalizationManager.shared.string(.friShort),
                        LocalizationManager.shared.string(.satShort),
                        LocalizationManager.shared.string(.sunShort)
                    ], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }
                .diagnosticBorder(.white.opacity(0.05), width: 0.5, label: "DAYS_HS")
                
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    // Padding for the start of the month
                    let weekday = calendar.component(.weekday, from: monthStart)
                    // adjust weekday (1=Sun, 2=Mon... -> 0=Mon, 6=Sun)
                    let offset = (weekday + 5) % 7
                    
                    ForEach(0..<offset, id: \.self) { _ in
                        Color.clear.frame(height: 40)
                    }
                    
                    ForEach(1...daysInMonth, id: \.self) { day in
                        let cellDate = calendar.date(byAdding: .day, value: day - 1, to: monthStart)!
                        let hasPracticed = practiceSet.contains(calendar.startOfDay(for: cellDate))
                        let isToday = calendar.isDateInToday(cellDate)
                        
                        calendarCell(day: day, isToday: isToday, hasPracticed: hasPracticed)
                    }
                }
                .diagnosticBorder(.white.opacity(0.1), width: 0.5, label: "GRID")
            }
            .frame(width: UIScreen.main.bounds.width - 40) // Match screen width minus padding
        }
    }
    
    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM_yyyy"
        return f
    }
    
    private func calendarCell(day: Int, isToday: Bool, hasPracticed: Bool) -> some View {
        ZStack {
            if isToday {
                ChamferedShape(chamferSize: 8, cornerRadius: 0)
                    .fill(Color.white)
                VStack {
                    HStack {
                        Spacer()
                        Circle().fill(Color(red: 1.0, green: 0.1, blue: 0.4)).frame(width: 4, height: 4).padding(4)
                    }
                    Spacer()
                }
                Text("\(day)").font(.system(size: 14, weight: .bold)).foregroundColor(.black)
            } else if hasPracticed {
                ChamferedShape(chamferSize: 8, cornerRadius: 0)
                    .fill(ThemeColors.getColor(for: "Neon Green"))
                Text("\(day)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(Color(red: 1.0, green: 0.1, blue: 0.4))
            } else {
                ChamferedShape(chamferSize: 8, cornerRadius: 0)
                    .fill(Color.white.opacity(0.05))
                Text("\(day)").font(.system(size: 12, weight: .bold)).foregroundColor(.gray)
                
                Path { p in
                    p.move(to: CGPoint(x: 5, y: 5))
                    p.addLine(to: CGPoint(x: 35, y: 35))
                }.stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .frame(height: 40)
        .diagnosticBorder(hasPracticed ? ThemeColors.getColor(for: "Neon Green") : .pink.opacity(0.1), width: 1)
    }
}

struct StatsChronotypeSection: View {
    @ObservedObject var appState: AppStateManager; let pair: LanguagePair; let chronotype: String; @Binding var cachedStudiedHours: Set<Int>
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Chronotype Header
            HStack(spacing: 8) {
                Rectangle().fill(Color.yellow).frame(width: 8, height: 8)
                    .diagnosticBorder(.yellow.opacity(0.5), width: 0.5, label: "SQ")
                Text(LocalizationManager.shared.string(.chronotype)).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(.gray)
                    .diagnosticBorder(.gray.opacity(0.3), width: 0.5, label: "HDR")
            }.padding(.horizontal, 20)
                .diagnosticBorder(.white.opacity(0.1), width: 0.5, label: "TIT_HS")

            // Dynamic Chronotype Card
            let typeInfo = getChronotypeInfo(chronotype)
            HStack(spacing: 20) {
                // Icon Box
                Rectangle()
                    .fill(typeInfo.color)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: typeInfo.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .diagnosticBorder(.white.opacity(0.3), width: 1, label: "ICON")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(typeInfo.title)
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.cyan)
                    
                    Text(typeInfo.description)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                }
            }.padding(.horizontal, 20)
                .diagnosticBorder(.blue.opacity(0.3), width: 1, label: "CHRONO_HS_S:20")

            // Activity Distribution
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationManager.shared.string(.activityDistribution))
                        .font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.cyan).padding(.horizontal, 20)
                        .diagnosticBorder(.cyan.opacity(0.3), width: 0.5, label: "LBL")
                    
                    ZStack(alignment: .bottom) {
                        // 24H Dot Line - Aligned perfectly with labels
                        HStack(spacing: 0) {
                            ForEach(0..<24) { hr in
                                let isStudied = cachedStudiedHours.contains(hr)
                                Circle()
                                    .fill(isStudied ? Color(red: 1.0, green: 0.1, blue: 0.4) : Color.cyan.opacity(0.7)) // SOLID NO DIM
                                    .frame(width: 8, height: 8)
                                    .frame(maxWidth: .infinity)
                                    .diagnosticBorder(isStudied ? .pink.opacity(0.3) : .clear, width: 0.5, label: "\(hr)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20) // MATCHES LABELS
                        .diagnosticBorder(.blue.opacity(0.2), width: 1, label: "DOTS_P:H20")
                    
                    // Hour labels
                    HStack {
                        Text("0").font(.system(size: 8)).foregroundColor(.gray)
                            .diagnosticBorder(.white.opacity(0.1), width: 0.5)
                        Spacer()
                        Text("6").font(.system(size: 8)).foregroundColor(.gray)
                            .diagnosticBorder(.white.opacity(0.1), width: 0.5)
                        Spacer()
                        Text("12").font(.system(size: 8)).foregroundColor(.gray)
                            .diagnosticBorder(.white.opacity(0.1), width: 0.5)
                        Spacer()
                        Text("18").font(.system(size: 8)).foregroundColor(.gray)
                            .diagnosticBorder(.white.opacity(0.1), width: 0.5)
                        Spacer()
                        Text("24").font(.system(size: 8)).foregroundColor(.gray)
                            .diagnosticBorder(.white.opacity(0.1), width: 0.5, label: "L:24")
                    }
                    .padding(.horizontal, 20)
                    .offset(y: 15)
                    .diagnosticBorder(.cyan.opacity(0.2), width: 0.5, label: "LABELS_P:H20")
                }
                .diagnosticBorder(.white.opacity(0.1), width: 1, label: "DIST_Z")
            }.padding(.top, 20)
                .diagnosticBorder(.blue.opacity(0.2), width: 1, label: "DIST_P:T20")
        }.padding(.top, 20)
            .diagnosticBorder(.pink.opacity(0.1), width: 1.5, label: "CHRONO_P:T20")
        .diagnosticBorder(.pink, width: 1, label: "CHRONO_SEC")
    }
    
    private func getChronotypeInfo(_ type: String) -> (icon: String, title: String, description: String, color: Color) {
        switch type {
        case "EARLY BIRD":
            return ("sun.max.fill", 
                    LocalizationManager.shared.string(.earlyBird), 
                    LocalizationManager.shared.string(.earlyBirdDesc), 
                    ThemeColors.secondaryAccent)
        case "DAY WALKER":
            return ("sun.horizon.fill", 
                    LocalizationManager.shared.string(.dayWalker), 
                    LocalizationManager.shared.string(.dayWalkerDesc), 
                    ThemeColors.secondaryAccent)
        default: // NIGHT OWL
            return ("moon.stars.fill", 
                    LocalizationManager.shared.string(.nightOwl), 
                    LocalizationManager.shared.string(.nightOwlDesc), 
                    ThemeColors.secondaryAccent)
        }
    }
}

struct StatsViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
