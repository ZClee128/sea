import SwiftUI

struct DesignTokens {
    // Colors
    struct Colors {
        static let background = Color(hex: "F9F7F2") // Pearl White
        static let surface = Color(hex: "FFFFFF")    // Pure White
        static let primary = Color(hex: "1C1C1C")     // Deep Charcoal
        static let secondary = Color(hex: "757575")   // Muted Grey
        static let accent = Color(hex: "C5A059")      // Refined Soft Gold
        static let slate = Color(hex: "E0E0E0")       // Light Slate
    }
    
    // Typography
    struct Typography {
        static func title(_ size: CGFloat = 34) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
        
        static func headline(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        
        static func body(_ size: CGFloat = 15) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }
        
        static func caption(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .medium, design: .default)
        }
    }
    
    // Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Global UI Utilities
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}
