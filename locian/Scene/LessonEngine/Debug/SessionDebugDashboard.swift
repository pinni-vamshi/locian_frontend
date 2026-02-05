import SwiftUI

// MARK: - COLORS (Cyber Theme Proxy)
extension Color {
    static let cyberBlue = ThemeColors.primaryAccent
    static let cyberPurple = ThemeColors.secondaryAccent
    static let cyberDarkBg = Color.black // FORCE PURE BLACK
    static let cyberCardBg = Color.black // FORCE PURE BLACK
}

struct SessionDebugDashboard: View {
    @ObservedObject var engine: LessonEngine
    var selectedThemeColor: Color = .cyberBlue 
    var dismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerPanelView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        hudGridView
                        
                        selectionQueuePanelView
                        
                        brickSection(title: "CONSTANTS", color: .cyberBlue, bricks: engine.lessonData?.bricks?.constants)
                        brickSection(title: "VARIABLES", color: .cyberPurple, bricks: engine.lessonData?.bricks?.variables)
                        brickSection(title: "STRUCTURAL", color: .yellow, bricks: engine.lessonData?.bricks?.structural)
                        
                        patternsPanelView
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerPanelView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: -5) {
                    Text("ENGINE")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text("PURE FLOW")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(selectedThemeColor)
                }
                
                Spacer()
                
                LocianButton(
                    action: { dismiss() },
                    backgroundColor: selectedThemeColor,
                    foregroundColor: .white,
                    shadowColor: .white,
                    shadowOffset: 4,
                    borderWidth: 0,
                    borderColor: .clear
                ) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 32, height: 32)
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 14))
                Text(">> STATELESS REAL-TIME MONITORING")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .foregroundColor(.cyberBlue)
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(Color.black)
    }
    
    @ViewBuilder
    private var hudGridView: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HUDCard(title: "STEP", value: "\(engine.currentStep)", icon: "stairs", color: .cyberBlue)
                HUDCard(title: "PROGRESS", value: "\(Int(engine.calculateOverallProgress() * 100))%", icon: "chart.bar.fill", color: .green)
                HUDCard(title: "DRILLS", value: "\(engine.allDrills.count)", icon: "circle.grid.3x3.fill", color: .cyberPurple)
                HUDCard(title: "QUEUE", value: "\(engine.selectionQueue.count)", icon: "list.bullet.indent", color: .yellow)
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var selectionQueuePanelView: some View {
        VStack(alignment: .leading, spacing: 12) {
            NonSlantedTag(text: "SELECTION QUEUE", textColor: .black, backgroundColor: .yellow, shadowColor: .white, shadowOffset: CGSize(width: 2, height: 2))
                .padding(.horizontal)
            
            if engine.selectionQueue.isEmpty {
                Text("Queue Empty (Linear Selection Mode)").font(.caption).foregroundColor(.gray).padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(engine.selectionQueue, id: \.self) { id in
                            ChamferedCard(color: .white.opacity(0.1), borderColor: .white.opacity(0.3), chamferSize: 8) {
                                Text(id)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    @ViewBuilder
    private func brickSection(title: String, color: Color, bricks: [BrickItem]?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            NonSlantedTag(text: title, textColor: .black, backgroundColor: color, shadowColor: .white, shadowOffset: CGSize(width: 2, height: 2))
                .padding(.horizontal)
            
            if let bricks = bricks, !bricks.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(bricks, id: \.id) { brick in
                            CyberBrickCard(brick: brick, engine: engine)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            } else {
                Text("No \(title.capitalized)").font(.caption).foregroundColor(.gray).padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var patternsPanelView: some View {
        VStack(alignment: .leading, spacing: 12) {
            NonSlantedTag(text: "PATTERNS", textColor: .black, backgroundColor: .green, shadowColor: .white, shadowOffset: CGSize(width: 2, height: 2))
                .padding(.horizontal)
            
            if let patterns = engine.lessonData?.patterns {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(patterns.enumerated()), id: \.offset) { index, pattern in
                        CyberPatternCard(pattern: pattern, index: index, engine: engine)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No Patterns Loaded").font(.caption).foregroundColor(.gray).padding(.horizontal)
            }
        }
    }
}
