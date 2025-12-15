//
//  StatsTabView.swift
//  locian
//
//  Progress tab with streak data and calendar
//

import SwiftUI

struct StatsTabView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    @State private var cachedPracticeDatesSet: Set<Date>?
    @State private var showingStreakModal: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            // Align all content to the top of the screen (not vertically centered)
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                if let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                    // Check if there are any practice dates
                    let hasPracticeDates = !defaultPair.practice_dates.isEmpty
                    
                    if hasPracticeDates {
                        // Show calendar with highlighted dates
                        VStack(spacing: 0) {
                            // Header section
                            headerSection(pair: defaultPair, geometry: geometry)
                            
                            // Streak count section
                            streakCountSection(pair: defaultPair)
                            
                            // Calendar scrolling section
                            calendarGridSection(pair: defaultPair)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    } else {
                        // No practice dates - show placeholder
                        noProgressPlaceholderView(pair: defaultPair)
                    }
                } else {
                    VStack(spacing: 24) {
                        Text(languageManager.progress.progress)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(languageManager.progress.addLanguagePairToSeeProgress)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .onAppear {
            
            // Load target languages (get targets endpoint) when Progress tab is tapped
            appState.loadAvailableLanguagePairs { success in
                // After loading, update practice dates cache for current default language
                DispatchQueue.main.async {
                    if let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                        updatePracticeDatesCache(practiceDates: defaultPair.practice_dates)
                    }
                }
            }
        }
        .onChange(of: appState.userLanguagePairs) { oldValue, newValue in
            // Clear cache first to force refresh
            cachedPracticeDatesSet = nil
            if let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                updatePracticeDatesCache(practiceDates: defaultPair.practice_dates)
            }
        }
        .fullScreenCover(isPresented: $showingStreakModal) {
            // Always use the current default pair when opening the editor
            if let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                EditStreakModal(
                    appState: appState,
                    pair: pair,
                    onDismiss: {
                        showingStreakModal = false
                    }
                )
            } else {
                // Fallback empty view if no pair exists
                Color.black
            }
        }
    }
    
    // MARK: - View Components
    
    private func headerSection(pair: LanguagePair, geometry: GeometryProxy) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Left: target language only
            Text(languageDisplayName(for: pair.target_language))
                .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            
            Spacer()
            
            // Right: Edit button only (bigger)
                Button(action: {
                    showingStreakModal = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 32, weight: .bold))
                        .foregroundColor(appState.selectedTheme == "Pure White" ? .white : appState.selectedColor)
                    .frame(width: 56, height: 56)
                }
                .buttonStyle(PlainButtonStyle())
                .circleButtonPressAnimation()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 25)
        .padding(.horizontal, 24)
    }
    
    private func streakCountSection(pair: LanguagePair) -> some View {
        let currentStreak = StreakCalculator.shared.calculateStreak(practiceDates: pair.practice_dates)
        let longestStreak = calculateLongestStreak(practiceDates: pair.practice_dates)
        
        return VStack(spacing: 28) {
            // Current streak big number
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(currentStreak)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Meta info row: current, longest
            HStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text(languageManager.progress.current)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(currentStreak) \(languageManager.progress.days)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Divider()
                    .frame(height: 48)
                    .background(Color.white.opacity(0.3))
                
                VStack(spacing: 6) {
                    Text(languageManager.progress.longest)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(longestStreak) \(languageManager.progress.days)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 60)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
    
    private func calendarGridSection(pair: LanguagePair) -> some View {
        let months = monthsWithPractice(practiceDates: pair.practice_dates)
        
        return ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 32) {
                if months.isEmpty {
                    // If no months with practice, at least show current month
                    currentMonthView(practiceDates: pair.practice_dates)
                } else {
                    // Show all months with practice
                    ForEach(Array(months.enumerated()), id: \.offset) { monthIndex, monthInfo in
                        monthCalendarView(monthInfo: monthInfo, monthIndex: monthIndex, practiceDates: pair.practice_dates)
                            .id("\(monthInfo.monthDate.timeIntervalSince1970)")
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
    
    private func currentMonthView(practiceDates: [String]) -> some View {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        
        guard let currentMonthStart = calendar.date(from: components) else {
            return AnyView(EmptyView())
        }
        
        let appLanguageCode = LanguageManager.shared.currentLanguage.code
        let locale = Locale(identifier: appLanguageCode)
        let monthFormatter = DateFormatter()
        monthFormatter.locale = locale
        monthFormatter.dateFormat = "MMMM"
        let monthName = monthFormatter.string(from: now)
        
        return AnyView(
            monthCalendarView(
                monthInfo: (monthName: monthName, monthDate: currentMonthStart),
                monthIndex: 0,
                practiceDates: practiceDates
            )
            .id("\(currentMonthStart.timeIntervalSince1970)")
        )
    }
    
    private func monthCalendarView(monthInfo: (monthName: String, monthDate: Date), monthIndex: Int, practiceDates: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Month name header
            Text(monthInfo.monthName)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            // Day headers
            dayHeadersView
            
            // Calendar grid
            calendarGridView(month: monthInfo.monthDate, practiceDates: practiceDates)
            
            // Divider between months
            if monthIndex < monthsWithPractice(practiceDates: practiceDates).count - 1 {
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }
        }
    }
    
    private var dayHeadersView: some View {
        let appLanguageCode = LanguageManager.shared.currentLanguage.code
        let locale = Locale(identifier: appLanguageCode)
        let dayFormatter = DateFormatter()
        dayFormatter.locale = locale
        dayFormatter.dateFormat = "EEE"
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.weekday = 1 // Sunday
        let sunday = calendar.date(from: components) ?? Date()
        
        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { dayIndex in
                if let dayDate = calendar.date(byAdding: .day, value: dayIndex, to: sunday) {
                    Text(dayFormatter.string(from: dayDate).prefix(3))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func calendarGridView(month: Date, practiceDates: [String]) -> some View {
        let days = daysInMonth(month)
        let practiceDatesSet = getPracticeDatesSet(practiceDates: practiceDates)
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                calendarDayView(day: day, practiceDatesSet: practiceDatesSet)
                    .id(day?.timeIntervalSince1970 ?? Double(index))
            }
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func calendarDayView(day: Date?, practiceDatesSet: Set<Date>) -> some View {
        if let day = day {
            let dayNumber = Calendar.current.component(.day, from: day)
            let dayStart = Calendar.current.startOfDay(for: day)
            let isPractice = practiceDatesSet.contains(dayStart)
            
            ZStack {
                if isPractice {
                    let accentColor: Color = appState.selectedTheme == "Pure White" ? .white : appState.selectedColor
                    Circle()
                        .fill(accentColor)
                        .frame(width: 36, height: 36)
                }
                
                Text("\(dayNumber)")
                    .font(.system(size: isPractice ? 16 : 14, weight: isPractice ? .bold : .medium))
                    .foregroundColor(isPractice ? .black : .white)
            }
            .frame(height: 40)
        } else {
            Color.clear
                .frame(height: 40)
        }
    }
    
    // MARK: - Helper Methods
    
    private func monthsWithPractice(practiceDates: [String]) -> [(monthName: String, monthDate: Date)] {
        let calendar = Calendar.current
        let appLanguageCode = LanguageManager.shared.currentLanguage.code
        let locale = Locale(identifier: appLanguageCode)
        let monthFormatter = DateFormatter()
        monthFormatter.locale = locale
        monthFormatter.dateFormat = "MMMM"
        
        let practiceDatesSet = getPracticeDatesSet(practiceDates: practiceDates)
        
        // Get unique months from practice dates
        var monthSet: Set<Date> = []
        for practiceDate in practiceDatesSet {
            let components = calendar.dateComponents([.year, .month], from: practiceDate)
            if let monthStart = calendar.date(from: components) {
                monthSet.insert(monthStart)
            }
        }
        
        // Convert to array with month names, sorted by date (most recent first)
        return monthSet.map { monthDate in
            (monthName: monthFormatter.string(from: monthDate), monthDate: monthDate)
        }
        .sorted { $0.monthDate > $1.monthDate }
    }
    
    private func daysInMonth(_ month: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        
        let firstDay = monthInterval.start
        let lastDay = monthInterval.end
        
        // Get first weekday of month (0 = Sunday, 6 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        // Get number of days in month
        let daysInMonth = calendar.dateComponents([.day], from: firstDay, to: lastDay).day ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before month starts
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            var components = calendar.dateComponents([.year, .month], from: firstDay)
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getPracticeDatesSet(practiceDates: [String]) -> Set<Date> {
        if let cached = cachedPracticeDatesSet {
            return cached
        }
        
        var dateSet: Set<Date> = []
        let calendar = Calendar.current
        
        // API returns dates in "yyyy-MM-dd" format (e.g., "2025-12-13")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for dateString in practiceDates {
            if let date = dateFormatter.date(from: dateString) {
                let dayStart = calendar.startOfDay(for: date)
                dateSet.insert(dayStart)
            } else {
            }
        }
        
        return dateSet
    }
    
    private func updatePracticeDatesCache(practiceDates: [String]) {
        cachedPracticeDatesSet = getPracticeDatesSet(practiceDates: practiceDates)
        // Cache updated
    }
    
    private func languageDisplayName(for targetCodeOrName: String) -> String {
        let mapping: [String: String] = [
            "en": "English",
            "ja": "日本語",
            "hi": "हिन्दी",
            "te": "తెలుగు",
            "ta": "தமிழ்",
            "fr": "Français",
            "de": "Deutsch",
            "es": "Español",
            "zh": "中文",
            "ko": "한국어",
            "ru": "Русский",
            "ml": "മലയാളം"
        ]
        
        let value = targetCodeOrName.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.count > 3 { return value }
        return mapping[value.lowercased()] ?? value
    }
    
    private func calculateLongestStreak(practiceDates: [String]) -> Int {
        // Use StreakCalculator.shared instead of duplicating logic
        // This ensures we use the correct API format (yyyy-MM-dd) and maintain consistency
        return StreakCalculator.shared.calculateLongestStreak(practiceDates: practiceDates)
    }
    
    // MARK: - No Progress Placeholder
    
    private func noProgressPlaceholderView(pair: LanguagePair) -> some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section (same as when there's progress)
                headerSection(pair: pair, geometry: geometry)
                
                // Placeholder content
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.white.opacity(0.3))
                    
                    // Main message
                    VStack(spacing: 16) {
                        Text("Start practicing to see your progress and consistency")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Quote
                    VStack(spacing: 12) {
                        Text("\"Consistency is the path to mastery\"")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(appState.selectedTheme == "Pure White" ? .white.opacity(0.9) : appState.selectedColor.opacity(0.9))
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
                .padding(.bottom, 100)
            }
        }
    }
    
}
