//
//  StatsTabView.swift
//  locian
//
//  Progress Tab: Unified Control Center (Integrated Audit Layout)
//

import SwiftUI

struct StatsTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appState: AppStateManager
    @ObservedObject var state: StatsTabState
    @Binding var selectedTab: MainTabView.TabItem
    
    @State private var animateIn = false
    @State private var visibleMonthIndex: Int = 0
    
    private var currentDayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                if state.activePair != nil {
                    VStack(spacing: 0) {
                        // 1. MINIMAL FIXED HEADER
                        StatsHeaderView(state: state)
                            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 10)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.0), value: animateIn)
                        
                        // 2. FIXED CALENDAR SECTION
                        VStack(alignment: .leading, spacing: 0) {
                            fullCalendarSection
                        }
                        .padding(.top, learnScaled(32, hSizeClass: horizontalSizeClass, min: 28, max: 40))
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 15)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateIn)
                        
                        // 3. SCROLLABLE DATA SECTION
                        ZStack(alignment: .top) {
                            if state.pullRefreshState != .idle {
                                CyberRefreshIndicator(state: state.pullRefreshState, height: max(60, state.scrollOffset), accentColor: CyberColors.neonPink).zIndex(0)
                            }
                            ScrollView(showsIndicators: false) {
                                dateDetailSection(for: state.selectedHistoryDate ?? currentDayString)
                                    .transition(.opacity)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, learnScaled(120, hSizeClass: horizontalSizeClass, min: 110, max: 150))
                                    .background(Color.black)
                                    .overlay(scrollOffsetTracker, alignment: .top)
                            }
                            .coordinateSpace(name: "statsPullToRefresh")
                            .onPreferenceChange(StatsViewOffsetKey.self) { state.handleRefresh(offset: $0) }
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateIn)
                    }
                } else {
                    noProgressPlaceholder
                }
            }
        }
        .onAppear { 
            animateIn = false
            state.onAppear()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Integrated Redesign Components
    

    private func calculateMonthlyStats(for monthDate: Date) -> (daysPracticed: Int, placesVisited: Int) {
        let calendar = Calendar.current
        let yearMonth = calendar.dateComponents([.year, .month], from: monthDate)
        
        let monthDays = state.dayActivityMap.keys.filter { dateString in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: dateString) else { return false }
            let comps = calendar.dateComponents([.year, .month], from: date)
            return comps.year == yearMonth.year && comps.month == yearMonth.month
        }
        
        let activities = monthDays.compactMap { state.dayActivityMap[$0] }.flatMap { $0 }
        let places = Set(activities.map { $0.place_id })
        
        return (daysPracticed: monthDays.count, placesVisited: places.count)
    }
    
    private var fullCalendarSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let monthsArray = Array(state.sortedMonths.reversed()) // Past months on left, current on right
            let monthDate = monthsArray.indices.contains(visibleMonthIndex) ? monthsArray[visibleMonthIndex] : Date()
            let monthStats = calculateMonthlyStats(for: monthDate)
            
            // 1. FIXED HEADER
            HStack(alignment: .lastTextBaseline) {
                let monthTitle = monthNameAndYear(for: monthDate)
                
                Menu {
                    ForEach(monthsArray.indices.reversed(), id: \.self) { idx in
                        Button(action: {
                            withAnimation {
                                self.visibleMonthIndex = idx
                            }
                        }) {
                            Text(monthNameAndYear(for: monthsArray[idx]))
                                .font(learnFont(size: 14, weight: .medium, hSizeClass: horizontalSizeClass))
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(monthTitle)
                            .font(learnFont(size: 16, weight: .medium, hSizeClass: horizontalSizeClass))
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.down")
                            .font(learnFont(size: 10, weight: .bold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(CyberColors.neonPink)
                    }
                }
                
                Spacer()
                
                // MONTH STATS
                HStack(spacing: 12) {
                    Text("\(monthStats.daysPracticed) DAYS")
                        .font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
                    Text("/")
                        .font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
                    Text("\(monthStats.placesVisited) PLACES")
                        .font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
                }
                .font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
                .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            .padding(.bottom, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
            
            // 3. SCROLLABLE CALENDAR GRID (Months scroll, initials don't)
            TabView(selection: $visibleMonthIndex) {
                ForEach(monthsArray.indices, id: \.self) { index in
                    monthGridView(for: monthsArray[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: learnScaled(80, hSizeClass: horizontalSizeClass, min: 80, max: 100)) // Just tall enough for the single row
            .onAppear {
                // Default to the last month (current month) in the reversed list
                visibleMonthIndex = max(0, state.sortedMonths.count - 1)
            }
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.top, learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 26))
        }
    }
    
    private func dateDetailSection(for dateStr: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            let items = state.dayActivityMap[dateStr] ?? []
            let places = Array(Set(items.map { $0.place_id })).sorted()
            
            if !places.isEmpty {
                // Vertical Places Scroll
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(Array(places.enumerated()), id: \.element) { index, placeId in
                        let placeName = items.first(where: { $0.place_id == placeId })?.place_name.uppercased() ?? "UNKNOWN"
                        let placeSentences = items.filter { $0.place_id == placeId }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(placeName)
                                .font(learnFont(size: 14, weight: .bold, hSizeClass: horizontalSizeClass))
                                .foregroundColor(ThemeColors.neonGreen)
                                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(placeSentences, id: \.pattern_id) { item in
                                    Text(item.sentence)
                                        .font(learnFont(size: 14, weight: .medium, hSizeClass: horizontalSizeClass))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.02))
                                        .border(Color.white.opacity(0.05), width: 1)
                                }
                            }
                            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3 + (Double(index) * 0.06)), value: animateIn)
                    }
                }
                .padding(.top, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
            } else {
                // NO DATA PREVIEW
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("UNKNOWN SECTOR").font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
                            Spacer()
                            Text("--:-- --").font(learnFont(size: 10, hSizeClass: horizontalSizeClass))
                        }
                        Text("NO SENTENCES PRACTICED").font(learnFont(size: 16, weight: .medium, hSizeClass: horizontalSizeClass))
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.02))
                    .border(Color.white.opacity(0.05), width: 1)
                    .opacity(0.5)
                }
                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                .padding(.top, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
            }
        }
    }
    
    private func monthGridView(for monthDate: Date) -> some View {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) else {
            return AnyView(EmptyView())
        }
        
        let days = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
        
        // Horizontal Scroll for the month's days
        return AnyView(
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12)) {
                        ForEach(days, id: \.self) { date in
                            let isFuture = date > Date() && !calendar.isDateInToday(date)
                            Button(action: {
                                if !isFuture {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    let dateStr = formatter.string(from: date)
                                    
                                    withAnimation(.spring()) {
                                        state.selectedHistoryDate = dateStr
                                    }
                                }
                            }) {
                                calendarDayCell(date: date)
                            }
                            .buttonStyle(.plain)
                            .disabled(isFuture)
                            .id(date)
                        }
                    }
                    .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                }
                .onAppear {
                    // Try to scroll to selected date on load
                    if let selectedStr = state.selectedHistoryDate {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        if let selectedDate = formatter.date(from: selectedStr) {
                            if calendar.isDate(selectedDate, equalTo: monthDate, toGranularity: .month) {
                                scrollProxy.scrollTo(selectedDate, anchor: .center)
                            }
                        }
                    }
                }
            }
        )
    }

    private func monthNameAndYear(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).uppercased()
    }
    
    private var fullPlacesListSection: some View {
        EmptyView()
    }
    
    // MARK: - Sub-UI Helpers (Updated)
    
    private func statNode(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(learnFont(size: 8, weight: .bold, hSizeClass: horizontalSizeClass))
                .foregroundColor(color.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(learnFont(size: 32, weight: .black, hSizeClass: horizontalSizeClass))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(learnFont(size: 10, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(color.opacity(0.4))
                    .padding(.bottom, learnScaled(4, hSizeClass: horizontalSizeClass, min: 4, max: 6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
        .background(color.opacity(0.03))
        .border(color.opacity(0.2), width: 1)
    }
    
    private func calendarDayCell(date: Date) -> some View {
        let calendar = Calendar.current
        let isFuture = date > Date() && !calendar.isDateInToday(date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        let isSelected = state.selectedHistoryDate == dateStr
        
        let dfShort = DateFormatter()
        dfShort.dateFormat = "EEE" // "MON", "TUE"
        let dayName = dfShort.string(from: date).uppercased()
        
        let dayNum = calendar.component(.day, from: date)
        
        return ZStack {
            if isSelected {
                ChamferedShape(chamferSize: 0)
                    .fill(CyberColors.neonPink)
            } else {
                ChamferedShape(chamferSize: 0)
                    .fill(Color.white.opacity(0.05))
            }
            
            VStack(spacing: 8) {
                Text(dayName)
                    .font(learnFont(size: 10, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(isSelected ? .black : Color.white.opacity(0.4))
                
                Text("\(dayNum)")
                    .font(learnFont(size: 20, weight: .black, hSizeClass: horizontalSizeClass))
                    .foregroundColor(isSelected ? .black : (isFuture ? Color.white.opacity(0.1) : .white))
            }
            .padding(.vertical, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
            .frame(width: learnScaled(60, hSizeClass: horizontalSizeClass, min: 60, max: 74))
        }
    }
    
    private func placeListItem(name: String, sentences: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(learnFont(size: 14, weight: .black, hSizeClass: horizontalSizeClass))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(sentences, id: \.self) { sentence in
                    Text(sentence)
                        .font(learnFont(size: 12, weight: .medium, hSizeClass: horizontalSizeClass))
                        .foregroundColor(CyberColors.neonCyan.opacity(0.7))
                        .padding(.vertical, learnScaled(4, hSizeClass: horizontalSizeClass, min: 4, max: 6))
                        .padding(.horizontal, learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.02))
                        .border(Color.white.opacity(0.05), width: 1)
                }
            }
            .padding(.leading, 8)
        }
    }
    
    private func calendarDays(for monthDate: Date) -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) else {
            return []
        }
        
        // Pad for start of week
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let padding = weekday - 1
        
        var days: [Date] = []
        for i in 0..<padding {
            if let date = calendar.date(byAdding: .day, value: -(padding - i), to: startOfMonth) {
                days.append(date)
            }
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date).uppercased()
    }
    
    private var noProgressPlaceholder: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(LocalizationManager.shared.string(.progressTab))
                .font(learnFont(size: 32, weight: .bold, hSizeClass: horizontalSizeClass))
                .foregroundColor(.white)
                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            
            Text(LocalizationManager.shared.string(.addLanguagePairToSeeProgress))
                .font(learnFont(size: 16, weight: .regular, hSizeClass: horizontalSizeClass))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, learnScaled(40, hSizeClass: horizontalSizeClass, min: 34, max: 52))
    }

    private var scrollOffsetTracker: some View {
        GeometryReader { geo in Color.clear.preference(key: StatsViewOffsetKey.self, value: geo.frame(in: .named("statsPullToRefresh")).minY) }.frame(height: 0)
    }
}

// MARK: - Sub-Components (Consolidated)

private struct StatsHeaderView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var state: StatsTabState
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Language Name on Pink Background
            Text(state.activeLanguageNativeName)
                .font(learnFont(size: 12, weight: .black, hSizeClass: horizontalSizeClass))
                .foregroundColor(.black)
                .padding(.horizontal, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
                .padding(.vertical, learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12))
                .background(CyberColors.neonPink)
            
            Spacer()
            
            // Streak Data Right-Aligned
            HStack(spacing: learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16)) {
                Text("STREAK")
                    .font(learnFont(size: 10, weight: .black, hSizeClass: horizontalSizeClass))
                    .foregroundColor(Color.white.opacity(0.2))
                
                // Current Streak
                HStack(spacing: learnScaled(4, hSizeClass: horizontalSizeClass, min: 4, max: 6)) {
                    Image(systemName: "flame.fill")
                    Text("\(state.currentStreak)")
                        .font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
                }
                
                // Max Streak
                HStack(spacing: learnScaled(4, hSizeClass: horizontalSizeClass, min: 4, max: 6)) {
                    Image(systemName: "flame.fill")
                    Text("MAX \(state.longestStreak)")
                        .font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
                }
            }
            .font(learnFont(size: 12, weight: .bold, hSizeClass: horizontalSizeClass))
            .foregroundColor(.white)
            .padding(.horizontal, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
            .padding(.vertical, learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12))
            .background(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 0)
        .padding(.top, learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 28))
        .padding(.bottom, 0)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Layout Utilities

private struct StatsActivityFlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let width: CGFloat = proposal.width ?? 300
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        for size in sizes {
            if x + size.width > width {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        height = y + maxHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}

private struct DiagonalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

struct StatsViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
