//
 //  SlantedTag.swift
 //  locian
 //
 //  Slanted ribbon/tag component for HUD-style UI elements
 //

 import SwiftUI

 // MARK: - Slanted Tag Shape
struct SlantedTagShape: Shape {
    var slant: CGFloat = 8   // controls angle depth (reduced from 12)

     func path(in rect: CGRect) -> Path {
         var path = Path()

         // Reversed slant direction (left side slant instead of right)
         path.move(to: CGPoint(x: slant, y: 0))                    // Start from indented top-left
         path.addLine(to: CGPoint(x: rect.width, y: 0))             // Top-right
         path.addLine(to: CGPoint(x: rect.width - slant, y: rect.height)) // Indented bottom-right
         path.addLine(to: CGPoint(x: 0, y: rect.height))            // Bottom-left
         path.closeSubpath()

         return path
     }
 }

 // MARK: - Slanted Tag View
struct SlantedTag: View {
    let text: String
    var slant: CGFloat = 8
     var font: Font = .system(size: 14, weight: .bold)
     var textColor: Color = .white
     var backgroundColor: Color = .blue
     var horizontalPadding: CGFloat = 14
     var verticalPadding: CGFloat = 6
    var shadowColor: Color = .white
    var shadowOffset: CGSize = CGSize(width: 3, height: 6)
    var hasTextShadow: Bool = false

    var body: some View {
        Text(text.uppercased())
            .font(font)
            .foregroundColor(textColor)
            .locianHardShadow(color: hasTextShadow ? .black : .clear, offset: hasTextShadow ? 1 : 0)
             .padding(.horizontal, horizontalPadding)
             .padding(.vertical, verticalPadding)
             .background(
                 ZStack {
                     // Shadow layer (offset at bottom)
                     SlantedTagShape(slant: slant)
                         .fill(shadowColor)
                         .offset(x: shadowOffset.width, y: shadowOffset.height)
                     
                     // Main shape
                     SlantedTagShape(slant: slant)
                         .fill(backgroundColor)
                 }
             )
     }
 }

 // MARK: - Convenience Initializers
 extension SlantedTag {
     // Theme-colored version (uses app's selected theme color)
     static func themed(text: String, themeColor: Color, slant: CGFloat = 8) -> SlantedTag {
         SlantedTag(
             text: text,
             slant: slant,
             backgroundColor: themeColor
         )
     }

     // HUD-style version (outlined with fill)
     static func hud(text: String, accentColor: Color, backgroundColor: Color = Color.black.opacity(0.8), slant: CGFloat = 8) -> some View {
         Text(text.uppercased())
             .font(.system(size: 14, weight: .bold))
             .foregroundColor(.white)
             .padding(.horizontal, 14)
             .padding(.vertical, 6)
             .background(
                 SlantedTagShape(slant: slant)
                     .stroke(accentColor, lineWidth: 2)
                     .background(
                         SlantedTagShape(slant: slant)
                             .fill(backgroundColor)
                     )
             )
     }
 }

 // MARK: - Preview (for development)
 struct SlantedTag_Previews: PreviewProvider {
     static var previews: some View {
         VStack(spacing: 20) {
             SlantedTag(text: "CURRENT LOCATION", backgroundColor: .blue)
             SlantedTag(text: "ACTIVE MOMENT", backgroundColor: .green)
             SlantedTag(text: "NEXT UP", slant: 16, backgroundColor: .orange)
             SlantedTag.hud(text: "WARNING", accentColor: .red)
         }
         .padding()
         .background(Color.gray.opacity(0.1))
     }
 }
