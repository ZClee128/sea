import Foundation
import Combine

struct Muse: Identifiable {
    let id = UUID()
    let name: String
    let category: MuseCategory
    let imageUrl: String
    let videoUrl: String?
    let description: String
    let palette: [String] // HEX codes for the mood
    let lightingTip: String // Professional lighting advice
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
    
    init() {
        self.muses = [
            // Ethereal
            Muse(name: "Aura", category: .ethereal, imageUrl: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80", videoUrl: "https://v.cdn.vine.co/r/videos/EC8F3BA7-8D63-49B5-B86C-49F9F8F8F8F8.mp4", description: "En embodies the ethereal spirit of morning mist and soft light.", palette: ["#E3F2FD", "#F3E5F5", "#FFF9C4"], lightingTip: "Use soft, diffused natural light (Golden Hour) to capture the dreamlike bloom effect."),
            Muse(name: "Luna", category: .ethereal, imageUrl: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80", videoUrl: nil, description: "Celestial grace captured in a moment of silent reflection.", palette: ["#CFD8DC", "#B0BEC5", "#ECEFF1"], lightingTip: "Cool-toned rim lighting helps separate the subject from a dark, atmospheric background."),
            Muse(name: "Iris", category: .ethereal, imageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80", videoUrl: nil, description: "A dreamlike presence in a garden of soft blooms.", palette: ["#FCE4EC", "#F8BBD0", "#F48FB1"], lightingTip: "Over-exposure (High-Key) can emphasize the delicate textures of flowers and skin."),
            
            // Cyberpunk
            Muse(name: "Neon", category: .cyberpunk, imageUrl: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&q=80", videoUrl: nil, description: "Digital soul wandering in a city of electric dreams.", palette: ["#FF00FF", "#00FFFF", "#0000FF"], lightingTip: "Mix high-contrast neon blues and magentas. Keep the shadows deep for that 'low-life, high-tech' look."),
            Muse(name: "Glitch", category: .cyberpunk, imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80", videoUrl: nil, description: "Imperfection is the ultimate high-tech beauty.", palette: ["#B71C1C", "#212121", "#7B1FA2"], lightingTip: "Experiment with prism effects or chromatic aberration. Lighting should be harsh and directional."),
            Muse(name: "Cyber", category: .cyberpunk, imageUrl: "https://images.unsplash.com/photo-1534732806146-b3bf32171b48?w=800&q=80", videoUrl: nil, description: "Futuristic lines meet the core of human emotion.", palette: ["#26C6DA", "#000000", "#FFEB3B"], lightingTip: "Focus on reflective surfaces like wet asphalt or glass to multiply the neon light sources."),
            
            // Urban
            Muse(name: "Vogue", category: .urban, imageUrl: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&q=80", videoUrl: nil, description: "High-street fashion meeting the concrete jungle.", palette: ["#212121", "#FFFFFF", "#9E9E9E"], lightingTip: "Harsh midday sun creates dramatic geometric shadows. Use skyscrapers to block light for high-contrast shots."),
            Muse(name: "Street", category: .urban, imageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&q=80", videoUrl: nil, description: "The rhythm of the city captured in casual grace.", palette: ["#8D6E63", "#3E2723", "#BDBDBD"], lightingTip: "Look for 'leading lines' in city streets. Golden hour reflected off buildings creates an urban glow."),
            Muse(name: "Metro", category: .urban, imageUrl: "https://images.unsplash.com/photo-1529139572172-db058ec517ac?w=800&q=80", videoUrl: nil, description: "Minimalist urban style for the modern metropolis.", palette: ["#263238", "#CFD8DC", "#455A64"], lightingTip: "Artificial street lights (Sodium Vapor) add a warm, industrial tone to nocturnal shots."),
            
            // Vintage
            Muse(name: "Retro", category: .vintage, imageUrl: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&q=80", videoUrl: nil, description: "Timeless style from the golden era of film.", palette: ["#8D6E63", "#A1887F", "#4E342E"], lightingTip: "Lower the exposure slightly and favor warm, incandescent lighting to simulate aged film stocks."),
            Muse(name: "Classic", category: .vintage, imageUrl: "https://images.unsplash.com/photo-1520333789090-1afc82db536a?w=800&q=80", videoUrl: nil, description: "Elegance that never goes out of fashion.", palette: ["#212121", "#FFFFFF", "#BDBDBD"], lightingTip: "Black and white photography relies on tonal contrast. Emphasize textures like silk or leather."),
            Muse(name: "Kodak", category: .vintage, imageUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80", videoUrl: "https://v.cdn.vine.co/r/videos/EC8F3BA7-8D63-49B5-B86C-49F9F8F8F8F8.mp4", description: "Vibrant colors and nostalgic film grain vibes.", palette: ["#FDD835", "#F4511E", "#004D40"], lightingTip: "Strong sunset light creates the warm, saturated look of classic 35mm film."),
            Muse(name: "Vinyl", category: .vintage, imageUrl: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80", videoUrl: nil, description: "A record of beauty from a slower, simpler time.", palette: ["#3E2723", "#A1887F", "#D7CCC8"], lightingTip: "Soft indoor lighting with warm wood tones creates a cozy, nostalgic atmosphere.")
        ]
    }
}



