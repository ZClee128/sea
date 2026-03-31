import Foundation

struct ProTip: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let content: String
    let icon: String
}

struct PaletteHarmony: Identifiable {
    let id = UUID()
    let name: String
    let colors: [String]
    let vibe: String
}

struct LightingBlueprint: Identifiable {
    let id = UUID()
    let title: String
    let setup: String
    let tip: String
}

struct PoseSkeleton: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageUrl: String // Simplified line-art reference
}

class LabDataStore {
    static let tips: [ProTip] = [
        ProTip(title: "Rule of Thirds", subtitle: "Composition", content: "Place your model at the intersections of a 3x3 grid for more balanced and professional shots.", icon: "rectangle.grid.3x3"),
        ProTip(title: "Complementary Colors", subtitle: "Aesthetics", content: "Use opposite colors on the wheel (like Teal and Orange) to make the subject pop effortlessly.", icon: "paintpalette.fill"),
        ProTip(title: "Negative Space", subtitle: "Layout", content: "Don't be afraid of empty space. It pulls the viewer's focus directly to your Muse.", icon: "square.dashed"),
        ProTip(title: "Texture Contrast", subtitle: "Styling", content: "Mix rough textures (concrete, metal) with soft elements (silk, skin) for high-end fashion results.", icon: "circle.grid.cross")
    ]
    
    static let palettes: [PaletteHarmony] = [
        PaletteHarmony(name: "Midnight Neon", colors: ["#FF00FF", "#00FFFF", "#311B92"], vibe: "Cyberpunk / High Contrast"),
        PaletteHarmony(name: "Morning Mist", colors: ["#E3F2FD", "#B2EBF2", "#ECEFF1"], vibe: "Ethereal / Soft Focus"),
        PaletteHarmony(name: "Urban Concrete", colors: ["#212121", "#9E9E9E", "#FFFFFF"], vibe: "Urban / Minimalist"),
        PaletteHarmony(name: "Autumn Vintage", colors: ["#BF360C", "#FFD54F", "#795548"], vibe: "Retro / Nostalgic"),
        PaletteHarmony(name: "Deep Forest", colors: ["#1B5E20", "#4CAF50", "#8BC34A"], vibe: "Nature / Serene")
    ]
    
    static let lightings: [LightingBlueprint] = [
        LightingBlueprint(title: "Rembrandt", setup: "45-degree Key Light + Rim Light", tip: "Place the key light high and to the side to create a triangle of light below the eye."),
        LightingBlueprint(title: "Cyber Glow", setup: "Dual Magenta/Cyan Side Fill", tip: "Use two tube lights on opposite sides for dramatic color contrast."),
        LightingBlueprint(title: "Ethereal Bloom", setup: "Large Softbox + Reflector", tip: "Diffuse the light as much as possible for a glowy, no-shadow look."),
        LightingBlueprint(title: "High Contrast Urban", setup: "Direct Sun + Deep Shadows", tip: "Use harsh shadows to create geometric patterns on the subject.")
    ]
    
    static let poses: [PoseSkeleton] = [
        PoseSkeleton(title: "The S-Curve", description: "Elegant curvature of the spine for fashion shots.", imageUrl: "https://images.pexels.com/photos/1036622/pexels-photo-1036622.jpeg?w=400&h=400&fit=crop"),
        PoseSkeleton(title: "Power Stance", description: "Symmetrical and strong, perfect for urban aesthetics.", imageUrl: "https://images.pexels.com/photos/1515886/pexels-photo-1515886.jpeg?w=400&h=400&fit=crop"),
        PoseSkeleton(title: "Floating Gaze", description: "Minimalist and dreamy, focusing on the profile.", imageUrl: "https://images.pexels.com/photos/1462637/pexels-photo-1462637.jpeg?w=400&h=400&fit=crop")
    ]
}

