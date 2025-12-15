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
        case custom
    }
    
    init(appState: AppStateManager) {
        self.appState = appState
    }
    
    @State var showingCamera = false
    @State var showingGallery = false
    @State var selectedImage: UIImage?
    @State var circleButtonScale: CGFloat = 0.0
    @State var circleButtonOpacity: Double = 0.0
    @State var loadingIconIndex = 0
    @State var loadingIconOpacity: Double = 0
    @State var isImageSelected: Bool = false
    @State var highlightedIndex: Int? = nil
    @State var viewOpacity: Double = 0
    @State var viewScale: CGFloat = 0.95
    @State var shouldScrollToLocian: Bool = false
    @State var showArrowInCircle: Bool = false // For alternating icon/arrow animation
    @State var iconArrowTimer: Timer? = nil
    @State var bigStackScale: CGFloat = 1.0 // For pulsating the big stack during loading
    @State var isCameraPreviewActive: Bool = false
    @State var dotAnimationPhase: Int = 0
    @State var dotAnimationTimer: Timer?
    @State var loadingIconCycleTimer: Timer?
    @State var hasSetDefaultSceneSelection: Bool = false
    @State var hasUserSelectedPlaceManually: Bool = false
    @State var recentPlaces: [String] = []
    @State var customSelectedPlace: String? = nil
    @State var openPlacesSection: PlacesSection? = .recommended
    @State var currentRecentBucket: String = "" // No longer using cache
    @State var customPlaces: [String] = []
    @State var showingQuickLookModal: Bool = false
    @State var customPlaceInputText: String = "" // For the input field in Learn tab
    @State var clickedWords: [ClickedWord] = []
    @State var isLoadingClickedWords: Bool = false
    @State var isButtonDisabled: Bool = false
    @State var showingStreakModal: Bool = false
    @State var showingProfileImagePicker: Bool = false
    @State var showingProfileImagePickerCamera: Bool = false
    @State var showingProfileImagePickerGallery: Bool = false
    @State var isProfileImageSelected: Bool = false
    @State var cachedProfileImage: UIImage? = nil
    @State var previousImages: [UIImage] = [] // Store previous captured images
    private let recentPlacesTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private let customPlacesStorageKey = "com.locian.customPlaces"
    private let previousImagesStorageKey = "com.locian.previousImages"
    private let inferInterestIconMap: [String: String] = [
        "airport": "airplane",
        "bank_branch": "building.columns.fill",
        "bar": "wineglass.fill",
        "cafe": "cup.and.saucer.fill",
        "cafeteria": "takeoutbag.and.cup.and.straw.fill",
        "cinema": "film.fill",
        "city_center": "building.2.fill",
        "client_site": "briefcase.fill",
        "clinic": "cross.case.fill",
        "court": "hammer.fill",
        "coworking_space": "person.2.fill",
        "dormitory": "bed.double.fill",
        "food_court": "fork.knife.circle.fill",
        "gallery": "photo.on.rectangle.angled",
        "grocery_store": "cart.fill",
        "gym": "figure.run",
        "home": "house.fill",
        "hospital": "cross.case.fill",
        "hospital_cafeteria": "fork.knife.circle.fill",
        "hostel": "bed.double.fill",
        "hotel": "bed.double.fill",
        "kitchen": "fork.knife",
        "library": "book.closed.fill",
        "market": "cart",
        "meeting_room": "person.3.fill",
        "museum": "building.columns.fill",
        "office": "building.2.fill",
        "office_cafeteria": "fork.knife.circle.fill",
        "park": "tree.fill",
        "restaurant": "fork.knife",
        "school": "building.columns",
        "school_canteen": "fork.knife.circle.fill",
        "shopping_mall": "bag.fill",
        "station": "tram.fill",
        "studio": "music.mic",
        "study_room": "book.closed.fill",
        "train_station": "tram.fill",
        "university": "graduationcap.fill",
        "citycentre": "building.2.fill",
        "trainstation": "tram.fill",
        "bank": "building.columns.fill",
        "gallery_space": "photo.on.rectangle.angled",
        "grocery": "cart.fill"
    ]
    
    // Slider state for vocabulary generation
    
    private var selectedColor: Color {
        appState.selectedColor
    }
    
    private var tileBackgroundColor: Color {
        Color.gray.opacity(0.28)
    }
    
    private var tileAccentColor: Color {
        appState.selectedTheme == "Pure White" ? Color.white : selectedColor
    }
    
    private var hasReadyVocabularyContext: Bool {
        let place = appState.vocabularySelectedPlace.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !place.isEmpty else { return false }
        
        let userLang = appState.vocabularyUserLanguage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !userLang.isEmpty else { return false }
        
        let targetLang = appState.vocabularyTargetLanguage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !targetLang.isEmpty else { return false }
        
        let time = appState.vocabularyRequestTime?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !time.isEmpty else { return false }
        
        return true
    }
    
    // Computed binding for profile image with caching
    private var profileImageBinding: Binding<UIImage?> {
        Binding(
            get: {
                // Use cached image if available
                if let cached = cachedProfileImage {
                    return cached
                }
                // Otherwise, create from data (cache will be updated in onAppear/onChange)
                if let data = appState.profileImageData, let image = UIImage(data: data) {
                    return image
                }
                return nil
            },
            set: { newImage in
                if let image = newImage, let data = image.jpegData(compressionQuality: 0.5) {
                    self.appState.profileImageData = data
                    // Update cache
                    self.cachedProfileImage = image
                } else {
                    self.appState.profileImageData = nil
                    // Clear cache
                    self.cachedProfileImage = nil
                }
            }
        )
    }
    
    // Situation examples for custom modal
    
    // Get localized scene options
    private var sceneOptions: [String] {
        let basePlaces = [
            languageManager.scene.airport,
            languageManager.scene.aquarium,
            languageManager.scene.bakery,
            languageManager.scene.beach,
            languageManager.scene.bookstore,
            languageManager.scene.cafe,
            languageManager.scene.cinema,
            languageManager.scene.gym,
            languageManager.scene.hospital,
            languageManager.scene.hotel,
            languageManager.scene.library,
            languageManager.scene.market,
            languageManager.scene.museum,
            languageManager.scene.office,
            languageManager.scene.park,
            languageManager.scene.restaurant,
            languageManager.scene.shoppingMall,
            languageManager.scene.stadium,
            languageManager.scene.supermarket,
            languageManager.scene.temple,
            languageManager.scene.travelling,
            languageManager.scene.university
        ]
        
        var uniquePlaces: [String] = []
        for place in basePlaces {
            if !uniquePlaces.contains(where: { $0.caseInsensitiveCompare(place) == .orderedSame }) {
                uniquePlaces.append(place)
            }
        }
        
        return uniquePlaces.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }
    
    // MARK: - Icon & Display Helpers
    // Map scene options to SF icons
    func getIconForScene(_ scene: String, index: Int? = nil) -> String {
        // Check if it's Locian's choice (index 0) using localized string comparison
        if let idx = index, idx == 0 {
            // Return language-specific icon for Locian's choice
            switch languageManager.currentLanguage {
            case .japanese: return "sparkles"
            case .hindi: return "sparkles"
            case .telugu: return "sparkles"
            case .tamil: return "sparkles"
            case .chinese: return "sparkles"
            case .korean: return "sparkles"
            case .russian: return "sparkles"
            case .malayalam: return "sparkles"
            case .french: return "sparkles"
            case .german: return "sparkles"
            case .spanish: return "sparkles"
            case .english: return "sparkles"
            }
        }
        
        // Check if it's image analysis result (index 1 if present)
        if let idx = index, idx == 1, let imageResult = appState.imageAnalysisResult, !imageResult.isEmpty, scene == imageResult {
            return "photo.fill"
        }
        
        // Check if scene matches localized "Locian's choice" string
        if scene == languageManager.scene.lociansChoice {
            return "sparkles"
        }
        
        if scene == "BY_LOCIAN_LOADING" {
            return "sparkles"
        }
        
        let normalized = scene
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
        
        if let icon = inferInterestIconMap[normalized] {
            return icon
        }
        
        // Map scene names to icons (using localized scene names)
        switch scene.lowercased() {
        case languageManager.scene.airport.lowercased(): return "airplane"
        case languageManager.scene.aquarium.lowercased(): return "fish.fill"
        case languageManager.scene.bakery.lowercased(): return "takeoutbag.and.cup.and.straw.fill"
        case languageManager.scene.beach.lowercased(): return "sun.max.fill"
        case languageManager.scene.bookstore.lowercased(): return "books.vertical.fill"
        case languageManager.scene.cafe.lowercased(): return "cup.and.saucer.fill"
        case languageManager.scene.cinema.lowercased(): return "film.fill"
        case languageManager.scene.gym.lowercased(): return "figure.run"
        case languageManager.scene.hospital.lowercased(): return "cross.case.fill"
        case languageManager.scene.hotel.lowercased(): return "bed.double.fill"
        case languageManager.scene.home.lowercased(): return "house.fill"
        case languageManager.scene.library.lowercased(): return "book.fill"
        case languageManager.scene.market.lowercased(): return "cart.fill"
        case languageManager.scene.museum.lowercased(): return "building.columns.fill"
        case languageManager.scene.office.lowercased(): return "building.2.fill"
        case languageManager.scene.park.lowercased(): return "tree.fill"
        case languageManager.scene.restaurant.lowercased(): return "fork.knife"
        case languageManager.scene.shoppingMall.lowercased(): return "bag.fill"
        case languageManager.scene.stadium.lowercased(): return "sportscourt"
        case languageManager.scene.supermarket.lowercased(): return "basket.fill"
        case languageManager.scene.temple.lowercased(): return "building.columns"
        case languageManager.scene.travelling.lowercased(): return "map.fill"
        case languageManager.scene.university.lowercased(): return "graduationcap.fill"
        default: return "location.fill"
        }
    }

    // MARK: - Place Selection Helpers
    @ViewBuilder
    func placeIconView(for place: String, index: Int? = nil) -> some View {
        ZStack {
            Circle()
                .fill(selectedColor)
                .frame(width: 40, height: 40)
            
            Image(systemName: getIconForScene(place, index: index))
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        }
        .transition(.opacity)
    }
    
    // Get the currently selected scene name
    func getSelectedSceneName() -> String? {
        guard let idx = highlightedIndex else { return nil }
        let options = displaySceneOptions()
        guard idx < options.count else { return nil }
        return options[idx]
    }
    
    func isPlaceSelected(_ place: String) -> Bool {
        if let customSelectedPlace,
           customSelectedPlace.caseInsensitiveCompare(place) == .orderedSame {
            return true
        }
        
        if let selected = getSelectedSceneName(),
           selected.caseInsensitiveCompare(place) == .orderedSame {
            return true
        }
        
        return false
    }
    
    // MARK: - Body & Main Views
    var body: some View {
        applySceneEventHandlers(
            sceneGeometryView()
        )
        .onChange(of: appState.vocabularySelectedPlace) { oldValue, newValue in
            // Sync customSelectedPlace with vocabulary generation place
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                customSelectedPlace = trimmed
            }
        }
    }


    @ViewBuilder
    func sceneGeometryView() -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if appState.isAnalyzingImage {
                    ImageAnalysisLoadingAnimationView(selectedColor: appState.selectedColor)
                        .transition(.opacity)
                        .zIndex(1)
                } else if appState.isGeneratingVocabulary {
                    VocabularyLoadingAnimationView(
                        request: appState.currentVocabularyRequest,
                        selectedColor: appState.selectedColor
                    )
                    .transition(.opacity)
                    .zIndex(1)
                } else {
                    VStack(spacing: 0) {
                        // Fixed header section
                        headerSection(geometry: geometry)
                            .background(Color.black)
                            .zIndex(1)
                        
                        // Scrollable content below header
                        ScrollView {
                            VStack(spacing: 0) {
                                // Camera tile - FIRST
                                cameraTileSection(geometry: geometry)
                                .padding(.top, 20)
                                
                                // Spacing between camera and images
                                Spacer()
                                    .frame(height: 24)
                                
                                // Previous images scrolling section - SECOND
                                self.previousImagesSection()
                                
                                // Spacing before routine section
                                Spacer()
                                    .frame(height: 20)
                                
                                // Your routine section (recommendations) - THIRD
                                YourRoutineSectionView(
                                    appState: appState,
                                    selectedColor: selectedColor,
                                    onPlaceTap: { place in
                                        handleRecommendedPlaceTap(place, options: displaySceneOptions())
                                    },
                                    isPlaceSelected: { place in
                                        isPlaceSelected(place)
                                    },
                                    cleanInferredCategory: cleanInferredCategory
                                )
                                .padding(.bottom, 14)
                                
                                // Spacing before custom places section
                                Spacer()
                                    .frame(height: 20)
                                
                                // Custom situations section - FOURTH
                                CustomPlacesSectionView(
                                    appState: appState,
                                    customPlaces: $customPlaces,
                                    customSelectedPlace: $customSelectedPlace,
                                    selectedColor: selectedColor,
                                    onPlaceTap: { place in
                                        handleRecommendedPlaceTap(place, options: displaySceneOptions())
                                    },
                                    onLearnTap: { placeName in
                                        generateVocabularyWithPlaceName(placeName: placeName)
                                    },
                                    onSaveCustomPlaces: {
                                        saveCustomPlaces()
                                    }
                                )
                                .padding(.bottom, 14)
                            }
                            .padding(.top, 0)
                            .padding(.horizontal, 0)
                        }
                        .scrollContentBackground(.hidden)
                        .contentMargins(.leading, 0, for: .scrollContent)
                        .frame(maxWidth: geometry.size.width)
                    }
                    .opacity(viewOpacity)
                    .scaleEffect(viewScale)
                    .background(Color.black)
                    .zIndex(0)
            }
            
                // Floating AssistiveTouch button (only show if enabled in settings and not loading)
                if appState.showQuickRecallButton && !appState.isLoadingSession {
            FloatingAssistiveButton(
                onTap: {
                    // Trigger API call when button is clicked
                            self.fetchClickedWords()
                },
                isDisabled: isButtonDisabled
            )
            .zIndex(1000) // Always on top
        }
    }
        }
    }

    func applySceneEventHandlers<V: View>(_ view: V) -> some View {
        applySceneSheetHandlers(
            applySceneAlertHandlers(
                applySceneFullScreenCovers(
                    applySceneChangeHandlers(
                        applySceneReceiveHandlers(view)
                    )
                )
            )
        )
    }

    func applySceneReceiveHandlers<V: View>(_ view: V) -> some View {
        view
            .onReceive(appState.$userLanguagePairs) { _ in
                handleLanguagePairsUpdate()
            }
            .onReceive(recentPlacesTimer) { _ in
                handleRecentPlacesTimerTick()
            }
        .onAppear {
                self.handleSceneAppear()
                // Load custom places
                self.loadCustomPlaces()
                // Load previous images
                self.loadPreviousImages()
                // Cache profile image on appear (only if not already cached)
                if self.cachedProfileImage == nil, let data = self.appState.profileImageData {
                    self.cachedProfileImage = UIImage(data: data)
                }
            }
            .onChange(of: appState.profileImageData) { oldValue, newValue in
                // Only update cache when profileImageData actually changes
                if let data = newValue {
                    self.cachedProfileImage = UIImage(data: data)
                } else {
                    self.cachedProfileImage = nil
                }
            }
    }

    func applySceneChangeHandlers<V: View>(_ view: V) -> some View {
        applyLanguageChangeHandlers(
            applyVocabularyChangeHandlers(
                applyInferenceChangeHandlers(
                    applyImageChangeHandlers(
                        applySelectionChangeHandlers(view)
                    )
                )
            )
        )
    }
    
    func applySelectionChangeHandlers<V: View>(_ view: V) -> some View {
        view
            .onChange(of: highlightedIndex) { oldValue, newValue in
                handleHighlightedIndexChange(oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: shouldScrollToLocian) { _, newValue in
                handleScrollToLocianChange(newValue)
            }
    }
    
    func applyImageChangeHandlers<V: View>(_ view: V) -> some View {
        view
            .onChange(of: appState.isAnalyzingImage) { _, isAnalyzing in
                handleImageAnalysisStateChange(isAnalyzing: isAnalyzing)
            }
            .onChange(of: appState.imageAnalysisResult) { _, _ in
                handleImageAnalysisResultChange()
            }
            .onChange(of: isImageSelected) { _, newValue in
                handleImageSelectionChange(newValue)
            }
    }
    
    func applyInferenceChangeHandlers<V: View>(_ view: V) -> some View {
        view
            .onChange(of: appState.inferredPlaceCategory) { _, newValue in
                handleInferredCategorySelection(newValue)
            }
            .onChange(of: appState.inferredPlaceCategory) { _, category in
                handleInferredCategoryVisibilityChange(category)
            }
            .onChange(of: appState.isInferringInterest) { _, isInferring in
                handleInferenceStateChange(isInferring: isInferring)
            }
            .onChange(of: appState.shouldAttemptInferInterest) { _, shouldAttempt in
                handleInferInterestFlagChange(shouldAttempt)
            }
    }
    
    func applyVocabularyChangeHandlers<V: View>(_ view: V) -> some View {
        view
            .onChange(of: appState.shouldShowVocabularyView) { _, showing in
                handleVocabularyViewVisibilityChange(showing)
            }
    }
    
    func applyLanguageChangeHandlers<V: View>(_ view: V) -> some View {
        view
            .onChange(of: appState.profession) { _, _ in
                handleProfessionOrLanguageChange()
            }
            .onChange(of: appState.nativeLanguage) { _, _ in
                handleProfessionOrLanguageChange()
            }
            .onChange(of: appState.userLanguagePairs) { _, _ in
                handleProfessionOrLanguageChange()
            }
    }
    
    // Refresh recommendations when profession or target language changes
    func handleProfessionOrLanguageChange() {
        // Clear current inference to force refresh
        appState.inferredPlaceCategory = nil
        appState.lastInferenceTime = nil
        
        // Trigger new inference
        // Always allow inference - no time constraints
        if true {
            appState.inferUserInterest { _ in
                // Recommendations will refresh automatically via displaySceneOptions()
            }
        }
    }

    func applySceneFullScreenCovers<V: View>(_ view: V) -> some View {
        view
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage, isImageSelected: $isImageSelected) {
                    self.analyzeImage()
                }
            }
            .fullScreenCover(isPresented: $showingGallery) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, isImageSelected: $isImageSelected) {
                    self.analyzeImage()
                }
            }
            .fullScreenCover(isPresented: $showingStreakModal) {
                if let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                    StreakModal(appState: appState, pair: defaultPair) {
                        showingStreakModal = false
                    }
                }
            }
    }

    func applySceneAlertHandlers<V: View>(_ view: V) -> some View {
        view.alert(LocalizationManager.shared.string(.error), isPresented: $appState.showVocabularyError) {
            Button(LocalizationManager.shared.string(.ok), role: .cancel) {
                appState.vocabularyError = nil
            }
        } message: {
            Text(appState.vocabularyError ?? "An error occurred")
        }
    }

    func applySceneSheetHandlers<V: View>(_ view: V) -> some View {
        view
            .fullScreenCover(isPresented: $showingQuickLookModal) {
                QuickLookModal(
                    appState: appState,
                    selectedColor: appState.selectedColor,
                    clickedWords: clickedWords,
                    isLoading: isLoadingClickedWords
                )
            }
    }

    func handleLanguagePairsUpdate() {
        self.syncVocabularySelection()
    }

    func handleRecentPlacesTimerTick() {
        // No longer using cache - timer disabled
    }

    func handleSceneAppear() {
            self.appState.clearWordCaches()
        // Recommendations are now handled by API via YourRoutineSectionView
        self.loadCustomPlaces()
        
        // NOTE: Studied places will be fetched automatically when YourRoutineSectionView appears
            
            if appState.shouldCheckGuestLoginVisibility || !appState.hasCheckedGuestLoginVisibility {
                appState.checkButtonVisibility()
                appState.shouldCheckGuestLoginVisibility = false
            }
            
            if !appState.isAnalyzingImage && !appState.isGeneratingVocabulary {
                isImageSelected = false
                selectedImage = nil
            customSelectedPlace = nil
            // No auto-selection - user must manually select
        } else {
            // No auto-selection even during loading
        }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                viewOpacity = 1.0
                viewScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.checkAndAutoInferInterest()
                if self.appState.isInferringInterest {
                    self.startBigStackPulsation()
                }
            }

        // Removed auto-call to syncVocabularySelection - only call on user interaction
        }

    func handleHighlightedIndexChange(oldValue: Int?, newValue: Int?) {
            guard oldValue != newValue else { return }

            if newValue != nil && newValue != oldValue {
                if isImageSelected {
                    isImageSelected = false
                    selectedImage = nil
                }
            }
            
            if let idx = newValue {
                if idx == 0 {
                    self.updateCircleButtonVisibility(self.appState.inferredPlaceCategory != nil && !self.appState.isInferringInterest)
                } else {
                    self.updateCircleButtonVisibility(true)
                }
            }
        self.syncVocabularySelection()
        }

    func handleImageAnalysisStateChange(isAnalyzing: Bool) {
            if isAnalyzing {
            self.updateCircleButtonVisibility(false)
            } else {
            self.updateCircleButtonVisibility(
                (self.highlightedIndex != nil) ||
                self.isImageSelected ||
                (self.appState.inferredPlaceCategory != nil && self.highlightedIndex == nil)
            )
        }
    }

    func handleScrollToLocianChange(_ shouldScroll: Bool) {
        if shouldScroll {
            highlightedIndex = 0
            shouldScrollToLocian = false
        }
    }

    func handleInferredCategorySelection(_ newValue: String?) {
        // Removed auto-selection - user must manually select a pill or image
        // Only sync state, don't auto-generate vocabulary
    }

    func handleImageAnalysisResultChange() {
        self.syncVocabularySelection()
    }

    func handleImageSelectionChange(_ newValue: Bool) {
        if newValue {
            self.customSelectedPlace = nil
        }
            self.updateCircleButtonVisibility((self.highlightedIndex != nil) || newValue || self.appState.isAnalyzingImage)
        self.syncVocabularySelection()
        }

    func handleInferenceStateChange(isInferring: Bool) {
            if !isInferring && self.appState.inferredPlaceCategory != nil {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    self.updateCircleButtonVisibility(true)
                }
                withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                    self.bigStackScale = 1.0
                }
            } else if isInferring {
                self.updateCircleButtonVisibility(false)
                self.startBigStackPulsation()
            }
        }

    func handleInferredCategoryVisibilityChange(_ category: String?) {
            if category != nil && !self.appState.isInferringInterest && self.highlightedIndex == nil && !self.isImageSelected {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    self.updateCircleButtonVisibility(true)
                }
                withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                    self.bigStackScale = 1.0
                }
            }
        self.syncVocabularySelection()
        }

    func handleInferInterestFlagChange(_ shouldAttempt: Bool) {
            if shouldAttempt {
                self.appState.shouldAttemptInferInterest = false
                self.checkAndAutoInferInterest()
            }
        }

    func handleVocabularyViewVisibilityChange(_ showing: Bool) {
            if !showing {
                isImageSelected = false
                selectedImage = nil
            highlightedIndex = nil
        }
    }

    @ViewBuilder
    func headerSection(geometry: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // First stack: 30% width - Profile icon
            HStack {
                Button(action: {
                    showingProfileImagePicker = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedColor)
                            .frame(width: 85, height: 85)
                        
                        if let uiImage = profileImageBinding.wrappedValue {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 85, height: 85)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .circleButtonPressAnimation()
                .confirmationDialog(LocalizationManager.shared.string(.selectPhoto), isPresented: $showingProfileImagePicker, titleVisibility: .visible) {
                    Button(LocalizationManager.shared.string(.camera)) {
                        showingProfileImagePickerCamera = true
                    }
                    Button(LocalizationManager.shared.string(.photoLibrary)) {
                        showingProfileImagePickerGallery = true
                    }
                    Button(LocalizationManager.shared.string(.cancel), role: .cancel) { }
                }
                .fullScreenCover(isPresented: $showingProfileImagePickerCamera) {
                    ImagePicker(sourceType: .camera, selectedImage: profileImageBinding, isImageSelected: $isProfileImageSelected) {}
                }
                .fullScreenCover(isPresented: $showingProfileImagePickerGallery) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: profileImageBinding, isImageSelected: $isProfileImageSelected) {}
                }
            }
            .frame(width: geometry.size.width * 0.30)
            .frame(maxHeight: .infinity)
            
            // Second stack: 70% width - Three equal height VStacks
            HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        // First VStack: Welcome
                        VStack(alignment: .leading) {
                Text(languageManager.scene.welcome)
                                .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        
                        // Second VStack: Username
                        VStack(alignment: .leading) {
                Text(appState.username.isEmpty ? languageManager.scene.user : appState.username)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        // Third VStack: Streak data
                        VStack(alignment: .leading) {
                            if let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first {
                                let currentStreak = StreakCalculator.shared.calculateStreak(practiceDates: defaultPair.practice_dates)
                                let maxStreak = StreakCalculator.shared.calculateLongestStreak(practiceDates: defaultPair.practice_dates)
                                
                                HStack(spacing: 6) {
                                    if !defaultPair.target_language.isEmpty {
                                        Text(self.languageNativeScript(for: defaultPair.target_language))
                                            .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selectedColor)
                                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.orange)
                                        Text("\(languageManager.scene.max) \(maxStreak)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(selectedColor)
                                    }
                                    
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.orange)
                                        Text("\(currentStreak)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(selectedColor)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxHeight: .infinity)
            }
            .frame(width: geometry.size.width * 0.70)
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
    
    @State var showingImagePickerModal = false
    
    @ViewBuilder
    func cameraTileSection(geometry: GeometryProxy) -> some View {
            Button(action: {
                self.requestCameraAccess()
            }) {
            VStack(spacing: 12) {
                // Top VStack: Camera icon and "Use camera" text
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(languageManager.customPractice.useCamera)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                
                // Bottom VStack: Instructional text
                VStack(alignment: .center, spacing: 0) {
                    Text("Learn what to say — before you need to say it.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.10))
                    .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 10)
            )
            .overlay(
                // Left border only
                HStack {
                    Rectangle()
                        .fill(selectedColor)
                        .frame(width: 15)
                    Spacer()
                }
            )
            }
        .buttonStyle(.plain)
            .buttonPressAnimation()
            .allowsHitTesting(!appState.isAnalyzingImage)
            .opacity(appState.isAnalyzingImage ? 0.5 : 1.0)
        .padding(.horizontal, 2)
    }
    
    // Build display options for scrolling; include infer interest response at top
    func displaySceneOptions() -> [String] {
        var options: [String] = []
        
        // Show "By Locian..." with loading dots during infer interest loading
        if appState.isInferringInterest {
            options.append("BY_LOCIAN_LOADING") // Special marker for loading state
        }
        
        // Add infer interest response if available (at the top)
        if let inferredCategory = appState.inferredPlaceCategory, !inferredCategory.isEmpty {
            options.append(self.cleanInferredCategory(inferredCategory))
        }
        
        // Add image analysis result if available (after infer interest, before regular options)
        if let imageAnalysisResult = appState.imageAnalysisResult, !imageAnalysisResult.isEmpty {
            options.append(imageAnalysisResult)
        }
        
        options.append(contentsOf: sceneOptions)
        return options
    }
    
    @ViewBuilder
    func scenesSection(geometry: GeometryProxy) -> some View {
        let options = displaySceneOptions()
        VStack(alignment: .leading, spacing: 20) {
                // Custom situations section - FIRST SECTION
                VStack(alignment: .leading, spacing: 12) {
                    // Heading
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 12) {
                            Text(languageManager.scene.customSituations)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("✦")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        // Description removed as per requirements
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .padding(.leading, 0)
                    .padding(.trailing, 0)
                    
                    // Input field and "Learn" button
                    HStack(spacing: 12) {
                        TextField("Enter your moment", text: $customPlaceInputText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button(action: {
                            let trimmed = customPlaceInputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && trimmed.count <= 30 {
                                // Add to custom places if not already there
                                if !customPlaces.contains(trimmed) {
                                    customPlaces.append(trimmed)
                                    saveCustomPlaces()
                                }
                                // Trigger vocabulary generation with this place name
                                generateVocabularyWithPlaceName(placeName: trimmed)
                                // Keep text in input field
                                customPlaceInputText = trimmed
                            }
                        }) {
                            Text("Learn")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(selectedColor)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(customPlaceInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.bottom, 12)
                    
                    // Custom places horizontal scrolling section
                    CustomPlacesSectionView(
                        appState: appState,
                        customPlaces: $customPlaces,
                        customSelectedPlace: $customSelectedPlace,
                        selectedColor: selectedColor,
                        onPlaceTap: { place in
                            handleRecommendedPlaceTap(place, options: options)
                        },
                        onLearnTap: { placeName in
                            generateVocabularyWithPlaceName(placeName: placeName)
                        },
                        onSaveCustomPlaces: {
                            saveCustomPlaces()
                        }
                    )
                }
                .padding(.bottom, 20)
                
                // Spacing before routine section
                Spacer()
                    .frame(height: 20)
                
                // Your routine section
                YourRoutineSectionView(
                    appState: appState,
                    selectedColor: selectedColor,
                    onPlaceTap: { place in
                        handleRecommendedPlaceTap(place, options: options)
                    },
                    isPlaceSelected: { place in
                        isPlaceSelected(place)
                    },
                    cleanInferredCategory: cleanInferredCategory
                )
        }
        .padding(.vertical, 18)
        .padding(.leading, 0)
        .padding(.trailing, 0)
        .onAppear {
            // No auto-selection - user must manually select
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    
    @ViewBuilder
    func horizontalPlaceSection(title: String, iconName: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(iconName)
                        .font(.system(size: 18, weight: .semibold))
                }
                // Description removed as per requirements
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .padding(.leading, 0)
            .padding(.trailing, 0)
            
            content()
        }
        .padding(.leading, 0)
        .padding(.trailing, 0)
    }
    
    @ViewBuilder
    func placeSection(title: String, iconName: String, section: PlacesSection, isExpanded: Bool, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
        Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if openPlacesSection == section {
                        openPlacesSection = nil
                    } else {
                        openPlacesSection = section
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isExpanded ? selectedColor : .white.opacity(0.8))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isExpanded ? selectedColor : .white.opacity(0.8))
                    
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isExpanded ? selectedColor : .white.opacity(0.92))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
            .buttonPressAnimation()
            
            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 5)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
    }
    
    @ViewBuilder
    func circleButtonContentView() -> some View {
        if appState.isAnalyzingImage {
            analyzingCircleButton()
        } else if appState.isGeneratingVocabulary {
            generatingCircleButton()
        } else {
            if let selectedScene = getSelectedSceneName() {
                selectedSceneCircleButton(selectedScene: selectedScene)
            } else {
                defaultArrowCircleButton()
            }
        }
    }

    @ViewBuilder
    func analyzingCircleButton() -> some View {
            Circle()
                .fill(selectedColor)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "photo.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .scaleEffect(0.7 + (loadingIconOpacity * 0.3))
                )
                .onAppear {
                    startImageAnalysisAnimation()
                }
                .onDisappear {
                    loadingIconOpacity = 0
                }
    }

    @ViewBuilder
    func generatingCircleButton() -> some View {
            Circle()
                .fill(selectedColor)
                .frame(width: 60, height: 60)
            .overlay(generatingIconStack())
            .onAppear {
                startLoadingIconCycle()
            }
            .onDisappear {
                loadingIconCycleTimer?.invalidate()
                loadingIconCycleTimer = nil
                loadingIconIndex = 0
                loadingIconOpacity = 0
            }
    }

    @ViewBuilder
    func generatingIconStack() -> some View {
                    Group {
                        switch loadingIconIndex {
                        case 0:
                            Image(systemName: "location.fill")
                        case 1:
                            Image(systemName: "clock.fill")
                        case 2:
                            Image(systemName: "cloud.fill")
                        case 3:
                            Image(systemName: "thermometer")
                        default:
                            Image(systemName: "location.fill")
                        }
                    }
        .font(.system(size: 20, weight: .bold))
        .foregroundColor(.black)
                    .opacity(loadingIconOpacity)
    }

    @ViewBuilder
    func selectedSceneCircleButton(selectedScene: String) -> some View {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        ZStack {
                            if showArrowInCircle {
                                Image(systemName: "arrow.right")
                            .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                            .transition(circleIconTransition(scale: 1.3))
                                    .id("arrow")
                            } else {
                                Image(systemName: getIconForScene(selectedScene, index: highlightedIndex))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            .transition(circleIconTransition(scale: 1.2))
                                    .id("icon_\(selectedScene)")
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showArrowInCircle)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: highlightedIndex)
                    )
                    .onAppear {
                showArrowInCircle = false
                        startIconArrowAlternation()
                    }
                    .onChange(of: highlightedIndex) { _, _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            self.showArrowInCircle = false
                        }
                        self.startIconArrowAlternation()
                    }
    }

    func circleIconTransition(scale: CGFloat) -> AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: scale)),
            removal: .opacity.combined(with: .scale(scale: 0.7))
        )
    }

    @ViewBuilder
    func defaultArrowCircleButton() -> some View {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "arrow.right")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                    )
    }
    
    func startImageAnalysisAnimation() {
        // Initialize opacity for pulsating animation
        loadingIconOpacity = 0.6
        
        // Pulsating animation for image analysis
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            loadingIconOpacity = 1.0
        }
    }
    
    func startLoadingIconCycle() {
        // Stop any existing timer
        loadingIconCycleTimer?.invalidate()
        
        withAnimation(.easeInOut(duration: 0.4)) {
            loadingIconOpacity = 1.0
        }
        
        loadingIconCycleTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { timer in
            if !self.appState.isGeneratingVocabulary {
                timer.invalidate()
                self.loadingIconCycleTimer = nil
                self.loadingIconIndex = 0
                self.loadingIconOpacity = 0
                return
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                self.loadingIconOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.loadingIconIndex = (self.loadingIconIndex + 1) % 4
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.loadingIconOpacity = 1.0
                }
            }
        }
    }
    
    func startBigStackPulsation() {
        // Stop any existing pulsation
        bigStackScale = 1.0
        
        // Start pulsating animation
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            bigStackScale = 1.03 // Subtle pulsation
        }
    }
    
    func startIconArrowAlternation() {
        // Stop any existing timer
        iconArrowTimer?.invalidate()
        
        // Start with icon
        showArrowInCircle = false
        
        // Alternate every 1.5 seconds consistently
        iconArrowTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            guard self.getSelectedSceneName() != nil else {
                timer.invalidate()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    self.showArrowInCircle = false
                }
                return
            }
            
            // Toggle between icon and arrow with smooth animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                self.showArrowInCircle.toggle()
            }
        }
    }
    
    func handleCircleButtonTap() {
        // Check if language pairs are set before generating vocabulary
        let hasDefaultPair = self.appState.userLanguagePairs.contains { $0.is_default }
        let hasAnyPair = !self.appState.userLanguagePairs.isEmpty
        
        if !hasDefaultPair && !hasAnyPair {
            self.appState.showLanguageModal(mode: .onboarding)
            return
        }
        
        if let defaultPair = self.appState.userLanguagePairs.first(where: { $0.is_default }) {
            if defaultPair.native_language.isEmpty || defaultPair.target_language.isEmpty {
                self.appState.showLanguageModal(mode: .onboarding)
                return
            }
        } else if hasAnyPair {
            let hasCompletePair = self.appState.userLanguagePairs.contains { pair in
                !pair.native_language.isEmpty && !pair.target_language.isEmpty
            }
            if !hasCompletePair {
                self.appState.showLanguageModal(mode: .onboarding)
                return
            }
        }
        
        // Language pairs are set - proceed with vocabulary generation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            circleButtonScale = 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                self.circleButtonScale = 1.0
            }
        }
        generateVocabulary()
    }
    
    
    func analyzeImage() {
        guard let image = selectedImage else { return }
        
        // Add image to previous images array (at the beginning for priority)
        // Only if it's a new image (not already in the list)
        if !previousImages.contains(where: { img in
            if let imgData = img.jpegData(compressionQuality: 0.7),
               let newImgData = image.jpegData(compressionQuality: 0.7) {
                return imgData == newImgData
            }
            return false
        }) {
            previousImages.insert(image, at: 0) // Insert at beginning
            // Keep only first 7
            if previousImages.count > 7 {
                previousImages = Array(previousImages.prefix(7))
            }
        savePreviousImages()
        }
        
        // Call the image analysis API
        SceneActions.analyzeImage(image, appState: appState) { success in
                DispatchQueue.main.async {
                if success, let placeName = self.appState.imageAnalysisResult, !placeName.isEmpty {
                    self.generateVocabularyWithPlaceName(placeName: placeName)
                } else if !success {
                    self.isImageSelected = false
                    self.selectedImage = nil
                }
            }
        }
    }
    
    @ViewBuilder
    func previousImagesSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if !previousImages.isEmpty {
                    ForEach(Array(previousImages.enumerated()), id: \.offset) { index, image in
                        Button(action: {
                            // Set the selected image and analyze it
                            selectedImage = image
                            isImageSelected = true
                            analyzeImage()
                        }) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                            .padding(.leading, index == 0 ? 15 : 0)
                    }
                }
                
                // Gallery button at the end
                Button(action: {
                    self.requestPhotoLibraryAccess()
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Gallery")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 100, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.trailing, 0)
        }
        .frame(height: 100)
    }
    
    func generateVocabularyWithPlaceName(placeName: String) {
        
        let hasDefaultPair = self.appState.userLanguagePairs.contains { $0.is_default }
        let hasAnyPair = !self.appState.userLanguagePairs.isEmpty
        
        if !hasDefaultPair && !hasAnyPair {
            self.appState.showLanguageModal(mode: .onboarding)
            return
        }
        
        if let defaultPair = self.appState.userLanguagePairs.first(where: { $0.is_default }) {
            if defaultPair.native_language.isEmpty || defaultPair.target_language.isEmpty {
                self.appState.showLanguageModal(mode: .onboarding)
                return
            }
        } else if hasAnyPair {
            let hasCompletePair = self.appState.userLanguagePairs.contains { pair in
                !pair.native_language.isEmpty && !pair.target_language.isEmpty
            }
            if !hasCompletePair {
                self.appState.showLanguageModal(mode: .onboarding)
                return
            }
        }
        
        // Get top 5 prioritized places with times and dates
        let previousPlaces = getTop5PrioritizedPlaces(excluding: placeName)
        for (_, _) in previousPlaces.enumerated() {
        }
        
        // Request location permission (if not already granted)
        LocationManager.shared.requestPermission()
        
        // NOTE: Place data will be saved AFTER API success (inside generateVocabulary)
        appState.generateVocabulary(placeName: placeName, isFromImageAnalysis: true, previousPlaces: previousPlaces.isEmpty ? nil : previousPlaces) { success in
            DispatchQueue.main.async {
                if success {
                    self.appState.vocabularyIsImageSelected = true
                    self.appState.vocabularySelectedPlace = placeName
                    // Sync customSelectedPlace with vocabulary generation place
                    self.customSelectedPlace = placeName
                    self.appState.shouldShowVocabularyView = true
                    // Note: Place already saved to recent history above (before API call)
                }
            }
        }
    }
    
    // Helper function to clean inferred category text (remove underscores, dots, etc.)
    func cleanInferredCategory(_ category: String) -> String {
        var cleaned = category
            .replacingOccurrences(of: "_", with: " ")  // Replace underscores with spaces
            .replacingOccurrences(of: ".", with: "")     // Remove dots
            .trimmingCharacters(in: .whitespaces)        // Trim whitespace
        
        // Capitalize first letter of each word
        let words = cleaned.components(separatedBy: .whitespaces)
        cleaned = words.map { word in
            guard !word.isEmpty else { return word }
            return word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
        
        return cleaned
    }
    
    // Get top 5 prioritized places with times and dates
    func getTop5PrioritizedPlaces(excluding currentPlace: String) -> [PreviousPlace] {
        // Recommendations are now handled by YourRoutineSectionView using API data
        // This function returns empty array as previous places are no longer needed
        // The API handles all recommendation logic via buildRecommendedHistoryFromAPI
        return []
    }
    
    func inferredSelectionName() -> String? {
        guard let inferredCategory = appState.inferredPlaceCategory,
              !inferredCategory.isEmpty else { return nil }
        return cleanInferredCategory(inferredCategory)
    }
    
    func selectPlace(named placeName: String, markManual: Bool = false) {
        let options = displaySceneOptions()
        
        if let exactIndex = options.firstIndex(of: placeName) {
            customSelectedPlace = nil
            handleSelection(at: exactIndex, options: options, markManual: markManual)
            return
        }
        
        let normalized = cleanInferredCategory(placeName)
        if let normalizedIndex = options.firstIndex(of: normalized) {
            customSelectedPlace = nil
            handleSelection(at: normalizedIndex, options: options, markManual: markManual)
        }
    }
    
    func placePill(for text: String, isSelected: Bool, onDelete: (() -> Void)? = nil) -> some View {
        HStack(spacing: 8) {
            // Icon without circle - just the icon
            Image(systemName: getIconForScene(text))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? Color.black : Color.white)
            
            Text(text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(isSelected ? Color.black : Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .transaction { $0.animation = nil }
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(isSelected ? selectedColor : Color.white.opacity(0.10))
        )
        .transaction { $0.animation = nil }
    }
    
    func nonClickablePill(text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    }
    
    // Recommended place pill with icon on top, text below
    func recommendedPlacePill(for text: String, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            // Icon on top, centered
            Image(systemName: getIconForScene(text))
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
            
            // Text below icon
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 92, height: 92)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(white: 0.05))
        )
        .transaction { $0.animation = nil }
    }
    
    // Custom place text-only pill (no icon, single line)
    func customPlaceTextPill(for text: String, isSelected: Bool) -> some View {
        HStack(spacing: 8) {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            
            // Delete button inside the pill
            Button(action: {
                deleteCustomPlace(text)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .buttonStyle(PlainButtonStyle())
        }
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .transaction { $0.animation = nil }
    }
    
    @ViewBuilder
    func locianChoicePill(isSelected: Bool) -> some View {
        if appState.isInferringInterest {
            byLocianLoadingView()
        } else {
            // Get the highest priority recommendation
            let locianChoiceLabel = languageManager.scene.lociansChoice
            
            // Use inferred category or fallback to locian choice label
            let displayName: String = {
                if let inferredName = inferredSelectionName() {
                    return inferredName
                } else {
                    return locianChoiceLabel
                }
            }()
            
            // Get icon for the place (use sparkles if it's still "By Locian" label)
            let iconName: String = {
                if displayName == locianChoiceLabel {
                    return "sparkles"
                } else {
                    return getIconForScene(displayName)
                }
            }()
            
            VStack(spacing: 8) {
                // Icon on top, centered
                Image(systemName: iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                
                // Text below icon
                Text(displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 92, height: 92)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color(white: 0.05))
            )
            .transaction { $0.animation = nil }
        }
    }
    
    func reloadRecentPlaces() {
        // No longer using cache - this function is kept for compatibility but does nothing
        recentPlaces = []
    }
    
    func addPlaceToRecentHistory(_ place: String) {
        // No longer saving to cache - data comes from API
        // Post notification to refresh studied places from API
        NotificationCenter.default.post(name: NSNotification.Name("refreshStudiedPlaces"), object: nil)
    }
    
    func handleSelection(at idx: Int, options: [String], markManual: Bool) {
        guard idx >= 0 && idx < options.count else { return }
        let placeName = options[idx]
        if placeName == "BY_LOCIAN_LOADING" { return }
        
        highlightedIndex = idx
        isImageSelected = false
        customSelectedPlace = nil
        
        if markManual {
            hasUserSelectedPlaceManually = true
        }
        
        if idx == 0 {
            updateCircleButtonVisibility(appState.inferredPlaceCategory != nil && !appState.isInferringInterest)
        } else {
            updateCircleButtonVisibility(true)
        }
        
        syncVocabularySelection()
        
        // Removed auto-generation from pill selection - only generate when circle button is tapped
    }
    
    func handleRecommendedPlaceTap(_ place: String, options: [String]) {
        
        
        let trimmedPlace = place.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let idx = options.firstIndex(where: { $0.caseInsensitiveCompare(trimmedPlace) == .orderedSame }) {
            // Recommended place in options - select and generate
            handleSelection(at: idx, options: options, markManual: true)
            // Start vocabulary generation immediately for recommended places (no conversation quiz)
            generateVocabularyWithPlaceName(placeName: trimmedPlace)
        } else {
            // Custom place tapped - start vocabulary generation immediately
            highlightedIndex = nil
            isImageSelected = false
            customSelectedPlace = trimmedPlace
            hasUserSelectedPlaceManually = true
            updateCircleButtonVisibility(true)
            syncVocabularySelection()
            
            // Generate vocabulary with the custom place name (starts generation immediately, no conversation quiz)
            generateVocabularyWithPlaceName(placeName: trimmedPlace)
        }
    }
    
    func handleLocianChoiceTap(options: [String]) {
        
        // Try to select based on inferred name first
        if let inferredName = inferredSelectionName(),
           let idx = options.firstIndex(where: { $0.caseInsensitiveCompare(inferredName) == .orderedSame }) {
            handleSelection(at: idx, options: options, markManual: true)
        } else {
            checkAndAutoInferInterest()
        }
    }
    
    // Helper function to get display text for scene option
    func getSceneOptionDisplayText(idx: Int) -> String {
        return sceneOptions[idx]
    }
    
    // Helper view builder for scene option text
    @ViewBuilder
    func sceneOptionView(idx: Int, options: [String]) -> some View {
        let displayText = options[idx]
        
        if displayText == "BY_LOCIAN_LOADING" {
            byLocianLoadingView()
            } else {
            let isSelected = isPlaceSelected(displayText)
            
            Button(action: {
                handleSelection(at: idx, options: options, markManual: true)
            }) {
                placePill(for: displayText, isSelected: isSelected)
            }
            .buttonStyle(PlainButtonStyle())
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: highlightedIndex)
        }
    }
    
    // All Places pill with icon on top, text below
    @ViewBuilder
    func allPlacePillView(idx: Int, options: [String]) -> some View {
        let displayText = options[idx]
        
        if displayText == "BY_LOCIAN_LOADING" {
            byLocianLoadingView()
        } else {
            let isSelected = isPlaceSelected(displayText)
            
            Button(action: {
                handleSelection(at: idx, options: options, markManual: true)
            }) {
                VStack(spacing: 12) {
                    // Icon on top, centered
                    Image(systemName: getIconForScene(displayText, index: idx))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? Color.black : Color.white)
                    
                    // Text below icon
                    Text(displayText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? Color.black : Color.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                }
                .frame(width: 100, height: 100) // Bigger height
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(isSelected ? selectedColor : Color.white.opacity(0.18))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: highlightedIndex)
        }
    }
    
    // Loading pill for "By Locian..." with animated dots
    @ViewBuilder
    func byLocianLoadingView() -> some View {
        HStack(spacing: 8) {
            Text("By Locian")
                .font(.system(size: 16, weight: .semibold))
            
            HStack(spacing: 4) {
                ForEach(0..<3) { dotIndex in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                        .opacity(dotOpacity(for: dotIndex))
                        .scaleEffect(dotScale(for: dotIndex))
                }
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.black.opacity(0.85)))
        .clipShape(Capsule())
        .onAppear {
            startDotAnimation()
        }
        .onDisappear {
            stopDotAnimation()
        }
    }
    
    // Calculate opacity for each dot based on animation phase
    func dotOpacity(for index: Int) -> Double {
        let phase = (dotAnimationPhase + index) % 6
        if phase < 2 {
            return 0.3
        } else if phase < 4 {
            return 0.6
            } else {
            return 1.0
        }
    }
    
    // Calculate scale for each dot based on animation phase
    func dotScale(for index: Int) -> CGFloat {
        let phase = (dotAnimationPhase + index) % 6
        if phase < 2 {
            return 0.8
        } else if phase < 4 {
            return 0.9
        } else {
            return 1.0
        }
    }
    
    func startDotAnimation() {
        stopDotAnimation() // Stop any existing timer
        dotAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if !self.appState.isInferringInterest {
                timer.invalidate()
                self.dotAnimationTimer = nil
                return
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                self.dotAnimationPhase = (self.dotAnimationPhase + 1) % 6
            }
        }
    }
    
    func stopDotAnimation() {
        dotAnimationTimer?.invalidate()
        dotAnimationTimer = nil
        dotAnimationPhase = 0
    }
    
    func getSelectedPlaceText() -> String {
        if appState.isAnalyzingImage {
            return LocalizationManager.shared.string(.analyzingImage)
        } else if isImageSelected {
            // After analysis is complete, show "Image analysis completed" instead of the analysis text
            if appState.imageAnalysisResult != nil {
                return LocalizationManager.shared.string(.imageAnalysisCompleted)
            } else {
                return LocalizationManager.shared.string(.imageSelected)
            }
        } else if let highlightedIdx = highlightedIndex {
            let options = displaySceneOptions()
            if highlightedIdx < options.count {
                let selected = options[highlightedIdx]
                if selected == "BY_LOCIAN_LOADING" {
                    return languageManager.scene.locianChoosing
                } else {
                    return selected
                }
            } else {
                return LocalizationManager.shared.string(.placeNotSelected)
            }
        } else if appState.isInferringInterest {
            // No selection yet, but inference is running
            return languageManager.scene.locianChoosing
        } else if let inferredCategory = appState.inferredPlaceCategory {
            // Show "Locian choose [place_name]" when inference is complete and nothing selected from scrolling (big stack default)
            let cleanedCategory = cleanInferredCategory(inferredCategory)
            return "\(languageManager.scene.continueWith) \(cleanedCategory)"
        } else {
            return LocalizationManager.shared.string(.placeNotSelected)
        }
    }
    
    // Check and auto-infer interest for big stack (ONLY ONCE on app launch)
    func checkAndAutoInferInterest() {
        guard !isImageSelected else {
            return
        }
        
        guard appState.hasValidLanguagePair() else {
            updateCircleButtonVisibility(false)
            return
        }
        
        if appState.isInferringInterest {
            startBigStackPulsation()
            return
        }
        
        // Always allow inference - no time constraints
        startBigStackPulsation()
        
        appState.inferUserInterest { _ in }
    }
    
    func updateCircleButtonVisibility(_ isVisible: Bool) {
        guard appState.hasValidLanguagePair() else { return }
        // No-op: slider always visible; method retained for compatibility
    }
    
    func locianChoiceTile(height: CGFloat) -> some View {
        let hasPair = appState.hasValidLanguagePair()
        let isLoading = appState.isInferringInterest
        let hasResult = appState.inferredPlaceCategory != nil
        
        return Button(action: {
            if !hasPair {
                appState.showLanguageModal(mode: .onboarding)
            } else if !appState.isInferringInterest, hasResult {
                shouldScrollToLocian = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.highlightedIndex = 0
                }
            }
        }) {
            RoundedRectangle(cornerRadius: 24)
                .fill(selectedColor)
                .overlay(
                    VStack(alignment: .leading, spacing: 6) {
                        if !hasPair {
                            Text(languageManager.scene.lociansChoice)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        } else if isLoading {
                            Text(languageManager.scene.lociansChoice)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Text(languageManager.scene.locianChoosing)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.black.opacity(0.75))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        } else if let inferredCategory = appState.inferredPlaceCategory {
                            Text(languageManager.scene.lociansChoice)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.black.opacity(0.75))
                            Text(cleanInferredCategory(inferredCategory))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        } else {
                            Text(languageManager.scene.lociansChoice)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Text(languageManager.scene.locianChoosing)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.black.opacity(0.75))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 16)
                )
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }
        .buttonStyle(PlainButtonStyle())
        .buttonPressAnimation()
        .allowsHitTesting(hasPair && (!isLoading || hasResult))
    }

    func defaultPairTile(height: CGFloat) -> some View {
        let hasPair = appState.hasValidLanguagePair()
        let pairDisplay = defaultPairDisplay()
        
        return Button(action: {
            if hasPair {
                appState.shouldFocusLanguagePairs = true
                appState.shouldShowSettingsView = true
            } else {
                appState.showLanguageModal(mode: .onboarding)
            }
        }) {
            RoundedRectangle(cornerRadius: 24)
                .fill(selectedColor)
                .overlay(
                    VStack(alignment: .leading, spacing: 8) {
                        Text(languageManager.settings.languagePairs)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.black.opacity(0.75))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        if let display = pairDisplay {
                            Text("\(display.native) → \(display.target)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        } else {
                            Text(languageManager.scene.chooseLanguages)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                )
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }
        .buttonStyle(PlainButtonStyle())
        .buttonPressAnimation()
    }
    
    func cameraTile(height: CGFloat) -> some View {
        return Button(action: {
            requestCameraAccess()
        }) {
            RoundedRectangle(cornerRadius: 24)
                .fill(selectedColor)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                )
                .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        }
        .frame(minWidth: 110)
        .buttonStyle(PlainButtonStyle())
        .buttonPressAnimation()
        .allowsHitTesting(!appState.isAnalyzingImage)
        .opacity(appState.isAnalyzingImage ? 0.5 : 1.0)
    }
    
    func galleryTile(height: CGFloat) -> some View {
        return Button(action: {
            requestPhotoLibraryAccess()
        }) {
            RoundedRectangle(cornerRadius: 24)
                .fill(selectedColor)
                .overlay(
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                )
                .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        }
        .frame(minWidth: 110)
        .buttonStyle(PlainButtonStyle())
        .buttonPressAnimation()
        .allowsHitTesting(!appState.isAnalyzingImage)
        .opacity(appState.isAnalyzingImage ? 0.5 : 1.0)
    }
    
    func defaultPairDisplay() -> (native: String, target: String)? {
        if let pair = appState.userLanguagePairs.first(where: { $0.is_default && !$0.native_language.isEmpty && !$0.target_language.isEmpty }) {
            return (languageNativeScript(for: pair.native_language), languageNativeScript(for: pair.target_language))
        }
        if let pair = appState.userLanguagePairs.first(where: { !$0.native_language.isEmpty && !$0.target_language.isEmpty }) {
            return (languageNativeScript(for: pair.native_language), languageNativeScript(for: pair.target_language))
        }
        return nil
    }
    
    func languageNativeScript(for codeOrName: String) -> String {
        let mapping: [String: String] = [
            // Arabic
            "ar": "العربية",
            "arabic": "العربية",
            // Chinese
            "zh": "中文",
            "chinese": "中文",
            // Dutch
            "nl": "Nederlands",
            "dutch": "Nederlands",
            // English
            "en": "English",
            "english": "English",
            // French
            "fr": "Français",
            "french": "Français",
            // German
            "de": "Deutsch",
            "german": "Deutsch",
            // Hindi
            "hi": "हिन्दी",
            "hindi": "हिन्दी",
            // Italian
            "it": "Italiano",
            "italian": "Italiano",
            // Japanese
            "ja": "日本語",
            "japanese": "日本語",
            // Korean
            "ko": "한국어",
            "korean": "한국어",
            // Malayalam
            "ml": "മലയാളം",
            "malayalam": "മലയാളം",
            // Portuguese
            "pt": "Português",
            "portuguese": "Português",
            // Russian
            "ru": "Русский",
            "russian": "Русский",
            // Spanish
            "es": "Español",
            "spanish": "Español",
            // Swedish
            "sv": "Svenska",
            "swedish": "Svenska",
            // Tamil
            "ta": "தமிழ்",
            "tamil": "தமிழ்",
            // Telugu
            "te": "తెలుగు",
            "telugu": "తెలుగు",
            // Turkish
            "tr": "Türkçe",
            "turkish": "Türkçe"
        ]
        
        let key = codeOrName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return mapping[key] ?? codeOrName
    }

    func resolvePlaceNameForGeneration(shouldLog: Bool = true) -> (name: String?, fromImageAnalysis: Bool) {
        // Check for custom place first
        if let customPlace = customSelectedPlace {
            return (customPlace, false)
        }
        
        var resolvedPlaceName: String?
        var fromImageAnalysis = false
        
        if let highlightedIdx = highlightedIndex {
            let options = displaySceneOptions()
            guard highlightedIdx < options.count else {
                return (nil, false)
            }
            
            let selectedOption = options[highlightedIdx]
            if selectedOption == "BY_LOCIAN_LOADING" {
                return (nil, false)
            }
            
            if highlightedIdx == 0 {
                guard let inferredCategory = appState.inferredPlaceCategory,
                      !inferredCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return (nil, false)
                }
                resolvedPlaceName = inferredCategory
            } else {
                if highlightedIdx == 1,
                   let imageResult = appState.imageAnalysisResult,
                   !imageResult.isEmpty,
                   selectedOption == imageResult {
                    resolvedPlaceName = imageResult
                    fromImageAnalysis = true
                } else if highlightedIdx == 1 {
                    if let imageResult = appState.imageAnalysisResult,
                       !imageResult.isEmpty {
                        resolvedPlaceName = imageResult
                        fromImageAnalysis = true
                    } else {
                        resolvedPlaceName = selectedOption
                    }
                } else {
                    let imageAnalysisOffset = (appState.imageAnalysisResult != nil && !(appState.imageAnalysisResult ?? "").isEmpty) ? 1 : 0
                    let sceneIndex = highlightedIdx - 1 - imageAnalysisOffset
                    if sceneIndex >= 0 && sceneIndex < sceneOptions.count {
                        resolvedPlaceName = sceneOptions[sceneIndex]
                    } else {
                        resolvedPlaceName = selectedOption
                    }
                }
            }
        } else if isImageSelected,
                  let imageResult = appState.imageAnalysisResult,
                  !imageResult.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            resolvedPlaceName = imageResult
            fromImageAnalysis = true
        } else if let inferredCategory = appState.inferredPlaceCategory,
                  !inferredCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            resolvedPlaceName = inferredCategory
        }
        
        return (resolvedPlaceName, fromImageAnalysis)
    }

    func syncVocabularySelection() {
        // Handle custom place selection
        if let customPlace = customSelectedPlace {
            appState.vocabularySelectedPlace = customPlace
            appState.vocabularyIsImageSelected = false
            let pair = defaultLanguagePair()
            appState.vocabularyUserLanguage = pair.native?.trimmingCharacters(in: .whitespacesAndNewlines)
            appState.vocabularyTargetLanguage = pair.target?.trimmingCharacters(in: .whitespacesAndNewlines)
            appState.vocabularyRequestTime = appState.humanReadableTimeString()
            return
        }
        
        // Original logic for regular places
        let resolution = resolvePlaceNameForGeneration(shouldLog: false)

        let hasPlace = resolution.name != nil
        if let placeName = resolution.name {
            if appState.vocabularySelectedPlace != placeName {
                appState.vocabularySelectedPlace = placeName
            }
            appState.vocabularyIsImageSelected = resolution.fromImageAnalysis
        } else {
            if !appState.vocabularySelectedPlace.isEmpty {
                appState.vocabularySelectedPlace = ""
            }
            appState.vocabularyIsImageSelected = false
        }
        
        let pair = defaultLanguagePair()
        let userLang = pair.native?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let targetLang = pair.target?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !userLang.isEmpty && !targetLang.isEmpty {
            appState.vocabularyUserLanguage = userLang
            appState.vocabularyTargetLanguage = targetLang
        } else {
            appState.vocabularyUserLanguage = nil
            appState.vocabularyTargetLanguage = nil
        }
        
        if hasPlace && !userLang.isEmpty && !targetLang.isEmpty {
            let timestamp = appState.humanReadableTimeString()
            appState.vocabularyRequestTime = timestamp
        } else {
            appState.vocabularyRequestTime = nil
        }
    }

    func generateVocabulary() {
        // Check if language pairs are set before generating vocabulary
        let hasDefaultPair = self.appState.userLanguagePairs.contains { $0.is_default }
        let hasAnyPair = !self.appState.userLanguagePairs.isEmpty
        
        if !hasDefaultPair && !hasAnyPair {
            self.appState.showLanguageModal(mode: .onboarding)
            return
        }
        
        if let defaultPair = self.appState.userLanguagePairs.first(where: { $0.is_default }) {
            if defaultPair.native_language.isEmpty || defaultPair.target_language.isEmpty {
                self.appState.showLanguageModal(mode: .onboarding)
                return
            }
        } else if hasAnyPair {
            let hasCompletePair = self.appState.userLanguagePairs.contains { pair in
                !pair.native_language.isEmpty && !pair.target_language.isEmpty
            }
            if !hasCompletePair {
                self.appState.showLanguageModal(mode: .onboarding)
                return
            }
        }
        
        let resolution = resolvePlaceNameForGeneration()
        guard let placeName = resolution.name else {
            return
        }
        let fromImageAnalysis = resolution.fromImageAnalysis
        
        // Get top 5 prioritized places with times and dates
        let previousPlaces = getTop5PrioritizedPlaces(excluding: placeName)
        
        appState.generateVocabulary(placeName: placeName, isFromImageAnalysis: fromImageAnalysis, previousPlaces: previousPlaces.isEmpty ? nil : previousPlaces) { success in
                    if success {
                self.appState.vocabularyIsImageSelected = fromImageAnalysis
                self.appState.vocabularySelectedPlace = placeName
                let pair = self.defaultLanguagePair()
                self.appState.vocabularyUserLanguage = pair.native?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.appState.vocabularyTargetLanguage = pair.target?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.appState.vocabularyRequestTime = self.appState.humanReadableTimeString()
                self.appState.shouldShowVocabularyView = true
                self.addPlaceToRecentHistory(placeName)
            }
        }
    }
    
    func defaultLanguagePair() -> (native: String?, target: String?) {
        if let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) {
            return (defaultPair.native_language, defaultPair.target_language)
        }
        if let firstPair = appState.userLanguagePairs.first {
            return (firstPair.native_language, firstPair.target_language)
        }
        return (nil, nil)
    }
    
    func deleteCustomPlace(_ place: String) {
        if let index = customPlaces.firstIndex(of: place) {
            customPlaces.remove(at: index)
            saveCustomPlaces()
            
            // If the deleted place was selected, clear selection
            if customSelectedPlace == place {
                customSelectedPlace = nil
            }
        }
    }
    
    // MARK: - Custom Places Persistence
    
    func loadCustomPlaces() {
        if let data = UserDefaults.standard.data(forKey: customPlacesStorageKey) {
            do {
                customPlaces = try JSONDecoder().decode([String].self, from: data)
            } catch {
                // Fallback to array if decoding fails
                if let array = UserDefaults.standard.array(forKey: customPlacesStorageKey) as? [String] {
                    customPlaces = array
                } else {
                    customPlaces = []
                }
            }
        } else {
            customPlaces = []
        }
    }
    
    func saveCustomPlaces() {
        do {
            let data = try JSONEncoder().encode(customPlaces)
            UserDefaults.standard.set(data, forKey: customPlacesStorageKey)
        } catch {
            // Fallback to array storage if encoding fails
            UserDefaults.standard.set(customPlaces, forKey: customPlacesStorageKey)
        }
    }
    
    // MARK: - Previous Images Persistence
    
    func loadPreviousImages() {
        // Load saved images first (app-analyzed images get priority)
        // Use file storage instead of UserDefaults for large image data
        var loadedImages = FileStorageManager.shared.loadImageArray(forKey: previousImagesStorageKey)
        
        // Migrate from UserDefaults if exists (one-time migration)
        if let dataArray = UserDefaults.standard.array(forKey: previousImagesStorageKey) as? [Data] {
            let migratedImages = dataArray.compactMap { UIImage(data: $0) }
            if !migratedImages.isEmpty {
                _ = FileStorageManager.shared.saveImageArray(migratedImages, forKey: previousImagesStorageKey)
                UserDefaults.standard.removeObject(forKey: previousImagesStorageKey)
                loadedImages = migratedImages
            }
        }
        
        // Request photo library permission if needed, then fetch gallery images
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    self.fetchRecentGalleryImages { galleryImages in
                        self.combineImages(appImages: loadedImages, galleryImages: galleryImages)
            }
        } else {
                    // No permission, just use app images
                    DispatchQueue.main.async {
                        self.previousImages = Array(loadedImages.prefix(7))
                    }
                }
            }
        } else if status == .authorized || status == .limited {
            // Already have permission, fetch gallery images
            fetchRecentGalleryImages { galleryImages in
                self.combineImages(appImages: loadedImages, galleryImages: galleryImages)
            }
        } else {
            // No permission, just use app images
            DispatchQueue.main.async {
                self.previousImages = Array(loadedImages.prefix(7))
            }
        }
    }
    
    func combineImages(appImages: [UIImage], galleryImages: [UIImage]) {
        DispatchQueue.main.async {
            // Start with app-analyzed images (priority)
            var combinedImages: [UIImage] = []
            var seenData: Set<Data> = []
            
            // Add app images first (up to 7)
            for image in appImages {
                if let imageData = image.jpegData(compressionQuality: 0.7),
                   !seenData.contains(imageData) {
                    combinedImages.append(image)
                    seenData.insert(imageData)
                    if combinedImages.count >= 7 {
                        break
        }
    }
            }
            
            // Fill remaining slots with gallery images
            if combinedImages.count < 7 {
                let remainingSlots = 7 - combinedImages.count
                for image in galleryImages.prefix(remainingSlots) {
                    if let imageData = image.jpegData(compressionQuality: 0.7),
                       !seenData.contains(imageData) {
                        combinedImages.append(image)
                        seenData.insert(imageData)
                        if combinedImages.count >= 7 {
                            break
                        }
                    }
                }
            }
            
            self.previousImages = combinedImages
        }
    }
    
    func fetchRecentGalleryImages(completion: @escaping ([UIImage]) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        guard status == .authorized || status == .limited else {
            completion([])
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 20 // Fetch more to ensure we get enough after filtering
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var images: [UIImage] = []
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .fast
        
        let group = DispatchGroup()
        let maxCount = min(assets.count, 20)
        
        for i in 0..<maxCount {
            let asset = assets.object(at: i)
            group.enter()
            
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(images)
        }
    }
    
    func savePreviousImages() {
        // Use file storage instead of UserDefaults for large image data
        _ = FileStorageManager.shared.saveImageArray(previousImages, forKey: previousImagesStorageKey)
    }
    
    func requestCameraAccess() {
        // Block if already analyzing or generating
        guard !appState.isAnalyzingImage && !appState.isGeneratingVocabulary else {
            return
        }
        
        PermissionsService.requestCameraAccess { granted in
            if granted {
                self.showingCamera = true
            }
        }
    }
    
    func requestPhotoLibraryAccess() {
        // Block if already analyzing or generating
        guard !appState.isAnalyzingImage && !appState.isGeneratingVocabulary else {
            return
        }
        
        PermissionsService.requestPhotoLibraryAccess { granted in
            if granted {
                self.showingGallery = true
            }
        }
    }
    
    
    // MARK: - Clicked Words API
    
    func fetchClickedWords() {
        // Only fetch from API - no cache loading
        guard let token = appState.authToken else {
            return
        }
        
        // Set loading state
        self.isLoadingClickedWords = true
        
        // Get current target language from default language pair
        var targetLanguage: String?
        for pair in appState.userLanguagePairs {
            if pair.is_default {
                targetLanguage = pair.target_language
                break
            }
        }
        
        // Fetch from API only
        PracticeAPIManager.shared.getClickedWords(sessionToken: token, targetLanguage: targetLanguage) { result in
            DispatchQueue.main.async {
                self.isLoadingClickedWords = false
                
                switch result {
                case .success(let response):
                    if let data = response.data {
                        // Handle both new nested format and old flat format
                        let apiWords = data.getAllWordsAsClickedWords()
                        
                        // Only show API data - no cache merging
                        if !apiWords.isEmpty {
                            self.clickedWords = apiWords
                            self.showingQuickLookModal = true
                        } else {
                        }
                    } else {
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
}


#Preview {
    SceneView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}

