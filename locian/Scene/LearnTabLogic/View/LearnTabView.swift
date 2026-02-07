//
//  LearnTabView.swift
//  locian
//
//  Consolidated Learn Tab UI Layer
//

import SwiftUI
import NaturalLanguage

struct LearnTabView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var state: LearnTabState
    @Binding var selectedTab: MainTabView.TabItem
    @Environment(\.scenePhase) var scenePhase 
    @State private var animateIn = false
    
    // Custom Moment Input
    @State private var showCustomInput: Bool = false
    @State private var customMomentText: String = ""
    var body: some View {
        let _ = print("🎨 [LearnTabView] BODY RE-EVALUATING")
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                placeNameHeader
                languagePromptHeader
                
                recommendedSection
                    .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                    .padding(.top, 10)
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $state.showLessonView) {
                if let lesson = state.currentLesson {
                    LessonView(lessonData: lesson).environmentObject(appState)
                }
            }
        }
        .onAppear { 
            print("🎨 [LearnTabView] onAppear TRIGGERED")
            handleOnAppear() 
        }
        .onChange(of: state.generationState) { _, newState in handleGenerationStateChange(newState) }
        .onChange(of: state.isLoadingHistory) { _, newVal in handleLoadingHistoryChange(newVal) }
        .onChange(of: appState.isLoadingTimeline) { _, newVal in handleLoadingHistoryChange(newVal) } 
        .onChange(of: scenePhase) { _, newPhase in handleScenePhaseChange(newPhase) }
        .onChange(of: state.showLessonView) { _, newValue in if !newValue { state.currentLesson = nil } }
        .fullScreenCover(isPresented: Binding(get: { state.generationState != .idle }, set: { _ in })) {
            loadingOverlay
        }
        .alert("Add Custom Moment", isPresented: $showCustomInput) {
            TextField("What do you want to say?", text: $customMomentText)
            Button("Cancel", role: .cancel) { customMomentText = "" }
            Button("Generate") {
                if !customMomentText.isEmpty {
                    state.generateSentence(for: customMomentText) // Use 'state' not 'learnTabState'
                    customMomentText = ""
                }
            }
        } message: {
            Text("Enter a sentence or moment you want to practice.")
        }
    }
    
    // MARK: - Navigation Components
    
    private var addNavigationButton: some View {
        let _ = print("🔘 [NAV-BTN] evaluating addNavigationButton body")
        return Button(action: {
            print("🌊 [NAV-BTN] 'Add a New Place' clicked")
            print("   -> Current Tab: \(selectedTab)")
            print("   -> triggering animation info selectedTab = .add")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                print("   -> [ANIMATION] Inside withAnimation block")
                selectedTab = .add
                print("   -> [ANIMATION] selectedTab set to .add")
            }
            print("   -> Animation block dispatched")
        }) {
            HStack {
                let _ = print("   -> Rendering Label HStack")
                Text("NOT SEEING WHAT YOU NEED?")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(white: 0.5))
                
                Text("ADD A NEW PLACE")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(ThemeColors.secondaryAccent)
                
                Spacer()
                
                Image(systemName: "plus.square.fill")
                    .font(.system(size: 18))
                    .foregroundColor(ThemeColors.secondaryAccent)
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(Color(white: 0.05))
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }



    // MARK: - Components

    private var headerView: some View {
        let _ = print("🎩 [HEADER] Rendering headerView")
        let username = appState.username.isEmpty ? LocalizationManager.shared.string(.user) : appState.username.uppercased()
        let _ = print("   -> Username to display: \(username)")
        let _ = print("   -> Streak text: \(state.uiStreakText)")
        let _ = print("   -> animateIn state: \(animateIn)")
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(username)
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(ThemeColors.secondaryAccent)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 12, weight: .bold)).foregroundColor(ThemeColors.primaryAccent)
                    Text(state.uiStreakText).font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(ThemeColors.primaryAccent)
                }
            }
            .padding(.horizontal, 10).padding(.top, 16).padding(.bottom, 10)
        }
        .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 10).animation(.spring(), value: animateIn)
    }

    private var placeNameHeader: some View {
        let isAnalyzing = state.isAnalyzingImage
        let _ = print("🏷 [PLACE-HEADER] Evaluating placeNameHeader")
        let _ = print("   -> isAnalyzing: \(isAnalyzing)")
        let _ = print("   -> isShowingGlobalRecommendations: \(state.isShowingGlobalRecommendations)")
        let _ = print("   -> Recommended Place Count: \(state.recommendedPlaces.count)")
        let _ = print("   -> First Place Name: \(state.recommendedPlaces.first?.place_name ?? "nil")")
        
        let name = isAnalyzing ? "GETTING YOUR PLACE..." : (state.showingNoDataError ? "NO DATA AVAILABLE" : (state.recommendedPlaces.first?.place_name ?? "ADD YOUR PLACE"))
        let _ = print("   -> Final Resolved Name: \(name)")
        
        return VStack(spacing: 0) {
            let _ = print("   -> Rendering Text View for Name")
            Text(name.uppercased())
                .font(.system(size: (isAnalyzing || state.showingNoDataError) ? 35 : 55.5, weight: .heavy))
                .minimumScaleFactor(0.3)
                .lineLimit(3)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 180)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.1))
        }
        .background(Color.black)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
        .animation(.spring(), value: animateIn)
    }

    private var languagePromptHeader: some View {
        let _ = print("🗣 [LANG-HEADER] Evaluating languagePromptHeader")
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let _ = print("   -> Active Pair: \(String(describing: activePair))")
        
        let targetRaw = activePair?.target_language ?? LocalizationManager.shared.currentLanguage.rawValue
        let _ = print("   -> Target Raw: \(targetRaw)")
        
        // Resolve full English name if targetRaw is a code or rawValue
        let languageName = AppLanguage(rawValue: targetRaw)?.englishName ?? AppLanguage.fromCode(targetRaw)?.englishName ?? targetRaw
        let _ = print("   -> Display Language Name: \(languageName)")
        
        return VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text("SELECT YOUR MOMENT TO TALK IN")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(white: 0.5))
                    
                    Text(languageName.uppercased())
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(ThemeColors.secondaryAccent)
                }
                .padding(.leading, 5)
                
                Spacer()
                
                Button(action: {
                    print("🔄 [LANG-HEADER] Refresh button tapped - TRIGGERING CONTEXT REFRESH")
                    print("   -> Calling state.refreshTokenContext()")
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    state.refreshTokenContext()
                    print("   -> Context Refresh dispatched")
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(ThemeColors.secondaryAccent)
                        .padding(8)
                        .background(ThemeColors.secondaryAccent.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.trailing, 16)
            }
            .frame(height: 50)
            .background(Color.black)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.1))
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
        .animation(.spring(), value: animateIn)
    }



    private var loadingOverlay: some View {
        let _ = print("🕐 [OVERLAY] Evaluating loadingOverlay body...")
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let _ = print("   -> Active Pair found: \(activePair != nil)")
        if let pair = activePair {
            print("   -> Pair Details: \(pair.native_language) -> \(pair.target_language)")
        }
        
        let targetName = activePair?.target_language ?? LocalizationManager.shared.currentLanguage.rawValue
        let _ = print("   -> Target Name: \(targetName)")
        
        let nativeName = activePair?.native_language ?? "English"
        let _ = print("   -> Native Name: \(nativeName)")
        
        let targetCode = AppLanguage(rawValue: targetName.capitalized)?.code ?? "en"
        let _ = print("   -> Target Code: \(targetCode)")
        
        let nativeCode = AppLanguage(rawValue: nativeName.capitalized)?.code ?? "en"
        let _ = print("   -> Native Code: \(nativeCode)")
        
        let targetLang = NLLanguage(rawValue: targetCode)
        let nativeLang = NLLanguage(rawValue: nativeCode)
        
        let isTargetAvailable = NLEmbedding.sentenceEmbedding(for: targetLang) != nil
        let _ = print("   -> Embedding available for Target (\(targetCode)): \(isTargetAvailable)")
        
        let isNativeAvailable = NLEmbedding.wordEmbedding(for: nativeLang) != nil
        let _ = print("   -> Embedding available for Native (\(nativeCode)): \(isNativeAvailable)")
        
        let placeName = state.recommendedPlaces.first?.place_name ?? "Unknown"
        let _ = print("   -> Place Name for Overlay: \(placeName)")
        
        let momentText = state.activeGeneratingMoment ?? "Analysis in Progress"
        let _ = print("   -> Moment Text for Overlay: \(momentText)")
        
        return AILoadingModal(
            placeName: placeName,
            moment: momentText,
            time: "Live Now",
            targetLangCode: targetCode.uppercased(),
            isTargetLoaded: isTargetAvailable,
            isNativeLoaded: isNativeAvailable,
            isReady: true,
            onFinish: {
                print("🏁 [OVERLAY] onFinish callback triggered!")
                print("   -> Current Lesson: \(String(describing: state.currentLesson))")
                if state.currentLesson != nil {
                    print("   -> Lesson exists, dismissing overlay...")
                    withAnimation {
                        print("   -> [ANIMATION] Setting showLessonView = true")
                        state.showLessonView = true
                        print("   -> [ANIMATION] Setting generationState = .idle")
                        state.generationState = .idle
                        print("   -> [ANIMATION] Clearing activeGeneratingMoment")
                        state.activeGeneratingMoment = nil
                    }
                } else {
                    print("   ⚠️ [OVERLAY] Current lesson is NIL. Overlay will not dismiss automatically.")
                }
            }
        ).onAppear { 
            print("👁 [OVERLAY] onAppear triggered")
            print("   -> Running NeuralValidator diagnostics for: \(targetCode)")
            NeuralValidator.runDiagnostics(for: targetCode) 
            print("   -> Diagnostics request sent.")
        }
    }

    // MARK: - Lifecycle Handlers

    // MARK: - Lifecycle Handlers

    private func handleOnAppear() {
        print("⚡️ [LIFECYCLE] handleOnAppear() triggered")
        print("   -> hasInitialHistoryLoaded: \(appState.hasInitialHistoryLoaded)")
        print("   -> isLoadingTimeline: \(appState.isLoadingTimeline)")
        print("   -> generationState: \(state.generationState)")
        
        if !appState.hasInitialHistoryLoaded && !appState.isLoadingTimeline {
            print("   -> Conditions met for fetching first recommended place.")
            state.fetchFirstRecommendedPlace()
            print("   -> fetchFirstRecommendedPlace called.")
        } else {
            print("   -> Skipping fetchFirstRecommendedPlace (History loaded or loading timeline)")
        }
        
        // Change: Animate in even if loading history/timeline, so inline states are visible
        if state.generationState == .idle {
            print("   -> Generation State is IDLE. Triggering animateIn = true")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { 
                animateIn = true 
            }
        } else {
            print("   -> Generation State is NOT IDLE (\(state.generationState)). Setting animateIn = false")
            animateIn = false
        }
        print("⚡️ [LIFECYCLE] handleOnAppear complete.")
    }
    
    private func handleGenerationStateChange(_ newState: SentenceGenerationState) {
        print("🔄 [STATE] Generation State Changed to: \(newState)")
        print("   -> isLoadingHistory: \(state.isLoadingHistory)")
        
        if newState == .idle && !state.isLoadingHistory {
            print("   -> State is IDLE and NOT loading history. Scheduling animateIn...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("      -> [ASYNC] Executing animateIn = true animation block")
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
            }
        } else if newState != .idle { 
            print("   -> State is BUSY. Setting animateIn = false immediately.")
            animateIn = false 
        } else {
            print("   -> No action taken for state change.")
        }
    }
    
    private func handleLoadingHistoryChange(_ isLoading: Bool) {
        print("⏳ [HISTORY] Loading History Changed. isLoading: \(isLoading)")
        print("   -> generationState: \(state.generationState)")
        print("   -> isLoadingTimeline: \(appState.isLoadingTimeline)")
        print("   -> isLoadingHistory (state): \(state.isLoadingHistory)")
        
        if !isLoading && state.generationState == .idle && !appState.isLoadingTimeline && !state.isLoadingHistory {
            print("   -> Conditions met: Loading FINISHED, Idle, Timeline Loaded. Animating In!")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
        } else {
            print("   -> Conditions NOT met for implicit animateIn.")
        }
        // No longer force animateIn = false when isLoading is true, 
        // because we want to see the inline "GETTING YOUR PLACE..." states.
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        print("🎭 [SCENE] Scene Phase Changed: \(newPhase)")
        print("   -> hasInitialHistoryLoaded: \(appState.hasInitialHistoryLoaded)")
        print("   -> isLoadingTimeline: \(appState.isLoadingTimeline)")
        
        if newPhase == .active && !appState.hasInitialHistoryLoaded && !appState.isLoadingTimeline {
            print("   -> App became ACTIVE and data needs loading. Fetching recommended place...")
            state.fetchFirstRecommendedPlace()
        } else {
            print("   -> handleScenePhaseChange ignoring change.")
        }
    }

    private var recommendedSection: some View {
        let _ = print("🎨 [LearnTabView] recommendedSection evaluating")
        let _ = print("   -> Checking dependencies...")
        return HStack(alignment: .top, spacing: 0) {
            let _ = print("   -> Laying out HStack...")
            // 2. Vertical Category Sidebar (Fixed)
            recommendedSidebar
                .frame(width: 50)
                .frame(maxHeight: .infinity)
            
            // 3. Vertical Moments List (Scrollable)
            recommendedMomentsScroll
            let _ = print("   -> Layout complete.")
        }
    }



    @ViewBuilder
    private var recommendedSidebar: some View {
        let _ = print("📊 [SIDEBAR] Rendering recommended sidebar...")
        VStack(spacing: 0) {
            let _ = print("   -> Rendering Top Arrow Box")
            // Top Arrow Box
            Rectangle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .overlay(
                    DoubleArrowButton(direction: .up, color: state.isAnalyzingImage ? .gray : ThemeColors.secondaryAccent, size: 16) {
                        if !state.isAnalyzingImage {
                            print("🔼 [SIDEBAR] Up arrow clicked - Cycling category BACKWARD")
                            cycleCategory(forward: false)
                        }
                    }
                )
            
            Spacer()
            
             // Category Text (Auto-scaling & Fixed Area)
            Group {
                if state.isAnalyzingImage {
                     Text("LOADING...")
                        .foregroundColor(ThemeColors.secondaryAccent)
                } else if state.showingNoDataError {
                     Text("NO DATA")
                        .foregroundColor(.gray)
                } else if let selectedCat = state.selectedRecommendedCategory {
                    Text(selectedCat.uppercased())
                        .foregroundColor(ThemeColors.secondaryAccent)
                } else {
                    Text("SELECT")
                        .foregroundColor(.gray)
                }
            }
            .font(.system(size: 13, weight: .black))
            .rotationEffect(.degrees(-90))
            .fixedSize()
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .frame(width: 50)
            .frame(maxHeight: .infinity) // Occupies space between boxes
            .clipped()
            
            Spacer()
            
            // Bottom Arrow Box
            Rectangle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .overlay(
                    DoubleArrowButton(direction: .down, color: state.isAnalyzingImage ? .gray : ThemeColors.secondaryAccent, size: 16) {
                        if !state.isAnalyzingImage {
                            print("🔽 [SIDEBAR] Down arrow clicked - Cycling category FORWARD")
                            cycleCategory(forward: true)
                        }
                    }
                )
        }
        .frame(width: 50)
        .background(Color(white: 0.05))
        .overlay(Rectangle().frame(width: 1).foregroundColor(Color.white.opacity(0.1)), alignment: .trailing)
    }

    private func cycleCategory(forward: Bool) {
        // ... (existing implementation)
        print("🔄 [CYCLE] Request received. Forward: \(forward)")
        let situations = state.recommendedPlaces.first?.micro_situations ?? []
        print("   -> Found \(situations.count) situations in first recommended place")
        guard !situations.isEmpty else { 
            print("   -> ⚠️ No situations found! Aborting cycle.")
            return 
        }
        
        let categories = situations.map { $0.category }
        print("   -> Available categories: \(categories)")
        let currentIndex = categories.firstIndex(of: state.selectedRecommendedCategory ?? "") ?? 0
        print("   -> Current Index: \(currentIndex) (Category: \(state.selectedRecommendedCategory ?? "nil"))")
        
        var nextIndex: Int
        if forward {
            nextIndex = (currentIndex + 1) % categories.count
            print("   -> Moving Forward to index: \(nextIndex)")
        } else {
            nextIndex = (currentIndex - 1 + categories.count) % categories.count
            print("   -> Moving Backward to index: \(nextIndex)")
        }
        
        let nextCategory = categories[nextIndex]
        print("   -> Next Category Selected: \(nextCategory)")
        
        withAnimation(.spring()) {
            print("   ✨ [ANIMATION] Updating selectedRecommendedCategory state...")
            state.selectedRecommendedCategory = nextCategory
        }
        print("🔄 [CYCLE] Update complete.")
    }

    private var recommendedMomentsScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
             VStack(spacing: 16) {
                 let _ = print("📜 [SCROLL] Rendering scroll content...")
                 
                 // EXCLUSIVE STATES
                 if state.isAnalyzingImage {
                     let _ = print("   -> State is Analyzing. Showing LOADING card ONLY.")
                     RecommendedCard(moment: "GETTING YOUR MOMENTS...", time: "LIVE", isGreen: false) {
                         // No action while loading
                     }
                 } else if state.showingNoDataError {
                     let _ = print("   -> State is NO DATA ERROR.")
                     RecommendedCard(moment: "NO DATA AVAILABLE", time: "--:--", isGreen: false) {
                         // No action
                     }
                 } else if state.recommendedPlaces.isEmpty {
                     let _ = print("   -> Recommended Places EMPTY. Showing placeholder.")
                     // Empty State Placeholder Card
                     RecommendedCard(moment: "TAP + TO ADD YOUR OWN MOMENT", time: "--:--", isGreen: false) {
                         print("➕ [ACTION] Tapped placeholder 'Add Your Own Moment'")
                         showCustomInput = true
                     }
                     .opacity(0.5)
                 } else {
                     let _ = print("   -> Rendering Content | Global: \(state.isShowingGlobalRecommendations)")
                     if state.isShowingGlobalRecommendations {
                         let _ = print("      -> Rendering GLOBAL list")
                         globalRecommendationsList
                     } else {
                         let _ = print("      -> Rendering LOCAL cards")
                         recommendedMomentCards
                     }
                 }
                 
                 // Hide add button during logic phases
                 if !state.isAnalyzingImage && !state.showingNoDataError {
                     addCustomMomentButton
                 }
             }
             .padding(.horizontal, 16)
             .padding(.bottom, 20)
        }
    }
    
    private var globalRecommendationsList: some View {
        VStack(spacing: 24) {
             let _ = print("🌍 [GLOBAL] Rendering Global List structure")
             // GENERIC RENDERING - VIEW DOES NOT KNOW OR CARE ABOUT SPLITS
             // It just iterates whatever structure strategy the Logic Layer provides.
             ForEach(state.globalRecommendations) { section in
                 VStack(alignment: .leading, spacing: 10) {
                     // SECTION HEADER
                     let _ = print("   -> Rendering Section: \(section.title)")
                     Text(section.title.uppercased())
                         .font(.system(size: 14, weight: .black))
                         .foregroundColor(ThemeColors.secondaryAccent)
                         .padding(.bottom, 4)
                         .padding(.top, 8)
                     ForEach(Array(section.items.enumerated()), id: \.1.id) { index, vm in
                         let _ = print("      -> Rendering Item [\(index)]: \(vm.moment)")
                         simpleGlobalRow(vm: vm)
                     }
                 }
             }
        }
    }
    
    // A truly "dumb" renderer for global items - no loops, no filter checks.
    // Logic Layer guarantees these ViewModels are perfectly formatted.
    // A truly "dumb" renderer for global items - no loops, no filter checks.
    // Logic Layer guarantees these ViewModels are perfectly formatted.
    private func simpleGlobalRow(vm: LearnTabState.RecommendedMomentViewModel) -> some View {
        // Debug print
        let _ = print("🎨 [UI-RENDER] simpleGlobalRow: \(vm.moment) (Cat: \(vm.category))")
        
        return AnyView(RecommendedCard(moment: vm.moment, time: vm.time, isGreen: false) {
            print("👆 [UI-INTERACTION] Tapped: \(vm.moment)")
            state.generateSentence(for: vm.moment)
        })
    }

    private var recommendedMomentCards: some View {
        ForEach(Array(state.recommendedPlaces.enumerated()), id: \.1.id) { (index: Int, place: MicroSituationData) in
            recommendedMomentRow(place: place, placeIndex: index)
        }
    }

    private func recommendedMomentRow(place: MicroSituationData, placeIndex: Int) -> some View {
        let situations = place.micro_situations ?? []
        return ForEach(Array(situations.enumerated()), id: \.1.category) { (sIndex: Int, section: UnifiedMomentSection) in
            // IGNORE CATEGORY FILTER IF GLOBAL RECOMMENDATIONS ARE ON
            if state.isShowingGlobalRecommendations || state.selectedRecommendedCategory == nil || section.category == state.selectedRecommendedCategory {
                recommendedCardGenerator(place: place, category: section.category, moments: section.moments)
            }
        }
    }

    private func recommendedCardGenerator(place: MicroSituationData, category: String, moments: [UnifiedMoment]) -> some View {
        let _ = print("🚀 [GENERATOR] START: processing place '\(place.place_name ?? "nil")'")
        let _ = print("   -> Category: \(category)")
        let _ = print("   -> Moment count: \(moments.count)")
        
        return ForEach(Array(moments.enumerated()), id: \.1.text) { (mIndex: Int, moment: UnifiedMoment) in
            let time = place.time ?? "--:--"
            let _ = print("🎨 [UI-RENDER] Card: \(moment.text) (Cat: \(category))")
            let _ = print("   -> Index: \(mIndex)")
            let _ = print("   -> Time: \(time)")
            let _ = print("   -> Place ID: \(place.id)")
            
            RecommendedCard(moment: moment.text, time: time, isGreen: false) {
                print("⚡️ [ACTION] Generating sentence for: \(moment.text)")
                print("   -> From Category: \(category)")
                print("   -> At Place: \(place.place_name ?? "unknown")")
                state.generateSentence(for: moment.text)
                print("   -> Action dispatched.")
            }
        }
    }

    private func RecommendedCard(moment: String, time: String, isGreen: Bool, action: @escaping () -> Void) -> some View {
        let _ = print("   🖼 [UI-Card] Building Card View for: \(moment)")
        let _ = print("      -> Time: \(time)")
        let _ = print("      -> IsGreen: \(isGreen)")
        
        return VStack(alignment: .leading, spacing: 0) {
            let _ = print("      -> Stacking Header...")
            recommendedCardHeader(time: time, isGreen: isGreen)
            Spacer()
            let _ = print("      -> Stacking Content...")
            recommendedCardContent(moment: moment, isGreen: isGreen)
            Spacer()
            let _ = print("      -> Stacking Footer...")
            recommendedCardFooter(isGreen: isGreen, action: action)
        }
        .frame(minHeight: 120)
        .frame(maxWidth: .infinity)
        .background(isGreen ? ThemeColors.neonGreen : Color(white: 0.1))
    }

    private func recommendedCardHeader(time: String, isGreen: Bool) -> some View {
        let _ = print("         🧢 [HEADER] Rendering header (Time: \(time))")
        return HStack {
            Spacer()
            Text(time)
        }
        .font(.system(size: 10, weight: .bold, design: .monospaced))
        .foregroundColor(isGreen ? .black.opacity(0.6) : .gray)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func recommendedCardContent(moment: String, isGreen: Bool) -> some View {
        let _ = print("         📝 [CONTENT] Rendering content text: \(moment.prefix(10))...")
        return Text(moment.uppercased())
            .font(.system(size: 24, weight: .black))
            .foregroundColor(isGreen ? .black : .white)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 12)
    }

    private func recommendedCardFooter(isGreen: Bool, action: @escaping () -> Void) -> some View {
        let _ = print("🤖 [UI] recommendedCardFooter rendering | isGreen: \(isGreen)")
        return HStack(alignment: .bottom, spacing: 0) {
            let _ = print("   -> Rendering Footer HStack")
            VStack(alignment: .leading, spacing: 0) {
                let _ = print("     -> Rendering GENERATE SENTENCE text")
                Text("GENERATE")
                Text("SENTENCE")
            }
            .font(.system(size: 10, weight: .black))
            .foregroundColor(isGreen ? .black : .gray)
            
            Spacer()
            
            Button(action: {
                print("🔘 [ACTION] 'Waveform' button tapped!")
                print("   -> Invoking footer action closure...")
                action() 
                print("   -> Footer action closure completed.")
            }) {
                let _ = print("     -> Rendering Waveform Button Label")
                Image(systemName: "waveform")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 32, height: 32)
                    .padding(8)
                    .background(ThemeColors.secondaryAccent)
            }
        }
        .padding(12)
    }
    

    
    // MARK: - Custom Moment Input
    
    private var addCustomMomentButton: some View {
        let _ = print("➕ [UI] addCustomMomentButton body evaluation")
        return Button(action: { 
            print("🟢 [ACTION] 'Add Your Own Moment' tapped")
            print("   -> Setting showCustomInput = true")
            showCustomInput = true 
        }) {
            HStack {
                let _ = print("   -> Rendering Add Button Content (Icon + Text)")
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                Text("ADD YOUR OWN MOMENT") 
                    .font(.system(size: 14, weight: .black))
                Spacer()
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(ThemeColors.neonGreen)
        }
    }
}
