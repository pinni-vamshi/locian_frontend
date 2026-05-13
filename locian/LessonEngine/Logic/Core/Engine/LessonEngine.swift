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
    @Published var isCompactPatternMCQVisible: Bool = false
    
    // ✅ NEW V4.2: The "Link Building" Layer
    // Precomputed map of which brick IDs belong to which pattern ID.
    // This stops the UI render loop from re-running the semantic scan 60 times a second.
    var patternBrickMap: [String: [String]] = [:]
    
    
    // MARK:    // Dependencies (The Triangle)
    var flow: LessonFlow?
    var orchestrator: LessonOrchestrator? {
        didSet {
            // Subscribe to orchestrator changes to trigger view updates
            orchestrator?.objectWillChange.sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }.store(in: &cancellables)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Extension Support (Temporary storage for algorithms)
    var allDrills: [DrillState] = [] // Needed by BricksQueuing
    var lastDrilledBricks: [BrickItem] = [] // Needed by BricksQueuing
    /// IDs of the exact bricks that were actually shown in the most recent Pattern Intro.
    /// Stamped by PatternIntroLogic.init; tracks which brick IDs were introduced in the current session.
    @Published var lastIntroBrickIDs: [String] = []

    /// ID of the brick the Pattern Intro is currently teaching. Drives the
    /// "moving accent" on the headline: every intro brick is underlined, but
    /// only this one is also colored. `nil` outside the intro stage.
    @Published var currentIntroBrickID: String? = nil
    @Published var isPlayingPatternIntroAnimation: Bool = false
    @Published var revealedIntroBrickIDs: Set<String> = []
    @Published var introAllRevealed: Bool = false
    
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
                    let id = brick.id
                    if !seenIDs.contains(id) {
                        seenIDs.insert(id)
                        allConstants.append(brick)
                    }
                }
                
                // Process variables
                for brick in bricks.variables ?? [] {
                    let id = brick.id
                    if !seenIDs.contains(id) {
                        seenIDs.insert(id)
                        allVariables.append(brick)
                    }
                }
                
                // Process structural
                for brick in bricks.structural ?? [] {
                    let id = brick.id
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
        DispatchQueue.main.async {
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

            // ── Mastery is SESSION-LOCAL ONLY.
            // Per the current design, mastery scores are not persisted on device.
            // They live for the lifetime of this LessonEngine instance and are
            // discarded the moment the user leaves the lesson. A backend-side
            // store will own long-term progress later — nothing to do here.
            print("\n⚖️⚖️⚖️ [GHOST COURT] LESSON INITIALIZED ⚖️⚖️⚖️")
            print("   👨‍⚖️ MISTAKE POOL CLEARED.")
            
            let patternCount = self.groups.flatMap { $0.patterns ?? [] }.count
            print(" [LessonEngine] INITIALIZE: Received \(self.groups.count) groups with \(patternCount) total patterns.")
            
            // ✅ NEW: Precompute brick relationships once per lesson initialization
            self.precomputeBrickMapping()
            
            // Mastery Reset (Clean Slate)
            self.componentMastery = [:] 
            
            // KICKSTART THE LOOP (Empty History)
            if !self.rawPatterns.isEmpty {
                self.flow?.pickNextPattern(history: [], mastery: self.componentMastery, candidates: self.rawPatterns)
            } else {
                print("⚠️ [LessonEngine] No patterns available to start lesson.")
                self.isSessionComplete = true
            }
        }
    }
    
    // MARK: - Entry Point
    func startLesson() {
        DispatchQueue.main.async {
            // The flow already handles the first pattern selection during initialize if history is empty.
            // But we can explicitly trigger it here if needed to be sure.
            if self.recentPatternHistory.isEmpty {
                if !self.rawPatterns.isEmpty {
                    self.flow?.pickNextPattern(history: [], mastery: self.componentMastery, candidates: self.rawPatterns)
                } else {
                    print("⚠️ [LessonEngine] Start requested but no patterns available.")
                    self.isSessionComplete = true
                }
            }
        }
    }
    
    // MARK: - The Callback (Called by Orchestrator when Done)
    func patternCompleted(id: String) {
        DispatchQueue.main.async {
            // 1. Update History (Deduplicated: remove if exists, then append to end)
            if let existingIndex = self.recentPatternHistory.firstIndex(of: id) {
                self.recentPatternHistory.remove(at: existingIndex)
            }
            self.recentPatternHistory.append(id)
            if self.recentPatternHistory.count > 3 { self.recentPatternHistory.removeFirst() }

            // 1b. Track full visited set (unbounded — used for one-pass completion check)
            self.visitedPatternIds.insert(id)

            // 2. 🧼 Centralized Cleanup: Clear mistakes from the just-finished pattern
            print("\n⚖️⚖️⚖️ [GHOST COURT] PATTERN COMPLETE: \(id) ⚖️⚖️⚖️")
            print("   🧹 CLEARING MISTAKE POOL (\(self.patternIntroMistakes.count) items removed)")
            self.patternIntroMistakes = []
            print("⚖️⚖️⚖️ [GHOST COURT] ========================= ⚖️⚖️⚖️\n")

            // 3. Trigger Flow (The Loop)
            if !self.rawPatterns.isEmpty {
                self.flow?.pickNextPattern(history: self.recentPatternHistory, mastery: self.componentMastery, candidates: self.rawPatterns)
            } else {
                print("⚠️ [LessonEngine] Pattern completed but no more candidates available.")
                self.isSessionComplete = true
            }
        }
    }
    
    // Advance to next group manually if we have logic for it
    // ✅ FINISH SESSION (Flat List Mode)
    // There are no "groups" to advance. When the Flow says we are done, we are done.
    func finishSession() {
        DispatchQueue.main.async {
            print("✅ [LessonEngine] SESSION COMPLETE. All patterns mastered.")
            self.isSessionComplete = true
        }
    }
    
    // MARK: - Mastery Updates (Pure Data)
    func updateMastery(
        id: String,
        delta: Double? = nil,
        newValue setVal: Double? = nil,
        callerFile: String = #fileID,
        callerFunction: String = #function,
        callerLine: Int = #line
    ) {

        // IDs are now clean (no prefixes), so we can use them directly
        let finalId = id

        // 1. Update the Target ID
        let current = componentMastery[finalId] ?? 0.0
        let newValue: Double
        if let sv = setVal {
            newValue = sv.clamped(to: 0.0...1.0)
        } else if let d = delta {
            newValue = (current + d).clamped(to: 0.0...1.0)
        } else {
            return
        }

        // 🔍 Diagnostic — full audit trail of every mastery mutation:
        //    who/where (file:function:line), the id, the OLD value, the NEW
        //    value, the delta sign+magnitude, and the active pattern context.
        let deltaStr: String
        if let d = delta {
            deltaStr = String(format: "%+.3f", d)
        } else if setVal != nil {
            deltaStr = "SET"
        } else {
            deltaStr = "?"
        }
        let activePid = orchestrator?.activeState?.patternId ?? "—"
        let activeMode = orchestrator?.activeState?.currentMode.map { String(describing: $0) } ?? "—"
        print("   📊 [Mastery] id='\(id)' \(String(format: "%.3f", current)) → \(String(format: "%.3f", newValue)) | Δ\(deltaStr) | active=[\(activePid) · \(activeMode)] | from \(callerFile):\(callerFunction):\(callerLine)")

        // 2. ✅ Live Update Hook: Force SwiftUI to re-render ALL views.
        //    Session-local only — no on-device persistence (see initialize()).
        DispatchQueue.main.async {
            self.componentMastery[finalId] = newValue
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Extension Helpers
    func getDecayedMastery(for id: String) -> Double {
        return componentMastery[id] ?? 0.0
    }

    /// Single source of truth for "which bricks does this pattern's intro teach".
    /// Used by the orchestrator (to stamp `lastIntroBrickIDs` before any view
    /// renders), by `PatternIntroLogic` (to build the brick drill queue), and
    /// by `ActiveTurnView` (to underline the headline). Identical inputs ⇒
    /// identical output, so all three callers agree on the same set.
    func computeIntroBricks(for state: DrillState) -> [BrickItem] {
        let bricksContainer = getBricks(for: state.patternId)

        let matches = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: bricksContainer,
            targetLanguage: lessonData?.target_language ?? "es"
        )

        let patternMastery = getBlendedMastery(for: state.id)
        let selectedIDs = MasteryFilterService.filterBricksBySemanticCliff(
            bricks: matches,
            patternMastery: patternMastery,
            activeBricks: bricksContainer
        )

        var bricks: [BrickItem] = []
        for id in selectedIDs {
            if let brick = MasteryFilterService.getBrick(id: id, from: bricksContainer) {
                bricks.append(brick)
            }
        }

        let meaningLower = state.drillData.meaning.lowercased()
        bricks.sort { a, b in
            let posA = meaningLower.range(of: a.meaning.lowercased())?.lowerBound ?? meaningLower.endIndex
            let posB = meaningLower.range(of: b.meaning.lowercased())?.lowerBound ?? meaningLower.endIndex
            return posA < posB
        }

        return bricks
    }
    
    // MARK: - Precompute Logic
    private func precomputeBrickMapping() {
        print("🧠 [LessonEngine] Precomputing Brick Relationships...")
        self.patternBrickMap = [:]
        
        for pattern in allPatterns {
            let bricksContainer = self.getBricks(for: pattern.id)
            let relevantIDs = ContentAnalyzer.findRelevantBricks(
                in: pattern.target, 
                meaning: pattern.meaning, 
                bricks: bricksContainer, 
                targetLanguage: self.lessonData?.target_language ?? "es"
            )
            self.patternBrickMap[pattern.id] = relevantIDs
        }
        print("🧠 [LessonEngine] Precompute Complete. Map Size: \(patternBrickMap.count) patterns.")
    }
}

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(range.upperBound, self))
    }
}
