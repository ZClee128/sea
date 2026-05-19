//
//  Theme.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI

struct Theme {
    // Colors
    static let primaryPeach = Color(red: 255/255, green: 110/255, blue: 125/255) // Vibrant melon peach
    static let secondaryOrange = Color(red: 255/255, green: 165/255, blue: 96/255) // Warm cantaloupe orange
    static let accentPink = Color(red: 255/255, green: 80/255, blue: 112/255) // Dark pink highlights
    static let champagne = Color(red: 254/255, green: 248/255, blue: 242/255) // Soft warm backdrop
    static let backgroundGray = Color(red: 246/255, green: 247/255, blue: 250/255) // Main backdrop
    static let cardBackground = Color.white
    static let borderGray = Color(red: 240/255, green: 241/255, blue: 244/255)
    
    // Text Colors
    static let textDark = Color(red: 35/255, green: 38/255, blue: 46/255) // Elegant dark charcoal
    static let textMedium = Color(red: 95/255, green: 100/255, blue: 115/255) // Reading gray
    static let textLight = Color(red: 160/255, green: 165/255, blue: 180/255) // Placeholder/Subtle gray
    
    // Gradients
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [secondaryOrange, primaryPeach]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryPeach, accentPink]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var lightPeachGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [champagne, Color.white]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var glassGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.92), Color.white.opacity(0.75)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Shadow
    static func cardShadow() -> some ViewModifier {
        CardShadowModifier()
    }
}

// Shadow ViewModifier to maintain a consistent depth feeling
struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .shadow(color: Theme.accentPink.opacity(0.03), radius: 16, x: 0, y: 8)
    }
}

// Reusable Components
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = icon {
                    Image(systemName: iconName)
                }
                Text(title)
                    .font(.headline)
                    .bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.accentGradient)
            .cornerRadius(14)
            .shadow(color: Theme.accentPink.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .foregroundColor(Theme.primaryPeach)
                }
                Text(title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(Theme.primaryPeach)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.primaryPeach.opacity(0.5), lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Button feedback animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Card Wrapper
struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Theme.glassGradient)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .modifier(CardShadowModifier())
    }
}

// Standard header component
struct ViewHeader: View {
    let title: String
    let subtitle: String
    var rightContent: AnyView? = nil
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(subtitle.uppercased())
                    .font(.caption)
                    .bold()
                    .foregroundColor(Theme.primaryPeach)
                    .tracking(1.5)
                
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Theme.textDark)
            }
            Spacer()
            if let right = rightContent {
                right
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - iOS 13 Font Compatibility Extension
extension Font {
    public static let title2 = Font.system(size: 22)
    public static let title3 = Font.system(size: 20)
    public static let caption2 = Font.system(size: 11)
}
