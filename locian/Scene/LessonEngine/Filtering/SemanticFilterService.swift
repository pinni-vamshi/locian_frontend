import Foundation

/// Service for identifying relevant bricks using a 2-stage semantic process.
struct SemanticFilterService {
    
    // MARK: - LOGGING
    static let LOG_FILTERING = false
    
    /// Finds relevant bricks in the text using Neural Search (ContentAnalyzer)
    static func getFilteredBricks(
        text: String,
        meaning: String,
        drillId: String? = nil,
        bricks: BricksData?,
        targetLanguage: String,
        nativeLanguage: String,
        validator: NeuralValidator?,
        threshold: Double // NOW PASSED IN
    ) -> [MasteryFilterService.FilterResult] { 
        
        // DYNAMIC LOGIC REMOVED (User Request Step 4998)
        // Now handled by caller (LessonEngine+Bricks).
        
        // Get candidate brick IDs via word matching
        let rawCandidates = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: text,
            meaning: meaning,
            bricks: bricks,
            targetLanguage: targetLanguage
        )
        
        // Extract just the brick IDs
        let candidateIds = rawCandidates.map { $0.id }
        
        // Calculate semantic similarity for each candidate brick
        var scoredBricks: [(brickId: String, score: Double)] = []
        
        // For each candidate brick, calculate semantic similarity
        for candidateId in candidateIds {
            // Find the brick in the data
            var brick: BrickItem?
            var brickCategory: BrickCategory = .constant
            
            if let found = bricks?.constants?.first(where: { $0.id == candidateId }) {
                brick = found
                brickCategory = .constant
            } else if let found = bricks?.variables?.first(where: { $0.id == candidateId }) {
                brick = found
                brickCategory = .variable
            } else if let found = bricks?.structural?.first(where: { $0.id == candidateId }) {
                brick = found
                brickCategory = .structural
            }
            
            guard let brick = brick else { continue }
            
            // ✅ Dual JNS: both L2 (target) and L1 (meaning), averaged
            // Each side uses its own language-specific embeddings + tagging
            let combinedScore = WordSimilarityService.calculateDualJointScore(
                word: brick.word,
                sentence: text,
                targetLanguage: targetLanguage,
                wordMeaning: brick.meaning,
                meaningContext: meaning,
                nativeLanguage: nativeLanguage,
                category: brickCategory
            )
            
            scoredBricks.append((brickId: candidateId, score: combinedScore))
        }

        
        // Filter by threshold
        let filteredBricks = scoredBricks.filter { $0.score >= threshold }
        
        // Convert to FilterResult format (mastery will be looked up by caller)
        return filteredBricks.map { 
            MasteryFilterService.FilterResult(brickId: $0.brickId, mastery: 0.0, similarityScore: $0.score)
        }
    }
}
