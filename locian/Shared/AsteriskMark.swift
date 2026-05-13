import SwiftUI

/// Tumb-style asterisk.
/// Each arm: thick uniform body from centre → parallel sides for most of arm
/// → slight flare outward near tip → flat blunt tip. Sharp corners throughout.
struct AsteriskMark: View {
    var size: CGFloat
    var color: Color = ThemeColors.secondaryAccent
    var rotation: Double = 0

    var body: some View {
        Canvas { ctx, canvasSize in
            let cx = canvasSize.width  / 2
            let cy = canvasSize.height / 2

            let armLength  = canvasSize.width * 0.46   // centre → tip
            let flareStart = canvasSize.width * 0.31   // parallel body ends here (~67% of arm), flare begins
            let bodyHW     = canvasSize.width * 0.135  // half-width of the uniform body (thick from centre)
            let tipHW      = canvasSize.width * 0.195  // half-width at the tip (slightly wider than body)

            for i in 0..<6 {
                let angleDeg = Double(i) * 60.0 + rotation
                let rad      = angleDeg * .pi / 180.0

                // Arm pointing straight up before rotation — 6 points
                // Shape: thick rectangle from centre to flareStart,
                //        then angles outward to tipHW at armLength, flat end.
                let raw: [CGPoint] = [
                    CGPoint(x: cx - bodyHW, y: cy),               // 0 base-left   (at centre)
                    CGPoint(x: cx + bodyHW, y: cy),               // 1 base-right  (at centre)
                    CGPoint(x: cx + bodyHW, y: cy - flareStart),  // 2 parallel end, right
                    CGPoint(x: cx + tipHW,  y: cy - armLength),   // 3 tip-right   (flat end)
                    CGPoint(x: cx - tipHW,  y: cy - armLength),   // 4 tip-left    (flat end)
                    CGPoint(x: cx - bodyHW, y: cy - flareStart),  // 5 parallel end, left
                ]

                let rotated = raw.map { p -> CGPoint in
                    let dx = p.x - cx, dy = p.y - cy
                    return CGPoint(
                        x: cx + dx * cos(rad) - dy * sin(rad),
                        y: cy + dx * sin(rad) + dy * cos(rad)
                    )
                }

                var path = Path()
                path.move(to: rotated[0])
                rotated.dropFirst().forEach { path.addLine(to: $0) }
                path.closeSubpath()

                ctx.fill(path, with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 40) {
            AsteriskMark(size: 120, color: ThemeColors.secondaryAccent)
            AsteriskMark(size: 60,  color: .white)
            AsteriskMark(size: 36,  color: CyberColors.neonCyan, rotation: 30)
        }
    }
}
