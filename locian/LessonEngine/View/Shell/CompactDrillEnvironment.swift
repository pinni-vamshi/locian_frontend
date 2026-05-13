//
//  CompactDrillEnvironment.swift
//  locian
//
//  Environment flag + view modifier that lets the existing drill views adapt
//  to the new conversation shell's 60% bottom zone without rewriting each
//  view top-to-bottom.
//
//  Drill views that opt in can read `@Environment(\.compactDrillZone)` and:
//    • skip their own back-button header (the conversation shell owns it)
//    • drop full-screen `Color.black.ignoresSafeArea()` backgrounds
//    • tighten outer padding
//
//  The shell sets it on ActiveTurnView's drill zone:
//    .environment(\.compactDrillZone, true)
//

import SwiftUI

private struct CompactDrillZoneKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var compactDrillZone: Bool {
        get { self[CompactDrillZoneKey.self] }
        set { self[CompactDrillZoneKey.self] = newValue }
    }
}
