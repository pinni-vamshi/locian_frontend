//
//  VocabularyView.swift
//  locian
//
//  Created by vamshi krishna pinni on 24/10/25.
//

import SwiftUI
import Foundation

struct VocabularyView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var iconOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.8
    @State private var wordsOpacity: Double = 0
    @State private var wordsScale: CGFloat = 0.8
    
    // Loading state for circle button
    @State private var isGeneratingSentence: Bool = false
    
    // Sentence generation modal state
    @State private var showingSentenceModal: Bool = false
    @State private var sentenceData: SentenceGenerationData?
    
    // Card stack borders - disabled by default
    @State private var showStackBorders: Bool = false
    
    // Card stack state for moments from vocabulary endpoint
    @State private var activeCategoryIndex: Int = 0
    @State private var cardDragOffset: CGSize = .zero
    @State private var textOpacity: Double = 1.0
    
    // Custom moment state
    @State private var customMomentText: String = ""
    
    // Slide-to-start state
    
    // Selection parameters passed from SceneView
    let isImageSelected: Bool
    let selectedPlace: String
    let selectedColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            content(for: geometry)
        }
        .onAppear {
        }
        .onDisappear {
            // Update vocabulary bulk when leaving vocabulary view
            appState.updateVocabularyBulk { _ in }
        }
    }
    
    @ViewBuilder
    private func headerIconSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main heading: "Choose your" (first line) and "Moment" (second line) – all in white, slightly inset
            VStack(alignment: .leading, spacing: 2) {
                Text("Choose your")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Moment")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
                    .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
            
            // Subtitle: real place name and generation time
            Text("Adjusted to \(sessionHeaderTitle()) • \(formattedCurrentTime())")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
                .padding(.leading, 4)
        }
        // Minimal padding so header hugs the top edge
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .opacity(iconOpacity)
        .scaleEffect(iconScale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.0)) {
                iconOpacity = 1
                iconScale = 1
            }
        }
    }
                    
    @ViewBuilder
    private func categoriesSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            // Check for new format: micro_situations
            if !appState.vocabularyMicroSituations.isEmpty {
                let microSituations = appState.vocabularyMicroSituations
                // Include custom moment card at the end
                let totalCards = microSituations.count + 1
                // Pre-calculate base card size
                let baseCardWidth = geometry.size.width * 0.65
                let baseCardHeight = geometry.size.height * 0.55
                
                ZStack {
                    // Render all cards stacked on top of each other, centered
                    // Regular moment cards
                    ForEach(microSituations.indices, id: \.self) { index in
                        let relativeIndex = (index - activeCategoryIndex + totalCards) % totalCards
                        let depth = CGFloat(relativeIndex)
                        
                        // Calculate card dimensions and properties
                        let cardWidth = baseCardWidth * calculateWidthMultiplier(for: Int(depth))
                        let cardHeight = baseCardHeight
                        // Opacity almost goes to zero by 4th depth card
                        let opacity = max(0.05, 1.0 - (depth * 0.25))
                        let dragOffset = relativeIndex == 0 ? cardDragOffset.width : 0
                        
                        CardView(
                            placeName: appState.vocabularyPlaceName ?? sessionHeaderTitle(),
                            categoryName: microSituations[index],
                            selectedColor: selectedColor,
                            isFront: relativeIndex == 0,
                            textOpacity: relativeIndex == 0 ? textOpacity : 1.0
                        )
                        .frame(width: cardWidth, height: cardHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: showStackBorders ? 2 : 0)
                        )
                        .offset(x: dragOffset, y: 0)
                        .opacity(opacity)
                        .zIndex(Double(totalCards - relativeIndex))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: activeCategoryIndex)
                        .onChange(of: activeCategoryIndex) {
                            // Fade in text when card becomes front
                            if relativeIndex == 0 {
                                textOpacity = 0
                                withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                                    textOpacity = 1.0
                                }
                            }
                        }
                    }
                    
                    // Custom moment card at the end
                    let customCardIndex = microSituations.count
                    let customRelativeIndex = (customCardIndex - activeCategoryIndex + totalCards) % totalCards
                    let customDepth = CGFloat(customRelativeIndex)
                    let customCardWidth = baseCardWidth * calculateWidthMultiplier(for: Int(customDepth))
                    let customOpacity = max(0.05, 1.0 - (customDepth * 0.25))
                    let customDragOffset = customRelativeIndex == 0 ? cardDragOffset.width : 0
                    
                    CustomMomentCardView(
                        placeName: appState.vocabularyPlaceName ?? sessionHeaderTitle(),
                        customMomentText: $customMomentText,
                        selectedColor: selectedColor,
                        isFront: customRelativeIndex == 0,
                        textOpacity: customRelativeIndex == 0 ? textOpacity : 1.0,
                        onCircleButtonTap: {
                            if !customMomentText.isEmpty {
                                handleCircleButtonTap(placeName: appState.vocabularyPlaceName ?? sessionHeaderTitle(), microSituation: customMomentText)
                            }
                        }
                    )
                    .frame(width: customCardWidth, height: baseCardHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: showStackBorders ? 2 : 0)
                    )
                    .offset(x: customDragOffset, y: 0)
                    .opacity(customOpacity)
                    .zIndex(Double(totalCards - customRelativeIndex))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: activeCategoryIndex)
                    .onChange(of: activeCategoryIndex) {
                        // Fade in text when card becomes front
                        if customRelativeIndex == 0 {
                            textOpacity = 0
                            withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                                textOpacity = 1.0
                            }
                        }
                    }
                }
                .frame(width: baseCardWidth, height: baseCardHeight + 40) // Increased height to prevent border from touching cards
                .frame(maxWidth: .infinity, alignment: .center)
                .clipped()
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Disable animations during drag for smooth following
                            let transaction = Transaction(animation: nil)
                            withTransaction(transaction) {
                                cardDragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            let horizontal = value.translation.width
                                // Always move to next card (circular loop), direction doesn't matter
                            if abs(horizontal) > 40 {
                                // Fade out text before transition
                                withAnimation(.easeOut(duration: 0.15)) {
                                    textOpacity = 0
                                }
                                
                                // Animate all cards forward - swiped card goes to back, others move forward
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    activeCategoryIndex = (activeCategoryIndex + 1) % totalCards
                                    cardDragOffset = .zero
                                }
                                
                                // Fade in text after transition
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    withAnimation(.easeIn(duration: 0.4)) {
                                        textOpacity = 1.0
                                    }
                                }
                            } else {
                                // Reset drag if swipe wasn't enough
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    cardDragOffset = .zero
                                }
                            }
                        }
                )
                
                // Swipe indicator and card counter
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(" swipe ")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text("\(activeCategoryIndex + 1)/\(totalCards)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 16)
            }
            // Check for old format: vocabularyResult with categories
            else if let vocabulary = appState.vocabularyResult {
                    let cats = vocabulary.categories
                if !cats.isEmpty {
                    // Include custom moment card at the end
                    let totalCards = cats.count + 1
                    // Pre-calculate base card size
                    let baseCardWidth = geometry.size.width * 0.65
                    let baseCardHeight = geometry.size.height * 0.55
                    
                    ZStack {
                        // Render all cards stacked on top of each other, centered
                        // Regular category cards
                        ForEach(cats.indices, id: \.self) { index in
                            let relativeIndex = (index - activeCategoryIndex + totalCards) % totalCards
                            let depth = CGFloat(relativeIndex)
                            
                            // Calculate card dimensions and properties
                            let cardWidth = baseCardWidth * calculateWidthMultiplier(for: Int(depth))
                            let cardHeight = baseCardHeight
                            // Opacity almost goes to zero by 4th depth card
                            let opacity = max(0.05, 1.0 - (depth * 0.25))
                            let dragOffset = relativeIndex == 0 ? cardDragOffset.width : 0
                            
                            let category = cats[index]
                            
                            CardView(
                                placeName: sessionHeaderTitle(),
                                categoryName: category,
                                selectedColor: selectedColor,
                                isFront: relativeIndex == 0,
                                textOpacity: relativeIndex == 0 ? textOpacity : 1.0
                            )
                            .frame(width: cardWidth, height: cardHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: showStackBorders ? 2 : 0)
                            )
                            .offset(x: dragOffset, y: 0)
                            .opacity(opacity)
                            .zIndex(Double(totalCards - relativeIndex))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: activeCategoryIndex)
                            .onChange(of: activeCategoryIndex) {
                                // Fade in text when card becomes front
                                if relativeIndex == 0 {
                                    textOpacity = 0
                                    withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                                        textOpacity = 1.0
                                    }
                                }
                            }
                        }
                        
                        // Custom moment card at the end
                        let customCardIndex = cats.count
                        let customRelativeIndex = (customCardIndex - activeCategoryIndex + totalCards) % totalCards
                        let customDepth = CGFloat(customRelativeIndex)
                        let customCardWidth = baseCardWidth * calculateWidthMultiplier(for: Int(customDepth))
                        let customOpacity = max(0.05, 1.0 - (customDepth * 0.25))
                        let customDragOffset = customRelativeIndex == 0 ? cardDragOffset.width : 0
                        
                        CustomMomentCardView(
                            placeName: sessionHeaderTitle(),
                            customMomentText: $customMomentText,
                            selectedColor: selectedColor,
                            isFront: customRelativeIndex == 0,
                            textOpacity: customRelativeIndex == 0 ? textOpacity : 1.0,
                            onCircleButtonTap: {
                                if !customMomentText.isEmpty {
                                    handleCircleButtonTap(placeName: sessionHeaderTitle(), microSituation: customMomentText)
                                }
                            }
                        )
                        .frame(width: customCardWidth, height: baseCardHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: showStackBorders ? 2 : 0)
                        )
                        .offset(x: customDragOffset, y: 0)
                        .opacity(customOpacity)
                        .zIndex(Double(totalCards - customRelativeIndex))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: activeCategoryIndex)
                        .onChange(of: activeCategoryIndex) {
                            // Fade in text when card becomes front
                            if customRelativeIndex == 0 {
                                textOpacity = 0
                                withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                                    textOpacity = 1.0
                                }
                            }
                        }
                    }
                    .frame(width: baseCardWidth, height: baseCardHeight + 40) // Increased height to prevent border from touching cards
                    .frame(maxWidth: .infinity, alignment: .center)
                    .clipped()
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Disable animations during drag for smooth following
                                let transaction = Transaction(animation: nil)
                                withTransaction(transaction) {
                                    cardDragOffset = value.translation
                                }
                            }
                            .onEnded { value in
                                let horizontal = value.translation.width
                                // Always move to next card (circular loop), direction doesn't matter
                                if abs(horizontal) > 40 {
                                    // Fade out text before transition
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        textOpacity = 0
                                    }
                                    
                                    // Animate all cards forward - swiped card goes to back, others move forward
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        activeCategoryIndex = (activeCategoryIndex + 1) % totalCards
                                        cardDragOffset = .zero
                                    }
                                    
                                    // Fade in text after transition
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        withAnimation(.easeIn(duration: 0.4)) {
                                            textOpacity = 1.0
                                        }
                                    }
                                } else {
                                    // Reset drag if swipe wasn't enough
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        cardDragOffset = .zero
                                    }
                                }
                            }
                    )
                    
                    // Swipe indicator and card counter below cards
                    VStack(spacing: 8) {
                        // Swipe indicator with chevron arrows
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(" swipe ")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // Card counter (e.g., "1/5")
                        Text("\(activeCategoryIndex + 1)/\(totalCards)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 16)
                }
            }
        }
        .frame(maxWidth: geometry.size.width)
        .opacity(wordsOpacity)
        .scaleEffect(wordsScale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15)) {
                wordsOpacity = 1
                wordsScale = 1
            }
        }
    }
    
    @ViewBuilder
    private func content(for geometry: GeometryProxy) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if appState.isLoadingQuiz {
                QuizLoadingAnimationView(selectedColor: appState.selectedColor)
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                VStack(spacing: 0) {
                    headerIconSection(geometry: geometry)
                    
                    Spacer()
                        .frame(height: 60) // Space between header and cards
                    
                    categoriesSection(geometry: geometry)
                }
                // Make the whole stack stick to the very top of the screen
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .top)
            }
        }
        .fullScreenCover(isPresented: $showingSentenceModal) {
            if let data = sentenceData {
                SentenceGenerationModal(
                    sentenceData: data,
                    isPresented: $showingSentenceModal,
                    selectedColor: selectedColor,
                    placeName: selectedPlace
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    
    // Calculate width multiplier based on depth (gradual decreasing percentage)
    private func calculateWidthMultiplier(for depth: Int) -> CGFloat {
        // Depth 0: base, Depth 1: +7%, Depth 2: +5%, Depth 3: +2.5%, Depth 4: +2%, Depth 5: +1.7%, Depth 6+: +1.5%
        let depthPercentages: [CGFloat] = [0.07, 0.05, 0.025, 0.02, 0.017, 0.015]
        
        // Cumulative multiplier
        var widthMultiplier: CGFloat = 1.0
        for i in 0..<min(depth, depthPercentages.count) {
            widthMultiplier *= (1.0 + depthPercentages[i])
        }
        // For depths beyond the array, continue with last percentage
        if depth > depthPercentages.count {
            for _ in depthPercentages.count..<depth {
                widthMultiplier *= (1.0 + (depthPercentages.last ?? 0.015))
            }
        }
        return widthMultiplier
    }
    
    // MARK: - Moment Card View
    @ViewBuilder
    private func CardView(
        placeName: String,
        categoryName: String,
        selectedColor: Color,
        isFront: Bool,
        textOpacity: Double = 1.0
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(selectedColor)
                // Side-biased shadow so it falls more to the side than the bottom
                .shadow(
                    color: .black.opacity(isFront ? 0.35 : 0.2),
                    radius: isFront ? 18 : 10,
                    x: isFront ? 14 : 8,
                    y: 2
                )
            
            if isFront {
        VStack(alignment: .leading, spacing: 12) {
                    // Top row: place icon (top-left)
                    Image(systemName: getIconForSelection())
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    // Centered endpoint text (category)
                    Text(categoryName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    // Bottom row: "Learn to communicate" + "in this moment" text + circle arrow button
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Learn to communicate")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                            
                            Text("in this moment")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                }
                        .opacity(textOpacity)
                        
                        Spacer()
                        
                        Button(action: {
                            // Call generate sentence API instead of word learning modal
                            handleCircleButtonTap(placeName: placeName, microSituation: categoryName)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 56, height: 56)
                                
                                if isGeneratingSentence {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: selectedColor))
                                        .scaleEffect(1.2)
                                } else {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(selectedColor)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .circleButtonPressAnimation()
                        .opacity(textOpacity)
                        .disabled(isGeneratingSentence)
                    }
                }
                .padding(22)
            }
        }
    }
    
    private func getIconForSelection() -> String {
        if isImageSelected {
            return "photo.fill"
        }
        
        // Use the same icon matching logic as SceneView, matching against localized place names
        let place = selectedPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if it's "Locian's choice" or inferred category
        if place == languageManager.scene.lociansChoice || place.lowercased().contains("brain") || place.lowercased().contains("locian") {
            return "sparkles"
        }
        
        // Map localized scene names to icons (using languageManager.scene properties)
        switch place.lowercased() {
        case languageManager.scene.airport.lowercased(): return "airplane"
        case languageManager.scene.cafe.lowercased(): return "cup.and.saucer.fill"
        case languageManager.scene.gym.lowercased(): return "figure.run"
        case languageManager.scene.home.lowercased(): return "house.fill"
        case languageManager.scene.library.lowercased(): return "book.fill"
        case languageManager.scene.office.lowercased(): return "building.2.fill"
        case languageManager.scene.park.lowercased(): return "tree.fill"
        case languageManager.scene.restaurant.lowercased(): return "fork.knife"
        case languageManager.scene.shoppingMall.lowercased(): return "bag.fill"
        case languageManager.scene.travelling.lowercased(): return "map.fill"
        case languageManager.scene.university.lowercased(): return "graduationcap.fill"
        default:
            // Fallback: try English names as well for backward compatibility
            switch place.lowercased() {
            case "airport": return "airplane"
            case "cafe": return "cup.and.saucer.fill"
            case "gym": return "figure.run"
            case "home", "house": return "house.fill"
            case "library": return "book.fill"
            case "office", "workplace": return "building.2.fill"
            case "park": return "tree.fill"
            case "restaurant": return "fork.knife"
            case "shopping mall", "mall": return "bag.fill"
            case "travelling", "travel": return "map.fill"
            case "university", "college", "school": return "graduationcap.fill"
            default: return "location.fill"
            }
        }
    }
    
    private func getSceneName() -> String {
        return isImageSelected ? "Scene" : "Your Surroundings"
    }
    
    private func getInstructionText() -> String {
        return "Tap each category you want to explore and learn. When you're ready, start practice!"
    }
    
    private func sessionHeaderTitle() -> String {
        if isImageSelected {
            return "Image Session"
        }
        
        let trimmed = selectedPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? languageManager.scene.lociansChoice : trimmed
    }
    
    private func sessionHeaderSubtitle() -> String {
        let timeString = formattedCurrentTime()
        if isImageSelected {
            return "Adjusted to your captured image • \(timeString)"
        }
        
        let trimmed = selectedPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Adjusted to Locian's choice • \(timeString)"
        }
        return "Adjusted to \(trimmed) • \(timeString)"
    }
    
    private func formattedCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
    
    // MARK: - Progressive Sentence Learning
    private func handleCircleButtonTap(placeName: String, microSituation: String) {
        TraceLogger.shared.trace(.targetLanguage, step: "Circle button tapped for sentence generation", data: [
            "place_name": placeName,
            "micro_situation": microSituation
        ])
        TraceLogger.shared.traceUI(.targetLanguage, component: "VocabularyView", state: [
            "place": placeName,
            "situation": microSituation
        ], action: "circle_button_tap")
        
        // Set loading state
        isGeneratingSentence = true
        
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else {
            TraceLogger.shared.trace(.targetLanguage, step: "No auth token for sentence generation")
            isGeneratingSentence = false
            return
        }
        
        // Get language codes
        guard let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) else {
            TraceLogger.shared.trace(.targetLanguage, step: "No default language pair found")
            return
        }
        
        TraceLogger.shared.trace(.targetLanguage, step: "Default pair found", data: [
            "native": defaultPair.native_language,
            "target": defaultPair.target_language
        ])
        
        let targetLanguage = appState.getLanguageCodeForAPI(for: defaultPair.target_language)
        let userLanguage = appState.getLanguageCodeForAPI(for: defaultPair.native_language)
        
        TraceLogger.shared.trace(.targetLanguage, step: "Language codes resolved", data: [
            "native_code": userLanguage,
            "target_code": targetLanguage
        ])
        
        // Get place name (use vocabulary place name if available, otherwise use passed placeName)
        let placeNameToUse = appState.vocabularyPlaceName ?? placeName
        
        // Get profession and time
        let profession = appState.profession.isEmpty ? nil : appState.profession
        let time = formattedCurrentTime()
        
        TraceLogger.shared.trace(.targetLanguage, step: "Request parameters prepared", data: [
            "place_name": placeNameToUse,
            "profession": profession ?? "nil",
            "time": time,
            "micro_situation": microSituation
        ])
        
        let request = SentenceGenerationRequest(
            target_language: targetLanguage,
            place_name: placeNameToUse,
            user_language: userLanguage,
            micro_situation: microSituation,
            profession: profession,
            time: time
        )
        
        TraceLogger.shared.traceAPI(.targetLanguage, endpoint: "/api/teaching/generate-sentence", request: [
            "target_language": targetLanguage,
            "place_name": placeNameToUse,
            "user_language": userLanguage,
            "profession": profession ?? "nil",
            "time": time,
            "micro_situation": microSituation
        ])
        
        TeachingAPIManager.shared.generateSentence(request: request, sessionToken: sessionToken) { result in
            DispatchQueue.main.async {
                // Reset loading state
                isGeneratingSentence = false
                
                switch result {
                case .success(let response):
                    TraceLogger.shared.trace(.targetLanguage, step: "Sentence generation API success", data: [
                        "lesson_id": response.lesson_id,
                        "place_name": response.place_name
                    ])
                    
                    TraceLogger.shared.traceParsing(.targetLanguage, parsedObject: [
                        "lesson_id": response.lesson_id,
                        "core1_steps": [
                            "step1": response.core1.step1.target_word,
                            "step2": response.core1.step2.target_word,
                            "step3": response.core1.step3.target_word
                        ],
                        "core2_sentence": response.core2.step1.sentence_target
                    ])
                    
                    // Store data and show modal (response IS the data in new format)
                    sentenceData = response
                    showingSentenceModal = true
                    
                    TraceLogger.shared.traceUI(.targetLanguage, component: "VocabularyView", state: [
                        "has_data": sentenceData != nil
                    ], action: "show_sentence_modal")
                    
                    // Record this micro-situation for Knowledge Graph update (deferred, batched)
                    KnowledgeGraphSessionManager.shared.recordMicroSituation(
                        placeName: placeNameToUse,
                        placeDetail: nil,
                        microSituation: microSituation,
                        sessionToken: sessionToken
                    )
                    
                case .failure(let error):
                    TraceLogger.shared.trace(.targetLanguage, step: "Sentence generation API failed", data: ["error": error.localizedDescription])
                    break
                }
            }
        }
    }
}

