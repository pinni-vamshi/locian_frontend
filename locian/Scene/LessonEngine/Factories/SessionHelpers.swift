//
//  SessionHelpers.swift
//  locian
//
//  Helper classes for session state management.
//

import Foundation
import Combine

// MARK: - Timer Manager
// Manages countdown/countup timers for drill cards
class TimerManager: ObservableObject {
    @Published var timeElapsed: TimeInterval = 0
    @Published var isTimerActive: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    
    func start() {
        guard !isTimerActive else { return }
        
        startTime = Date()
        isTimerActive = true
        timeElapsed = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.timeElapsed = Date().timeIntervalSince(start)
        }
    }
    
    func stop() -> TimeInterval {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        return timeElapsed
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
        timeElapsed = 0
        startTime = nil
    }
}

// MARK: - Pattern Mastery Tracker (Pure Flow)
// Tracks per-pattern performance during session using pure scores
class PatternMasteryTracker: ObservableObject {
    
    // MARK: - Published State
    @Published var patternScores: [String: Double] = [:]
    
    // MARK: - Methods
    
    /// Record an attempt for a pattern
    func recordAttempt(patternId: String, isCorrect: Bool) {
        // Simple binary update for pure flow
        patternScores[patternId] = isCorrect ? 1.0 : 0.0
    }
    
    /// Check if pattern needs reinforcement (< 0.95 mastery)
    func needsReinforcement(patternId: String) -> Bool {
        return (patternScores[patternId] ?? 0.0) < 0.95
    }
    
    /// Get mastery level for a pattern (0.0 - 1.0)
    func getMasteryLevel(patternId: String) -> Double {
        return patternScores[patternId] ?? 0.0
    }
}
