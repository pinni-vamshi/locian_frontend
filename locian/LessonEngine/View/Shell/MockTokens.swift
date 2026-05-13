//
//  MockTokens.swift
//  locian
//
//  Color/spacing tokens lifted directly from the lesson-engine HTML mock:
//    --bg:#080808; --fg:#F2F2F0; --pink:#FF1F6B; --green:#00E87A;
//    --g0:#0E0E0E; --g1:#141414; --g2:#222; --g3:#2c2c2c; --g4:#3a3a3a;
//    --muted:#6A6A6A; --muted2:#9A9A9A;
//
//  Use these inside the lesson shell so the SwiftUI surface and the
//  HTML mock stay visually identical.
//

import SwiftUI

enum MockTokens {
    static let bg = Color(red: 0x08/255, green: 0x08/255, blue: 0x08/255)
    static let fg = Color(red: 0xF2/255, green: 0xF2/255, blue: 0xF0/255)
    static let pink = Color(red: 0xFF/255, green: 0x1F/255, blue: 0x6B/255)
    static let green = Color(red: 0x00/255, green: 0xE8/255, blue: 0x7A/255)
    static let yellow = Color(red: 0xFF/255, green: 0xD6/255, blue: 0x00/255)

    static let g0 = Color(red: 0x0E/255, green: 0x0E/255, blue: 0x0E/255)
    static let g1 = Color(red: 0x14/255, green: 0x14/255, blue: 0x14/255)
    static let g2 = Color(red: 0x22/255, green: 0x22/255, blue: 0x22/255)
    static let g3 = Color(red: 0x2C/255, green: 0x2C/255, blue: 0x2C/255)
    static let g4 = Color(red: 0x3A/255, green: 0x3A/255, blue: 0x3A/255)

    static let muted = Color(red: 0x6A/255, green: 0x6A/255, blue: 0x6A/255)
    static let muted2 = Color(red: 0x9A/255, green: 0x9A/255, blue: 0x9A/255)
}

/// A "stage" card — dark surface with a 3pt pink left border, used to
/// host the active sentence/word/cloze/etc. throughout the lesson.
struct StageCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(MockTokens.pink)
                .frame(width: 3)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
        }
        .background(MockTokens.g0)
    }
}