// MARK: - Custom Moment Card View
struct CustomMomentCardView: View {
    let placeName: String
    @Binding var customMomentText: String
    let selectedColor: Color
    let isFront: Bool
    let textOpacity: Double
    let onCircleButtonTap: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(selectedColor)
                .shadow(
                    color: .black.opacity(isFront ? 0.35 : 0.2),
                    radius: isFront ? 18 : 10,
                    x: isFront ? 14 : 8,
                    y: 2
                )
            
            if isFront {
                VStack(alignment: .leading, spacing: 12) {
                    // Top row: place icon (top-left)
                    Image(systemName: "location.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    // Center: Show "+" button if empty, or show text if filled
                    ZStack {
                        // Display text or "+" button (visual only, behind text field)
                        // Hide "+" when focused, show text when not focused or when there's text
                        if customMomentText.isEmpty && !isFocused {
                            Text("+")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .opacity(textOpacity)
                                .allowsHitTesting(false) // Don't block text field taps
                        } else if !customMomentText.isEmpty && !isFocused {
                            Text(customMomentText)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .opacity(textOpacity)
                                .allowsHitTesting(false) // Don't block text field taps
                        }
                        
                        // Text field that brings up keyboard - visible cursor when focused
                        TextField("", text: $customMomentText, axis: .vertical)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(isFocused ? .black : .clear) // Show text when focused
                            .tint(.black) // Show cursor when focused
                            .focused($isFocused)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .lineLimit(1...10) // Allow multiple lines, up to 10
                            .contentShape(Rectangle()) // Make entire area tappable
                    }
                    .onTapGesture {
                        // Focus the text field when tapping anywhere in the center area
                        isFocused = true
                    }
                    
                    Spacer()
                    
                    // Bottom row: Conditional display based on whether text is entered
                    if customMomentText.isEmpty {
                        // Show instruction text when empty
                        Text("Tap + button to enter your own moment")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .opacity(textOpacity)
                    } else {
                        // Show "Learn to communicate" text and circle button when text is entered
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Learn to communicate")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                                
                                Text("in this moment")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                            }
                            .opacity(textOpacity)
                            
                            Spacer()
                            
                            Button(action: onCircleButtonTap) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(selectedColor)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .circleButtonPressAnimation()
                            .opacity(textOpacity)
                        }
                    }
                }
                .padding(22)
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isFocused = false
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    VocabularyView(
        appState: AppStateManager(),
        isImageSelected: false,
        selectedPlace: "Home",
        selectedColor: AppStateManager.selectedColor
    )
    .preferredColorScheme(.dark)
}

