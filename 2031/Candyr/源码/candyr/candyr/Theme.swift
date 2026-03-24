import SwiftUI

struct NeonCouture {
    static let primary = Color(hex: "#FF007F") // Neon Pink
    static let secondary = Color(hex: "#9D00FF") // Neon Purple
    static let background = Color.white
    static let accent = Color(hex: "#00E5FF") // Neon Cyan
    
    static let titleFont = Font.system(size: 32, weight: .bold, design: .serif)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct NeonModifier: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: 8, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: 15, x: 0, y: 0)
    }
}

extension View {
    func neonGlow(color: Color = NeonCouture.primary) -> some View {
        modifier(NeonModifier(color: color))
    }
}
