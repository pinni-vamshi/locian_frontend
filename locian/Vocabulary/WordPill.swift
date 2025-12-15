import SwiftUI

struct WordPill: View {
    let nativeText: String
    
    let selectedColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            Text(nativeText)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(selectedColor)
                        .overlay(
                            Capsule()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .buttonPressAnimation() // Centralized animation
    }
}

#Preview {
    VStack(spacing: 10) {
        WordPill(nativeText: "order", selectedColor: AppStateManager.selectedColor) { }
        WordPill(nativeText: "take away", selectedColor: AppStateManager.selectedColor) { }
        WordPill(nativeText: "menu", selectedColor: AppStateManager.selectedColor) { }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
