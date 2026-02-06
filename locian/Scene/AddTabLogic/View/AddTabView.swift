//
//  AddTabView.swift
//  locian
//
//  Consolidated Add Tab UI (Single File UI)
//

import SwiftUI
import CoreLocation

struct AddTabView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var state: AddTabState
    @Binding var selectedTab: MainTabView.TabItem
    
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var selectedImage: UIImage? = nil
    @State private var isImageSelected = false
    @State private var showingRoutineModal = false
    @State private var animateIn = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 20)
                .background(Color.black)
                .diagnosticBorder(.purple, width: 2, label: "HDR")
                .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 10)
                .zIndex(2)
            
            Spacer().frame(height: 8) // TIGHTENED from 15
            
            ZStack(alignment: .top) {
                if state.scrollOffset > 0 || state.pullRefreshState == .loading || state.pullRefreshState == .finishing {
                    CyberRefreshIndicator(state: state.pullRefreshState, height: max(60, state.scrollOffset), accentColor: ThemeColors.secondaryAccent).zIndex(0)
                }
                
                // Divider line before scrolling content
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 48) { // Increased from 24 to 48
                        // timelineSection removed - user doesn't need next/previous routine display
                        // .diagnosticBorder(.pink, width: 1, label: "TIMELINE")
                        textInputSection
                            .diagnosticBorder(.cyan, width: 1, label: "INPUT")
                        suggestedPlacesView
                            .diagnosticBorder(.white.opacity(0.3), width: 1, label: "SUGGESTED")
                        imageActionsSection
                            .diagnosticBorder(.green.opacity(0.3), width: 1, label: "IMAGES")
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20) // Add space from header
                    .diagnosticBorder(.white.opacity(0.2), width: 1.5, label: "SEC_V_S:48")
                    .background(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(scrollOffsetTracker, alignment: .top)
                }
                .diagnosticBorder(.cyan, width: 2)
                .coordinateSpace(name: "addTabScroll")
                .zIndex(1)
                .onPreferenceChange(AddTabViewOffsetKey.self) { state.handlePullToRefresh(offset: $0) }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .fullScreenCover(isPresented: $showingCamera) { cameraPicker }
        .fullScreenCover(isPresented: $showingGallery) { galleryPicker }
        .fullScreenCover(isPresented: $showingRoutineModal) { routineModal }
        .onAppear { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animateIn = true } }
        .onDisappear { animateIn = false }
        .onChange(of: selectedTab) { _, n in if n == .add { animateIn = false; DispatchQueue.main.asyncAfter(deadline: .now()+0.05) { withAnimation(.spring()) { animateIn = true } } } }
    }

    // MARK: - Sections
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            AddProfileHeader(appState: appState)
            AddRoutineHeader(appState: appState, showingRoutineModal: $showingRoutineModal, selectedPlaces: $state.routineSelections) { state.startRoutine(); switchToLearnTab() }
        }
        .diagnosticBorder(.white, width: 1)
    }

    private var timelineSection: some View {
        AddTimelineHeader(selectedPlaces: $state.routineSelections)
            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
            .animation(.spring().delay(0.1), value: animateIn)
            .diagnosticBorder(.pink, width: 1)
    }

    private var textInputSection: some View {
        TextInputSection(customPlaceText: $state.customPlaceText) { state.handleTextStart(); switchToLearnTab() }
            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
            .animation(.spring().delay(0.15), value: animateIn)
            .diagnosticBorder(.cyan, width: 1)
    }

    private var suggestedPlacesView: some View {
        SuggestedPlacesView(appState: appState, customPlaceText: $state.customPlaceText, refreshId: state.refreshId) { state.selectSuggestedPlace($0); switchToLearnTab() }
            .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
            .animation(.spring().delay(0.2), value: animateIn)
            .diagnosticBorder(.white.opacity(0.3), width: 1)
    }

    private var imageActionsSection: some View {
        HStack(spacing: 4) {
             VerticalHeading(
                 text: LocalizationManager.shared.string(.imagesLabel),
                 textColor: .black,
                 backgroundColor: ThemeColors.secondaryAccent,
                 width: 20,
                 height: 130 // Increased from 100 to 130 to match Title + Button height
             )
             .diagnosticBorder(.black.opacity(0.5), width: 0.5)
             HStack(spacing: 16) {
                actionButton(title: LocalizationManager.shared.string(.cameraLabel).uppercased(), icon: "camera.fill", color: .cyan) { PermissionsService.ensureCameraAccess { if $0 { showingCamera = true } } }
                    .diagnosticBorder(.cyan, width: 0.5)
                actionButton(title: LocalizationManager.shared.string(.galleryLabel).uppercased(), icon: "square.grid.2x2.fill", color: .pink) { PermissionsService.ensurePhotoLibraryAccess { if $0 { showingGallery = true } } }
                    .diagnosticBorder(.pink, width: 0.5)
             }.padding(.horizontal, 8)
                .diagnosticBorder(.white.opacity(0.1), width: 1, label: "ACT_HS_P:H8")
        }.padding(.leading, 2)
        .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
        .animation(.spring().delay(0.25), value: animateIn)
        .diagnosticBorder(.green.opacity(0.3), width: 1, label: "IMG_HS_P:L2")
    }

    // MARK: - Components
    private var routineLockedChallenge: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill").font(.system(size: 16)).foregroundColor(.white.opacity(0.3))
            VStack(alignment: .leading, spacing: 4) {
                Text("LOCKED FEATURE: ROUTINES").font(.system(size: 9, weight: .heavy)).foregroundColor(ThemeColors.secondaryAccent).tracking(1)
                    .diagnosticBorder(.orange, width: 0.5)
                Text("BUILD ROUTINES WITH \(min(state.maxCurrentStreak, 3))/3 DAY STREAK").font(.system(size: 11, weight: .black, design: .monospaced)).foregroundColor(.white.opacity(0.8))
                    .diagnosticBorder(.white.opacity(0.5), width: 0.5)
            }
            .diagnosticBorder(.gray.opacity(0.3), width: 1)
        }
        .diagnosticBorder(.white.opacity(0.1), width: 1)
        .padding(.vertical, 14).padding(.horizontal, 16).frame(maxWidth: .infinity, alignment: .leading).background(Color.white.opacity(0.03)).padding(.horizontal, 16).padding(.top, 12)
    }

    @ViewBuilder
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.gray)
            Button(action: action) {
                ZStack {
                    Rectangle().fill(Color.black.opacity(0.3)).overlay(Rectangle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    Image(systemName: icon).font(.system(size: 32, weight: .bold)).foregroundColor(color)
                    cornerDots
                }
                .diagnosticBorder(.white.opacity(0.1), width: 0.5)
                .frame(width: 100, height: 100)
            }.buttonStyle(ScaleButtonStyle())
        }
        .diagnosticBorder(.gray.opacity(0.5), width: 1)
    }

    private var cornerDots: some View {
        VStack {
            HStack { dotPair(Color.gray.opacity(0.4)); Spacer() }.padding(6)
                .diagnosticBorder(.white.opacity(0.2), width: 0.5)
            Spacer()
            HStack { Spacer(); dotPair(Color.gray.opacity(0.4)) }.padding(6)
                .diagnosticBorder(.white.opacity(0.2), width: 0.5)
        }
        .diagnosticBorder(.white.opacity(0.1), width: 0.5)
    }

    private func dotPair(_ color: Color) -> some View {
        HStack(spacing: 2) { Rectangle().fill(color).frame(width: 3, height: 3); Rectangle().fill(color).frame(width: 3, height: 3) }
            .diagnosticBorder(.white.opacity(0.3), width: 0.5)
    }

    private var cameraPicker: some View { ImagePicker(sourceType: .camera, selectedImage: $selectedImage, isImageSelected: $isImageSelected) { if let i = selectedImage { state.handleImageSelection(i, source: .camera); switchToLearnTab() } } }
    private var galleryPicker: some View { ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, isImageSelected: $isImageSelected) { if let i = selectedImage { state.handleImageSelection(i, source: .gallery); switchToLearnTab() } } }
    private var routineModal: some View { RoutineModalView(appState: appState, isPresented: $showingRoutineModal, selectedPlaces: $state.routineSelections) }
    private var scrollOffsetTracker: some View { GeometryReader { geo in Color.clear.preference(key: AddTabViewOffsetKey.self, value: geo.frame(in: .named("addTabScroll")).minY) }.frame(height: 0) }
    private func switchToLearnTab() { withAnimation { selectedTab = .learn } }
}

