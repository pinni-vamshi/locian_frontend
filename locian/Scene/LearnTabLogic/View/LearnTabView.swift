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
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        if !state.recommendedPlaces.isEmpty || state.isAnalyzingImage {
                            recommendedSection
                                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                .padding(.top, 10)
                        }
                        
                        addNavigationButton
                            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                            .padding(.vertical, 8)
                        

                    }
                }
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
        // ONLY animate if NOT loading history or timeline
        if state.generationState == .idle && !appState.isLoadingTimeline && !state.isLoadingHistory {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
        } else {
            // Ensure hidden if loading
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
        } else if isLoading {
            animateIn = false // Hide content if loading starts
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .active && !appState.hasInitialHistoryLoaded && !appState.isLoadingTimeline {
            state.fetchFirstRecommendedPlace()
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // 1. Place Name (Large Header)
            if let placeName = state.recommendedPlaces.first?.place_name {
                 Text(placeName.uppercased())
                    .font(.system(size: 40, weight: .heavy)) // 40pt Heavy
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
            }
                
            // 2. Theme Selector
            recommendedThemeSelector
            
            // 3. Vertical Moments List
            recommendedMomentsScroll
        }
        .padding(.bottom, 20)
    }



    @ViewBuilder
    private var recommendedThemeSelector: some View {
        if let place = state.recommendedPlaces.first, let situations = place.micro_situations, situations.count > 1 {
            // Content Only: Theme Blocks
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(situations, id: \.category) { section in
                        let isSelected = state.selectedRecommendedCategory == section.category
                        Button(action: { state.selectedRecommendedCategory = section.category }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(section.category.uppercased())
                                    .font(.system(size: 13, weight: .black))
                                
                                if isSelected {
                                    Text("THEME")
                                        .font(.system(size: 10, weight: .bold))
                                        .opacity(0.8)
                                }
                            }
                            .foregroundColor(isSelected ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(minWidth: 140, minHeight: 60, alignment: .leading)
                            .background(isSelected ? Color(white: 0.8) : Color(white: 0.1))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 80)
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.2)), alignment: .bottom)
        }
    }

    private var recommendedMomentsScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
             VStack(spacing: 16) {
                 recommendedAnalysisPlaceholder
                 recommendedMomentCards
                 addCustomMomentButton
             }
             .padding(.horizontal, 16)
             .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private var recommendedAnalysisPlaceholder: some View {
        if state.recommendedPlaces.isEmpty && state.isAnalyzingImage {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 220, height: 220)
                .overlay(ProgressView().tint(.white))
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
                recommendedCardGenerator(category: section.category, moments: section.moments, placeIndex: placeIndex, sectionIndex: sIndex)
            }
        }
    }

    private func recommendedCardGenerator(category: String, moments: [UnifiedMoment], placeIndex: Int, sectionIndex: Int) -> some View {
        ForEach(Array(moments.enumerated()), id: \.1.text) { (mIndex: Int, moment: UnifiedMoment) in
            let catId = 9021 + placeIndex + sectionIndex + mIndex
            let time = placeIndex == 0 ? "08:45 AM" : "09:12 AM"
            
            RecommendedCard(moment: moment.text, catId: "\(catId)", time: time, isGreen: false) {
                state.generateSentence(for: moment.text)
            }
        }
    }

    private func RecommendedCard(moment: String, catId: String, time: String, isGreen: Bool, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            recommendedCardHeader(catId: catId, time: time, isGreen: isGreen)
            Spacer()
            recommendedCardContent(moment: moment, isGreen: isGreen)
            Spacer()
            recommendedCardFooter(isGreen: isGreen, action: action)
        }
        .frame(minHeight: 120)
        .frame(maxWidth: .infinity)
        .background(isGreen ? Color.green : Color(white: 0.1))
    }

    private func recommendedCardHeader(catId: String, time: String, isGreen: Bool) -> some View {
        HStack {
            Text("CAT_ID: \(catId)")
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
                    .font(.system(size: 14, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(white: 0.15))
        }
    }
}
