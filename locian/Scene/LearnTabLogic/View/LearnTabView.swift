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
        .onAppear { handleOnAppear() }
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
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                selectedTab = .add
            }
        }) {
            HStack {
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(appState.username.isEmpty ? LocalizationManager.shared.string(.user) : appState.username.uppercased())
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
        let name = isAnalyzing ? "GETTING YOUR PLACE..." : (state.isShowingGlobalRecommendations ? "SUGGESTED MOMENTS" : (state.recommendedPlaces.first?.place_name ?? "ADD YOUR PLACE"))
        
        return VStack(spacing: 0) {
            Text(name.uppercased())
                .font(.system(size: isAnalyzing ? 35 : 55.5, weight: .heavy))
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
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let targetRaw = activePair?.target_language ?? LocalizationManager.shared.currentLanguage.rawValue
        
        // Resolve full English name if targetRaw is a code or rawValue
        let languageName = AppLanguage(rawValue: targetRaw)?.englishName ?? AppLanguage.fromCode(targetRaw)?.englishName ?? targetRaw
        
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
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    state.fetchFirstRecommendedPlace()
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
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let targetName = activePair?.target_language ?? LocalizationManager.shared.currentLanguage.rawValue
        let nativeName = activePair?.native_language ?? "English"
        
        let targetCode = AppLanguage(rawValue: targetName.capitalized)?.code ?? "en"
        let nativeCode = AppLanguage(rawValue: nativeName.capitalized)?.code ?? "en"
        
        let targetLang = NLLanguage(rawValue: targetCode)
        let nativeLang = NLLanguage(rawValue: nativeCode)
        let isTargetAvailable = NLEmbedding.sentenceEmbedding(for: targetLang) != nil
        let isNativeAvailable = NLEmbedding.wordEmbedding(for: nativeLang) != nil
        
        return AILoadingModal(
            placeName: state.recommendedPlaces.first?.place_name ?? "Unknown",
            moment: state.activeGeneratingMoment ?? "Analysis in Progress",
            time: "Live Now",
            targetLangCode: targetCode.uppercased(),
            isTargetLoaded: isTargetAvailable,
            isNativeLoaded: isNativeAvailable,
            isReady: true,
            onFinish: {
                if state.currentLesson != nil {
                    withAnimation {
                        state.showLessonView = true
                        state.generationState = .idle
                        state.activeGeneratingMoment = nil
                    }
                }
            }
        ).onAppear { NeuralValidator.runDiagnostics(for: targetCode) }
    }

    // MARK: - Lifecycle Handlers

    private func handleOnAppear() {
        if !appState.hasInitialHistoryLoaded && !appState.isLoadingTimeline {
            state.fetchFirstRecommendedPlace()
        }
        // Change: Animate in even if loading history/timeline, so inline states are visible
        if state.generationState == .idle {
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
        } else if newState != .idle { animateIn = false }
    }
    
    private func handleLoadingHistoryChange(_ isLoading: Bool) {
        if !isLoading && state.generationState == .idle && !appState.isLoadingTimeline && !state.isLoadingHistory {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
        }
        // No longer force animateIn = false when isLoading is true, 
        // because we want to see the inline "GETTING YOUR PLACE..." states.
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .active && !appState.hasInitialHistoryLoaded && !appState.isLoadingTimeline {
            state.fetchFirstRecommendedPlace()
        }
    }

    private var recommendedSection: some View {
        HStack(alignment: .top, spacing: 0) {
            // 2. Vertical Category Sidebar (Fixed)
            recommendedSidebar
                .frame(width: 50)
                .frame(maxHeight: .infinity)
            
            // 3. Vertical Moments List (Scrollable)
            recommendedMomentsScroll
        }
    }



    @ViewBuilder
    private var recommendedSidebar: some View {
        VStack(spacing: 0) {
            // Top Arrow Box
            Rectangle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .overlay(
                    DoubleArrowButton(direction: .up, color: ThemeColors.secondaryAccent, size: 16) {
                        cycleCategory(forward: false)
                    }
                )
            
            Spacer()
            
            // Category Text (Auto-scaling & Fixed Area)
            Group {
                if let selectedCat = state.selectedRecommendedCategory {
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
                    DoubleArrowButton(direction: .down, color: ThemeColors.secondaryAccent, size: 16) {
                        cycleCategory(forward: true)
                    }
                )
        }
        .frame(width: 50)
        .background(Color(white: 0.05))
        .overlay(Rectangle().frame(width: 1).foregroundColor(Color.white.opacity(0.1)), alignment: .trailing)
    }

    private func cycleCategory(forward: Bool) {
        let situations = state.recommendedPlaces.first?.micro_situations ?? []
        guard !situations.isEmpty else { return }
        
        let categories = situations.map { $0.category }
        let currentIndex = categories.firstIndex(of: state.selectedRecommendedCategory ?? "") ?? 0
        
        var nextIndex: Int
        if forward {
            nextIndex = (currentIndex + 1) % categories.count
        } else {
            nextIndex = (currentIndex - 1 + categories.count) % categories.count
        }
        
        withAnimation(.spring()) {
            state.selectedRecommendedCategory = categories[nextIndex]
        }
    }

    private var recommendedMomentsScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
             VStack(spacing: 16) {
                 if state.isAnalyzingImage {
                     RecommendedCard(moment: "GETTING YOUR MOMENTS...", time: "LIVE", isGreen: false) {
                         // No action while loading
                     }
                 }
                 
                 if state.recommendedPlaces.isEmpty && !state.isAnalyzingImage {
                     // Empty State Placeholder Card
                     RecommendedCard(moment: "TAP + TO ADD YOUR OWN MOMENT", time: "--:--", isGreen: false) {
                         showCustomInput = true
                     }
                     .opacity(0.5)
                 } else {
                     if state.isShowingGlobalRecommendations {
                         globalRecommendationsList
                     } else {
                         recommendedMomentCards
                     }
                 }
                 
                 addCustomMomentButton
             }
             .padding(.horizontal, 16)
             .padding(.bottom, 20)
        }
    }
    
    private var globalRecommendationsList: some View {
        VStack(spacing: 24) {
             // Simple Top 10 List (No Headers)
             ForEach(Array(state.recommendedPlaces.enumerated()), id: \.1.id) { index, place in
                 recommendedMomentRow(place: place, placeIndex: index)
             }
        }
    }

    private var recommendedMomentCards: some View {
        ForEach(Array(state.recommendedPlaces.enumerated()), id: \.1.id) { (index: Int, place: MicroSituationData) in
            recommendedMomentRow(place: place, placeIndex: index)
        }
    }

    private func recommendedMomentRow(place: MicroSituationData, placeIndex: Int) -> some View {
        let situations = place.micro_situations ?? []
        return ForEach(Array(situations.enumerated()), id: \.1.category) { (sIndex: Int, section: UnifiedMomentSection) in
            if state.selectedRecommendedCategory == nil || section.category == state.selectedRecommendedCategory {
                recommendedCardGenerator(place: place, category: section.category, moments: section.moments)
            }
        }
    }

    private func recommendedCardGenerator(place: MicroSituationData, category: String, moments: [UnifiedMoment]) -> some View {
        ForEach(Array(moments.enumerated()), id: \.1.text) { (mIndex: Int, moment: UnifiedMoment) in
            let time = place.time ?? "--:--"
            
            RecommendedCard(moment: moment.text, time: time, isGreen: false) {
                state.generateSentence(for: moment.text)
            }
        }
    }

    private func RecommendedCard(moment: String, time: String, isGreen: Bool, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            recommendedCardHeader(time: time, isGreen: isGreen)
            Spacer()
            recommendedCardContent(moment: moment, isGreen: isGreen)
            Spacer()
            recommendedCardFooter(isGreen: isGreen, action: action)
        }
        .frame(minHeight: 120)
        .frame(maxWidth: .infinity)
        .background(isGreen ? ThemeColors.neonGreen : Color(white: 0.1))
    }

    private func recommendedCardHeader(time: String, isGreen: Bool) -> some View {
        HStack {
            Spacer()
            Text(time)
        }
        .font(.system(size: 10, weight: .bold, design: .monospaced))
        .foregroundColor(isGreen ? .black.opacity(0.6) : .gray)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private func recommendedCardContent(moment: String, isGreen: Bool) -> some View {
        Text(moment.uppercased())
            .font(.system(size: 24, weight: .black))
            .foregroundColor(isGreen ? .black : .white)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 12)
    }

    private func recommendedCardFooter(isGreen: Bool, action: @escaping () -> Void) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("GENERATE")
                Text("SENTENCE")
            }
            .font(.system(size: 10, weight: .black))
            .foregroundColor(isGreen ? .black : .gray)
            
            Spacer()
            
            Button(action: action) {
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
        Button(action: { showCustomInput = true }) {
            HStack {
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
