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
    @State private var sidebarTextHeight: CGFloat = 180

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                    .diagnosticBorder(.pink, width: 1, label: "HDR")
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        if !state.recommendedPlaces.isEmpty || state.isAnalyzingImage {
                            recommendedSection
                                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                .padding(.top, 10)
                            
                            addNavigationButton
                                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                .padding(.vertical, 8)
                            
                            if !state.discoveryPlaces.isEmpty {
                                suggestedContextsSection
                                    .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                            }
                            
                            activeMomentsContent
                                .padding(.top, 10)
                                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                        }
                        
                VStack(spacing: 0) {
                    let studiedPlaces = state.allTimelinePlaces.filter { $0.type != "image" && $0.type != "custom" }
                    if !studiedPlaces.isEmpty {
                        HStack(spacing: 0) {
                            timelineSidebar.frame(width: 70) 
                                .diagnosticBorder(.purple.opacity(0.3), width: 1, label: "SIDEBAR")
                            
                            // Only show hero if the currently selected hour place is "studied"
                            let currentPlace = state.stickyPlaceForHour(state.selectedTimelineHour)
                            if currentPlace?.type != "image" && currentPlace?.type != "custom" {
                                heroPlaceDisplay
                                    .diagnosticBorder(.cyan.opacity(0.3), width: 1, label: "HERO")
                            } else {
                                Spacer()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.5))
                                    .overlay(Text("NO STUDIED HISTORY FOR THIS HOUR").font(.system(size: 10, weight: .bold)).foregroundColor(.gray))
                            }
                        }
                        .diagnosticBorder(.purple, width: 2, label: "HERO_HS_S:0")
                        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.2)), alignment: .bottom)
                        .frame(height: 180)
                    }
                }
                        .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                        .animation(.spring().delay(0.1), value: animateIn)
                    }
                }
            }
            .diagnosticBorder(.white, width: 2, label: "LEARN_V_S:0")
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
        .onChange(of: appState.isLoadingTimeline) { _, newVal in handleLoadingHistoryChange(newVal) } // Added observer for timeline loading
        .onChange(of: scenePhase) { _, newPhase in handleScenePhaseChange(newPhase) }
        .onChange(of: state.showLessonView) { _, newValue in if !newValue { state.currentLesson = nil } }
        .fullScreenCover(isPresented: Binding(get: { state.generationState != .idle }, set: { _ in })) {
            loadingOverlay
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
                
                Text("ADD A NEW MOMENT")
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

    private var suggestedContextsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SUGGESTED FOR YOU")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(state.discoveryPlaces, id: \.id) { place in
                        let isSelected = state.selectedDiscoveryPlace?.id == place.id
                        Button(action: {
                            withAnimation(.spring()) {
                                if isSelected {
                                    state.resetSelectedDiscovery()
                                } else {
                                    state.selectedDiscoveryPlace = place
                                }
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.place_name?.uppercased() ?? "MOMENT")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(isSelected ? .black : .white)
                                
                                Text("SELECT SECTION")
                                    .font(.system(size: 9, weight: .bold))
                                    .opacity(0.7)
                                    .foregroundColor(isSelected ? .black : .gray)
                            }
                            .padding(16)
                            .frame(width: 160, height: 80, alignment: .leading)
                            .background(isSelected ? ThemeColors.secondaryAccent : Color(white: 0.1))
                            .overlay(
                                Rectangle()
                                    .stroke(isSelected ? .clear : Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 10)
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
                    .diagnosticBorder(.white, width: 0.5, label: "NAME_P:H8,V6")
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 12, weight: .bold)).foregroundColor(ThemeColors.primaryAccent)
                        .diagnosticBorder(.red, width: 0.5)
                    Text(state.uiStreakText).font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(ThemeColors.primaryAccent)
                        .diagnosticBorder(.yellow, width: 0.5)
                }
                .diagnosticBorder(.orange, width: 1)
            }
            .diagnosticBorder(.green, width: 1.5, label: "HDR_HS_P:H10,T16,B10")
            .padding(.horizontal, 10).padding(.top, 16).padding(.bottom, 10)
        }
        .diagnosticBorder(.pink, width: 1.5, label: "HDR_V_S:12")
        .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 10).animation(.spring(), value: animateIn)
        .diagnosticBorder(.white, width: 1)
    }

    private var heroPlaceDisplay: some View {
        let isLoading = state.isAnalyzingImage || appState.isLoadingTimeline
        return Text(isLoading ? "GETTING PLACE..." : state.uiPlaceName.uppercased())
            .font(.system(size: 60, weight: .heavy)).foregroundColor(.white)
            .multilineTextAlignment(.leading).lineLimit(2).minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).padding(.horizontal, 16)
            .diagnosticBorder(.cyan, width: 1)
    }

    private var timelineSidebar: some View {
        GeometryReader { geo in
            let mid = geo.size.height / 2
            let scrollMid = geo.frame(in: .global).midY
            ZStack(alignment: .trailing) {
                Rectangle().fill(Color.pink).frame(width: 20, height: 4).cornerRadius(2).position(x: 35, y: mid).zIndex(1)
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear.frame(height: mid - 25)
                            ForEach(0..<24) { hr in
                                hourTick(hr, scrollMid: scrollMid).id(hr).frame(height: 50)
                            }
                            Color.clear.frame(height: mid - 25)
                        }
                        .diagnosticBorder(.blue.opacity(0.3), width: 1)
                    }.onAppear { proxy.scrollTo(state.selectedTimelineHour, anchor: .center) }
                }
            }
            .diagnosticBorder(.pink.opacity(0.5), width: 1)
        }
        .diagnosticBorder(.pink, width: 1)
    }

    private func hourTick(_ hr: Int, scrollMid: CGFloat) -> some View {
        GeometryReader { geo in
            let distance = abs(geo.frame(in: .global).midY - scrollMid)
            let factor = max(0, 1.0 - (distance / 80))
            let hasPlace = state.hasStudiedPlace(forHour: hr)
            return HStack(spacing: 6) {
                Spacer()
                VStack(spacing: 2) {
                    Text("\(hr % 12 == 0 ? 12 : hr % 12)").font(.system(size: 10, weight: .black, design: .monospaced))
                        .diagnosticBorder(.white.opacity(0.5), width: 0.5)
                    Text(hr < 12 ? "AM" : "PM").font(.system(size: 7, weight: .bold, design: .monospaced))
                        .diagnosticBorder(.white.opacity(0.5), width: 0.5)
                }.foregroundColor(hasPlace ? .pink : .white.opacity(0.3 + (0.7 * Double(factor)))).scaleEffect(0.8 + (0.2 * factor))
                    .diagnosticBorder(.blue.opacity(0.5), width: 0.5)
                Rectangle().fill(hasPlace ? .pink : .white.opacity(0.4 + (0.6 * Double(factor)))).frame(width: 8 * (1.0 + Double(factor) * 1.5), height: 1.5)
                    .diagnosticBorder(.pink.opacity(0.5), width: 0.5)
            }
            .frame(height: geo.size.height) // FIX: Center content vertically in 50pt slot
            .padding(.trailing, 10)
            .onChange(of: distance) { _, d in if d < 25 && state.selectedTimelineHour != hr { state.selectedTimelineHour = hr } }
        }
    }

    private var activeMomentsContent: some View {
        let isLoading = state.isAnalyzingImage || appState.isLoadingTimeline || state.isLoadingMoments
        return HStack(spacing: 0) {
            if !isLoading && !state.uiCategories.isEmpty { 
                verticalCategorySidebar 
                    .diagnosticBorder(.white, width: 0.5, label: "CAT_SIDEBAR")
            }
            
            VStack(spacing: 0) {
                if isLoading {
                    loadingHeader
                    loadingSpinner
                } else if state.uiCategories.isEmpty {
                    noMomentsView
                } else {
                    momentsList
                }
            }
            .frame(maxWidth: .infinity)
        }
        .diagnosticBorder(.cyan.opacity(0.2), width: 1)
    }


    private var instructionalHeader: some View {
        let activePair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
        let targetCode = activePair?.target_language ?? "en"
        let lang = AppLanguage.fromCode(targetCode) ?? .english
        let langName = lang.englishName.uppercased()
        
        return VStack(alignment: .leading, spacing: 0) {
            Text("SELECT A MOMENT TO TALK IN \(langName)")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(Color(white: 0.3)) // Heavy grey
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(Color.black)
        .diagnosticBorder(.gray, width: 1, label: "INSTR_HDR")
    }

    private var momentsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(state.uiMomentsInSelectedCategory, id: \.text) { moment in
                ChamferedCard(
                    color: .black,
                    borderColor: .white.opacity(0.1),
                    borderWidth: 1,
                    chamferSize: 12
                ) {
                    HStack(spacing: 12) {
                        Text(moment.text.uppercased())
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Button(action: { state.generateSentence(for: moment.text) }) {
                            Image(systemName: "waveform")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(ThemeColors.secondaryAccent)
                                .frame(width: 32, height: 32)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(ThemeColors.secondaryAccent, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
            Spacer().frame(height: 100)
        }
        .padding(.leading, 12).padding(.trailing, 16)
        .diagnosticBorder(.green.opacity(0.3), width: 1, label: "LIST_V_S:12,P:L5,R16")
    }

    private var loadingHeader: some View {
        Text("DISCOVERING YOUR JOURNEY...").font(.system(size: 24, weight: .heavy)).foregroundColor(.white).padding(20).frame(maxWidth: .infinity, alignment: .leading)
    }

    private var verticalCategorySidebar: some View {
        VStack(spacing: 24) {
            // Up Arrow
            DoubleArrowButton(
                direction: .up,
                color: ThemeColors.secondaryAccent,
                size: 16,
                action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        state.selectPreviousCategory()
                    }
                }
            )
            .padding(.top, 16)

            // Rotated Category Name
            Text(state.uiSelectedCategoryName?.uppercased() ?? "CATEGORY")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.black)
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .fixedSize()
                .frame(maxHeight: .infinity)
                .diagnosticBorder(.gray, width: 0.5)

            // Down Arrow
            DoubleArrowButton(
                direction: .down,
                color: ThemeColors.secondaryAccent,
                size: 16,
                action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        state.selectNextCategory()
                    }
                }
            )
            .padding(.bottom, 24)
        }
        .frame(width: 36)
        .frame(maxHeight: .infinity)
        .background(Color.white)
        .padding(.leading, 5)
    }

    private var loadingSpinner: some View {
        VStack { Spacer(); ProgressView().tint(ThemeColors.primaryAccent).scaleEffect(2.0); Text("DISCOVERING MOMENTS...").font(.system(size: 14, weight: .bold)).foregroundColor(.white.opacity(0.6)).padding(.top, 16); Spacer() }.frame(minHeight: 200)
    }

    private var noMomentsView: some View {
        VStack(spacing: 20) {
            Spacer(); Image(systemName: "sparkles").font(.system(size: 40)).foregroundColor(.white.opacity(0.3)); Text("NO MOMENTS PREPARED").foregroundColor(.white.opacity(0.4))
            Spacer()
        }.frame(minHeight: 200)
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
            placeName: state.firstRecommendedPlace ?? "Unknown",
            moment: state.activeGeneratingMoment ?? "Analysis in Progress",
            time: state.firstRecommendedPlaceTimeGap ?? "Live Now",
            targetLangCode: targetCode.uppercased(),
            isTargetLoaded: isTargetAvailable,
            isNativeLoaded: isNativeAvailable,
            isReady: state.isEmbeddingsReady,
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
        VStack(alignment: .leading, spacing: 0) {
            recommendedPlaceHero
            
            HStack(spacing: 0) {
                // Unified Sidebar: Place Name "Spine" (Rotated 90 deg)
                VStack {
                    Spacer()
                    Text(state.recommendedPlaces.first?.place_name?.uppercased() ?? "MOMENT")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .fixedSize()
                        .rotationEffect(.degrees(-90))
                        .fixedSize()
                    Spacer()
                }
                .frame(width: 40)
                .background(Color(white: 0.15))
                
                // Right Content Area
                VStack(alignment: .leading, spacing: 0) {
                    recommendedThemeSelector
                    recommendedMomentsScroll
                }
                .background(Color.black)
            }
        }
        .padding(.bottom, 20)
    }

    private var recommendedPlaceHero: some View {
        // Content Only: Section Header "RECOMMENDED"
        VStack(alignment: .leading) {
            Text("RECOMMENDED")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 30)
        .diagnosticBorder(.blue, width: 1, label: "REC_PLACE_STACK")
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
            .diagnosticBorder(.orange, width: 1, label: "REC_CAT_STACK")
        }
    }

    private var recommendedMomentsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                recommendedAnalysisPlaceholder
                recommendedMomentCards
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 240)
        .padding(.top, 10)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.2)), alignment: .bottom)
        .diagnosticBorder(.green, width: 1, label: "REC_MOMENTS_STACK")
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
        .frame(width: 220, height: 220)
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
}
