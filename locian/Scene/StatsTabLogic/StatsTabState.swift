//
//  StatsTabState.swift
//  locian
//
//  Logic Controller for Stats Tab
//

import SwiftUI
import Combine

class StatsTabState: ObservableObject {
    @ObservedObject var appState: AppStateManager
    
    // Cached Data
    @Published var practiceDatesSet: Set<Date> = []
    @Published var chronotypeData: ChronotypeData?
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
                await appState.forceRefreshLanguages()
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
}
