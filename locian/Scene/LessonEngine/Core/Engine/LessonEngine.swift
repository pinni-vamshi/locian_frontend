import Foundation
import Combine
import NaturalLanguage

// MARK: - THE LIBRARIAN (Data Store)
class LessonEngine: ObservableObject {
    
    // MARK: - Core Data
    @Published var recentPatternHistory: [String] = [] 
    @Published var componentMastery: [String: Double] = [:]
    @Published var isSessionComplete: Bool = false
    @Published var patternIntroMistakes: [DrillState] = []
    
    // MARK:    // Dependencies (The Triangle)
    var flow: LessonFlow?
    var orchestrator: LessonOrchestrator? {
        didSet {
            // Subscribe to orchestrator changes to trigger view updates
            orchestrator?.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    var activeGroupBricks: BricksData? {
        return activeGroup?.bricks
    }
    
    var rawPatterns: [PatternData] {
        return allPatterns // ✅ NOW FLAT: Draw from all groups
    }
    
    // ✅ NEW: All patterns across ALL groups (for MCQ distractor generation)
    var allPatterns: [PatternData] {
        return groups.compactMap { $0.patterns }.flatMap { $0 }
    }
    
    // ✅ NEW: All bricks across ALL groups (for MCQ distractor generation)
    var allBricks: BricksData? {
        var allConstants: [BrickItem] = []
        var allVariables: [BrickItem] = []
        var allStructural: [BrickItem] = []
        
        for group in groups {
            if let bricks = group.bricks {
                allConstants += bricks.constants ?? []
                allVariables += bricks.variables ?? []
                allStructural += bricks.structural ?? []
            }
        }
        
        guard !allConstants.isEmpty || !allVariables.isEmpty || !allStructural.isEmpty else {
            return nil
        }
        
        return BricksData(
            constants: allConstants.isEmpty ? nil : allConstants,
            variables: allVariables.isEmpty ? nil : allVariables,
            structural: allStructural.isEmpty ? nil : allStructural
        )
    }
    
    // ✅ NEW: Smart Brick Lookup (Finds bricks for the SPECIFIC group a pattern belongs to)
    func getBricks(for patternId: String) -> BricksData? {
        // Find the group that contains this pattern
        guard let group = groups.first(where: { group in
            return group.patterns?.contains(where: { $0.id == patternId }) ?? false
        }) else {
            return activeGroupBricks // Fallback to active group if not found (safer than nil)
        }
        
        return group.bricks
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
        
        let patternCount = groups.flatMap { $0.patterns ?? [] }.count
        print("   📦 [LessonEngine] Received \(groups.count) groups with \(patternCount) patterns.")
        
        // Load Mastery from ALL groups (Forced to 0.0 as per memory removal)
        for group in self.groups {

            // patterns
            for p in group.patterns ?? [] { componentMastery[p.id] = 0.0 }
            
            // Bricks
            if let bricks = group.bricks {
                let allBricks = (bricks.constants ?? []) + (bricks.variables ?? []) + (bricks.structural ?? [])
                for b in allBricks { componentMastery[b.safeID] = 0.0 }
            }
        }
        
        // KICKSTART THE LOOP (Empty History)
        flow?.pickNextPattern(history: [], mastery: componentMastery, candidates: rawPatterns)
    }
    
    // MARK: - Entry Point
    func startLesson() {
        // The flow already handles the first pattern selection during initialize if history is empty.
        // But we can explicitly trigger it here if needed to be sure.
        if recentPatternHistory.isEmpty {
            flow?.pickNextPattern(history: [], mastery: componentMastery, candidates: rawPatterns)
        }
    }
    
    // MARK: - The Callback (Called by Orchestrator when Done)
    func patternCompleted(id: String) {
        
        // 1. Update History
        recentPatternHistory.append(id)
        if recentPatternHistory.count > 4 { recentPatternHistory.removeFirst() }
        
        // 2. 🧼 Centralized Cleanup: Clear mistakes from the just-finished pattern
        self.patternIntroMistakes = []
        print("   🧹 [LessonEngine] Pattern \(id) complete. Mistake pool cleared for next loop.")
        
        // 2. Advance Groups if needed (Simple version: if all patterns in group mastered or seen)
        // For now, let the Flow decide based on current rawPatterns.
        
        // 3. Trigger Flow (The Loop)
        flow?.pickNextPattern(history: recentPatternHistory, mastery: componentMastery, candidates: rawPatterns)
    }
    
    // Advance to next group manually if we have logic for it
    func advanceGroup() {
        // Since we are now using a FLAT structure via rawPatterns (allPatterns),
        // we advance the index mostly for metadata tracking, but the flow already sees everything.
        if currentGroupIndex < groups.count - 1 {
            currentGroupIndex += 1
            // No need to re-trigger pickNextPattern here, as the flow will do it on completion
        } else {
            // Full session complete if all patterns mastered
            isSessionComplete = true
        }
    }
    
    // MARK: - Mastery Updates (Pure Data)
    func updateMastery(id: String, delta: Double) {
        let current = componentMastery[id] ?? 0.0
        let newValue = (current + delta).clamped(to: 0.0...1.0)
        componentMastery[id] = newValue
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
