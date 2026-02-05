//
//  AddTabState.swift
//  locian
//
//  Centralized Logic for Add Tab (Routines, Custom Inputs, UI State)
//

import SwiftUI
import Combine

class AddTabState: ObservableObject {
    @Published var customPlaceText: String = ""
    @Published var isImageSelected: Bool = false
    @Published var activeGenerationSource: AddTabGenerationSource = .none
    
    // Routine Management
    @Published var routineSelections: [Int: String] = [:]
    @AppStorage("routine_selections_json") private var routineSelectionsJSON: String = "{}"
    
    // Pull-to-Refresh State
    @Published var pullRefreshState: CyberRefreshState = .idle
    @Published var scrollOffset: CGFloat = 0.0
    @Published var isRefreshFinished: Bool = false
    @Published var refreshId = UUID()
    
    let appState: AppStateManager
    let learnState: LearnTabState
    
    init(appState: AppStateManager, learnState: LearnTabState) {
        self.appState = appState
        self.learnState = learnState
        loadRoutineSelections()
    }
    
    // MARK: - Routine Actions
    
    func startRoutine() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        if let place = routineSelections[currentHour] {
            learnState.generateMomentsForPlace(name: place)
        }
    }
    
    func handleTextStart() {
        guard !customPlaceText.isEmpty else { return }
        learnState.generateMomentsForPlace(name: customPlaceText)
    }
    
    func handleImageSelection(_ image: UIImage, source: AddTabGenerationSource) {
        self.activeGenerationSource = source
        learnState.analyzeImageAndGenerateMoments(image: image)
    }
    
    func selectSuggestedPlace(_ place: String) {
        self.customPlaceText = place
        learnState.generateMomentsForPlace(name: place)
    }
    
    // MARK: - Persistence
    
    func saveRoutineSelections() {
        if let encoded = try? JSONEncoder().encode(routineSelections) {
            routineSelectionsJSON = String(data: encoded, encoding: .utf8) ?? "{}"
        }
    }
    
    private func loadRoutineSelections() {
        if let data = routineSelectionsJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Int: String].self, from: data) {
            self.routineSelections = decoded
        }
    }
    
    // Streak Properties (Calculated from AppStateManager)
    var maxCurrentStreak: Int {
        appState.userLanguagePairs.map { calculateStreak(practiceDates: $0.practice_dates) }.max() ?? 0
    }
    
    var maxLongestStreak: Int {
        // For now using current as longest since we don't have separate historical data here
        maxCurrentStreak
    }
    
    @MainActor
    func handlePullToRefresh(offset: CGFloat) {
        if abs(self.scrollOffset - offset) > 0.5 {
            self.scrollOffset = offset
        }
        
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
                TargetLanguageLogic.shared.loadTargetLanguages { [weak self] _ in
                    self?.refreshId = UUID()
                    withAnimation { self?.pullRefreshState = .finishing }
                    self?.isRefreshFinished = true
                }
             Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if self.isRefreshFinished {
                    withAnimation(.spring()) {
                        self.pullRefreshState = .idle
                        self.isRefreshFinished = false
                    }
                }
             }
            }
        } else if offset > 0 {
            pullRefreshState = .pulling(progress: min(1.0, offset / 110.0))
        } else {
            pullRefreshState = .idle
        }
    }
    
    private func calculateStreak(practiceDates: [String]) -> Int {
        guard !practiceDates.isEmpty else { return 0 }
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let validDates = practiceDates.compactMap { formatter.date(from: $0) }
        guard !validDates.isEmpty else { return 0 }
        let uniqueDates = Set(validDates); let sortedDates = uniqueDates.sorted(by: >)
        let calendar = Calendar.current; let today = Date()
        guard let latestDate = sortedDates.first else { return 0 }
        let isToday = calendar.isDateInToday(latestDate)
        let isYesterday = calendar.isDate(latestDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!)
        if !isToday && !isYesterday { return 0 }
        var currentStreak = 1; var previousDate = latestDate
        for i in 1..<sortedDates.count {
            let date = sortedDates[i]
            if let expectedPrevDay = calendar.date(byAdding: .day, value: -1, to: previousDate),
               calendar.isDate(date, inSameDayAs: expectedPrevDay) {
                currentStreak += 1; previousDate = date
            } else { break }
        }
        return currentStreak
    }
}

enum AddTabGenerationSource {
    case none
    case camera
    case gallery
}
