import SwiftUI

struct LessonCompletionView: View {
    @ObservedObject var engine: LessonEngine
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // --- HEADER ---
            VStack(alignment: .leading, spacing: 4) {
                Text("MISSION ACCOMPLISHED")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(MockTokens.pink)
                    .tracking(2)
                    .diagnosticBorder(.blue)

                Text("YOU COMPLETED\nTHE LESSON")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .diagnosticBorder(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 30)
            .diagnosticBorder(.orange)

            // --- SUMMARY CARD ---
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(MockTokens.pink)
                        .diagnosticBorder(.blue)
                    Text("PRACTICED SENTENCES")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .diagnosticBorder(.blue)
                }
                .padding(.horizontal, 16)
                .diagnosticBorder(.green)

                ScrollView {
                    VStack(spacing: 12) {
                        let completedPatterns = engine.allPatterns.filter {
                            engine.visitedPatternIds.contains($0.id)
                        }

                        ForEach(completedPatterns) { pattern in
                            PracticedPatternRow(pattern: pattern)
                                .diagnosticBorder(.cyan)
                        }
                    }
                    .padding(.horizontal, 16)
                    .diagnosticBorder(.yellow)
                }
                .diagnosticBorder(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(MockTokens.g0)
            .overlay(
                Rectangle()
                    .stroke(MockTokens.g2, lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .diagnosticBorder(.orange)

            Spacer()

            // --- FOOTER / BUTTON ---
            VStack(spacing: 20) {
                Text("Mastery levels updated. Ready for the next challenge?")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(MockTokens.muted2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .diagnosticBorder(.blue)

                Button(action: onFinish) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ALL SYSTEMS GO")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.black.opacity(0.6))
                                .diagnosticBorder(.blue)
                            Text("FINISH LESSON")
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(.black)
                                .diagnosticBorder(.blue)
                        }
                        .diagnosticBorder(.cyan)

                        Spacer()

                        Image(systemName: "chevron.right.2")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.black)
                            .diagnosticBorder(.blue)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(MockTokens.pink)
                    .clipShape(Rectangle())
                    .diagnosticBorder(.green)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .diagnosticBorder(.cyan)
            }
            .diagnosticBorder(.orange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MockTokens.bg.ignoresSafeArea())
        .diagnosticBorder(.red)
    }
}

fileprivate struct PracticedPatternRow: View {
    let pattern: PatternData

    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            Rectangle()
                .fill(MockTokens.pink)
                .frame(width: 3)
                .diagnosticBorder(.purple)

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.target)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .diagnosticBorder(.blue)

                Text(pattern.meaning)
                    .font(.system(size: 14))
                    .foregroundColor(MockTokens.muted2)
                    .diagnosticBorder(.blue)
            }
            .diagnosticBorder(.green)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(MockTokens.green)
                .font(.system(size: 20))
                .diagnosticBorder(.blue)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(MockTokens.g0)
        .overlay(Rectangle().stroke(MockTokens.g2, lineWidth: 1))
        .diagnosticBorder(.red)
    }
}
