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
    @Environment(\.scenePhase) var scenePhase 
    @State private var animateIn = false
    @State private var sidebarTextHeight: CGFloat = 180

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                    .diagnosticBorder(.pink, width: 1, label: "HDR")
                
                HStack(spacing: 0) {
                    timelineSidebar.frame(width: 70) 
                        .diagnosticBorder(.purple.opacity(0.3), width: 1, label: "SIDEBAR")
                    heroPlaceDisplay
                        .diagnosticBorder(.cyan.opacity(0.3), width: 1, label: "HERO")
                }
                .diagnosticBorder(.purple, width: 2, label: "HERO_HS_S:0")
                .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.2)), alignment: .bottom) // Updated to 0.2 opacity
                .frame(height: 180)
                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                .animation(.spring().delay(0.1), value: animateIn)
                
                
                instructionalHeader
                    .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                    .animation(.spring().delay(0.15), value: animateIn)

                activeMomentsContent
                    .diagnosticBorder(.green, width: 1, label: "MOMENTS")
                    .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                    .animation(.spring().delay(0.2), value: animateIn)
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

    // MARK: - Components

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizationManager.shared.string(.welcomeLabel)).font(.system(size: 14, weight: .black, design: .monospaced)).foregroundColor(.black).padding(.horizontal, 8).padding(.vertical, 6).background(Color.white)
                        .diagnosticBorder(.gray, width: 0.5)
                    Text(appState.username.isEmpty ? LocalizationManager.shared.string(.user) : appState.username.uppercased()).font(.system(size: 20, weight: .black, design: .monospaced)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 6).background(ThemeColors.secondaryAccent)
                        .diagnosticBorder(.white, width: 0.5, label: "NAME_P:H8,V6")
                }
                .diagnosticBorder(.blue, width: 1, label: "HDR_V_LEFT_S:4")
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
            let hasPlace = state.hasPlace(forHour: hr)
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
                    ScrollView(.vertical, showsIndicators: false) {
                        momentsList
                    }
                    .diagnosticBorder(.white.opacity(0.1), width: 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .diagnosticBorder(.cyan.opacity(0.2), width: 1)
        .frame(maxHeight: .infinity)
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
                Button(action: { state.generateSentence(for: moment.text) }) {
                    HStack(spacing: 12) {
                        Rectangle().fill(Color.green).frame(width: 4).frame(maxHeight: .infinity)
                            .diagnosticBorder(.green, width: 0.5)
                        Text(moment.text.uppercased()).font(.system(size: 15, weight: .bold)).foregroundColor(.white.opacity(0.8)).multilineTextAlignment(.leading)
                            .diagnosticBorder(.white.opacity(0.5), width: 0.5)
                        Spacer()
                    }.padding(.vertical, 12).padding(.horizontal, 16)
                        .diagnosticBorder(.cyan.opacity(0.3), width: 1)
                }
                .diagnosticBorder(.white.opacity(0.1), width: 1)
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
            Button(action: { 
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    state.selectPreviousCategory()
                }
            }) {
                Image(systemName: "chevron.up").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                    .frame(width: 36, height: 44)
            }
            .padding(.top, 8)

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
            Button(action: { 
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    state.selectNextCategory()
                }
            }) {
                Image(systemName: "chevron.down").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                    .frame(width: 36, height: 44)
            }
            .padding(.bottom, 16)
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
}
