import SwiftUI

struct AppTheme {
    static let primary = Color.blue // Electric Blue
    static let accent = Color.pink // Radiant Pink
    static let background = Color.black
    static let surface = Color(white: 0.1)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let gold = Color.yellow
}

extension View {
    func standardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}
