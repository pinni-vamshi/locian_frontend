import Foundation

extension LessonEngine {
    
    /// Filters and arranges bricks for a pattern.
    /// Returns the prioritized list of bricks to show in the Intro.
    func calculateFilteredBricks(brickMatches: [(id: String, score: Double)], for state: DrillState) -> [BrickItem] {
        
        // 1. Calculate Dynamic Threshold
        let patternMastery = self.getBlendedMastery(for: state.id)
        let dynamicThreshold = MasteryFilterService.calculateThreshold(
            text: state.drillData.target,
            mastery: patternMastery,
            languageCode: self.lessonData?.target_language ?? "en"
        )
        
        // 1.5 Tag the Sentence (System Tagger)
        let sentenceTags = TokenTaggerService.tagContent(
            text: state.drillData.target,
            languageCode: self.lessonData?.target_language ?? "en"
        )
        
        // 2. Perform Filtering & Scoring
        var bricksToQueue: [(id: String, score: Double)] = []
        var currentlyStudyingBricks: [BrickItem] = [] // Temporary list to update engine
        
        for match in brickMatches {
            let brickId = match.id
            
            // B. Semantic Filter & Type Check
            // ✅ NOW USING GROUP-SPECIFIC BRICKS ONLY
            if let brick = MasteryFilterService.getBrick(id: brickId, from: activeGroupBricks) {
                
                // [MODIFIED] Use System Tagger instead of API Lists
                // "Variable" -> Content Word (Noun, Verb, Adj, Adv) in THIS context
                let isVariable = TokenTaggerService.isContentWord(brick.word, in: sentenceTags)
                
                // "Constant" -> Structure Word (Not a content word)
                let isConstant = !isVariable
                
                // Calculate Similarity
                let targetCode = self.lessonData?.target_language ?? "en"
                let targetSim = EmbeddingService.compare(textA: state.drillData.target, textB: brick.word, languageCode: targetCode)
                
                let nativeCode = self.lessonData?.user_language ?? "en"
                let meaningSim = EmbeddingService.compare(textA: state.drillData.meaning, textB: brick.meaning, languageCode: nativeCode)
                
                let actualScore = max(targetSim, meaningSim)
                
                let result = MasteryFilterService.evaluateBrickRelevance(
                    brick: brick.word,
                    isVariable: isVariable,
                    isConstant: isConstant,
                    score: actualScore,
                    threshold: dynamicThreshold,
                    mastery: patternMastery
                )
                
                if result.accepted {
                    // Main words get a sorting boost to appear first
                    let finalSortingScore = MasteryFilterService.getSortingScore(originalScore: actualScore, isVariable: isVariable)
                    bricksToQueue.append((id: brickId, score: finalSortingScore))
                    currentlyStudyingBricks.append(brick)
                    ensureDrillStateExists(for: brickId, originalPattern: state, brick: brick)
                }
            }
        }
        
        // 3. Update Engine State for Semantic Chaining
        self.lastDrilledBricks = currentlyStudyingBricks
        
        // 4. Sort by Similarity (Descending - Most relevant first) (AND Variables Boost)
        let sortedIds = bricksToQueue.sorted { $0.score > $1.score }.map { $0.id }
        
        // Resolve full objects in sorted order
        // ✅ NOW USING GROUP-SPECIFIC BRICKS ONLY
        let finalTextBricks = MasteryFilterService.resolveBricks(ids: Set(sortedIds), from: activeGroupBricks)
            .sorted { brick1, brick2 in
                // Re-apply sort because resolveBricks returns arbitrary order
                let score1 = bricksToQueue.first(where: { $0.id == (brick1.id ?? brick1.word) })?.score ?? 0
                let score2 = bricksToQueue.first(where: { $0.id == (brick2.id ?? brick2.word) })?.score ?? 0
                return score1 > score2
            }
        
        return finalTextBricks
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
