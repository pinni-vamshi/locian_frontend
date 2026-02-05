//
//  StatsTabState.swift
//  locian
//
//  Logic Controller for Stats Tab
//

import SwiftUI
import Combine

class StatsTabState: ObservableObject {
    var appState: AppStateManager
    
    // Cached Data
    @Published var practiceDatesSet: Set<Date> = []
    @Published var studiedHours: Set<Int> = []
    @Published var sortedMonths: [Date] = []
    
    // UI State
    @Published var pullRefreshState: CyberRefreshState = .idle
    @Published var scrollOffset: CGFloat = 0.0
    @Published var isRefreshFinished: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppStateManager) {
        self.appState = appState
        setupBindings()
    }
    
    private func setupBindings() {
        appState.$userLanguagePairs
            .sink { [weak self] _ in
                self?.refreshData()
            }
            .store(in: &cancellables)
            
        appState.$timeline
            .sink { [weak self] _ in
                self?.updateStudiedHours()
            }
            .store(in: &cancellables)
    }
    
    func refreshData() {
        if let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
            updatePracticeDatesCache(practiceDates: pair.practice_dates)
        }
        updateStudiedHours()
    }
    
    private func updateStudiedHours() {
        guard let places = appState.timeline?.places else { 
            print("📊 [StatsState] No timeline places found for studiedHours.")
            return 
        }
        
        var hoursSet = Set<Int>()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        for place in places {
            if let h = place.hour {
                hoursSet.insert(h)
            } else if let tStr = place.time, let date = formatter.date(from: tStr) {
                let h = Calendar.current.component(.hour, from: date)
                hoursSet.insert(h)
            }
        }
        
        print("📊 [StatsState] Extracted \(hoursSet.count) unique study hours: \(hoursSet.sorted())")
        
        DispatchQueue.main.async {
            self.studiedHours = hoursSet
        }
    }
    
    func onAppear() {
        if !appState.hasLoadedLanguages {
            appState.loadAvailableLanguagePairs { [weak self] success in
                if success {
                    DispatchQueue.main.async { self?.refreshData() }
                    self?.fetchTimelineIfNeeded()
                }
            }
        } else {
            refreshData()
            fetchTimelineIfNeeded()
        }
    }
    
    private func fetchTimelineIfNeeded() {
        if (appState.timeline == nil || !appState.hasInitialHistoryLoaded) && !appState.isLoadingTimeline, let token = appState.authToken {
            appState.isLoadingTimeline = true
            LearnTabService.shared.fetchAndLoadContent(sessionToken: token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self?.appState.timeline = data.timeline
                    case .failure(let error):
                        print("Failed to load stats history: \(error)")
                    }
                    self?.appState.isLoadingTimeline = false
                    self?.appState.hasInitialHistoryLoaded = true
                }
            }
        }
    }
    
    private func updatePracticeDatesCache(practiceDates: [String]) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var dateSet: Set<Date> = []
        var monthSet: Set<Date> = []
        
        // Add current month by default
        let now = Date()
        if let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
            monthSet.insert(currentMonth)
        }
        
        for dateString in practiceDates {
            if let date = dateFormatter.date(from: dateString) {
                let startOfDay = calendar.startOfDay(for: date)
                dateSet.insert(startOfDay)
                
                // Extract month start
                if let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: startOfDay)) {
                    monthSet.insert(monthStart)
                }
            }
        }
        
        self.practiceDatesSet = dateSet
        self.sortedMonths = monthSet.sorted(by: { $0 > $1 }) // Newest first
        print("📅 [StatsState] Calculated \(sortedMonths.count) scrollable months.")
    }
    
    func handleRefresh(offset: CGFloat) {
        if abs(self.scrollOffset - offset) > 0.5 { self.scrollOffset = offset }
        if isRefreshFinished {
            if offset < 10 {
                withAnimation(.spring()) {
                    pullRefreshState = .idle
                    isRefreshFinished = false
                }
            }
            return
        }
        if pullRefreshState == .loading || pullRefreshState == .finishing { return }
        
        if offset > 110 {
            pullRefreshState = .loading
            isRefreshFinished = false
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                await self.forceRefreshLanguages()
                DispatchQueue.main.async {
                    withAnimation { self.pullRefreshState = .finishing }
                    self.isRefreshFinished = true
                }
            }
        } else if offset > 0 {
            pullRefreshState = .pulling(progress: min(1.0, offset / 110.0))
        } else {
            pullRefreshState = .idle
        }
    }
    
    // MARK: - Calculated Stats (from practice_dates)
    
    /// Current streak - calculated from practice dates
    var currentStreak: Int {
        guard let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first else {
            return 0
        }
        return calculateCurrentStreak(practiceDates: pair.practice_dates)
    }
    
    /// Longest streak - calculated from practice dates
    var longestStreak: Int {
        guard let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first else {
            return 0
        }
        return calculateLongestStreak(practiceDates: pair.practice_dates)
    }
    
    /// Chronotype - calculated from practice dates and timeline
    var chronotype: String {
        guard let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first else {
            return "NIGHT OWL"
        }
        return determineChronotype(practiceDates: pair.practice_dates)
    }
    
    // MARK: - Private Calculation Methods
    
    private func calculateCurrentStreak(practiceDates: [String]) -> Int {
        guard !practiceDates.isEmpty else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let validDates = practiceDates.compactMap { formatter.date(from: $0) }
        guard !validDates.isEmpty else { return 0 }
        
        let uniqueDates = Set(validDates)
        let sortedDates = uniqueDates.sorted(by: >) // Descending (Newest first)
        
        let calendar = Calendar.current
        let today = Date()
        
        guard let latestDate = sortedDates.first else { return 0 }
        
        // Check if streak is alive (Last practice must be Today or Yesterday)
        let isToday = calendar.isDateInToday(latestDate)
        let isYesterday = calendar.isDate(latestDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!)
        
        if !isToday && !isYesterday {
            return 0
        }
        
        // Count backwards
        var currentStreak = 1
        var previousDate = latestDate
        
        for i in 1..<sortedDates.count {
            let date = sortedDates[i]
            
            if let expectedPrevDay = calendar.date(byAdding: .day, value: -1, to: previousDate),
               calendar.isDate(date, inSameDayAs: expectedPrevDay) {
                currentStreak += 1
                previousDate = date
            } else {
                break
            }
        }
        
        return currentStreak
    }
    
    private func calculateLongestStreak(practiceDates: [String]) -> Int {
        guard !practiceDates.isEmpty else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let validDates = practiceDates.compactMap { formatter.date(from: $0) }
        guard !validDates.isEmpty else { return 0 }
        
        let uniqueDates = Set(validDates)
        let sortedDates = uniqueDates.sorted()
        
        var maxStreak = 1
        var currentStreak = 1
        let calendar = Calendar.current
        
        for i in 0..<(sortedDates.count - 1) {
            let currentDate = sortedDates[i]
            let nextDate = sortedDates[i + 1]
            
            if let dayAfter = calendar.date(byAdding: .day, value: 1, to: currentDate),
               calendar.isDate(dayAfter, inSameDayAs: nextDate) {
                currentStreak += 1
            } else {
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 1
            }
        }
        
        maxStreak = max(maxStreak, currentStreak)
        return maxStreak
    }
    
    private func determineChronotype(practiceDates: [String]) -> String {
        var hourCounts = [Int](repeating: 0, count: 24)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Count hours from practice dates (if they have time info)
        // For now, use timeline data for hour distribution
        if let places = appState.timeline?.places {
            for place in places {
                if let h = place.hour {
                    hourCounts[h] += 1
                }
            }
        }
        
        // Find peak 3-hour window
        var maxWindowCount = 0
        var bestWindowStart = 0
        
        for h in 0..<24 {
            let c1 = hourCounts[h]
            let c2 = hourCounts[(h+1)%24]
            let c3 = hourCounts[(h+2)%24]
            let total = c1 + c2 + c3
            if total > maxWindowCount {
                maxWindowCount = total
                bestWindowStart = h
            }
        }
        
        let peakCenter = (bestWindowStart + 1) % 24
        
        switch peakCenter {
        case 5..<12:
            return "EARLY BIRD"
        case 12..<17:
            return "DAY WALKER"
        default:
            return "NIGHT OWL"
        }
    }
    
    // MARK: - Local Orchestration
    
    @MainActor
    private func forceRefreshLanguages() async {
        await withCheckedContinuation { continuation in
            appState.loadAvailableLanguagePairs { _ in
                continuation.resume()
            }
        }
    }
}
