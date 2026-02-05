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
    
    // MARK: - Refresh Logic
    
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
                await appState.forceRefreshLanguages()
                refreshId = UUID()
                withAnimation { pullRefreshState = .finishing }
                isRefreshFinished = true
            }
        } else if offset > 0 {
            pullRefreshState = .pulling(progress: min(1.0, offset / 110.0))
        } else {
            pullRefreshState = .idle
        }
    }
}

enum AddTabGenerationSource {
    case none
    case camera
    case gallery
}
