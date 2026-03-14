
import SwiftUI

/// An octagonal shape with 45° chamfered (clipped) corners.
/// Used for calendar cells in StatsTabView and option cards in CyberComponents.
struct ChamferedShape: Shape {
    var chamferSize: CGFloat = 8
    var cornerRadius: CGFloat = 0  // kept for API compatibility

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let c = chamferSize

        path.move(to: CGPoint(x: 0, y: 0))                          // top-left (normal)
        path.addLine(to: CGPoint(x: rect.width, y: 0))              // top-right (normal)
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - c)) // down to chamfer start
        path.addLine(to: CGPoint(x: rect.width - c, y: rect.height)) // chamfer cut (bottom-right only)
        path.addLine(to: CGPoint(x: 0, y: rect.height))             // bottom-left (normal)
        path.closeSubpath()

        return path
    }
}
