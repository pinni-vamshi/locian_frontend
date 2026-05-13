import SwiftUI

func learnScaleFactor(_ hSizeClass: UserInterfaceSizeClass?) -> CGFloat {
    hSizeClass == .regular ? 1.22 : 1.0
}

func learnScaled(
    _ base: CGFloat,
    hSizeClass: UserInterfaceSizeClass?,
    min: CGFloat? = nil,
    max: CGFloat? = nil
) -> CGFloat {
    var value = base * learnScaleFactor(hSizeClass)
    if let min { value = Swift.max(min, value) }
    if let max { value = Swift.min(max, value) }
    return value
}

func learnFont(
    size: CGFloat,
    weight: Font.Weight = .regular,
    hSizeClass: UserInterfaceSizeClass?
) -> Font {
    LearnHelvetica.font(size: learnScaled(size, hSizeClass: hSizeClass), weight: weight)
}

enum LearnHelvetica {
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .ultraLight, .thin, .light:
            return .custom("Helvetica-Light", size: size)
        case .regular, .medium:
            return .custom("Helvetica", size: size)
        case .semibold, .bold, .heavy, .black:
            return .custom("Helvetica-Bold", size: size)
        default:
            return .custom("Helvetica", size: size)
        }
    }
}

struct SentenceToken: Identifiable, Hashable {
    let id: Int
    let text: String
    let brickIndex: Int?
}

func normalizedWord(_ value: String) -> String {
    value
        .lowercased()
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .joined()
}

struct StorySegmentBar: View {
    let isActive: Bool
    let isDone: Bool
    let progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color(white: 0.17))
                Rectangle()
                    .fill(ThemeColors.secondaryAccent)
                    .frame(width: isDone ? geo.size.width : (isActive ? geo.size.width * progress : 0))
            }
        }
        .frame(height: 2)
    }
}

struct AngledTopButton: Shape {
    let notch: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: notch))
        p.addLine(to: CGPoint(x: rect.midX, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: notch))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
