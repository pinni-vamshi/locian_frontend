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
            // Reset immediately without animation to ensure clean state
            animateIn = false
            handleOnAppear() 
        }
        .onDisappear {
            print("👋 [LearnTabView] onDisappear TRIGGERED - Resetting animation state")
            // Cancel any in-progress animations immediately
            withAnimation(.none) {
                animateIn = false
            }
        }
        .onChange(of: appState.hasInitialHistoryLoaded) { _, loaded in
            print("🔄 [ANIMATION] hasInitialHistoryLoaded changed to: \(loaded)")
            if loaded && state.generationState == .idle && !animateIn {
                print("   -> Triggering delayed animation after loading screen dismissal")
                // Small delay to ensure loading screen animation completes first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        animateIn = true
                    }
                }
            }
        }
        .onChange(of: state.generationState) { _, newState in handleGenerationStateChange(newState) }
        .onChange(of: state.isLoadingHistory) { _, newVal in handleLoadingHistoryChange(newVal) }
        .onChange(of: appState.isLoadingTimeline) { _, newVal in handleLoadingHistoryChange(newVal) } 
        .onChange(of: scenePhase) { _, newPhase in handleScenePhaseChange(newPhase) }
        .onChange(of: state.showLessonView) { _, newValue in if !newValue { state.currentLesson = nil } }
        .fullScreenCover(isPresented: Binding(get: { state.generationState != .idle }, set: { _ in })) {
            SentenceGenerationLoadingModal(appState: appState, state: state)
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
        let isFetching = state.isFetchingData
        let _ = print("🏷 [PLACE-HEADER] Evaluating placeNameHeader")
        let _ = print("   -> isFetchingData: \(isFetching) (History: \(state.isLoadingHistory), Timeline: \(appState.isLoadingTimeline))")
        
        let name = isFetching ? "GETTING YOUR PLACE..." : (state.showingNoDataError ? "NO DATA AVAILABLE" : (state.recommendedPlaces.first?.place_name ?? "ADD YOUR PLACE"))
        
        return VStack(spacing: 0) {
            let _ = print("   -> Rendering Text View for Name")
            Text(name.uppercased())
                .font(.system(size: (isFetching || state.showingNoDataError) ? 35 : 55.5, weight: .heavy))
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

    // MARK: - Lifecycle Handlers

    private func handleOnAppear() {
        print("⚡️ [LIFECYCLE] handleOnAppear() triggered")
        if appState.hasInitialHistoryLoaded {
            state.loadRecommendations()
        }
        if appState.hasInitialHistoryLoaded && state.generationState == .idle {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
        } else {
            animateIn = false
        }
    }
    
    private func handleGenerationStateChange(_ newState: SentenceGenerationState) {
        if newState == .idle && !state.isLoadingHistory {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
            }
        } else if newState != .idle { 
            animateIn = false 
        }
    }
    
    private func handleLoadingHistoryChange(_ isLoading: Bool) {
        if !isLoading && state.generationState == .idle && !appState.isLoadingTimeline && !state.isLoadingHistory && appState.hasInitialHistoryLoaded {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .active && appState.hasInitialHistoryLoaded {
            state.loadRecommendations()
        }
    }

    private var recommendedSection: some View {
        HStack(alignment: .top, spacing: 0) {
            recommendedSidebar.frame(width: 50).frame(maxHeight: .infinity)
            recommendedMomentsScroll
        }
    }

    @ViewBuilder
    private var recommendedSidebar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white).frame(width: 50, height: 50).overlay(
                DoubleArrowButton(direction: .up, color: state.isFetchingData ? .gray : ThemeColors.secondaryAccent, size: 16) {
                    if !state.isFetchingData { cycleCategory(forward: false) }
                }
            )
            Spacer()
            Group {
                if state.isFetchingData { Text("LOADING...").foregroundColor(ThemeColors.secondaryAccent) }
                else if state.showingNoDataError { Text("NO DATA").foregroundColor(.gray) }
                else if let selectedCat = state.selectedRecommendedCategory { Text(selectedCat.uppercased()).foregroundColor(ThemeColors.secondaryAccent) }
                else { Text("SELECT").foregroundColor(.gray) }
            }
            .font(.system(size: 13, weight: .black)).rotationEffect(.degrees(-90)).fixedSize().minimumScaleFactor(0.4).lineLimit(1).frame(width: 50).frame(maxHeight: .infinity).clipped()
            Spacer()
            Rectangle().fill(Color.white).frame(width: 50, height: 50).overlay(
                DoubleArrowButton(direction: .down, color: state.isFetchingData ? .gray : ThemeColors.secondaryAccent, size: 16) {
                    if !state.isFetchingData { cycleCategory(forward: true) }
                }
            )
        }
        .frame(width: 50).background(Color(white: 0.05)).overlay(Rectangle().frame(width: 1).foregroundColor(Color.white.opacity(0.1)), alignment: .trailing)
    }

    private func cycleCategory(forward: Bool) {
        let situations = state.recommendedPlaces.first?.micro_situations ?? []
        guard !situations.isEmpty else { return }
        let categories = situations.map { $0.category }
        let currentIndex = categories.firstIndex(of: state.selectedRecommendedCategory ?? "") ?? 0
        let nextIndex = forward ? (currentIndex + 1) % categories.count : (currentIndex - 1 + categories.count) % categories.count
        withAnimation(.spring()) { state.selectedRecommendedCategory = categories[nextIndex] }
    }

    private var recommendedMomentsScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
             VStack(spacing: 16) {
                 let _ = print("📜 [VIEW] Rendering recommendedMomentsScroll")
                 let _ = print("   - recommendedPlaces count: \(state.recommendedPlaces.count)")
                 
                 if state.isFetchingData {
                     let _ = print("   - state isFetchingData=true -> Loading Card")
                     RecommendedCard(momentData: UnifiedMoment(text: "GETTING A MOMENT...", keywords: nil, embedding: nil), time: "LIVE", isGreen: false) {}
                 } else if state.showingNoDataError {
                     let _ = print("   - state showingNoDataError=true -> No Data Card")
                     RecommendedCard(momentData: UnifiedMoment(text: "NO DATA AVAILABLE", keywords: nil, embedding: nil), time: "--:--", isGreen: false) {}
                 } else if state.recommendedPlaces.isEmpty {
                     let _ = print("   - recommendedPlaces EMPTY -> Custom Input Card")
                     RecommendedCard(momentData: UnifiedMoment(text: "TAP + TO ADD YOUR OWN MOMENT", keywords: nil, embedding: nil), time: "--:--", isGreen: false) { showCustomInput = true }.opacity(0.5)
                  } else {
                      let _ = print("   - Rendering unified recommended cards...")
                      recommendedMomentCards
                  }
                 if !state.isFetchingData && !state.showingNoDataError { addCustomMomentButton }
             }
             .padding(.horizontal, 16).padding(.bottom, 20)
        }
    }
    

    private var recommendedMomentCards: some View {
        ForEach(Array(state.recommendedPlaces.enumerated()), id: \.1.id) { (index: Int, place: MicroSituationData) in
            let _ = print("   🗂 [VIEW] Processing Place [\(index)]: '\(place.place_name ?? "nil")'")
            recommendedMomentRow(place: place, placeIndex: index)
        }
    }

    private func recommendedMomentRow(place: MicroSituationData, placeIndex: Int) -> some View {
        let situations = place.micro_situations ?? []
        let _ = print("      - Situations count for '\(place.place_name ?? "nil")': \(situations.count)")
        
        return ForEach(Array(situations.enumerated()), id: \.1.category) { (_, section: UnifiedMomentSection) in
            let isSelected = section.category == state.selectedRecommendedCategory
            let _ = print("      - Section category: '\(section.category)' (Selected: \(state.selectedRecommendedCategory ?? "nil") -> Matches: \(isSelected))")
            
            if state.selectedRecommendedCategory == nil || isSelected {
                let _ = print("         -> Rendering \(section.moments.count) moments for category '\(section.category)'")
                recommendedCardGenerator(place: place, category: section.category, moments: section.moments)
            }
        }
    }

    private func recommendedCardGenerator(place: MicroSituationData, category: String, moments: [UnifiedMoment]) -> some View {
        ForEach(Array(moments.enumerated()), id: \.1.text) { (_, moment: UnifiedMoment) in
            RecommendedCard(momentData: moment, time: place.time ?? "--:--", isGreen: false) { state.generateSentence(for: moment.text, fromPlace: place.place_name) }
        }
    }

    private func RecommendedCard(momentData: UnifiedMoment, time: String, isGreen: Bool, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            recommendedCardHeader(momentData: momentData, time: time, isGreen: isGreen)
            Spacer()
            recommendedCardContent(moment: momentData.text, isGreen: isGreen)
            Spacer()
            recommendedCardFooter(isGreen: isGreen, action: action)
        }
        .frame(minHeight: 120).frame(maxWidth: .infinity).background(isGreen ? ThemeColors.neonGreen : Color(white: 0.1))
    }

    private func recommendedCardHeader(momentData: UnifiedMoment, time: String, isGreen: Bool) -> some View {
        HStack { 
            if let mastery = getMomentMastery(momentData) {
                Text("\(Int(mastery * 100))%")
                    .foregroundColor(isGreen ? .black.opacity(0.8) : ThemeColors.secondaryAccent)
            }
            Spacer() 
            Text(time) 
        }
        .font(.system(size: 10, weight: .bold, design: .monospaced))
        .foregroundColor(isGreen ? .black.opacity(0.6) : .gray)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func recommendedCardContent(moment: String, isGreen: Bool) -> some View {
        Text(moment.uppercased()).font(.system(size: 24, weight: .black)).foregroundColor(isGreen ? .black : .white)
            .multilineTextAlignment(.leading).lineLimit(3).minimumScaleFactor(0.7).padding(.horizontal, 12)
    }

    private func recommendedCardFooter(isGreen: Bool, action: @escaping () -> Void) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) { Text("GENERATE"); Text("SENTENCE") }
                .font(.system(size: 10, weight: .black)).foregroundColor(isGreen ? .black : .gray)
            Spacer()
            Button(action: { action() }) {
                Image(systemName: "waveform").font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                    .frame(width: 32, height: 32).padding(8).background(ThemeColors.secondaryAccent)
            }
        }.padding(12)
    }
    
    private var addCustomMomentButton: some View {
        Button(action: { showCustomInput = true }) {
            HStack {
                Image(systemName: "plus.circle.fill").font(.system(size: 16))
                Text("ADD YOUR OWN MOMENT").font(.system(size: 14, weight: .black))
                Spacer()
            }
            .foregroundColor(.black).padding().frame(maxWidth: .infinity).background(ThemeColors.neonGreen)
        }
    }

    // MARK: - Mastery Calculation
    
    private func getMomentMastery(_ momentData: UnifiedMoment) -> Double? {
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let targetLangCode = activePair?.target_language ?? "en"
        
        // Use existing embedding if available (Fixes redundant on-the-fly generation)
        let vector = momentData.embedding
        
        let score = SemanticMemoryService.shared.getEffectiveMastery(
            text: momentData.text,
            vector: vector, 
            languageCode: targetLangCode,
            currentStep: 0
        )
        
        return score > 0.05 ? score : nil // Only show if there's meaningful progress
    }
}
