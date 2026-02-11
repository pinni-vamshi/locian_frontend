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
            if let found = bricks?.constants?.first(where: { ($0.id ?? $0.word) == candidateId }) {
                brick = found
            } else if let found = bricks?.variables?.first(where: { ($0.id ?? $0.word) == candidateId }) {
                brick = found
            } else if let found = bricks?.structural?.first(where: { ($0.id ?? $0.word) == candidateId }) {
                brick = found
            }
            
            guard let brick = brick else { continue }
            
            var maxScore = 0.0
            
            // Calculate similarity against target text (L2)
            // Use targetLanguage code passed in params
            let targetScore = EmbeddingService.compare(textA: text, textB: brick.word, languageCode: targetLanguage)
            maxScore = max(maxScore, targetScore)
            
            // Calculate similarity against meaning text (L1)
            let meaningScore = EmbeddingService.compare(textA: meaning, textB: brick.meaning, languageCode: nativeLanguage)
            maxScore = max(maxScore, meaningScore)
            
            scoredBricks.append((brickId: candidateId, score: maxScore))
        }

        
        // Filter by threshold
        let filteredBricks = scoredBricks.filter { $0.score >= threshold }
        
        // Convert to FilterResult format (mastery will be looked up by caller)
        return filteredBricks.map { 
            MasteryFilterService.FilterResult(brickId: $0.brickId, mastery: 0.0, similarityScore: $0.score)
        }
    }
}
