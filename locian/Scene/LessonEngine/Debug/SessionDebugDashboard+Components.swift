import SwiftUI

// MARK: - CYBER COMPONENTS

struct HUDCard: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .cyberBlue
    
    var body: some View {
        ChamferedCard(color: .black, borderColor: .white, chamferSize: 10) {
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .font(.caption2)
                        .foregroundColor(color)
                    Text(title)
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.gray)
                }
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
    }
}

struct CyberSection<Content: View>: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let content: () -> Content
    
    init(title: String, icon: String, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.cyberBlue)
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    ChamferedShape(chamferSize: 15, cornerRadius: 0)
                        .fill(Color.cyberCardBg)
                )
                .overlay(
                    ChamferedShape(chamferSize: 15, cornerRadius: 0)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            
            if isExpanded {
                VStack(spacing: 0) {
                    content()
                }
                .background(Color.black.opacity(0.3))
            }
        }
        .padding(.horizontal)
    }
}

struct DebugDrillRow: View {
    let drill: DrillState
    
    var body: some View {
        let rate = Int(drill.masteryScore * 100)
        
        ChamferedCard(color: Color.black, borderColor: Color.white, borderWidth: 1, chamferSize: 10, cornerRadius: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // Status Header
                    HStack {
                        if rate >= 95 { 
                            Text("DONE").font(.system(size: 9, weight: .bold)).foregroundColor(.black).padding(2).background(Color.green).cornerRadius(2)
                        } else {
                            Text("ACTIVE").font(.system(size: 9, weight: .bold)).foregroundColor(.black).padding(2).background(Color.white).cornerRadius(2)
                        }
                        Spacer()
                        Text(drill.currentMode?.rawValue ?? "AUTO")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.cyberBlue)
                    }
                    
                    Text(drill.drillData.meaning)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        
                    Divider().background(Color.white.opacity(0.2))
                    
                    // Score Footer
                    HStack(spacing: 8) {
                        Text("ID: \(drill.id.suffix(4))")
                            .font(.caption2).foregroundColor(.gray).monospaced()
                        
                        Spacer()
                        
                        Text("SCORE: \(rate)%")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(rate >= 95 ? .green : .white)
                    }
                }
            }
            .padding(10)
            .frame(width: 220, height: 100)
        }
    }
}

// StageColumn and PatternStatRow removed as they were tracking-dependent
