//
//  RoutineModalView.swift
//  locian
//
//  Routine Setup Modal UI
//

import SwiftUI

struct RoutineModalView: View {
    @ObservedObject var appState: AppStateManager
    @Binding var isPresented: Bool
    @Binding var selectedPlaces: [Int: String]
    @State private var localSelections: [Int: String] = [:]
    

    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            CyberGridBackground().opacity(0.1).ignoresSafeArea()
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
                    LazyVStack(alignment: .leading, spacing: 40) { 
                        ForEach(0..<24, id: \.self) { hr in row(hr) } 
                    }
                    .diagnosticBorder(.cyan.opacity(0.2), width: 1, label: "CYBER_LIST")
                    .padding(.vertical, 32).padding(.horizontal, 16) 
                }
                VStack(spacing: 12) { 
                    Rectangle().fill(Color.cyan.opacity(0.3)).frame(height: 1)
                    

                    
                    // Always show button

                        LocianButton(
                            action: { 
                                selectedPlaces = localSelections
                                isPresented = false
                            }, 
                            backgroundColor: .pink, 
                            foregroundColor: .white, 
                            fullWidth: true
                        ) { 
                            Text("S A V E   R O U T I N E")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .padding(.vertical, 8)
                        }
                        .diagnosticBorder(.pink, width: 1)

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
        HStack(alignment: .top, spacing: 20) {
            // Left Column: Time + Current Selection
            VStack(alignment: .leading, spacing: 12) {
                Text(String(format: "%02d:00", hr))
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.cyan)
                
                if let selectedPlace = localSelections[hr] {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACTIVE_NODE")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                        Text(selectedPlace.uppercased())
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(ThemeColors.getColor(for: "Neon Green"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(width: 90, alignment: .leading)
            
            // Right Column: Options & Input
            VStack(alignment: .leading, spacing: 12) {
                let places = UserRoutineManager.getPlaces(for: appState.profession, hour: hr)
                if !places.isEmpty {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(places, id: \.self) { p in
                            Button(action: { 
                                localSelections[hr] = (localSelections[hr] == p ? nil : p) 
                            }) {
                                Text(p.uppercased())
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(localSelections[hr] == p ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(localSelections[hr] == p ? ThemeColors.getColor(for: "Neon Green") : Color.black)
                                    .overlay(Rectangle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                CustomPlaceInput(hour: hr, localSelections: $localSelections)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.5))
        .overlay(
            Rectangle()
                .fill(Color.cyan.opacity(0.1))
                .frame(width: 2)
                .padding(.vertical, 8),
            alignment: .leading
        )
    }
}

// Custom place input component
struct CustomPlaceInput: View {
    let hour: Int
    @Binding var localSelections: [Int: String]
    @State private var customText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Text input field
            HStack(spacing: 8) {
                Text("+")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(ThemeColors.getColor(for: "Neon Green"))
                
                TextField("ADD NEW NODE", text: $customText)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.characters)
                    .focused($isFocused)
                    .onSubmit {
                        addCustomPlace()
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.black)
            .overlay(Rectangle().stroke(Color.white.opacity(0.2), lineWidth: 1))
            
            // Plus button to add
            Button(action: {
                addCustomPlace()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(customText.isEmpty ? .gray : ThemeColors.getColor(for: "Neon Green"))
            }
            .disabled(customText.isEmpty)
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }
    
    private func addCustomPlace() {
        guard !customText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        localSelections[hour] = customText.trimmingCharacters(in: .whitespaces)
        customText = ""
        isFocused = false
    }
}

// Triangle shape for arrow notch
struct TimelineArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
