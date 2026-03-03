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
    // ✅ DEDUPLICATION: Prevents same brick appearing multiple times across groups
    var allBricks: BricksData? {
        var seenIDs: Set<String> = []
        var allConstants: [BrickItem] = []
        var allVariables: [BrickItem] = []
        var allStructural: [BrickItem] = []
        
        for group in groups {
            if let bricks = group.bricks {
                // Process constants
                for brick in bricks.constants ?? [] {
                    let id = brick.safeID
                    if !seenIDs.contains(id) {
                        seenIDs.insert(id)
                        allConstants.append(brick)
                    }
                }
                
                // Process variables
                for brick in bricks.variables ?? [] {
                    let id = brick.safeID
                    if !seenIDs.contains(id) {
                        seenIDs.insert(id)
                        allVariables.append(brick)
                    }
                }
                
                // Process structural
                for brick in bricks.structural ?? [] {
                    let id = brick.safeID
                    if !seenIDs.contains(id) {
                        seenIDs.insert(id)
                        allStructural.append(brick)
                    }
                }
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
        self.patternIntroMistakes = [] // ✅ FIX: Clear mistakes pool for new session
        
        print("\n⚖️⚖️⚖️ [GHOST COURT] LESSON INITIALIZED ⚖️⚖️⚖️")
        print("   👨‍⚖️ MISTAKE POOL CLEARED.")
        
        let patternCount = groups.flatMap { $0.patterns ?? [] }.count
        print("� [LessonEngine] INITIALIZE: Received \(groups.count) groups with \(patternCount) total patterns.")
        
        // Mastery Reset (Clean Slate)
        self.componentMastery = [:] 
        
        // KICKSTART THE LOOP (Empty History)
        if !rawPatterns.isEmpty {
            flow?.pickNextPattern(history: [], mastery: componentMastery, candidates: rawPatterns)
        } else {
            print("⚠️ [LessonEngine] No patterns available to start lesson.")
            isSessionComplete = true
        }
    }
    
    // MARK: - Entry Point
    func startLesson() {
        // The flow already handles the first pattern selection during initialize if history is empty.
        // But we can explicitly trigger it here if needed to be sure.
        if recentPatternHistory.isEmpty {
            if !rawPatterns.isEmpty {
                flow?.pickNextPattern(history: [], mastery: componentMastery, candidates: rawPatterns)
            } else {
                print("⚠️ [LessonEngine] Start requested but no patterns available.")
                isSessionComplete = true
            }
        }
    }
    
    // MARK: - The Callback (Called by Orchestrator when Done)
    func patternCompleted(id: String) {
        
        // 1. Update History
        recentPatternHistory.append(id)
        if recentPatternHistory.count > 3 { recentPatternHistory.removeFirst() }
        
        // 2. 🧼 Centralized Cleanup: Clear mistakes from the just-finished pattern
        print("\n⚖️⚖️⚖️ [GHOST COURT] PATTERN COMPLETE: \(id) ⚖️⚖️⚖️")
        print("   🧹 CLEARING MISTAKE POOL (\(patternIntroMistakes.count) items removed)")
        self.patternIntroMistakes = []
        print("⚖️⚖️⚖️ [GHOST COURT] ========================= ⚖️⚖️⚖️\n")
        
        // 2. Advance Groups if needed (Simple version: if all patterns in group mastered or seen)
        // For now, let the Flow decide based on current rawPatterns.
        
        // 3. Trigger Flow (The Loop)
        if !rawPatterns.isEmpty {
            flow?.pickNextPattern(history: recentPatternHistory, mastery: componentMastery, candidates: rawPatterns)
        } else {
            print("⚠️ [LessonEngine] Pattern completed but no more candidates available.")
            isSessionComplete = true
        }
    }
    
    // Advance to next group manually if we have logic for it
    // ✅ FINISH SESSION (Flat List Mode)
    // There are no "groups" to advance. When the Flow says we are done, we are done.
    func finishSession() {
        print("✅ [LessonEngine] SESSION COMPLETE. All patterns mastered.")
        isSessionComplete = true
    }
    
    // MARK: - Mastery Updates (Pure Data)
    func updateMastery(id: String, delta: Double) {
        
        // IDs are now clean (no prefixes), so we can use them directly
        let finalId = id
        
        // 1. Update the Target ID
        let current = componentMastery[finalId] ?? 0.0
        let newValue = (current + delta).clamped(to: 0.0...1.0)
        componentMastery[finalId] = newValue
        
        print("   📊 [Mastery] Updated '\(id)' -> Score: \(newValue)")
        
        // 2. ✅ GLOBAL BRICK SYNC (The "Same Word" Rule)
        // If this ID belongs to a brick, find ALL other bricks with the SAME ID (word text) and update them too.
        // This prevents "apple" in Group 1 from being different than "apple" in Group 2.
        if let allBricks = self.allBricks {
            // Find the word text for this ID
            let flatList = (allBricks.constants ?? []) + (allBricks.variables ?? []) + (allBricks.structural ?? [])
            
            if let sourceBrick = flatList.first(where: { ($0.id ?? $0.word) == id }) {
                let sourceWord = sourceBrick.word.lowercased()
                
                // Find all OTHER bricks with the exact same word
                let duplicates = flatList.filter {
                    let brickId = $0.id ?? $0.word
                    return brickId != id && $0.word.lowercased() == sourceWord
                }
                
                for dup in duplicates {
                    let dupId = dup.id ?? dup.word
                    componentMastery[dupId] = newValue
                    print("   🔄 [GlobalSync] Synced Duplicate Brick '\(dup.word)' (ID: \(dupId)) to \(newValue)")
                }
            }
        }
        
        // 3. ✅ Live Update Hook: Force SwiftUI to re-render ALL views
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
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
