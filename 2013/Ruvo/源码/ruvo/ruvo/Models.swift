import Foundation
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var enableBackgroundPlayback: Bool {
        didSet {
            UserDefaults.standard.set(enableBackgroundPlayback, forKey: "enable_background_playback")
        }
    }
    
    init() {
        self.enableBackgroundPlayback = UserDefaults.standard.object(forKey: "enable_background_playback") as? Bool ?? true
    }
}


struct Artwork: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let description: String
    let imageName: String 
    let videoURL: String? 
    let colors: [String] 
    let category: String
    let isPremium: Bool
    let coinCost: Int
}

class UnlockedManager: ObservableObject {
    static let shared = UnlockedManager()
    @Published var unlockedIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(unlockedIDs), forKey: "unlocked_artwork_titles")
        }
    }
    
    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "unlocked_artwork_titles") ?? []
        self.unlockedIDs = Set(saved)
    }
    
    func isUnlocked(_ artwork: Artwork) -> Bool {
        if !artwork.isPremium { return true }
        return unlockedIDs.contains(artwork.title)
    }
    
    func unlock(_ artwork: Artwork) -> Bool {
        let balance = StoreManager.shared.userCoins
        if balance >= artwork.coinCost {
            StoreManager.shared.userCoins -= artwork.coinCost
            unlockedIDs.insert(artwork.title)
            return true
        }
        return false
    }
}

struct MockData {
    static let artworks: [Artwork] = [
        Artwork(title: "Neon Cyber-Girl", artist: "Alice Wu", description: "A vibrant futuristic portrait illuminated by striking neon pink and cyan city lights. Great reference for rim lighting.", imageName: "person.crop.square.fill", videoURL: "27.mp4", colors: ["#FF007F", "#00FFFF", "#2A0845", "#0C012A"], category: "Sci-Fi Portrait", isPremium: false, coinCost: 0),
        
        Artwork(title: "Classic Profile", artist: "Jane Doe", description: "A detailed study of classic Rembrandt lighting on a human profile, focusing on blending skin tones and soft shadows.", imageName: "person.crop.circle.fill", videoURL: "27.mp4", colors: ["#FAD7A1", "#D68953", "#8B4513", "#3E1E04"], category: "Portrait", isPremium: true, coinCost: 20),
        
        Artwork(title: "The Old Maestro", artist: "David Kim", description: "Character design highlighting intricate facial wrinkles and expressive, deep-set eyes using charcoal techniques.", imageName: "person.fill", videoURL: nil, colors: ["#5C5C5C", "#333333", "#1A1A1A", "#8B8878"], category: "Character Design", isPremium: true, coinCost: 30),
        
        Artwork(title: "Ethereal Beauty", artist: "Emma Stone", description: "A soft, fantasy-inspired portrait with glowing, translucent skin and flowing hair mechanics.", imageName: "sparkles", videoURL: nil, colors: ["#FFF0F5", "#F5B7B1", "#E8DAEF", "#D4E6F1"], category: "Fantasy Portrait", isPremium: false, coinCost: 0),
        
        Artwork(title: "Action Gesture", artist: "John Smith", description: "A 5-minute quick gesture sketch capturing the dynamic energy and anatomy of a human figure in full sprint.", imageName: "figure.walk", videoURL: nil, colors: ["#CD5C5C", "#A52A2A", "#800000", "#4A2311"], category: "Figure Drawing", isPremium: false, coinCost: 0),
        
        Artwork(title: "Golden Hour Glow", artist: "Sarah Lee", description: "A color study focusing on the warm, intense light of the sunset reflecting off the subject's face.", imageName: "person.circle.fill", videoURL: nil, colors: ["#F5CBA7", "#DC7633", "#BA4A00", "#6E2C00"], category: "Portrait", isPremium: false, coinCost: 0),
        
        // Brand new data to enrich the app!
        Artwork(title: "Soft Box Lighting", artist: "Chen Wei", description: "A studio portrait mimicking softbox diffusion, perfect for smooth gradient skin transitions.", imageName: "person.crop.rectangle.fill", videoURL: nil, colors: ["#EAD1C1", "#CB9A84", "#A25D43", "#4A2B1D"], category: "Portrait", isPremium: true, coinCost: 15),
        
        Artwork(title: "Harsh Shadows", artist: "Elena Rossi", description: "High contrast chiaroscuro framing the face diagonally. Excellent reference for understanding hard edges.", imageName: "person.fill.viewfinder", videoURL: nil, colors: ["#D4D4D4", "#7F7F7F", "#3A3A3A", "#0F0F0F"], category: "Character Design", isPremium: true, coinCost: 25),
        
        Artwork(title: "Painterly Brushstrokes", artist: "Mark Owens", description: "Thick impasto painting style prioritizing expressive strokes over hyper-realism.", imageName: "paintpalette.fill", videoURL: nil, colors: ["#7FA99B", "#F1D18A", "#D36A4F", "#3D4849"], category: "Portrait", isPremium: true, coinCost: 15),
        
        Artwork(title: "Contemplation", artist: "Aisha Patel", description: "A subtle, introspective facial expression emphasizing subtle micro-expressions around the eyes.", imageName: "person.text.rectangle", videoURL: nil, colors: ["#E0C3AB", "#A4745E", "#664030", "#2C1814"], category: "Expression Study", isPremium: false, coinCost: 0),
        
        Artwork(title: "Vintage Vibes", artist: "Chris Evans", description: "A figure drawing sketch completed with sepia tones and a retro texturing pass.", imageName: "figure.stand", videoURL: nil, colors: ["#EEDCBE", "#CDB38B", "#8B7355", "#4A3B2C"], category: "Figure Drawing", isPremium: false, coinCost: 0),
        
        Artwork(title: "Neon Glow", artist: "Lily Chen", description: "An experimental palette using almost exclusively cool blues contrasted with hot magentas.", imageName: "bolt.fill", videoURL: nil, colors: ["#00BFFF", "#1E90FF", "#8A2BE2", "#FF00FF"], category: "Sci-Fi Portrait", isPremium: true, coinCost: 40)
    ]
    
    static var featuredArtworks: [Artwork] {
        return Array(artworks.prefix(2))
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