// MARK: - SubViews
struct AddProfileHeader: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            if !appState.profession.isEmpty {
                Text(localizationManager.getLocalizedProfession(appState.profession)).font(.system(size: 18, weight: .black)).foregroundColor(.white).padding(.horizontal, 16).padding(.vertical, 8).background(ThemeColors.secondaryAccent)
                    .diagnosticBorder(.white, width: 1)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .diagnosticBorder(.blue, width: 1)
    }
}

struct AddRoutineHeader: View {
    @ObservedObject var appState: AppStateManager
    @Binding var showingRoutineModal: Bool
    @Binding var selectedPlaces: [Int: String]
    var onStart: () -> Void
    var body: some View {
        let hr = Calendar.current.component(.hour, from: Date())
        VStack(alignment: .leading, spacing: 10) {
            if let p = selectedPlaces[hr] {
                Button(action: onStart) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Image(systemName: "hand.tap.fill"); Text("Tap to Start Learning") }.font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.5))
                            .diagnosticBorder(.gray, width: 0.5)
                        LocianSmartHeader(text: p.uppercased(), fontSize: 35.5, maxLines: 3, textColor: .white, shadowColor: .gray, scale: 1.0)
                            .diagnosticBorder(.white, width: 1)
                    }
                    .diagnosticBorder(.blue, width: 1.5)
                    .padding(.horizontal, 16).padding(.vertical, 12)
                }.buttonStyle(PlainButtonStyle())
            } else {
                Button(action: { showingRoutineModal = true }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Image(systemName: "hand.tap.fill"); Text("Tap to Setup") }.font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.5))
                            .diagnosticBorder(.gray, width: 0.5)
                        LocianSmartHeader(text: "ADD ROUTINE", fontSize: 35.5, maxLines: 3, textColor: .white, shadowColor: .gray, scale: 1.0)
                            .diagnosticBorder(.white, width: 1)
                    }
                    .diagnosticBorder(.orange, width: 1.5)
                    .padding(.horizontal, 16).padding(.vertical, 12)
                }.buttonStyle(PlainButtonStyle())
            }
            
            // Only show Edit Routine button if user has at least one routine set
            if !selectedPlaces.isEmpty {
                ZStack { Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1); Button(action: { showingRoutineModal = true }) { Text("EDIT ROUTINE").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.black).padding(.horizontal, 12).padding(.vertical, 4).background(ThemeColors.primaryAccent) } }
                    .diagnosticBorder(.white.opacity(0.2), width: 1)
            }
        }
        .diagnosticBorder(.pink.opacity(0.3), width: 2)
        .padding(.top, 10).padding(.trailing, 16)
    }
}

