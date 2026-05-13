import SwiftUI
import UIKit

// MARK: - 1. Debug Configuration
struct DebugConfig {
    /// Toggle this to show or hide all diagnostic borders across the app.
    static var showDiagnosticBorders: Bool {
        return AppStateManager.shared.showDiagnosticBorders
    }
}

enum DiagnosticBorderStyle {
    case solid
    case dashed
}

extension View {
    /// Applies a border only if diagnostic borders are enabled in DebugConfig.
    @ViewBuilder
    func diagnosticBorder(_ color: Color, width: CGFloat = 1, style: DiagnosticBorderStyle = .solid, label: String? = nil) -> some View {
        if DebugConfig.showDiagnosticBorders {
            self.overlay(
                ZStack(alignment: .topTrailing) {
                    if style == .dashed {
                        Rectangle()
                            .stroke(color, style: StrokeStyle(lineWidth: width, dash: [4, 4]))
                    } else {
                        Rectangle()
                            .stroke(color, lineWidth: width)
                    }
                }
                .allowsHitTesting(false)
            )
        } else {
            self
        }
    }
}

// MARK: - 2. Error Handler
struct ErrorHandler {
    enum LogLevel {
        case info, warning, error, debug
    }
    
    static func log(_ error: Error, context: String = "", level: LogLevel = .error) {
        // Logging removed
    }
    
    static func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return "No internet connection. Please check your network."
            case .networkConnectionLost: return "Network connection lost. Please try again."
            case .timedOut: return "Request timed out. Please try again."
            case .cannotConnectToHost: return "Cannot connect to server. Please try again later."
            default: return urlError.localizedDescription
            }
        } else if let apiError = error as? APIError {
            return apiError.localizedDescription
        } else {
            return "Something went wrong. Please try again."
        }
    }
    
    static func info(_ message: String, context: String = "") {}
    static func warning(_ message: String, context: String = "") {}
    static func debug(_ message: String, context: String = "") {}
}

// MARK: - 3. Haptic Feedback
struct HapticFeedback {
    static func buttonPress() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func buttonRelease() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - 4. Category UI
struct CategoryUI {
    static func icon(for category: String) -> String {
        let normalized = category.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch normalized {
        case "airport": return "airplane"
        case "bakery": return "birthday.cake.fill"
        case "bar_pub": return "wineglass.fill"
        case "beach": return "beach.umbrella.fill"
        case "bus_stop": return "bus.fill"
        case "cafe": return "cup.and.saucer.fill"
        case "clinic": return "stethoscope"
        case "coaching_center": return "person.2.fill"
        case "fast_food_outlet": return "flame.fill"
        case "food_court": return "fork.knife"
        case "gym": return "dumbbell.fill"
        case "home": return "house.fill"
        case "hospital": return "cross.case.fill"
        case "library": return "books.vertical.fill"
        case "metro_station": return "tram.fill"
        case "movie_theatre": return "popcorn.fill"
        case "office": return "building.2.fill"
        case "park": return "tree.fill"
        case "pharmacy": return "pill.fill"
        case "railway_station": return "train.side.front.car"
        case "restaurant": return "fork.knife"
        case "school": return "pencil.and.ruler.fill"
        case "shopping_mall": return "bag.fill"
        case "supermarket": return "cart.fill"
        case "university": return "graduationcap.fill"
        case "yoga_studio": return "figure.mind.and.body"
        default: return "mappin.and.ellipse"
        }
    }
    
    static func color(for category: String) -> Color {
        // All categories use themed neon cyan as per "Stitch" reference
        return Color(red: 0.0, green: 0.8, blue: 1.0)
    }
}
