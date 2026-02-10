import SwiftUI

struct AppLaunchLoadingView: View {
    @ObservedObject var appState: AppStateManager
    @State private var dotDraw: CGFloat = 0.0
    @State private var tailDraw: CGFloat = 0.0
    @State private var dotFillOpacity: Double = 0.0
    @State private var tailFillOpacity: Double = 0.0
    @State private var dotScale: CGFloat = 0.0
    @State private var tailScale: CGFloat = 0.0
    @State private var letterOpacities: [Double] = [0, 0, 0, 0, 0, 0]
    @State private var letterScales: [CGFloat] = [0.9, 0.9, 0.9, 0.9, 0.9, 0.9]
    @State private var subtitleOpacity: Double = 0.0
    
    private let brandingLetters = Array("LOCIAN")
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 60) {
                Spacer()
                
                // Massive Semicolon Logo
                SemicolonLogoView(
                    dotDraw: dotDraw,
                    tailDraw: tailDraw,
                    dotFillOpacity: dotFillOpacity,
                    tailFillOpacity: tailFillOpacity,
                    dotScale: dotScale,
                    tailScale: tailScale
                )
                .frame(width: 140, height: 260)
                
                // Techy Logo Branding
                VStack(spacing: 16) {
                    HStack(spacing: 2) {
                        ForEach(0..<brandingLetters.count, id: \.self) { index in
                            Text(String(brandingLetters[index]))
                                .font(.system(size: 34, weight: .black))
                                .foregroundColor(.white)
                                .opacity(letterOpacities[index])
                                .scaleEffect(letterScales[index])
                        }
                    }
                    
                    Text("ADAPTIVE LANGUAGE ENGINE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(ThemeColors.secondaryAccent)
                        .tracking(4)
                        .opacity(subtitleOpacity)
                }
                
                Spacer()
                
                // Minimalist Progress
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.secondaryAccent))
                    .opacity(subtitleOpacity > 0.8 ? 1.0 : 0.0)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // --- DOT SEQUENCE ---
        // 1. Immediate visible start (Reduced duration for faster pick-up)
        withAnimation(.easeIn(duration: 1.6)) {
            dotDraw = 1.0
            dotFillOpacity = 1.0
        }
        
        // 2. Instant Scale Reveal (Removed delay for immediate feedback)
        withAnimation(.easeInOut(duration: 0.9)) {
            dotScale = 1.0
        }
        
        // --- TAIL SEQUENCE (Staggered) ---
        // 1. Tightened stagger for continuous movement
        withAnimation(.easeIn(duration: 1.8).delay(0.2)) {
            tailDraw = 1.0
            tailFillOpacity = 1.0
        }
        
        // 2. Snappy Scaling
        withAnimation(.easeInOut(duration: 1.1).delay(0.3)) {
            tailScale = 1.0
        }
        
        // --- BRANDING TEXT SEQUENCE ---
        // Earlier start of branding reveal
        for i in 0..<brandingLetters.count {
            let delay = 0.7 + Double(i) * 0.12
            withAnimation(.easeIn(duration: 1.2).delay(delay)) {
                letterOpacities[i] = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).delay(delay)) {
                letterScales[i] = 1.0
            }
        }
        
        // Final Subtitle Reveal
        withAnimation(.easeOut(duration: 1.5).delay(1.8)) {
            subtitleOpacity = 0.8
        }
    }
}

// MARK: - Massive Semicolon Logo Components
struct SemicolonLogoView: View {
    let dotDraw: CGFloat
    let tailDraw: CGFloat
    let dotFillOpacity: Double
    let tailFillOpacity: Double
    let dotScale: CGFloat
    let tailScale: CGFloat
    
    var body: some View {
        VStack(spacing: 20) {
            // THE DOT (White Square)
            ZStack {
                Rectangle()
                    .trim(from: 0, to: dotDraw)
                    .stroke(Color.white, lineWidth: 2.03) // Refined to 2.03
                    .frame(width: 80, height: 80)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
            }
            .opacity(dotFillOpacity) // Entire block fades in together
            .scaleEffect(dotScale)
            
            // THE COMMA (Red/Pink Tail)
            ZStack {
                CommaShape()
                    .trim(from: 0, to: tailDraw)
                    .stroke(ThemeColors.secondaryAccent, lineWidth: 2.03) // Refined to 2.03
                    .frame(width: 80, height: 135)
                
                CommaShape()
                    .fill(ThemeColors.secondaryAccent)
                    .frame(width: 80, height: 135)
            }
            .opacity(tailFillOpacity) // Entire tail fades in together
            .scaleEffect(tailScale)
        }
    }
}

// Custom shape for the red comma part
struct CommaShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Proportions based on the logo image
        let blockHeight = w // Perfect square block
        let indentWidth = w * 0.54
        let tipEdgeHeight = h * 0.08
        
        // Start Top Left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 1. Top edge
        path.addLine(to: CGPoint(x: w, y: 0))
        
        // 2. Right vertical side
        path.addLine(to: CGPoint(x: w, y: blockHeight))
        
        // 3. The outer sweep of the comma tail
        // Pure smooth sweep from the vertical edge to the tip
        path.addCurve(to: CGPoint(x: 0, y: h),
                      control1: CGPoint(x: w, y: blockHeight + (h - blockHeight) * 0.5),
                      control2: CGPoint(x: w * 0.5, y: h))
        
        // 4. THE TIP EDGE (Vertical blunt tip)
        path.addLine(to: CGPoint(x: 0, y: h - tipEdgeHeight))
        
        // 5. The inner curve of the tail
        // Aligned and parallel to the outer sweep for a clean professional look
        path.addCurve(to: CGPoint(x: indentWidth, y: blockHeight),
                      control1: CGPoint(x: indentWidth * 0.2, y: h - tipEdgeHeight),
                      control2: CGPoint(x: indentWidth, y: h * 0.8))
        
        // 6. THE HORIZONTAL SEGMENT ("Straight inside")
        path.addLine(to: CGPoint(x: 0, y: blockHeight))
        
        // 7. Left vertical side back to start
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        path.closeSubpath()
        return path
    }
}











#Preview {
    AppLaunchLoadingView(appState: AppStateManager.shared)
}
