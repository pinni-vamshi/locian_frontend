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
    }
    
    func refreshData() {
        let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        updatePracticeDatesCache(practiceDates: pair?.practice_dates ?? [])
        updateStudiedHours()
        updateChronotype()
    }
    
    private func updateStudiedHours() {
        // V3 cleanup: timelinePlaces no longer used for local stats calculation
    }
    
    func onAppear() {
        if !appState.hasLoadedLanguages {
            appState.loadAvailableLanguagePairs { [weak self] success in
                if success {
                    DispatchQueue.main.async { self?.refreshData() }
                }
            }
        } else {
            refreshData()
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
    
    @Published var chronotype: String = "NIGHT OWL"
    
    // MARK: - Private Calculation Methods
    
    private func updateChronotype() {
        guard let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first else {
            self.chronotype = "NIGHT OWL"
            return
        }
        self.chronotype = determineChronotype(practiceDates: pair.practice_dates)
    }
    
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
        // V3 cleanup: timelinePlaces no longer used. Defaulting to Night Owl for now.
        return "NIGHT OWL"
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
