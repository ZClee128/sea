//
//  Theme.swift
//  vibble
//

import SwiftUI

struct Theme {
    static let primary = Color(hex: "E91E63") // 活力粉红
    static let secondary = Color(hex: "9C27B0") // 紫色
    static let background = Color(hex: "0F0F12") // 极深背景色
    static let cardBackground = Color(hex: "1C1C23") // 卡片背景
    static let textPrimary = Color.white
    static let textSecondary = Color.gray.opacity(0.8)
    static let accent = Color(hex: "00F5FF") // 霓虹青
    
    struct Gradients {
        static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [Theme.primary, Theme.secondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let darkOverlay = LinearGradient(
            gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
