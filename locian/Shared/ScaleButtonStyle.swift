import SwiftUI

// Custom button style for scaling effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    HapticFeedback.buttonPress()
                } else {
                    HapticFeedback.buttonRelease()
                }
            }
    }
}
