import Foundation

/// Possible outcomes of a user's drill response
enum ValidationResult {
    case correct           // Exact match (Green)
    case meaningCorrect    // Semantic match + Hard structure pass (Orange)
    case wrong             // Fail (Red)
}

/// Configuration constants for the Neural Engine and validation logic
struct NeuralConfig {
    static let semanticStrictThreshold = 0.10
    static let hardStructureOverlap = 0.70
    static let typoTolerance = 0.25
    static let brickSemanticMatch = 0.20
    static let brickDebug = 0.40
}

/// Shared protocol for all drill-specific validators
protocol DrillValidator {
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult
}

/// Contextual data needed for validation logic
struct ValidationContext {
    let state: DrillState
    let locale: Locale
    let engine: LessonEngine
    let neuralEngine: NeuralValidator?
}

/// Common utilities for validation
struct ValidationUtils {
    
    /// Calculate Levenshtein distance between two strings
    static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        if s1.isEmpty { return s2.count }
        if s2.isEmpty { return s1.count }
        
        let s1 = Array(s1)
        let s2 = Array(s2)
        let m = s1.count
        let n = s2.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                if s1[i-1] == s2[j-1] {
                    matrix[i][j] = matrix[i-1][j-1]
                } else {
                    matrix[i][j] = min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + 1)
                }
            }
        }
        return matrix[m][n]
    }
    
    }

