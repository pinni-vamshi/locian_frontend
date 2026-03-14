//
//  CompletePatternLogic.swift
//  locian
//
//  Logic Layer for Pattern Completion.
//  Handles the side effects (updating session state) after the service call.
//

import Foundation

class CompletePatternLogic {
    static let shared = CompletePatternLogic()
    private init() {}
    
    /// Entry point for reporting completion.
    /// Triggered by the drill logic (e.g., PatternVoiceLogic).
    func reportCompletion(patternId: String, engine: LessonEngine) {
        // 1. Session-level De-duplication Guard
        guard !engine.visitedPatternIds.contains(patternId) else { 
            print("🛡️ [CompletePatternLogic] Completion already reported for '\(patternId)'. Skipping redundant call.")
            return 
        }
        
        // 2. Identify the place context
        guard let placeId = engine.lessonData?.place_name else {
            print("⚠️ [CompletePatternLogic] Cannot report completion: place_id missing in engine.")
            return
        }
        
        // 3. Mark as visited in the session immediately to prevent race conditions
        engine.visitedPatternIds.insert(patternId)
        
        // 4. Call Service
        CompletePatternService.shared.completePattern(patternId: patternId, placeId: placeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print("✅ [CompletePatternLogic] Successfully logged mastery for '\(patternId)'. Server says: \(response.message ?? "OK")")
                    } else {
                        print("⚠️ [CompletePatternLogic] Server returned failure for '\(patternId)': \(response.error ?? "Unknown Error")")
                    }
                case .failure(let error):
                    print("❌ [CompletePatternLogic] Network failure during completion report: \(error.localizedDescription)")
                }
            }
        }
    }
}
