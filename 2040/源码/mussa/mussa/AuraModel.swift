import Foundation

enum AuraCategory: String, CaseIterable, Identifiable {
    case amethyst = "Amethyst"
    case emerald = "Emerald"
    case ruby = "Ruby"
    case sapphire = "Sapphire"
    case obsidian = "Obsidian"
    
    var id: String { self.rawValue }
    
    var soundscapeIndex: Int {
        switch self {
        case .emerald: return 0  // Deep Focus
        case .sapphire: return 1 // Zen Clarity
        case .amethyst: return 2 // Dream State
        case .ruby, .obsidian: return 3 // Ethereal
        }
    }
}

struct AuraItem: Identifiable {
    let id: String
    let title: String
    let museName: String
    let description: String
    let crystalType: String
    let rarity: String
    let imageName: String
    let videoURL: String?
    let category: AuraCategory
    let unlockCost: Int
    
    let prompt: String
    let cameraSettings: String
    let hasVideo: Bool
    
    var rarityValue: Int {
        switch rarity.lowercased() {
        case "legendary": return 3
        case "rare": return 2
        case "common": return 1
        default: return 0
        }
    }
}
