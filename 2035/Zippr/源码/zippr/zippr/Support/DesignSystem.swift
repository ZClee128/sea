import SwiftUI

// MARK: - App Color Palette
extension Color {
    static let zPrimary    = Color(hex: "#E8517A")   // vibrant rose
    static let zSecondary  = Color(hex: "#FF8C69")   // warm coral
    static let zAccent     = Color(hex: "#C13584")   // deep magenta
    static let zBackground = Color(hex: "#FFF8F9")   // warm white
    static let zSurface    = Color(hex: "#FFFFFF")
    static let zText       = Color(hex: "#1A1A2E")
    static let zTextSub    = Color(hex: "#7A7A9D")
    static let zCardBg     = Color(hex: "#FFF0F3")
    static let zDivider    = Color(hex: "#F0E0E5")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - Typography helpers
extension Font {
    static func zTitle(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func zHeadline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func zBody(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    static func zCaption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}