struct AddTimelineHeader: View {
    @Binding var selectedPlaces: [Int: String]
    var body: some View {
        let hr = Calendar.current.component(.hour, from: Date())
        let p = selectedPlaces[(hr-1+24)%24]; let n = selectedPlaces[(hr+1)%24]
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                row("PREVIOUS", p ?? "ADD ROUTINE").opacity(p==nil ? 0.5 : 1)
                    .diagnosticBorder(.purple.opacity(0.5), width: 1)
                Divider().background(Color.white.opacity(0.1))
                row("NEXT", n ?? "ADD ROUTINE").opacity(n==nil ? 0.5 : 1)
                    .diagnosticBorder(.pink.opacity(0.5), width: 1)
            }
            .diagnosticBorder(.white.opacity(0.2), width: 1)
            .padding(.horizontal, 16).padding(.vertical, 15)
            Divider().background(Color.white.opacity(0.1))
        }
        .diagnosticBorder(.cyan.opacity(0.3), width: 1)
        .padding(.trailing, 16)
    }
    private func row(_ l: String, _ p: String) -> some View {
        VStack(alignment: .leading, spacing: 4) { 
            Text(l).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.white.opacity(0.4))
                .diagnosticBorder(.gray, width: 0.5)
            Text(p.uppercased()).font(.system(size: 16, weight: .bold)).foregroundColor(.white.opacity(0.6)).lineLimit(1).minimumScaleFactor(0.4) 
                .diagnosticBorder(.white, width: 0.5)
        }.frame(maxWidth: .infinity, alignment: .leading)
            .diagnosticBorder(.cyan, width: 1)
    }
}

