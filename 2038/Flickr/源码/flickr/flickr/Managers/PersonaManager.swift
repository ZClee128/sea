import Foundation
import SwiftUI
import Combine

enum AestheticPersona: String, Codable, CaseIterable {
    case ethereal = "Ethereal Minimalist"
    case noir = "Noir Architect"
    case vibrant = "Vibrant Dreamer"
    case naturalString = "Natural Sage"
    case undiagnosed = "Undiagnosed"
    
    var description: String {
        switch self {
        case .ethereal: return "You find beauty in light, space, and the subtle whispers of high-key compositions."
        case .noir: return "You are drawn to shadows, structure, and the dramatic tension of monochromatic depth."
        case .vibrant: return "You embrace life through saturation, dynamic energy, and bold aesthetic statements."
        case .naturalString: return "Your soul is anchored in the organic rhythms and muted tones of the natural world."
        case .undiagnosed: return "Your unique aesthetic DNA is waiting to be discovered."
        }
    }
    
    var icon: String {
        switch self {
        case .ethereal: return "sparkles"
        case .noir: return "moon.stars.fill"
        case .vibrant: return "bolt.fill"
        case .naturalString: return "leaf.fill"
        case .undiagnosed: return "questionmark.circle"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .ethereal: return .blue.opacity(0.6)
        case .noir: return .purple.opacity(0.8)
        case .vibrant: return .orange
        case .naturalString: return .green.opacity(0.7)
        case .undiagnosed: return .gray
        }
    }
}

@available(iOS 14.0, *)
class PersonaManager: ObservableObject {
    @AppStorage("userAestheticPersona") var personaRawValue: String = AestheticPersona.undiagnosed.rawValue
    
    static let shared = PersonaManager()
    
    var currentPersona: AestheticPersona {
        get { AestheticPersona(rawValue: personaRawValue) ?? .undiagnosed }
        set { personaRawValue = newValue.rawValue }
    }
    
    func setPersona(basedOn points: [AestheticPersona: Int]) {
        if let top = points.max(by: { $0.value < $1.value }) {
            currentPersona = top.key
        } else {
            currentPersona = .ethereal // Fallback
        }
    }
    
    func reset() {
        currentPersona = .undiagnosed
    }
}
