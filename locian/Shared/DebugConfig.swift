import SwiftUI

/// Global configuration for app-wide debugging features.
struct DebugConfig {
    /// Toggle this to show or hide all diagnostic borders across the app.
    static var showDiagnosticBorders: Bool {
        return AppStateManager.shared.showDiagnosticBorders
    }
}


enum DiagnosticBorderStyle {
    case solid
    case dashed
}

extension View {
    /// Applies a border only if diagnostic borders are enabled in DebugConfig.
    /// - Parameters:
    ///   - color: The color of the border.
    ///   - width: The width of the border.
    ///   - style: The style of the border (.solid or .dashed).
    /// - Returns: A view with a conditional border.
    @ViewBuilder
    func diagnosticBorder(_ color: Color, width: CGFloat = 1, style: DiagnosticBorderStyle = .solid, label: String? = nil) -> some View {
        if DebugConfig.showDiagnosticBorders {
            self.overlay(
                ZStack(alignment: .topTrailing) {
                    if style == .dashed {
                        Rectangle()
                            .stroke(color, style: StrokeStyle(lineWidth: width, dash: [4, 4]))
                    } else {
                        Rectangle()
                            .stroke(color, lineWidth: width)
                    }
                    
                    if let label = label {
                        Text(label)
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(color)
                            .offset(x: 0, y: -12) // Move above the frame
                    }
                }
                .allowsHitTesting(false)
            )
        } else {
            self
        }
    }
}
