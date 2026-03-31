import Foundation
import Combine

struct Muse: Identifiable {
    let id: UUID
    let name: String
    let category: MuseCategory
    let imageUrl: String
    let videoUrl: String?
    let description: String
    let palette: [String] // HEX codes for the mood
    let lightingTip: String // Professional lighting advice
    var isFavorite: Bool = false
    
    init(id: UUID = UUID(), name: String, category: MuseCategory, imageUrl: String, videoUrl: String?, description: String, palette: [String], lightingTip: String, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.description = description
        self.palette = palette
        self.lightingTip = lightingTip
        self.isFavorite = isFavorite
    }
}

enum MuseCategory: String, CaseIterable, Identifiable {
    case ethereal = "Ethereal"
    case cyberpunk = "Cyberpunk"
    case urban = "Urban"
    case vintage = "Vintage"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .ethereal: return "cloud.sun.fill"
        case .cyberpunk: return "cpu.fill"
        case .urban: return "building.2.fill"
        case .vintage: return "camera.on.rectangle.fill"
        }
    }
}

class MuseDataStore: ObservableObject {
    @Published var muses: [Muse] = []
    @Published var isBackgroundPlayEnabled: Bool = true
    @Published var activeVideoID: UUID? = nil
    @Published var coinBalance: Int = 0
    @Published var unlockedInsights: Set<String> = [] // Set of Muse UUID strings
    
    private let favoritesKey = "user_favorites_muses"
    private let backgroundPlayKey = "is_background_play_enabled"
    private let coinsKey = "user_dazzl_coins_balance"
    private let unlockedKey = "user_unlocked_insights_list"
    
    func toggleFavorite(for id: UUID) {
        if let index = muses.firstIndex(where: { $0.id == id }) {
            muses[index].isFavorite.toggle()
            saveFavorites()
        }
    }
    