struct TextInputSection: View {
    @Binding var customPlaceText: String; var onStart: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.string(.whatAreYouDoing)).font(.system(size: 10, weight: .bold)).foregroundColor(.black).padding(.horizontal, 8).padding(.vertical, 4).background(Color.white)
                .diagnosticBorder(.white, width: 0.5)
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.black).overlay(Rectangle().stroke(Color.cyan, lineWidth: 1))
                        .diagnosticBorder(.cyan.opacity(0.3), width: 0.5)
                    HStack(spacing: 8) {
                        Text(">").font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(.cyan)
                            .diagnosticBorder(.cyan, width: 0.5)
                        ZStack(alignment: .leading) {
                            if customPlaceText.isEmpty { Text(LocalizationManager.shared.string(.typeHere)).font(.system(size: 14)).foregroundColor(.white.opacity(0.3)) }
                            TextField("", text: $customPlaceText).font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(.white).accentColor(.cyan)
                                .diagnosticBorder(.cyan.opacity(0.5), width: 0.5)
                        }
                        .diagnosticBorder(.white.opacity(0.1), width: 1)
                    }
                    .diagnosticBorder(.cyan.opacity(0.2), width: 1)
                    .padding(.horizontal, 16)
                }
                .diagnosticBorder(.cyan.opacity(0.1), width: 1)
                .frame(height: 60)
                Button(action: onStart) { Text(LocalizationManager.shared.string(.start).uppercased()).font(.system(size: 16, weight: .black, design: .monospaced)).foregroundColor(.black).frame(width: 110, height: 60).background(ThemeColors.secondaryAccent) }
                    .buttonStyle(ScaleButtonStyle())
                    .diagnosticBorder(ThemeColors.secondaryAccent, width: 1)
            }
            .diagnosticBorder(.white.opacity(0.2), width: 1)
        }.padding(.trailing, 16).padding(.leading, 2)
            .diagnosticBorder(.white.opacity(0.3), width: 1)
    }
}

