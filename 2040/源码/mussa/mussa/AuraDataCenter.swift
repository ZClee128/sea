import Foundation
import SwiftUI
import Combine

class AuraStore: ObservableObject {
    @Published var items: [AuraItem] = [
        // Original 5 Muses
        AuraItem(id: "aura_emerald_1", title: "Emerald Silence", museName: "Elara", description: "The profound depth of ancient forests, captured in a gaze.", crystalType: "Emerald", rarity: "Legendary", imageName: "emerald_muse", videoURL: nil, category: .emerald, unlockCost: 155, prompt: "Cinematic portrait of a beautiful woman, emerald-green silk, surrounded by giant emerald crystals, forest morning fog, prismatic lighting, 8k", cameraSettings: "f/1.8, 85mm, ISO 100, 1/250s", hasVideo: true),
        AuraItem(id: "aura_ruby_1", title: "Ruby Radiance", museName: "Sera", description: "A flash of crimson in the urban sprawl, where passion meets the neon light.", crystalType: "Ruby", rarity: "Rare", imageName: "ruby_muse", videoURL: nil, category: .ruby, unlockCost: 60, prompt: "Vibrant cinematic portrait, red velvet fashion, urban neon background, glowing ruby crystals integrated into hair, high contrast", cameraSettings: "f/1.4, 50mm, ISO 400, 1/125s", hasVideo: false),
        AuraItem(id: "aura_amethyst_1", title: "Amethyst Dream", museName: "Lyra", description: "Soft lavender hues and ethereal whispers of the twilight.", crystalType: "Amethyst", rarity: "Common", imageName: "amethyst_muse", videoURL: nil, category: .amethyst, unlockCost: 32, prompt: "Ethereal woman in purple tulle gown, lavender twilight sky, floating amethyst clusters, neon purple highlights, dreamy atmosphere", cameraSettings: "f/2.0, 35mm, ISO 200, 1/500s", hasVideo: false),
        AuraItem(id: "aura_sapphire_1", title: "Sapphire Echo", museName: "Maya", description: "Infinite horizons and the calm of the deep blue abyss.", crystalType: "Sapphire", rarity: "Rare", imageName: "sapphire_muse", videoURL: nil, category: .sapphire, unlockCost: 96, prompt: "Ethereal woman in shallow blue water, sapphire crystals growing from water, blue moonlight, oceanic aesthetic", cameraSettings: "f/1.8, 85mm, ISO 100, 1/200s", hasVideo: false),
        AuraItem(id: "aura_obsidian_1", title: "Obsidian Mystery", museName: "Nyx", description: "Shadows that dance with the light, sharp and impenetrable.", crystalType: "Obsidian", rarity: "Legendary", imageName: "obsidian_muse", videoURL: nil, category: .obsidian, unlockCost: 189, prompt: "Dark mysterious woman, black latex fashion, sharp black obsidian crystal shards, chiaroscuro lighting, sleek and minimalist", cameraSettings: "f/2.8, 105mm, ISO 800, 1/60s", hasVideo: false),
        
        // Gallery/Secondary 5 Muses
        AuraItem(id: "aura_emerald_2", title: "Forest Gaze", museName: "Elara", description: "A macro view of the forest spirit's crystalline essence.", crystalType: "Emerald", rarity: "Rare", imageName: "emerald_gallery1", videoURL: nil, category: .emerald, unlockCost: 45, prompt: "Macro shot of female eyes, emerald green iris, crystalline makeup with small green gems around eyes, mystical and ethereal", cameraSettings: "f/2.8, 100mm Macro, ISO 200, 1/125s", hasVideo: false),
        AuraItem(id: "aura_ruby_2", title: "Crimson Spark", museName: "Sera", description: "The raw power of the passion crystal against the city steel.", crystalType: "Ruby", rarity: "Legendary", imageName: "ruby_gallery1", videoURL: nil, category: .ruby, unlockCost: 210, prompt: "Fashion model leaning against a wall of sharp red raw ruby crystals, dramatic red lighting, urban cyberpunk aesthetic", cameraSettings: "f/1.2, 50mm, ISO 100, 1/400s", hasVideo: false),
        AuraItem(id: "aura_amethyst_2", title: "Twilight Shard", museName: "Lyra", description: "A single moment of calm captured in a floating violet gem.", crystalType: "Amethyst", rarity: "Common", imageName: "amethyst_gallery1", videoURL: nil, category: .amethyst, unlockCost: 25, prompt: "Close up of a female hand holding a glowing violet amethyst crystal, purple particles in the air, dark mysterious background", cameraSettings: "f/1.8, 35mm, ISO 400, 1/60s", hasVideo: false),
        AuraItem(id: "aura_sapphire_2", title: "Royal Crown", museName: "Maya", description: "The majesty of the deep, crowned in celestial blue.", crystalType: "Sapphire", rarity: "Legendary", imageName: "sapphire_gallery1", videoURL: nil, category: .sapphire, unlockCost: 199, prompt: "Portrait of a woman wearing a crown of raw blue sapphire crystals, deep blue aesthetic, frozen ocean background, majestic", cameraSettings: "f/2.0, 85mm, ISO 100, 1/200s", hasVideo: false),
        AuraItem(id: "aura_obsidian_2", title: "Dark Reflection", museName: "Nyx", description: "Seeing the truth through the dark mirror of the soul.", crystalType: "Obsidian", rarity: "Rare", imageName: "obsidian_gallery1", videoURL: nil, category: .obsidian, unlockCost: 75, prompt: "A woman looking into a black obsidian mirror, her reflection is glowing, dark aesthetic, smoke in the air, mysterious", cameraSettings: "f/1.4, 50mm, ISO 640, 1/100s", hasVideo: false)
    ]
    
    @Published var unlockedIds: Set<String> = [] {
        didSet {
            saveUnlocked()
        }
    }
    
    @Published var userCoins: Int = 0 {
        didSet {
            UserDefaults.standard.set(userCoins, forKey: "Mussa_UserCoins_V2")
        }
    }
    
    @Published var isBackgroundPlaybackEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isBackgroundPlaybackEnabled, forKey: "Mussa_BG_Playback")
        }
    }
    
    init() {
        loadUnlocked()
        self.userCoins = UserDefaults.standard.integer(forKey: "Mussa_UserCoins_V2")
        self.isBackgroundPlaybackEnabled = UserDefaults.standard.object(forKey: "Mussa_BG_Playback") as? Bool ?? true
    }
    
    private func saveUnlocked() {
        let ids = Array(unlockedIds)
        UserDefaults.standard.set(ids, forKey: "Mussa_UnlockedIds_V2")
    }
    
    private func loadUnlocked() {
        if let ids = UserDefaults.standard.stringArray(forKey: "Mussa_UnlockedIds_V2") {
            unlockedIds = Set(ids)
        }
    }
    
    func isUnlocked(_ item: AuraItem) -> Bool {
        unlockedIds.contains(item.id)
    }
    
    func unlock(_ item: AuraItem) -> Bool {
        if userCoins >= item.unlockCost {
            userCoins -= item.unlockCost
            unlockedIds.insert(item.id)
            return true
        }
        return false
    }
}