    func updateBackgroundPlay(_ enabled: Bool) {
        isBackgroundPlayEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: backgroundPlayKey)
    }
    
    // Coin Economy Methods
    func addCoins(_ amount: Int) {
        coinBalance += amount
        saveEconomy()
    }
    
    func spendCoins(_ amount: Int, for museID: UUID) -> Bool {
        if coinBalance >= amount {
            coinBalance -= amount
            unlockedInsights.insert(museID.uuidString)
            saveEconomy()
            return true
        }
        return false
    }
    
    func isUnlocked(_ museID: UUID) -> Bool {
        return unlockedInsights.contains(museID.uuidString)
    }
    
    private func saveFavorites() {
        let favoriteIds = muses.filter { $0.isFavorite }.map { $0.id.uuidString }
        UserDefaults.standard.set(favoriteIds, forKey: favoritesKey)
    }
    
    private func saveEconomy() {
        UserDefaults.standard.set(coinBalance, forKey: coinsKey)
        UserDefaults.standard.set(Array(unlockedInsights), forKey: unlockedKey)
    }
    
    private func loadPersistence() {
        // Load Favorites
        let favoriteIds = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        for index in 0..<muses.count {
            if favoriteIds.contains(muses[index].id.uuidString) {
                muses[index].isFavorite = true
            }
        }
        
        // Load Background Play
        if UserDefaults.standard.object(forKey: backgroundPlayKey) != nil {
            isBackgroundPlayEnabled = UserDefaults.standard.bool(forKey: backgroundPlayKey)
        } else {
            isBackgroundPlayEnabled = true
        }
        
        // Load Economy
        coinBalance = UserDefaults.standard.integer(forKey: coinsKey)
        let unlocked = UserDefaults.standard.stringArray(forKey: unlockedKey) ?? []
        unlockedInsights = Set(unlocked)
    }
    
    init() {
        self.muses = [
            // Ethereal
            Muse(id: UUID(uuidString: "A1111111-1111-1111-1111-111111111111")!, name: "Aura", category: .ethereal, imageUrl: "Aura", videoUrl: "Aura", description: "En embodies the ethereal spirit of morning mist and soft light.", palette: ["#E3F2FD", "#F3E5F5", "#FFF9C4"], lightingTip: "Use soft, diffused natural light (Golden Hour) to capture the dreamlike bloom effect."),
            Muse(id: UUID(uuidString: "A2222222-2222-2222-2222-222222222222")!, name: "Luna", category: .ethereal, imageUrl: "Luna", videoUrl: nil, description: "Celestial grace captured in a moment of silent reflection.", palette: ["#CFD8DC", "#B0BEC5", "#ECEFF1"], lightingTip: "Cool-toned rim lighting helps separate the subject from a dark, atmospheric background."),
            Muse(id: UUID(uuidString: "A3333333-3333-3333-3333-333333333333")!, name: "Iris", category: .ethereal, imageUrl: "Iris", videoUrl: nil, description: "A dreamlike presence in a garden of soft blooms.", palette: ["#FCE4EC", "#F8BBD0", "#F48FB1"], lightingTip: "Over-exposure (High-Key) can emphasize the delicate textures of flowers and skin."),
            
            // Cyberpunk
            Muse(id: UUID(uuidString: "B1111111-1111-1111-1111-111111111111")!, name: "Neon", category: .cyberpunk, imageUrl: "Neon", videoUrl: nil, description: "Digital soul wandering in a city of electric dreams.", palette: ["#FF00FF", "#00FFFF", "#0000FF"], lightingTip: "Mix high-contrast neon blues and magentas. Keep the shadows deep for that 'low-life, high-tech' look."),
            Muse(id: UUID(uuidString: "B2222222-2222-2222-2222-222222222222")!, name: "Glitch", category: .cyberpunk, imageUrl: "Glitch", videoUrl: nil, description: "Imperfection is the ultimate high-tech beauty.", palette: ["#B71C1C", "#212121", "#7B1FA2"], lightingTip: "Experiment with prism effects or chromatic aberration. Lighting should be harsh and directional."),
            Muse(id: UUID(uuidString: "B3333333-3333-3333-3333-333333333333")!, name: "Cyber", category: .cyberpunk, imageUrl: "Cyber", videoUrl: nil, description: "Futuristic lines meet the core of human emotion.", palette: ["#26C6DA", "#000000", "#FFEB3B"], lightingTip: "Focus on reflective surfaces like wet asphalt or glass to multiply the neon light sources."),
            
            // Urban
            Muse(id: UUID(uuidString: "C1111111-1111-1111-1111-111111111111")!, name: "Vogue", category: .urban, imageUrl: "Vogue", videoUrl: nil, description: "High-street fashion meeting the concrete jungle.", palette: ["#212121", "#FFFFFF", "#9E9E9E"], lightingTip: "Harsh midday sun creates dramatic geometric shadows. Use skyscrapers to block light for high-contrast shots."),
            Muse(id: UUID(uuidString: "C2222222-2222-2222-2222-222222222222")!, name: "Street", category: .urban, imageUrl: "Street", videoUrl: nil, description: "The rhythm of the city captured in casual grace.", palette: ["#8D6E63", "#3E2723", "#BDBDBD"], lightingTip: "Look for 'leading lines' in city streets. Golden hour reflected off buildings creates an urban glow."),
            Muse(id: UUID(uuidString: "C3333333-3333-3333-3333-333333333333")!, name: "Metro", category: .urban, imageUrl: "Metro", videoUrl: nil, description: "Minimalist urban style for the modern metropolis.", palette: ["#263238", "#CFD8DC", "#455A64"], lightingTip: "Artificial street lights (Sodium Vapor) add a warm, industrial tone to nocturnal shots."),
            
            // Vintage
            Muse(id: UUID(uuidString: "D1111111-1111-1111-1111-111111111111")!, name: "Retro", category: .vintage, imageUrl: "Retro", videoUrl: nil, description: "Timeless style from the golden era of film.", palette: ["#8D6E63", "#A1887F", "#4E342E"], lightingTip: "Lower the exposure slightly and favor warm, incandescent lighting to simulate aged film stocks."),
            Muse(id: UUID(uuidString: "D2222222-2222-2222-2222-222222222222")!, name: "Classic", category: .vintage, imageUrl: "Classic", videoUrl: nil, description: "Elegance that never goes out of fashion.", palette: ["#212121", "#FFFFFF", "#BDBDBD"], lightingTip: "Black and white photography relies on tonal contrast. Emphasize textures like silk or leather."),
            Muse(id: UUID(uuidString: "D3333333-3333-3333-3333-333333333333")!, name: "Kodak", category: .vintage, imageUrl: "Kodak", videoUrl: "Kodak", description: "Vibrant colors and nostalgic film grain vibes.", palette: ["#FDD835", "#F4511E", "#004D40"], lightingTip: "Strong sunset light creates the warm, saturated look of classic 35mm film."),
            Muse(id: UUID(uuidString: "D4444444-4444-4444-4444-444444444444")!, name: "Vinyl", category: .vintage, imageUrl: "Vinyl", videoUrl: nil, description: "A record of beauty from a slower, simpler time.", palette: ["#3E2723", "#A1887F", "#D7CCC8"], lightingTip: "Soft indoor lighting with warm wood tones creates a cozy, nostalgic atmosphere.")
        ]
        
        loadPersistence()
    }
}




