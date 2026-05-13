import SwiftUI

struct GhostModeHistoryAnimationView: View {
    @ObservedObject var engine: LessonEngine
    let onComplete: () -> Void
    
    // UI State
    @State private var viewOpacity: Double = 1.0
    @State private var currentHeaderText: String = "HISTORY REVIEW"
    @State private var visibleIndexSet: Set<Int> = []
    
    // ✅ UI Header Variations (4-5 words each)
    private let headerVariations = [
        "Reviewing your recent patterns",
        "Recalling previously learned sentences",
        "Strengthening your recent progress",
        "Revisiting some past words",
        "Practice these older sentences"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ✅ Header Text (Top Aligned, Matches Mistakes Style)
            Text(currentHeaderText)
                .font(.system(size: 40, weight: .black))
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
                .padding(.bottom, 24)
                .diagnosticBorder(.blue)
            
            // ✅ List of Sentences from recentPatternHistory (Deduplicated)
            VStack(alignment: .leading, spacing: 12) {
                let uniqueHistory = engine.recentPatternHistory.reduce(into: [String]()) { result, id in
                    if !result.contains(id) { result.append(id) }
                }.prefix(3)
                
                ForEach(Array(uniqueHistory.enumerated()), id: \.offset) { index, patternId in
                    if visibleIndexSet.contains(index) {
                        if let pattern = engine.rawPatterns.first(where: { $0.id == patternId }) {
                            HStack(spacing: 12) {
                                Text(pattern.meaning)
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundColor(.gray)
                                    .diagnosticBorder(.blue)
                                
                                Text(":")
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .diagnosticBorder(.blue)
                                
                                Text(pattern.target)
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundColor(CyberColors.neonPink)
                                    .diagnosticBorder(.blue)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .diagnosticBorder(.cyan)
                        }
                    }
                }
            }
            .padding(.horizontal, 5)
            .diagnosticBorder(.green)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
        .opacity(viewOpacity)
        .onAppear {
            setupUI()
            startRevealChain()
        }
        .diagnosticBorder(.red)
    }
    
    private func setupUI() {
        currentHeaderText = headerVariations.randomElement() ?? "HISTORY REVIEW"
    }
    
    private func startRevealChain() {
        visibleIndexSet.removeAll()
        
        // Short delay before first reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.revealPatternsSequentially(at: 0)
        }
    }
    
    private func revealPatternsSequentially(at index: Int) {
        let historyCount = engine.recentPatternHistory.count
        guard index < historyCount else {
            // ALL PATTERNS REVEALED: Fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    viewOpacity = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
            return
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            _ = visibleIndexSet.insert(index)
        }
        
        // Wait before next reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            revealPatternsSequentially(at: index + 1)
        }
    }
}
