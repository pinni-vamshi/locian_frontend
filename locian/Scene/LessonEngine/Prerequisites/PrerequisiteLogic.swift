import SwiftUI
import Combine

class PrerequisiteLogic: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var isShowingMCQ: Bool = false
    @Published var isComplete: Bool = false
    
    let engine: LessonEngine
    let patternState: DrillState
    
    // The items to teach: Prerequisites + Bricks linked to this pattern
    var items: [PrerequisiteItem] = []
    
    struct PrerequisiteItem: Identifiable {
        let id: String
        let brick: BrickItem
        var isPrerequisite: Bool
    }
    
    init(patternState: DrillState, engine: LessonEngine) {
        self.patternState = patternState
        self.engine = engine
        
        // 1. Identify the group that actually contains this pattern
        let group = engine.groups.first(where: { g in
            g.patterns?.contains(where: { p in p.id == patternState.patternId }) ?? false
        })
        
        let prereqs = group?.prerequisites ?? []
        
        // 2. Identify Bricks relevant to THIS specific pattern
        let relevantBricks = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: patternState.drillData.target,
            meaning: patternState.drillData.meaning,
            bricks: group?.bricks,
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        
        // 3. Resolve actual objects
        let resolvedBricks = MasteryFilterService.resolveBricks(
            ids: Set(relevantBricks.map { $0.id }),
            from: group?.bricks
        )
        
        // 4. Combine and Filter by Mastery (The 0.85 Rule)
        var allItems: [PrerequisiteItem] = []
        
        // Prerequisites first (High priority)
        for p in prereqs {
            let mastery = engine.componentMastery[p.safeID] ?? 0.0
            if mastery < 0.85 {
                allItems.append(PrerequisiteItem(id: p.safeID, brick: p, isPrerequisite: true))
            }
        }
        
        // Bricks next
        for b in resolvedBricks {
            let brickId = b.id ?? b.word
            let mastery = engine.componentMastery[brickId] ?? 0.0
            if mastery < 0.85 {
                // Avoid duplicates
                if !allItems.contains(where: { $0.id == brickId }) {
                    allItems.append(PrerequisiteItem(id: brickId, brick: b, isPrerequisite: false))
                }
            }
        }
        
        self.items = allItems
        
        if items.isEmpty {
            print("   ⏩ [PrerequisiteLogic] Foundation is already strong. Skipping Stage.")
            self.isComplete = true
        } else {
            print("   🧱 [PrerequisiteLogic] Scoped \(items.count) items for foundation stage.")
        }
    }
    
    var currentItem: PrerequisiteItem? {
        guard currentIndex < items.count else { return nil }
        return items[currentIndex]
    }
    
    // Advance logic
    func showMCQ() {
        withAnimation {
            isShowingMCQ = true
        }
    }
    
    func next() {
        if currentIndex < items.count - 1 {
            withAnimation {
                currentIndex += 1
                isShowingMCQ = false
            }
            print("   🧱 [PrerequisiteLogic] Moving to next brick: \(currentIndex + 1)/\(items.count)")
        } else {
            print("   🏁 [PrerequisiteLogic] Foundation teaching complete. Finish stage.")
            isComplete = true
            engine.orchestrator?.finishPrerequisites()
        }
    }
    
    // Helper to materialize a DrillState for the MCQ reuse
    func materializeMCQState() -> DrillState? {
        guard let item = currentItem else { return nil }
        
        let drillItem = DrillItem(
            target: item.brick.word,
            meaning: item.brick.meaning,
            phonetic: item.brick.phonetic
        )
        
        var drill = DrillState(
            id: "PRE-\(item.id)",
            patternId: patternState.patternId,
            drillIndex: -1,
            drillData: drillItem,
            isBrick: true
        )
        drill.currentMode = DrillMode.componentMcq
        return drill
    }
}
