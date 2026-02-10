import Foundation
import Combine
import NaturalLanguage

// MARK: - THE LIBRARIAN (Data Store)
class LessonEngine: ObservableObject {
    
    // MARK: - Core Data
    @Published var recentPatternHistory: [String] = [] 
    @Published var componentMastery: [String: Double] = [:]
    @Published var isSessionComplete: Bool = false
    
    // MARK:    // Dependencies (The Triangle)
    var flow: LessonFlow?
    var orchestrator: LessonOrchestrator?
    
    // MARK: - Extension Support (Temporary storage for algorithms)
    var allDrills: [DrillState] = [] // Needed by BricksQueuing
    var lastDrilledBricks: [BrickItem] = [] // Needed by BricksQueuing
    
    // MARK: - Localized Content (Groups)
    var lessonData: GenerateSentenceData?
    var groups: [LessonGroup] = []
    @Published var currentGroupIndex: Int = 0
    @Published var visitedPatternIds: Set<String> = []
    
    var activeGroup: LessonGroup? {
        guard currentGroupIndex < groups.count else { return nil }
        return groups[currentGroupIndex]
    }
    
    var rawPatterns: [PatternData] {
        return activeGroup?.patterns ?? []
    }
    
    // MARK: - Initialization
    func initialize(with data: GenerateSentenceData) {
        // Setup Triangle if missing
        if self.flow == nil {
            let newFlow = LessonFlow()
            let newOrch = LessonOrchestrator()
            newFlow.orchestrator = newOrch
            newOrch.engine = self
            self.flow = newFlow
            self.orchestrator = newOrch
        }
        
        self.lessonData = data
        self.recentPatternHistory = []
        self.visitedPatternIds = []
        self.currentGroupIndex = 0
        self.groups = data.groups ?? []
        self.isSessionComplete = false
        
        // Load Mastery from ALL groups
        print("\n🚀 [Engine: Init] Loading Mastery for all groups...")
        for group in self.groups {
            // Prerequisites
            for p in group.prerequisites ?? [] { componentMastery[p.safeID] = p.mastery ?? 0.0 }
            
            // patterns
            for p in group.patterns ?? [] { componentMastery[p.id] = p.mastery ?? 0.0 }
            
            // Bricks
            if let bricks = group.bricks {
                let allBricks = (bricks.constants ?? []) + (bricks.variables ?? []) + (bricks.structural ?? [])
                for b in allBricks { componentMastery[b.safeID] = b.mastery ?? 0.0 }
            }
        }
        
        // KICKSTART THE LOOP (Empty History)
        print("   ⚡️ [Engine] Kickstart: Asking Flow for First Pattern in Group \(currentGroupIndex + 1)...")
        flow?.pickNextPattern(history: [], mastery: componentMastery, candidates: rawPatterns)
    }
    
    // MARK: - Entry Point
    func startLesson() {
        print("🚀 [Engine] Lesson Started.")
        // The flow already handles the first pattern selection during initialize if history is empty.
        // But we can explicitly trigger it here if needed to be sure.
        if recentPatternHistory.isEmpty {
            flow?.pickNextPattern(history: [], mastery: componentMastery, candidates: rawPatterns)
        }
    }
    
    // MARK: - The Callback (Called by Orchestrator when Done)
    func patternCompleted(id: String) {
        print("\n🏁 [Engine] Pattern '\(id)' Completed.")
        
        // 1. Update History
        recentPatternHistory.append(id)
        if recentPatternHistory.count > 4 { recentPatternHistory.removeFirst() }
        
        // 2. Advance Groups if needed (Simple version: if all patterns in group mastered or seen)
        // For now, let the Flow decide based on current rawPatterns.
        
        // 3. Trigger Flow (The Loop)
        print("   🌊 [Engine] Calling Flow for Next Pattern...")
        flow?.pickNextPattern(history: recentPatternHistory, mastery: componentMastery, candidates: rawPatterns)
    }
    
    // Advance to next group manually if we have logic for it
    func advanceGroup() {
        if currentGroupIndex < groups.count - 1 {
            currentGroupIndex += 1
            print("   🚀 [Engine] Advancing to Group \(currentGroupIndex + 1)")
            flow?.pickNextPattern(history: [], mastery: componentMastery, candidates: rawPatterns)
        } else {
            print("   🏁 [Engine] No more groups. Session complete.")
            isSessionComplete = true
        }
    }
    
    // MARK: - Mastery Updates (Pure Data)
    func updateMastery(id: String, delta: Double) {
        let current = componentMastery[id] ?? 0.0
        let newValue = (current + delta).clamped(to: 0.0...1.0)
        componentMastery[id] = newValue
        // Persistence calls here...
    }
    
    // MARK: - Extension Helpers
    func getDecayedMastery(for id: String) -> Double {
        return componentMastery[id] ?? 0.0
    }
}

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(range.upperBound, self))
    }
}
