import Foundation

extension LessonEngine {
    
    /// Filters and arranges bricks for a pattern.
    /// Returns the prioritized list of bricks to show in the Intro.
    func calculateFilteredBricks(brickMatches: [(id: String, score: Double)], for state: DrillState) -> [BrickItem] {
        
        let patternMastery = self.getBlendedMastery(for: state.id)
        
        // ✅ [V4.1] HOLISTIC FILTRATION
        // Use the Semantic Cliff Detection model to decide which bricks to include.
        // This replaces the old loop-based thresholding.
        let selectedIDs = MasteryFilterService.filterBricksBySemanticCliff(
            bricks: brickMatches,
            patternMastery: patternMastery,
            activeBricks: activeGroupBricks
        )
        
        var selectedBricks: [BrickItem] = []
        for id in selectedIDs {
            if let brick = MasteryFilterService.getBrick(id: id, from: activeGroupBricks) {
                selectedBricks.append(brick)
                // Ensure drill state exists for the selected brick
                ensureDrillStateExists(for: id, originalPattern: state, brick: brick)
            }
        }
        
        // Update engine state for semantic chaining context
        self.lastDrilledBricks = selectedBricks
        
        return selectedBricks
    }
    
    /// Helper to ensure a brick drill state exists in the session
    private func ensureDrillStateExists(for brickId: String, originalPattern: DrillState, brick: BrickItem) {
        let drillId = "INT-\(brickId)"
        if !allDrills.contains(where: { $0.id == drillId }) {
            let fakeItem = DrillItem(
                target: brick.word,
                meaning: brick.meaning,
                phonetic: brick.phonetic
            )
            var newDrill = DrillState(id: drillId, patternId: originalPattern.patternId, drillIndex: -1, drillData: fakeItem, isBrick: true)
            newDrill.contextMeaning = originalPattern.drillData.meaning
            newDrill.contextSentence = originalPattern.drillData.target
            allDrills.append(newDrill)
        }
    }
}
