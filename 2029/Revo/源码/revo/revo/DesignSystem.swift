import SwiftUI

struct RevoDesign {
    
    // Core Colors - Premium, Glamorous, and Light Mode only
    static let primary = Color(hex: "D4AF37") // Champagne Gold
    static let secondary = Color(hex: "F5F5DC") // Beige/Cream
    static let background = Color(hex: "FFFFFF") // Pure White
    static let text = Color(hex: "1C1C1C") // Off-Black
    static let textSecondary = Color(hex: "6D6D6D") // Soft Gray
    static let accent = Color(hex: "8E6B23") // Darker Gold for buttons/emphasis
    
    // Gradient for premium feel
    static let premiumGradient = LinearGradient(
        gradient: Gradient(colors: [primary, accent]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
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
            blue: Double(Double(b) / 255),
            opacity: Double(a) / 255
        )
    }
}

// Premium Card Component
struct PremiumCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(RevoDesign.secondary.opacity(0.5), lineWidth: 1)
            )
    }
}

// Glassy Button style for a modern look
struct GlassyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RevoDesign.premiumGradient
                    Color.white.opacity(configuration.isPressed ? 0.2 : 0)
                }
            )
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring())
    }
}

// Global Modifier for Light Mode
struct ForceLightModeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(.light)
    }
}

extension View {
    func forceLightMode() -> some View {
        self.modifier(ForceLightModeModifier())
    }
}
