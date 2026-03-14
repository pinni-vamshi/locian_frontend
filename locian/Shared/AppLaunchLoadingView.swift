import SwiftUI
import Combine

struct AppLaunchLoadingView: View {
    @ObservedObject var appState: AppStateManager
    @State private var logoOpacity: Double = 0.0
    @State private var asteriskOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.82
    @State private var asteriskScale: CGFloat = 0.82
    @State private var letterOpacities: [Double] = [0, 0, 0, 0, 0, 0]
    @State private var letterScales: [CGFloat] = [0.9, 0.9, 0.9, 0.9, 0.9, 0.9]
    @State private var subtitleOpacity: Double = 0.0
    
    // Dot Animation for "GETTING YOUR MOMENTS"
    @State private var dotCount = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    private let brandingLetters = Array("LOCIAN")
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 60) {
                Spacer()
                
                // Massive Semicolon Logo
                SemicolonLogoView(
                    logoOpacity: logoOpacity,
                    asteriskOpacity: asteriskOpacity,
                    logoScale: logoScale,
                    asteriskScale: asteriskScale
                )
                .frame(width: 190, height: 140)
                
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
                
                // Minimalist Progress & Status
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.cyan))
                    
                    Text("GETTING YOUR MOMENTS" + String(repeating: ".", count: dotCount))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.cyan)
                        .onReceive(timer) { _ in
                            dotCount = (dotCount + 1) % 4
                        }
                }
                .opacity(subtitleOpacity >= 0.01 ? 1.0 : 0.0)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Small delay so the initial frame renders before animations begin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            // COMMA — fade + subtle scale
            withAnimation(.easeOut(duration: 0.7)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            
            // ASTERISK — staggered
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                asteriskOpacity = 1.0
                asteriskScale = 1.0
            }
            
            // LOCIAN — per-letter stagger via asyncAfter (reliable under CPU load)
            for i in 0..<6 {
                let letterDelay = 0.9 + Double(i) * 0.08
                DispatchQueue.main.asyncAfter(deadline: .now() + letterDelay) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        letterOpacities[i] = 1.0
                        letterScales[i] = 1.0
                    }
                }
            }
            
            // Subtitle — after all letters done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    subtitleOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - Massive Semicolon Logo Components
struct SemicolonLogoView: View {
    let logoOpacity: Double
    let asteriskOpacity: Double
    let logoScale: CGFloat
    let asteriskScale: CGFloat
    
    var body: some View {
        // COMMA — static fill, no trim animation (smooth)
        CommaShape()
            .fill(Color.white)
            .frame(width: 80, height: 135)
            .opacity(logoOpacity)
            .scaleEffect(logoScale)
            .overlay(alignment: .topTrailing) {
                Text("*")
                    .font(.system(size: 68, weight: .black))
                    .foregroundColor(ThemeColors.secondaryAccent)
                    .opacity(asteriskOpacity)
                    .scaleEffect(asteriskScale)
                    .offset(x: 46, y: -20)
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
        let tipEdgeHeight = h * 0.16 // Increased thickness for blunter tip
        let tailTipX = w * 0.15 // Offset from the left edge so tail doesn't reach full width
        
        // Start Top Left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 1. Top edge
        path.addLine(to: CGPoint(x: w, y: 0))
        
        // 2. Right vertical side
        path.addLine(to: CGPoint(x: w, y: blockHeight))
        
        // 3. The outer sweep of the comma tail
        // Pure smooth sweep from the vertical edge to the tip
        path.addCurve(to: CGPoint(x: tailTipX, y: h),
                      control1: CGPoint(x: w, y: blockHeight + (h - blockHeight) * 0.5),
                      control2: CGPoint(x: w * 0.5, y: h))
        
        // 4. THE TIP EDGE (Vertical blunt tip)
        path.addLine(to: CGPoint(x: tailTipX, y: h - tipEdgeHeight))
        
        // 5. The inner curve of the tail
        // Aligned and parallel to the outer sweep for a clean professional look
        path.addCurve(to: CGPoint(x: indentWidth, y: blockHeight),
                      control1: CGPoint(x: indentWidth * 0.2 + tailTipX, y: h - tipEdgeHeight),
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
