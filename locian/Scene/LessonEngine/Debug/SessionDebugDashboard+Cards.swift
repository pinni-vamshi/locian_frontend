import SwiftUI

// MARK: - CYBER BRICK CARD (Horizontal) - MISSION CONTROL STYLE
struct CyberBrickCard: View {
    let brick: BrickItem
    @ObservedObject var engine: LessonEngine
    
    var body: some View {
        let brickId = brick.id ?? brick.word
        let mastery = engine.componentMastery[brickId] ?? 0.0
        let rate = Int(mastery * 100)
        
        ChamferedCard(
            color: Color.black,
            borderColor: rate > 0 ? Color.white.opacity(0.8) : Color.white.opacity(0.2),
            chamferSize: 15
        ) {
            VStack(alignment: .leading, spacing: 6) {
                // Header: ID + Mastery
                HStack {
                    Text(brickId)
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.cyberPurple)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        if rate >= 95 {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                        }
                        Text(rate >= 95 ? "MASTERED" : "SCORE \(rate)%")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(rate >= 95 ? Color.green.opacity(0.8) : (rate > 0 ? Color.white : Color.gray))
                            .cornerRadius(2)
                    }
                }
                
                // Panel: Meaning
                VStack(alignment: .leading, spacing: 4) {
                    Text(brick.meaning)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding(.vertical, 4)
                
                Divider().background(Color.white.opacity(0.1))

                // Pure Flow Visualization
                VStack(alignment: .leading, spacing: 10) {
                    Text("PURE FLOW DATA")
                        .font(.system(size: 7, weight: .black))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    HStack {
                        Text("MASTERY")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f", mastery))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        Z {
                            Rectangle().fill(Color.white.opacity(0.1))
                            Rectangle()
                                .fill(rate >= 95 ? Color.green : Color.cyberPurple)
                                .frame(width: geo.size.width * mastery)
                        }
                    }
                    .frame(height: 4)
                    .cornerRadius(2)
                }
                .padding(.vertical, 10)

                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(width: 180, height: 180) // Shorter now as history is gone
        }
    }
}

// MARK: - CYBER PATTERN CARD
struct CyberPatternCard: View {
    let pattern: PatternData
    let index: Int
    @ObservedObject var engine: LessonEngine
    
    var body: some View {
        let patternId = pattern.pattern_id
        let mastery = engine.getBlendedMastery(for: "\(patternId)-d0")
        let rate = Int(mastery * 100)
        
        ChamferedCard(
            color: .black,
            borderColor: rate > 0 ? .white.opacity(0.8) : .white.opacity(0.2),
            chamferSize: 10
        ) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PATTERN \(index + 1)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.white)
                        Text(patternId)
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyberBlue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            if rate >= 95 {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                            }
                        Text("\(rate)%")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(rate >= 95 ? .green : (rate > 50 ? .orange : .white))
                    }
                    Text("BLENDED SCORE")
                        .font(.system(size: 7, weight: .black))
                        .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                
                // Meaning Context
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.meaning)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 12)
                
                // Drills Preview of this pattern
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        let relatedDrills = engine.allDrills.filter { $0.patternId == patternId }
                        ForEach(relatedDrills) { drill in
                             VStack(alignment: .leading, spacing: 2) {
                                 Text(drill.id)
                                     .font(.system(size: 7, weight: .black, design: .monospaced))
                                     .foregroundColor(.cyberBlue)
                                 Text(drill.currentMode?.rawValue ?? "AUTO")
                                     .font(.system(size: 6, weight: .bold))
                                     .foregroundColor(.white.opacity(0.5))
                             }
                             .padding(6)
                             .background(Color.white.opacity(0.05))
                             .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)
            }
        }
        .frame(width: 240, height: 160)
    }
}

// Z stack helper for cleaner code in complex views
struct Z<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View { ZStack { content } }
}