struct SuggestedPlacesView: View {
    @ObservedObject var appState: AppStateManager; @Binding var customPlaceText: String; var refreshId: UUID; var onSelect: (String) -> Void
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var nearbyPlaces: [String] = []
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Image(systemName: "location.fill"); Text(LocalizationManager.shared.string(.chooseContext)) }.font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.5)).padding(.bottom, 6).padding(.leading, 6)
                .diagnosticBorder(.white.opacity(0.2), width: 0.5, label: "P:B6,L6")
            
            HStack(spacing: 0) {
                VerticalHeading(
                    text: LocalizationManager.shared.string(.nearbyLabel),
                    textColor: .black,
                    backgroundColor: ThemeColors.getColor(for: "Neon Green"),
                    width: 20,
                    height: 130 // Increased to 130 as requested
                )
                .diagnosticBorder(.black, width: 0.5)
                
                // Check if location tracking is disabled in Settings
                if !appState.isLocationTrackingEnabled {
                    ZStack {
                        Color.black
                        VStack(spacing: 8) {
                            Image(systemName: "location.slash.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.3))
                            Text("LOCATION DISABLED")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Turn it on in Settings to get nearby places")
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: 130)
                        .diagnosticBorder(.white.opacity(0.1), width: 1)
                } else if isLoading {
                    ZStack {
                        Color.black
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }.frame(maxWidth: .infinity, maxHeight: 130)
                        .diagnosticBorder(.white.opacity(0.1), width: 1)
                } else if nearbyPlaces.isEmpty {
                    ZStack {
                        Color.black
                        Text(LocalizationManager.shared.string(.noNearbyPlaces))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }.frame(maxWidth: .infinity, maxHeight: 130)
                        .diagnosticBorder(.white.opacity(0.1), width: 1)
                } else {
                    HorizontalMasonryLayout(data: nearbyPlaces, rows: 3, spacing: 8, constrainedHeight: 130) { p in
                        Button(action: { onSelect(p) }) {
                            Text(p.uppercased())
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10) // Increased from 6 to 10 to fill height
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                    .padding(.horizontal, 8)
                    .background(Color.black)
                    .frame(height: 130) // Fixed height 130
                    .diagnosticBorder(.white.opacity(0.1), width: 1)
                }
            }
        }
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestPermission()
            } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                loadNearbyPlaces()
            }
        }
        .onChange(of: locationManager.authorizationStatus) { _, status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                loadNearbyPlaces()
            }
        }
        .onChange(of: refreshId) { _, _ in loadNearbyPlaces() }
    }
    
    private func loadNearbyPlaces() {
        isLoading = true
        locationManager.fetchNearbyPlaces { places in
            DispatchQueue.main.async {
                self.nearbyPlaces = places
                self.isLoading = false
            }
        }
    }
}


struct RoutineModalView: View {
    @ObservedObject var appState: AppStateManager; @Binding var isPresented: Bool; @Binding var selectedPlaces: [Int: String]
    @State private var localSelections: [Int: String] = [:]
    
