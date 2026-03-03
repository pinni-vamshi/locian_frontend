import SwiftUI

struct DrillMasteryVictoryView: View {
    let drill: DrillState
    let onComplete: ((Bool) -> Void)?
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var progress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Celebration Icon
            ZStack {
                Circle()
                    .stroke(CyberColors.neonCyan.opacity(0.2), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(CyberColors.neonCyan)
                    .shadow(color: CyberColors.neonCyan, radius: 10)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            
            VStack(spacing: 8) {
                Text("PRO LEVEL")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberColors.neonCyan)
                    .kerning(4)
                
                Text("MASTERED")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
            }
            .opacity(opacity)
            
            // Auto-advance progress bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 6)
                
                Capsule()
                    .fill(CyberColors.neonCyan)
                    .frame(width: 200 * progress, height: 6)
                    .shadow(color: CyberColors.neonCyan, radius: 4)
            }
            .padding(.top, 16)
            .opacity(opacity)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Fill progress bar over 1.5s
            withAnimation(.linear(duration: 1.5)) {
                progress = 1.0
            }
            
            // Trigger completion after 1.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                print("🏆 [VictoryLap] Auto-advancing mastered drill: \(drill.id)")
                onComplete?(true)
            }
        }
    }
}
