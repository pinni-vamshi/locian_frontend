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
    @Published var sortedMonths: [Date] = []
    
    // --- 📊 UNIFIED DATA REPOSITORY (MVVM) ---
    @Published var totalWordsCount: Int = 0
    @Published var uniquePlacesCount: Int = 0
    @Published var dayActivityMap: [String: [PracticeActivityItem]] = [:]
    @Published var placeActivityMap: [String: [PracticeActivityItem]] = [:]
    @Published var chronotype: String = "NIGHT OWL"
    
    // UI State
    @Published var pullRefreshState: CyberRefreshState = .idle
    @Published var scrollOffset: CGFloat = 0.0
    @Published var isRefreshFinished: Bool = false
    @Published var isLoading: Bool = false
    
    // --- 🧭 NAVIGATION & CATEGORY STATE ---
    enum StatsCategory: String, CaseIterable { case calendar, places }
    @AppStorage("stats_selected_category") var selectedCategory: StatsCategory = .calendar
    
    @Published var selectedHistoryDate: String? = nil
    @Published var selectedHistoryPlaceId: String? = nil
    
    // Helper to get YYYY-MM-DD for today
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // UI Metadata & Presentation Logic
    var activePair: LanguagePair? {
        appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
    }

    var activeLanguageNativeName: String {
        activePair?.targetNativeName.uppercased() ?? ""
    }

    struct ChronotypeMetadata {
        let icon: String
        let title: String
        let description: String
        let color: Color
    }

    var isChronotypeUnlocked: Bool {
        !dayActivityMap.isEmpty
    }

    var chronotypeMetadata: ChronotypeMetadata {
        guard isChronotypeUnlocked else {
            return ChronotypeMetadata(
                icon: "lock.rectangle.stack.fill",
                title: "ANALYSIS PENDING",
                description: "Complete more lessons to reveal your unique learning profile.",
                color: Color.white.opacity(0.1)
            )
        }
        
        switch chronotype {
        case "EARLY BIRD":
            return ChronotypeMetadata(icon: "sun.max.fill", title: LocalizationManager.shared.string(.earlyBird), description: LocalizationManager.shared.string(.earlyBirdDesc), color: ThemeColors.secondaryAccent)
        case "DAY WALKER":
            return ChronotypeMetadata(icon: "sun.horizon.fill", title: LocalizationManager.shared.string(.dayWalker), description: LocalizationManager.shared.string(.dayWalkerDesc), color: ThemeColors.secondaryAccent)
        default:
            return ChronotypeMetadata(icon: "moon.stars.fill", title: LocalizationManager.shared.string(.nightOwl), description: LocalizationManager.shared.string(.nightOwlDesc), color: ThemeColors.secondaryAccent)
        }
    }

    var streakProgress: CGFloat {
        let maxStreak = max(longestStreak, 1)
        return CGFloat(min(currentStreak, maxStreak)) / CGFloat(maxStreak)
    }

    // --- 🧬 NEURAL INSIGHTS CALCULATIONS ---

    var topWords: [(String, Int)] {
        let allWords = dayActivityMap.values.flatMap { $0 }.flatMap { $0.words }
        var counts: [String: Int] = [:]
        for w in allWords { counts[w, default: 0] += 1 }
        return counts.sorted { $0.value > $1.value }.prefix(15).map { ($0.key, $0.value) }
    }

    var primeSyncHour: Int? {
        var hourCounts: [Int: Int] = [:]
        let allItems = dayActivityMap.values.flatMap { $0 }
        for item in allItems {
            let components = item.user_time.components(separatedBy: " ")
            guard components.count == 2 else { continue }
            let timePart = components[0]
            let amPm = components[1].uppercased()
            let hourPart = timePart.components(separatedBy: ":")[0]
            if let hour = Int(hourPart) {
                var h24 = hour
                if amPm == "PM" && hour != 12 { h24 += 12 }
                if amPm == "AM" && hour == 12 { h24 = 0 }
                hourCounts[h24, default: 0] += 1
            }
        }
        return hourCounts.max { $0.value < $1.value }?.key
    }

    var nextMilestone: Int {
        let milestones = [100, 250, 500, 1000, 2500, 5000, 10000]
        return milestones.first { $0 > totalWordsCount } ?? (totalWordsCount + 1000)
    }

    var milestoneProgress: CGFloat {
        CGFloat(totalWordsCount) / CGFloat(nextMilestone)
    }

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
        guard let pair = activePair else { return }
        updatePracticeDatesCache(practiceDates: pair.practice_dates)
        processRecentActivity(pair.recent_activity ?? [:])
        updateChronotype(pair.recent_activity ?? [:])
        
        // Ensure we have an active date by default (e.g. today or last practiced)
        if selectedHistoryDate == nil {
            selectedHistoryDate = todayString
            selectedHistoryPlaceId = dayActivityMap[todayString]?.first?.place_id
        }
    }
    
    func onAppear() {
        if !appState.hasLoadedLanguages {
            isLoading = true
            appState.loadAvailableLanguagePairs { [weak self] success in
                self?.isLoading = false
                if success {
                    DispatchQueue.main.async { self?.refreshData() }
                }
            }
        } else {
            refreshData()
        }
    }

    // MARK: - Core Data Processing (Logic Layer)

    private func processRecentActivity(_ activity: [String: [PracticeActivityItem]]) {
        var wordCount = 0
        var places: Set<String> = []
        var placeMap: [String: [PracticeActivityItem]] = [:]
        
        // Flatten all items to calculate global stats and place map
        let allItems = activity.values.flatMap { $0 }
        
        for item in allItems {
            wordCount += item.words.count
            places.insert(item.place_id)
            
            // Group by Place
            var existing = placeMap[item.place_id] ?? []
            existing.append(item)
            placeMap[item.place_id] = existing
        }
        
        self.totalWordsCount = wordCount
        self.uniquePlacesCount = places.count
        self.dayActivityMap = activity
        self.placeActivityMap = placeMap
        
        print("📊 [StatsState] Processed \(wordCount) words across \(places.count) places.")
    }

    private func updateChronotype(_ activity: [String: [PracticeActivityItem]]) {
        let allItems = activity.values.flatMap { $0 }
        guard !allItems.isEmpty else { return }
        
        var morningCount = 0
        var afternoonCount = 0
        var nightCount = 0
        
        for item in allItems {
            // Parse "user_time" (e.g., "10:30 AM")
            let components = item.user_time.components(separatedBy: " ")
            guard components.count == 2 else { continue }
            
            let timePart = components[0]
            let amPm = components[1].uppercased()
            
            let hourPart = timePart.components(separatedBy: ":")[0]
            guard let hour = Int(hourPart) else { continue }
            
            // Convert to 24h format for easier range check
            var hour24 = hour
            if amPm == "PM" && hour != 12 { hour24 += 12 }
            if amPm == "AM" && hour == 12 { hour24 = 0 }
            
            switch hour24 {
            case 5..<12:  morningCount += 1
            case 12..<22: afternoonCount += 1
            default:       nightCount += 1 // 10 PM - 4 AM
            }
        }
        
        if morningCount >= afternoonCount && morningCount >= nightCount {
            self.chronotype = "EARLY BIRD"
        } else if afternoonCount >= morningCount && afternoonCount >= nightCount {
            self.chronotype = "DAY WALKER"
        } else {
            self.chronotype = "NIGHT OWL"
        }
        
        print("🦉 [StatsState] Chronotype resolved: \(self.chronotype)")
    }
    
    private func updatePracticeDatesCache(practiceDates: [String]) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var dateSet: Set<Date> = []
        var monthSet: Set<Date> = []
        
        let now = Date()
        if let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
            monthSet.insert(currentMonth)
        }
        
        for dateString in practiceDates {
            if let date = dateFormatter.date(from: dateString) {
                let startOfDay = calendar.startOfDay(for: date)
                dateSet.insert(startOfDay)
                if let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: startOfDay)) {
                    monthSet.insert(monthStart)
                }
            }
        }
        
        self.practiceDatesSet = dateSet
        self.sortedMonths = monthSet.sorted(by: { $0 > $1 })
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
                isLoading = true
                await self.forceRefreshLanguages()
                isLoading = false
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
    
    // MARK: - Calculated Stats
    
    var currentStreak: Int {
        guard let pair = activePair else { return 0 }
        return calculateCurrentStreak(practiceDates: pair.practice_dates)
    }
    
    var longestStreak: Int {
        guard let pair = activePair else { return 0 }
        return calculateLongestStreak(practiceDates: pair.practice_dates)
    }
    
    private func calculateCurrentStreak(practiceDates: [String]) -> Int {
        let sortedDates = Set(practiceDates.compactMap { d -> Date? in
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            f.locale = Locale(identifier: "en_US_POSIX")
            return f.date(from: d)
        }).sorted(by: >)
        
        guard let latest = sortedDates.first else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if !calendar.isDate(latest, inSameDayAs: today) && !calendar.isDate(latest, inSameDayAs: yesterday) {
            return 0
        }
        
        var streak = 1
        var prev = latest
        for i in 1..<sortedDates.count {
            if let expected = calendar.date(byAdding: .day, value: -1, to: prev), calendar.isDate(sortedDates[i], inSameDayAs: expected) {
                streak += 1
                prev = sortedDates[i]
            } else { break }
        }
        return streak
    }
    
    private func calculateLongestStreak(practiceDates: [String]) -> Int {
        let sortedDates = Set(practiceDates.compactMap { d -> Date? in
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            f.locale = Locale(identifier: "en_US_POSIX")
            return f.date(from: d)
        }).sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        var maxS = 1, currentS = 1
        let calendar = Calendar.current
        for i in 0..<(sortedDates.count - 1) {
            if let next = calendar.date(byAdding: .day, value: 1, to: sortedDates[i]), calendar.isDate(next, inSameDayAs: sortedDates[i+1]) {
                currentS += 1
            } else {
                maxS = max(maxS, currentS)
                currentS = 1
            }
        }
        return max(maxS, currentS)
    }
    
    @MainActor
    private func forceRefreshLanguages() async {
        await withCheckedContinuation { continuation in
            appState.loadAvailableLanguagePairs { _ in continuation.resume() }
        }
    }
}