    var canSave: Bool {
        let maxStreak = appState.userLanguagePairs.map { calculateStreak(practiceDates: $0.practice_dates) }.max() ?? 0
        return maxStreak > 3
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea(); CyberGridBackground().opacity(0.1).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: -5) {
                        Text("YOUR").font(.system(size: 36, weight: .heavy)).foregroundColor(.white)
                            .diagnosticBorder(.white.opacity(0.5), width: 0.5)
                        Text("ROUTINE").font(.system(size: 36, weight: .heavy)).foregroundColor(.pink)
                            .diagnosticBorder(.pink.opacity(0.5), width: 0.5)
                    }
                    .diagnosticBorder(.white.opacity(0.2), width: 1)
                    Spacer()
                    LocianButton(action: { isPresented = false }, backgroundColor: .white, foregroundColor: .black, shadowColor: .gray, shadowOffset: 4) { Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).frame(width: 32, height: 32) }
                        .diagnosticBorder(.white, width: 1)
                }
                .diagnosticBorder(.pink.opacity(0.3), width: 1.5)
                .padding().background(Color.black.opacity(0.9))
                Rectangle().fill(Color.cyan.opacity(0.3)).frame(height: 1)
                ScrollView { 
                    LazyVStack(alignment: .leading, spacing: 0) { 
                        ForEach(0..<24, id: \.self) { hr in row(hr) } 
                    }
                    .diagnosticBorder(.cyan.opacity(0.2), width: 1, label: "CYBER_LIST")
                    .padding(.vertical, 32).padding(.horizontal, 16) 
                }
                VStack { 
                    Rectangle().fill(Color.cyan.opacity(0.3)).frame(height: 1)
                    LocianButton(
                        action: { 
                            if canSave {
                                selectedPlaces = localSelections
                                isPresented = false
                            }
                        }, 
                        backgroundColor: canSave ? .pink : .gray, 
                        foregroundColor: canSave ? .white : .white.opacity(0.5), 
                        fullWidth: true
                    ) { 
                        Text(canSave ? "S A V E   R O U T I N E" : "STREAK > 3 REQUIRED")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .padding(.vertical, 8)
                    }
                    .disabled(!canSave)
                    .diagnosticBorder(canSave ? .pink : .gray, width: 1)
                }
                .diagnosticBorder(.white.opacity(0.1), width: 1)
                .padding(16)
                .background(Color.black)
            }
            .diagnosticBorder(.white, width: 2)
        }
        .onAppear {
            localSelections = selectedPlaces
        }
    }
    
    private func calculateStreak(practiceDates: [String]) -> Int {
        guard !practiceDates.isEmpty else { return 0 }
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let validDates = practiceDates.compactMap { formatter.date(from: $0) }
        guard !validDates.isEmpty else { return 0 }
        let uniqueDates = Set(validDates); let sortedDates = uniqueDates.sorted(by: >)
        let calendar = Calendar.current; let today = Date()
        guard let latestDate = sortedDates.first else { return 0 }
        let isToday = calendar.isDateInToday(latestDate)
        let isYesterday = calendar.isDate(latestDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!)
        if !isToday && !isYesterday { return 0 }
        var currentStreak = 1; var previousDate = latestDate
        for i in 1..<sortedDates.count {
            let date = sortedDates[i]
            if let expectedPrevDay = calendar.date(byAdding: .day, value: -1, to: previousDate),
               calendar.isDate(date, inSameDayAs: expectedPrevDay) {
                currentStreak += 1; previousDate = date
            } else { break }
        }
        return currentStreak
    }
    private func row(_ hr: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                HStack { 
                    Text("+").diagnosticBorder(.pink.opacity(0.5), width: 0.5)
                    Text(String(format: "%02d:00", hr)).diagnosticBorder(.pink.opacity(0.5), width: 0.5)
                }
                .diagnosticBorder(.pink, width: 1)
                .font(.system(size: 15, weight: .bold, design: .monospaced)).foregroundColor(.pink).padding(.horizontal, 8).frame(height: 28).background(Color.white)
                
                if localSelections[hr] == nil { 
                    Text("Add Routine")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.3))
                        .diagnosticBorder(.white.opacity(0.1), width: 0.5)
                }
            }
            .diagnosticBorder(.white.opacity(0.2), width: 1)
            
            HStack(alignment: .top, spacing: 20) {
                Rectangle().fill(Color.white).frame(width: 2).frame(maxHeight: .infinity).frame(width: 80)
                    .diagnosticBorder(.white, width: 0.5)
                FlowLayout(data: UserRoutineManager.getPlaces(for: appState.profession, hour: hr), spacing: 8) { p in
                    Button(action: { localSelections[hr] = (localSelections[hr] == p ? nil : p) }) {
                        Text(p.uppercased()).font(.system(size: 10, weight: .bold)).foregroundColor(localSelections[hr] == p ? .black : .gray).padding(.horizontal, 12).padding(.vertical, 8).background(localSelections[hr] == p ? Color.pink : Color.black).overlay(Rectangle().stroke(localSelections[hr] == p ? Color.pink : Color.white.opacity(0.15)))
                            .diagnosticBorder(localSelections[hr] == p ? .pink : .white.opacity(0.2), width: 0.5)
                    }.buttonStyle(.plain)
                }
                .diagnosticBorder(.cyan.opacity(0.3), width: 1)
                .padding(.top, 12).padding(.bottom, 24)
            }
            .diagnosticBorder(.white.opacity(0.1), width: 1)
        }
        .diagnosticBorder(.white.opacity(0.05), width: 1.5)
    }
}
struct AddTabViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
