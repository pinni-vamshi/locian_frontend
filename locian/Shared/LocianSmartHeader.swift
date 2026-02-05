import SwiftUI
import UIKit


struct LocianSmartHeader: View {
    let text: String
    let fontSize: CGFloat
    var maxLines: Int = 2
    var textColor: Color = .white
    var shadowColor: Color = .gray
    var scale: CGFloat = 1.0
    var fontWeight: Font.Weight = .black
    var highlightedWords: [String: Color] = [:]
    
    var body: some View {
        attributedText
            .font(.system(size: fontSize * scale, weight: fontWeight))
            .shadow(color: shadowColor, radius: 1, x: 0, y: 1)
            .lineLimit(maxLines)
            .minimumScaleFactor(0.01) // Allow unlimited scaling down to fit geometry
            .id(text) // Force view recreation on text change
            .transition(.opacity.animation(.easeInOut(duration: 0.2))) // Smooth Fade In/Out
    }
    
    private var attributedText: Text {
        let words = text.split(separator: " ")
        var result = Text("")
        
        for (index, word) in words.enumerated() {
            let string = String(word)
            // Check for exact match or uppercased match
            let color = highlightedWords[string] ?? 
                        highlightedWords[string.uppercased()] ?? 
                        textColor
            
            let wordText = Text(string).foregroundColor(color)
            
            if index == 0 {
                result = wordText
            } else {
                result = result + Text(" ") + wordText
            }
        }
        
        return result
    }

}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
