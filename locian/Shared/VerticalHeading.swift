//
//  VerticalHeading.swift
//  locian
//
//  Reusable vertical heading component with rotated text.
//

import SwiftUI

struct VerticalHeading: View {
    let text: String
    var textColor: Color = .black
    var backgroundColor: Color = .white
    var width: CGFloat = 24
    var height: CGFloat = 120
    
    var body: some View {
        GeometryReader { geo in
            Text(text)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .frame(width: geo.size.height) // Use measured height
                .fixedSize(horizontal: false, vertical: true)
                .rotationEffect(.degrees(-90))
                .frame(width: geo.size.width, height: geo.size.height)
                .background(backgroundColor)
        }
        .frame(width: width) // Width is still fixed, height is flexible
    }
}
