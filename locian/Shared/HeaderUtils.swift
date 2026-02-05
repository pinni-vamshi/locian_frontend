import SwiftUI

struct HeaderUtils {
    // Standardizes the shrinking logic across all tabs
    static func calculateHeaderScale(offset: CGFloat) -> CGFloat {
        // Offset is negative when scrolling UP (content moves up)
        // Add a 10pt deadzone buffer to prevent jitter on initial touch/micro-scrolls
        // Scale stays 1.0 until offset < -10
        let effectiveOffset = min(0, offset + 10)
        
        // 1.0 + (-offset * 0.002)
        // Example: Offset -10 -> Effective 0 -> Scale 1.0
        // Example: Offset -60 -> Effective -50 -> Scale 0.9
        // Increased rate to 0.004 (Shrink faster)
        let scale = 1.0 + (effectiveOffset * 0.004)
        // Allow limiting down to 0.3 (let LocianSmartHeader enforce the 25pt floor)
        return max(0.3, min(1.0, scale))
    }
}
