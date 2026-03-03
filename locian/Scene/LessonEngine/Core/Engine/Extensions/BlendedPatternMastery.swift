import Foundation

extension LessonEngine {
    
    /// Returns the simple mastery for a given ID (Pattern or Brick).
    /// Cleaned of all "Shitty" artificial weights and string stripping.
    func getBlendedMastery(for id: String) -> Double {
        // IDs are now clean (no prefixes), so we can use them directly
        let cleanId = id
        
        // 3. Return the clean score from the engine
        let score = self.getDecayedMastery(for: cleanId)
        print("🔍 [Mastery] Requested: '\(id)' -> Score: \(score)")
        return score
    }
}
