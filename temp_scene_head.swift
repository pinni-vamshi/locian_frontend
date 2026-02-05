//
//  SceneView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import Combine
import Photos

struct SceneView: View {
    // MARK: - Properties & State
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    enum PlacesSection {
        case recommended
        case other
struct TestView: View { }
