import Foundation

enum AuraCategory: String, CaseIterable, Identifiable {
    case amethyst = "Amethyst"
    case emerald = "Emerald"
    case ruby = "Ruby"
    case sapphire = "Sapphire"
    case obsidian = "Obsidian"
    
    var id: String { self.rawValue }
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
