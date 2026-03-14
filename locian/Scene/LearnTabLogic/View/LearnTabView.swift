//
//  LearnTabView.swift
//  locian
//
//  V3.0 "Context Intelligence" Cyber UI
//

import SwiftUI

struct LearnTabView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var state: LearnTabState
    @Binding var selectedTab: MainTabView.TabItem
    
    @Environment(\.scenePhase) var scenePhase 
    
    @State private var selectedImage: UIImage? = nil
    @State private var isImageSelected = false
    @State private var animateIn = false
    
    // Pull-to-refresh state
    @State private var pullRefreshState: CyberRefreshState = .idle
    @State private var scrollOffset: CGFloat = 0
    
    // Skeleton Animation State
    @State private var shimmerPhase: Bool = false
    @State private var loadingStatusIndex: Int = 0
    @State private var loadingTimer: Timer? = nil
    
    private var loadingMessages: [String] {
        [
            LanguageManager.shared.ui.analyzingImage,
            LanguageManager.shared.ui.generatingMoments,
            LanguageManager.shared.ui.callingAI
        ]
    }
    
    var body: some View {
        mainContentStack
            .background(Color.black.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                animateIn = false
                if state.recommendations.isEmpty {
                    state.discover()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true }
                }
            }
            .onDisappear {
                withAnimation(.none) { animateIn = false }
            }
            .onChange(of: state.showLessonView) { _, newValue in 
                if !newValue { state.currentLesson = nil } 
            }
            .fullScreenCover(isPresented: $state.isGeneratingSentence) {
                SentenceGenerationLoadingModal(appState: appState, state: state)
            }
            .onAppear {
                // Initial shimmer trigger
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    shimmerPhase.toggle()
                }
            }
            .fullScreenCover(isPresented: $state.showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage, isImageSelected: $isImageSelected) {
                    if let img = selectedImage {
                        state.discover(image: img)
                    }
                }
            }
    }

    private var mainContentStack: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // STICKY HEADER AREA
                VStack(spacing: 24) {
                    v3Header
                        .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                        .animation(.spring().delay(0.0), value: animateIn)
                        
                    v3RecommendationSelector
                        .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                        .animation(.spring().delay(0.1), value: animateIn)
                }
                .padding(.vertical, 10)
                .background(Color.black)
                
                ZStack(alignment: .top) {
                    if pullRefreshState != .idle {
                        CyberRefreshIndicator(state: pullRefreshState, height: max(60, scrollOffset), accentColor: ThemeColors.neonGreen).zIndex(0)
                    }
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // 2.5 Location Warning (Conditional)
                            if !appState.isLocationTrackingEnabled {
                                locationWarningBanner
                                    .padding(.top, 10)
                                    .padding(.bottom, 5)
                            }
                            
                            // 3. Main Sentence Display
                            v3MainSentenceModule
                                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                .animation(.spring().delay(0.2), value: animateIn)
                            
                            // 4. Interaction Module
                            Group {
                                if state.isTextInputMode {
                                    v3NearbyModule
                                        .padding(.top, 30)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                } else {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 16) {
                                            v3PatternProgressionModule
                                                .padding(.vertical, 5)
                                                
                                            v3ActionModule
                                        }
                                        
                                        v3GradientDivider // Bottom Divider
                                    }
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                            .animation(.spring().delay(0.3), value: animateIn)
                            
                            
                            if !state.isTextInputMode {
                                // 5. History
                                v3HistorySection
                                    .padding(.top, 40)
                                    .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                    .animation(.spring().delay(0.5), value: animateIn)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        } // closes VStack
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                        .padding(.horizontal, 5)
                        .background(Color.black) // Ensure opaque background over the indicator
                        .overlay(scrollOffsetTracker, alignment: .top)
                    } // closes ScrollView
                    .coordinateSpace(name: "learnPullToRefresh")
                    .onPreferenceChange(LearnViewOffsetKey.self) { handleRefresh(offset: $0) }
                
                } // closes ZStack
                .onAppear {
                    state.loadNearbyPlaces()
                }

            } // closes external VStack
            .background(Color.black.ignoresSafeArea())
            .navigationDestination(isPresented: $state.showLessonView) {
                if let lesson = state.currentLesson {
                    LessonView(lessonData: lesson).environmentObject(appState)
                }
            }
        }
    }

    // MARK: - V3 Components

    private var v3EnvironmentStatusBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // GPS Button
                environmentStatusButton(
                    type: .gps,
                    icon: "location.fill",
                    label: "GPS (LIVE)",
                    value: state.telemetry.activeSensors.contains(.gps) ? 
                           (state.telemetry.latitude != nil ? "\(String(format: "%.4f", state.telemetry.latitude!)), \(String(format: "%.4f", state.telemetry.longitude!)) (\(Int(state.telemetry.velocity))kmh)" : "INITIALIZING...") : 
                           "OFF"
                )
                
                // MOTION Button
                environmentStatusButton(
                    type: .motion,
                    icon: "figure.walk",
                    label: "VELOCITY",
                    value: state.telemetry.activeSensors.contains(.motion) ? "\(Int(state.telemetry.velocity)) km/h" : "OFF"
                )
                
                // LIGHT Button
                environmentStatusButton(
                    type: .light,
                    icon: "sun.max.fill",
                    label: "LIGHT",
                    value: state.telemetry.activeSensors.contains(.light) ? "\(state.telemetry.lightLevel) (\(String(format: "%.1f", state.telemetry.lightValue)))" : "OFF"
                )
                
                // SOUND Button
                environmentStatusButton(
                    type: .sound,
                    icon: "waveform",
                    label: "SOUND",
                    value: state.telemetry.activeSensors.contains(.sound) ? "\(Int(state.telemetry.decibels))dB" : "OFF"
                )
                
                // WEATHER Button
                environmentStatusButton(
                    type: .weather,
                    icon: "cloud.sun.fill",
                    label: "WEATHER",
                    value: state.telemetry.activeSensors.contains(.weather) ? state.telemetry.weather : "OFF"
                )
            }
        }
    }
    
    private func environmentStatusButton(type: SensorType, icon: String, label: String, value: String) -> some View {
        let isActive = state.telemetry.activeSensors.contains(type)
        
        return Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                state.toggleEnvironmentSensor(type)
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 8))
                    .foregroundColor(isActive ? ThemeColors.neonGreen : .gray)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(label)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(value)
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(isActive ? .white : .gray.opacity(0.5))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isActive ? Color.white.opacity(0.05) : Color.white.opacity(0.02))
            .border(isActive ? ThemeColors.neonGreen.opacity(0.3) : Color.white.opacity(0.1), width: 1)
        }
        .buttonStyle(.plain)
    }

    private var v3Header: some View {
        HStack(spacing: 0) {
            Text(appState.username.uppercased())
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ThemeColors.secondaryAccent)
            
            v3EnvironmentStatusBar
                .padding(.leading, 8)
        }
        .padding(.horizontal, 5)
        .padding(.top, 10)
    }

    private var v3RecommendationSelector: some View {
        let recs = state.recommendations.prefix(4)
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // LOCATION STATUS CARD (Conditional: Only show when OFF)
                if !appState.isLocationTrackingEnabled {
                    locationStatusCard
                }

                // LOADING/EMPTY PLACEHOLDERS
                if state.isFetchingData || state.recommendations.isEmpty {
                    recommendationLoadingPlaceholders
                }

                ForEach(Array(recs.enumerated()), id: \.1.id) { index, rec in
                    let isSelected = state.selectedRecommendationIndex == index && !state.isTextInputMode
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            state.selectedRecommendationIndex = index
                            state.selectedPatternIndex = 0
                            state.isTextInputMode = false
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: CategoryUI.icon(for: rec.place_id))
                                .font(.system(size: 18))
                                .frame(width: 24, height: 24, alignment: .leading)
                                .foregroundColor(isSelected ? .black : .white)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(rec.place_id.uppercased())
                                    .font(.system(size: 16, weight: .black))
                                Text((rec.grounding ?? "").uppercased())
                                    .font(.system(size: 8, weight: .bold))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .opacity(0.6)
                            }
                            .foregroundColor(isSelected ? .black : .white)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Rectangle().fill(isSelected ? Color.black : Color.white.opacity(0.3)).frame(height: 1)
                                
                                HStack {
                                    Text("CONFIDENCE")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.2f", rec.confidence))
                                        .font(.system(size: 14, weight: .black, design: .monospaced))
                                        .foregroundColor(isSelected ? .black : .white)
                                }
                            }
                        }
                        .padding(12)
                        .frame(width: 140, height: 130, alignment: .leading)
                        .background(isSelected ? Color.white : Color(white: 0.08))
                        .border(isSelected ? Color.cyan : Color.white.opacity(0.1), width: 1)
                    }
                    .buttonStyle(.plain)
                }
                
                // VERTICAL DIVIDER
                Rectangle()
                    .fill(ThemeColors.neonGreen)
                    .frame(width: 3, height: 130)
                    .padding(.leading, 16)
                    .padding(.trailing, 4)
                
                cameraActionCard
                textActionCard
            }
            .padding(.horizontal, 16)
        }
    }

    private var locationStatusCard: some View {
        Button(action: {
            withAnimation { selectedTab = .settings }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24, alignment: .leading)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("LOCATION")
                        .font(.system(size: 16, weight: .black))
                    Text("LOC: OFF")
                        .font(.system(size: 8, weight: .bold))
                        .opacity(0.6)
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding(12)
            .frame(width: 140, height: 130, alignment: .leading)
            .background(Color.red)
            .border(Color.white.opacity(0.1), width: 1)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var recommendationLoadingPlaceholders: some View {
        ForEach(0..<2, id: \.self) { _ in
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24, alignment: .leading)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    CyberSkeleton(width: 80, height: 16)
                    CyberSkeleton(width: 40, height: 8)
                        .opacity(0.6)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
                    
                    HStack {
                        Text("CONFIDENCE")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.gray)
                        Spacer()
                        CyberSkeleton(width: 30, height: 14)
                    }
                }
            }
            .padding(12)
            .frame(width: 140, height: 130, alignment: .leading)
            .background(Color(white: 0.08))
            .border(Color.white.opacity(0.1), width: 1)
            .opacity((state.isFetchingData && shimmerPhase) ? 1.0 : 0.5)
        }
    }

    private var cameraActionCard: some View {
        Button(action: {
            PermissionsService.shared.ensureCameraAccess { if $0 { state.showingCamera = true } }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24, alignment: .leading)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("CAMERA")
                        .font(.system(size: 16, weight: .black))
                    Text("MKPY")
                        .font(.system(size: 8, weight: .bold))
                        .opacity(0.6)
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding(12)
            .frame(width: 140, height: 130, alignment: .leading)
            .background(Color(white: 0.08))
            .border(Color.white.opacity(0.1), width: 1)
        }
        .buttonStyle(.plain)
    }

    private var textActionCard: some View {
        Button(action: {
            withAnimation { state.isTextInputMode = true }
            state.loadNearbyPlaces() // Auto-load nearby when entering text mode
        }) {
            let isTextSelected = state.isTextInputMode
            
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24, alignment: .leading)
                    .foregroundColor(isTextSelected ? .black : .white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("TEXT")
                        .font(.system(size: 16, weight: .black))
                    Text("MKPY")
                        .font(.system(size: 8, weight: .bold))
                        .opacity(0.6)
                }
                .foregroundColor(isTextSelected ? .black : .white)
                
                Spacer()
            }
            .padding(12)
            .frame(width: 140, height: 130, alignment: .leading)
            .background(isTextSelected ? Color.white : Color(white: 0.08))
            .border(isTextSelected ? Color.cyan : Color.white.opacity(0.1), width: 1)
        }
        .buttonStyle(.plain)
    }

    private var v3MainSentenceModule: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .leading) {
                if state.isTextInputMode {
                    v3ManualTextInputMode
                } else {
                    v3StandardPatternMode
                }
            }
            .frame(minHeight: 120, alignment: .leading)
            
            if !state.isTextInputMode {
                v3GradientDivider
            }
        }
    }

    private var v3ManualTextInputMode: some View {
        VStack(alignment: .leading, spacing: 12) {
           HStack {
               Text(">")
                   .font(.system(size: 32, weight: .black, design: .monospaced))
                   .foregroundColor(.cyan)
                   .padding(.leading, 5)
                HStack(spacing: 8) {
                   TextField("WHERE ARE YOU?", text: $state.manualInputText)
                       .font(.system(size: 32, weight: .black, design: .monospaced))
                       .foregroundColor(.white)
                       .submitLabel(.go)
                       .onSubmit { state.submitManualDiscovery() }
                   
                   // ✅ Whisper Mic Button
                   Button(action: { state.toggleVoiceInput() }) {
                       Image(systemName: state.isRecordingVoice ? "mic.fill" : "mic")
                           .font(.system(size: 24, weight: .bold))
                           .foregroundColor(state.isRecordingVoice ? .cyan : .white)
                           .padding(8)
                           .background(state.isRecordingVoice ? Color.white.opacity(0.1) : Color.clear)
                           .clipShape(Circle())
                   }
                   .padding(.trailing, 10)
               }
           }
           .padding(.bottom, 8)
           
           HStack(spacing: 12) {
               Button(action: { state.submitManualDiscovery() }) {
                   Text("DISCOVER")
                       .font(.system(size: 14, weight: .black))
                       .foregroundColor(.black)
                       .padding(.horizontal, 20)
                       .padding(.vertical, 10)
                       .background(ThemeColors.secondaryAccent)
               }
               .padding(.leading, 5)
               
           }
        }
        .padding(.top, 24)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var v3StandardPatternMode: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Target Sentence Section (Fixed Height)
            v3TargetSentenceSection
            
            Spacer(minLength: 16)
            
            // 2. Unified Brick Scroll Section (Fixed Height)
            v3UnifiedBrickScrollSection
        }
    }

    private var v3TargetSentenceSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if state.isFetchingData {
                Text(loadingMessages[loadingStatusIndex])
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .id("loading_text_\(loadingStatusIndex)")
                    .transition(.opacity)
                    .onAppear { startTextRotation() }
                    .onDisappear {
                        loadingTimer?.invalidate()
                        loadingTimer = nil
                    }
            } else if state.recommendations.isEmpty {
                Button(action: { state.discover() }) {
                    Text(LanguageManager.shared.ui.tapToGetMoments.uppercased())
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(ThemeColors.secondaryAccent)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                }
            } else {
                Text(state.activePattern?.target ?? "SELECT A MOMENT")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(height: 90, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var v3UnifiedBrickScrollSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if state.isFetchingData || state.recommendations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 4) {
                                CyberSkeleton(width: 40, height: 8)
                                CyberSkeleton(width: 80, height: 14)
                                CyberSkeleton(width: 50, height: 8)
                            }
                            .padding(12)
                            .frame(height: 70)
                            .background(Color.white.opacity(0.05))
                            .border(Color.white.opacity(0.1), width: 1)
                        }
                    }
                }
                .opacity((state.isFetchingData || state.recommendations.isEmpty) && shimmerPhase ? 1.0 : 0.5)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(state.activeBricks) { brick in
                            v3UnifiedBrickCard(brick: brick)
                        }
                    }
                }
            }
        }
        .frame(height: 80, alignment: .leading)
    }
    
    private var v3GradientDivider: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, ThemeColors.secondaryAccent.opacity(1.0)]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 2)
    }

    private var v3NearbyModule: some View {
        HStack(spacing: 5) {
            v3NearbyHeader
            v3NearbyContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true) // Allow to grow vertically
    }
    
    private var v3NearbyHeader: some View {
        VStack(spacing: 0) {
            Button(action: { state.loadNearbyPlaces() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)
                    .background(ThemeColors.neonGreen)
            }
            .buttonStyle(.plain)
            
            VerticalHeading(
                text: LanguageManager.shared.ui.nearbyLabel,
                textColor: .black,
                backgroundColor: ThemeColors.neonGreen,
                width: 20
            )
            .frame(maxHeight: .infinity) // Grow to fill
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private var v3NearbyContent: some View {
        if !state.appState.isLocationTrackingEnabled {
            ZStack {
                Color.black
                Text(LanguageManager.shared.ui.locationOff)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .border(Color.white.opacity(0.1), width: 1)
        } else if state.isNearbyLoading {
            ZStack {
                Color.black
                ProgressView().tint(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .border(Color.white.opacity(0.1), width: 1)
        } else if state.nearbyPlaces.isEmpty {
            ZStack {
                Color.black
                Text(LanguageManager.shared.ui.noNearbyPlaces.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .border(Color.white.opacity(0.1), width: 1)
        } else {
            v3NearbyPlacesGrid
        }
    }
    
    private var v3NearbyPlacesGrid: some View {
        JustifiedBrickGrid(data: state.nearbyPlaces, rows: 10, spacing: 8) { p in
            Button(action: { state.selectNearbyPlace(name: p.name, category: p.category) }) {
                nearbyPlaceLabel(name: p.name, category: p.category)
            }
            .frame(height: 38) // Fixed row height for consistency
        }
        .padding(.horizontal, 8)
        .background(Color.black)
        .border(Color.white.opacity(0.1), width: 1)
    }

    private func nearbyPlaceLabel(name: String, category: String?) -> some View {
        HStack(spacing: 4) {
            Text(name.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            if let cat = category, !cat.isEmpty {
                Text("[\(cat.uppercased())]")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(ThemeColors.neonGreen)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.1))
        .border(Color.white.opacity(0.1), width: 1)
    }

    private var v3PatternProgressionModule: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LanguageManager.shared.ui.currentlyLearning.uppercased())
                .font(.system(size: 25, weight: .black))
                .foregroundColor(.gray.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 8) {
                if state.isFetchingData || (state.activeRecommendation?.patterns ?? []).isEmpty {
                    v3PatternProgressionSkeletons
                } else {
                    v3PatternProgressionList
                }
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var v3PatternProgressionSkeletons: some View {
        ForEach(0..<3, id: \.self) { index in
            HStack(spacing: 5) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 3)
                    .padding(.vertical, 6)
                
                VStack(alignment: .leading, spacing: 6) {
                    CyberSkeleton(width: 80, height: 10)
                        .opacity(0.6)
                    CyberSkeleton(width: 150, height: 18)
                }
                .padding(.vertical, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity((state.isFetchingData && shimmerPhase) ? 1.0 : 0.5)
        }
    }
    
    @ViewBuilder
    private var v3PatternProgressionList: some View {
        let patterns = state.activeRecommendation?.patterns ?? []
        ForEach(0..<patterns.count, id: \.self) { index in
            let p = patterns[index]
            let isSelected = state.selectedPatternIndex == index
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    state.selectedPatternIndex = index
                }
            }) {
                HStack(spacing: 5) {
                    Rectangle()
                        .fill(isSelected ? ThemeColors.neonGreen : Color.clear)
                        .frame(width: 3)
                        .padding(.vertical, 6)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SENTENCE 0\(index + 1)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
                        
                        Text(p.meaning ?? "---")
                            .font(.system(size: isSelected ? 16 : 14, weight: isSelected ? .black : .bold))
                            .foregroundColor(isSelected ? .black : .gray)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.white : Color.clear)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    .padding(.vertical, 6)
                    .offset(x: isSelected ? 10 : 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }

    private var v3ActionModule: some View {
        Button(action: {
            state.startPractice()
        }) {
            ZStack {
                if state.isFetchingData || state.recommendations.isEmpty {
                    CyberSkeleton(width: 60, height: 110)
                        .opacity(shimmerPhase ? 0.6 : 0.3)
                } else {
                    // TEXT centered in the column
                    Text("START PRACTICE")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                        .fixedSize()
                        .rotationEffect(.degrees(-90))
                        .frame(width: 60, height: 110)
                }
                
                // ARROWS pinned to top and bottom edges
                VStack {
                    DoubleArrowButton(
                        direction: .down,
                        color: .white,
                        size: 16,
                        spacing: -4,
                        action: {}
                    )
                    .foregroundColor(.white)
                    .tint(.white)
                    .allowsHitTesting(false)
                    .padding(.vertical, -12)
                    
                    Spacer()
                    
                    DoubleArrowButton(
                        direction: .up,
                        color: .white,
                        size: 16,
                        spacing: -4,
                        action: {}
                    )
                    .foregroundColor(.white)
                    .tint(.white)
                    .allowsHitTesting(false)
                    .padding(.vertical, -12)
                }
            }
            .frame(width: 60)
            .frame(maxHeight: .infinity)
            .background(ThemeColors.secondaryAccent)
            .border(Color.white.opacity(0.1), width: 1)
            .clipped() // Prevents components from ever bleeding outside the pink area
        }
        .buttonStyle(ActionPressStyle())
    }

    private func v3UnifiedBrickCard(brick: RecommendationBrickItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(brick.meaning.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            
            Text(brick.word.uppercased())
                .font(.system(size: 14, weight: .black))
                .foregroundColor(ThemeColors.neonGreen)
            
            if let phonetic = brick.phonetic, !phonetic.isEmpty {
                Text(phonetic)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .border(Color.white.opacity(0.1), width: 1)
    }

    private var v3HistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if state.isFetchingData || state.recommendations.isEmpty {
                    CyberSkeleton(width: 200, height: 14)
                        .opacity(shimmerPhase ? 0.6 : 0.3)
                } else {
                    Text("\(LanguageManager.shared.ui.previouslyPracticed) — \(state.activeRecommendation?.place_id.uppercased() ?? "N/A")")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.black)
                }
                Spacer()
                if state.isFetchingData || state.recommendations.isEmpty {
                    CyberSkeleton(width: 50, height: 8)
                        .opacity(shimmerPhase ? 0.6 : 0.3)
                } else {
                    Text(LanguageManager.shared.ui.historyStrength)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background((state.isFetchingData || state.recommendations.isEmpty) ? ThemeColors.primaryAccent.opacity(0.3) : ThemeColors.primaryAccent)
            
            VStack(spacing: 1) {
                if state.isFetchingData || state.recommendations.isEmpty {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack {
                            Rectangle().fill(Color.white.opacity(0.1)).frame(width: 6, height: 6)
                            CyberSkeleton(width: 120, height: 12)
                            Spacer()
                            CyberSkeleton(width: 40, height: 10)
                        }
                        .padding(.vertical, 12)
                        .opacity(shimmerPhase ? 0.8 : 0.4)
                    }
                } else {
                    HistoryRow(text: "COFFEE PLEASE.", strength: "100%")
                    HistoryRow(text: "CAN I SEE THE MENU?", strength: "87%")
                    HistoryRow(text: "TWO COFFEES PLEASE.", strength: "64%")
                }
            }
            .padding(.bottom, 16)
        }
    }

    private var locationWarningBanner: some View {
        Button(action: {
            withAnimation { selectedTab = .settings }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.black)
                
                Text(LanguageManager.shared.ui.locationAccessRequired)
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.red)
        }
        .buttonStyle(.plain)
    }

    private func startTextRotation() {
        loadingTimer?.invalidate()
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                loadingStatusIndex = (loadingStatusIndex + 1) % loadingMessages.count
            }
        }
    }

    private func HistoryRow(text: String, strength: String) -> some View {
        HStack {
            Rectangle().fill(Color.yellow).frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text(strength)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .border(Color.white.opacity(0.05), width: 0.5)
    }


    private func CyberSkeleton(width: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.2))
            .frame(width: width, height: height)
    }

    
    private var scrollOffsetTracker: some View {
        GeometryReader { geo in
            Color.clear.preference(key: LearnViewOffsetKey.self, value: geo.frame(in: .named("learnPullToRefresh")).minY)
        }.frame(height: 0)
    }
    
    private func handleRefresh(offset: CGFloat) {
        scrollOffset = offset
        let threshold: CGFloat = 80 // Distance needed to trigger
        
        // Prevent triggering while already loading
        guard pullRefreshState != .loading && pullRefreshState != .finishing else { return }
        
        if offset > threshold {
            if pullRefreshState != .loading {
                pullRefreshState = .loading
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                
                // Trigger AI discovery manually
                state.discover()
                
                // Custom reset delay mimicking the StatsTab behavior
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        pullRefreshState = .finishing
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        pullRefreshState = .idle
                    }
                }
            }
        } else if offset > 0 {
            // Track pulling progress (0.0 to 1.0)
            let progress = min(offset / threshold, 1.0)
            pullRefreshState = .pulling(progress: progress)
        } else {
            pullRefreshState = .idle
        }
    }
}

struct LearnViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
