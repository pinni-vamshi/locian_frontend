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
    
    var body: some View {
        mainContentStack
            .background(Color.black.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                animateIn = false
                state.discover()
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
                            if state.isFetchingData && state.recommendations.isEmpty {
                            v3LoadingState
                        } else if state.recommendations.isEmpty {
                            v3EmptyState
                        } else {
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
                                // 5. LEGO Bricks Grid
                                v3BricksGrid
                                    .padding(.top, 40)
                                    .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                    .animation(.spring().delay(0.4), value: animateIn)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                
                                // 6. History
                                v3HistorySection
                                    .padding(.top, 40)
                                    .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                    .animation(.spring().delay(0.5), value: animateIn)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            
                            // 7. Assembly Bar
                            v3AssemblyBar
                                .padding(.top, 24)
                                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
                                .animation(.spring().delay(0.6), value: animateIn)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } // closes else
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

    private var v3Header: some View {
        HStack {
            Text(appState.username.uppercased())
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ThemeColors.secondaryAccent)
            Spacer()
        }
        .padding(.horizontal, 5)
        .padding(.top, 10)
    }

    private var v3RecommendationSelector: some View {
        let recs = state.recommendations.prefix(4)
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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
                                Text("PRIMARY")
                                    .font(.system(size: 8, weight: .bold))
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
                
                // CAMERA ACTION CARD
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
                
                // TEXT ACTION CARD
                Button(action: {
                    withAnimation { state.isTextInputMode = true }
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
            .padding(.horizontal, 16)
        }
    }

    private var v3MainSentenceModule: some View {
        
        return VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .leading) {
                if state.isTextInputMode {
                    // Manual Text Input Mode
                    VStack(alignment: .leading, spacing: 12) {
                       HStack {
                           Text(">")
                               .font(.system(size: 32, weight: .black, design: .monospaced))
                               .foregroundColor(.cyan)
                               .padding(.leading, 5)
                           TextField("WHERE ARE YOU?", text: $state.manualInputText)
                               .font(.system(size: 32, weight: .black, design: .monospaced))
                               .foregroundColor(.white)
                               .submitLabel(.go)
                               .onSubmit { state.submitManualDiscovery() }
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
                           
                           Button(action: { withAnimation { state.isTextInputMode = false } }) {
                               Text("CANCEL")
                                   .font(.system(size: 14, weight: .bold))
                                   .foregroundColor(.gray)
                           }
                       }
                    }
                    .padding(.top, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    // Standard Pattern Mode
                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.activePattern?.meaning ?? "SELECT A MOMENT")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                        
                        if let target = state.activePattern?.target {
                            Text(target)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(minHeight: 120, alignment: .leading)
            
            if !state.isTextInputMode {
                v3GradientDivider
            }
        }
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
        HStack(spacing: 0) {
            VerticalHeading(
                text: "NEARBY",
                textColor: .black,
                backgroundColor: ThemeColors.neonGreen,
                width: 20,
                height: 130
            )
            
            if !state.appState.isLocationTrackingEnabled {
                ZStack {
                    Color.black
                    Text("LOCATION DISABLED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: 130)
                .border(Color.white.opacity(0.1), width: 1)
            } else if state.isNearbyLoading {
                ZStack {
                    Color.black
                    ProgressView().tint(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 130)
                .border(Color.white.opacity(0.1), width: 1)
            } else if state.nearbyPlaces.isEmpty {
                ZStack {
                    Color.black
                    Text("NO PLACES FOUND")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: 130)
                .border(Color.white.opacity(0.1), width: 1)
            } else {
                HorizontalMasonryLayout(data: state.nearbyPlaces, rows: 3, spacing: 8, constrainedHeight: 130) { p in
                    Button(action: { state.selectNearbyPlace(name: p.name, category: p.category) }) {
                        Text(p.name.uppercased())
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .frame(maxHeight: .infinity)
                            .background(Color.white.opacity(0.1))
                            .border(Color.white.opacity(0.1), width: 1)
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding(.horizontal, 8)
                .frame(height: 130)
                .background(Color.black)
                .border(Color.white.opacity(0.1), width: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var v3PatternProgressionModule: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CURRENT PATTERNS")
                .font(.system(size: 25, weight: .black))
                .foregroundColor(.gray.opacity(0.2))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    let patterns = state.activeRecommendation?.patterns ?? []
                    let p = index < patterns.count ? patterns[index] : nil
                    let isSelected = state.selectedPatternIndex == index
                    
                    Button(action: {
                        if p != nil {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                state.selectedPatternIndex = index
                            }
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
                                
                                Text(p?.target ?? "---")
                                    .font(.system(size: (isSelected && p != nil) ? 16 : 14, weight: (isSelected && p != nil) ? .black : .bold))
                                    .foregroundColor((isSelected && p != nil) ? .black : .gray)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background((isSelected && p != nil) ? Color.white : Color.clear)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .opacity(p == nil ? 0.3 : 1.0)
                            }
                            .padding(.vertical, 6)
                            .offset(x: isSelected ? 10 : 0) // Only text slides right
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .disabled(p == nil)
                }
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var v3ActionModule: some View {
        Button(action: {
            state.startPractice()
        }) {
            ZStack {
                // TEXT centered in the column
                Text("START PRACTICE")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 110)
                
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

    private var v3BricksGrid: some View {
        let pattern = state.activePattern
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                // 01 VARIABLES
                BrickColumn(
                    label: "VARIABLES",
                    items: pattern?.bricks?.variables ?? []
                )
                
                // 02 CONSTANTS
                BrickColumn(
                    label: "CONSTANTS",
                    items: pattern?.bricks?.constants ?? []
                )
                
                // 03 STRUCTURE
                BrickColumn(
                    label: "STRUCTURE",
                    items: pattern?.bricks?.structural ?? []
                )
            }
            .padding(.horizontal, 5)
        }
    }

    private var v3HistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("PREVIOUSLY PRACTICED — \(state.activeRecommendation?.place_id.uppercased() ?? "N/A")")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.black)
                Spacer()
                Text("HISTORY_STRENGTH")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ThemeColors.primaryAccent)
            
            VStack(spacing: 1) {
                HistoryRow(text: "COFFEE PLEASE.", strength: "100%")
                HistoryRow(text: "CAN I SEE THE MENU?", strength: "87%")
                HistoryRow(text: "TWO COFFEES PLEASE.", strength: "64%")
            }
            .padding(.bottom, 16)
        }
    }

    private var v3AssemblyBar: some View {
        VStack(spacing: 12) {
            if !state.isTextInputMode {
                HStack(spacing: 12) {
                    AssemblyTag(type: "s_", text: "I WOULD LIKE", color: Color.cyan)
                    AssemblyTag(type: "c_", text: "A", color: Color.white)
                    AssemblyTag(type: "v_", text: "COFFEE", color: Color.blue)
                }
            }
        }
    }
    
    private var v3LoadingState: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(.cyan)
            Text("SCANNING REALITY...")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
    
    private var v3EmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("NO REALITIES COHERENT")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            Button("RE-SCAN") {
                state.discover()
            }
            .font(.system(size: 12, weight: .black))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
            .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    // MARK: - Subviews

    private func BrickColumn(label: String, items: [RecommendationBrickItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.black)
                .frame(maxWidth: 140, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
            
            VStack(alignment: .leading, spacing: 0) {
                if items.isEmpty {
                    Text("---").foregroundColor(.gray).padding(12)
                }
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.meaning)
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                        Text(item.word)
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(ThemeColors.neonGreen)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    
                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 12)
                    }
                }
            }
            .frame(width: 140, alignment: .leading)
        }
        .frame(width: 140, height: 220, alignment: .topLeading)
        .background(Color(white: 0.05))
        .border(Color.white.opacity(0.1), width: 1)
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

    private func AssemblyTag(type: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text("[\(type)]")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color.opacity(0.8))
            Text(text.uppercased())
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .border(color.opacity(0.5), width: 1)
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
