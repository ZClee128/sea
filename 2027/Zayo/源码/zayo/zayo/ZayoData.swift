import Foundation
import Combine

struct Portrait: Identifiable {
    let id: String
    let imageName: String
    let title: String
    let category: PortraitCategory
    let concept: String
    let mastery: String
}

enum PortraitCategory: String, CaseIterable {
    case editorial = "Editorial"
    case cinematic = "Cinematic"
    case minimal = "Minimal"
    case vintage = "Vintage"
}

struct ChecklistItem: Identifiable {
    let id = UUID()
    let task: String
    let isCompleted: Bool = false
}

struct LightSource: Identifiable {
    let id = UUID()
    let type: String // "Key", "Fill", "Rim", "Background"
    let x: CGFloat // 0 to 1 relative position
    let y: CGFloat // 0 to 1 relative position
}

struct LightingSetup: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let diagramDescription: String 
    let technicalChecklist: [String]
    let lights: [LightSource]
}

class FavoritesManager: ObservableObject {
    @Published var favoriteIds: Set<String> = [] {
        didSet {
            UserDefaults.standard.set(Array(favoriteIds), forKey: "FavoritePortraitIds")
        }
    }
    
    init() {
        if let savedIds = UserDefaults.standard.stringArray(forKey: "FavoritePortraitIds") {
            self.favoriteIds = Set(savedIds)
        }
    }
    
    func toggleFavorite(id: String) {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
    }
    
    func isFavorite(id: String) -> Bool {
        favoriteIds.contains(id)
    }
}

struct VideoPortrait: Identifiable {
    let id: String
    let title: String
    let remoteVideoUrl: String // Fallback remote URL
    let thumbnail: String
    let description: String
    let duration: String
    let format: String
    let cost: Int
    let isFree: Bool
    
    var resolvedUrl: URL? {
        // Try to find local video in bundle first (mp4 or mov)
        if let localUrl = Bundle.main.url(forResource: title, withExtension: "mp4") {
            return localUrl
        }
        if let localUrl = Bundle.main.url(forResource: title, withExtension: "mov") {
            return localUrl
        }
        // Fallback to remote URL
        return URL(string: remoteVideoUrl)
    }
}

struct ZayoData {
    static let lightingSetups: [LightingSetup] = [
        LightingSetup(
            id: "setup_soft",
            name: "Soft Minimal",
            icon: "sun.max",
            description: "A gentle, wrap-around light perfect for capturing natural and serene expressions.",
            diagramDescription: "Key: Large octabox at 45° left. Fill: White V-flat on right. Background: Natural wall fall-off.",
            technicalChecklist: [
                "Use lens between 35mm - 50mm",
                "ISO 100-400 for maximum detail",
                "Aperture f/2.0 - f/4.0 for soft fall-off",
                "Large softbox or silk scrim required"
            ],
            lights: [
                LightSource(type: "Key", x: 0.25, y: 0.4),
                LightSource(type: "Fill", x: 0.75, y: 0.5)
            ]
        ),
        LightingSetup(
            id: "setup_dramatic",
            name: "Classic Dramatic",
            icon: "moon.fill",
            description: "High contrast lighting that emphasizes bone structure and creates deep shadows.",
            diagramDescription: "Key: Gridded beauty dish at 45° high-right. Rim: Strip box behind subject. Fill: Minimal to none.",
            technicalChecklist: [
                "Use lens 85mm or longer",
                "High shutter speed to freeze motion",
                "Aperture f/8.0 - f/11 for sharpness",
                "Grids required to control light spill"
            ],
            lights: [
                LightSource(type: "Key", x: 0.8, y: 0.3),
                LightSource(type: "Rim", x: 0.5, y: 0.1)
            ]
        ),
        LightingSetup(
            id: "setup_cinematic",
            name: "Cinematic Glow",
            icon: "film",
            description: "A moody, atmospheric setup inspired by classic noir and modern cinema.",
            diagramDescription: "Key: Large soft source through a door or window. Accent: Warm gel on back-left kick light.",
            technicalChecklist: [
                "Use anamorphic or wide-aperture lens",
                "Expose for the highlights",
                "Add subtle smoke/haze for texture",
                "Color temperature set to 3200K (Tungsten)"
            ],
            lights: [
                LightSource(type: "Key", x: 0.2, y: 0.5),
                LightSource(type: "Rim", x: 0.7, y: 0.2)
            ]
        )
    ]
    
    static let videoPortraits: [VideoPortrait] = [
        VideoPortrait(
            id: "vid_1",
            title: "Midnight Echo",
            remoteVideoUrl: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4", 
            thumbnail: "Midnight Echo",
            description: "A slow-motion study of movement and light in a velvet-draped studio.",
            duration: "0:15",
            format: "4K ProRes 422",
            cost: 50,
            isFree: true
        ),
        VideoPortrait(
            id: "vid_2",
            title: "Glitch Aura",
            remoteVideoUrl: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4",
            thumbnail: "Glitch Aura",
            description: "Experimental digital artifacts blended with cinematic portraiture.",
            duration: "0:25",
            format: "4K H.264",
            cost: 50,
            isFree: false
        ),
        VideoPortrait(
            id: "vid_3",
            title: "Wind Muse",
            remoteVideoUrl: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4",
            thumbnail: "Wind Muse",
            description: "Capturing the elemental force of wind through fabric and expression.",
            duration: "0:10",
            format: "HEVC 10-bit",
            cost: 50,
            isFree: false
        )
    ]
    
    static let portraits: [Portrait] = [
        Portrait(
            id: "port_1",
            imageName: "Ethereal Morning",
            title: "Ethereal Morning",
            category: .minimal,
            concept: "Capturing the soft, diffused light of early dawn to emphasize natural serenity.",
            mastery: "Used a large silk scrim to soften direct sunlight, creating an even, low-contrast skin tone."
        ),
        Portrait(
            id: "port_2",
            imageName: "Urban Noir",
            title: "Urban Noir",
            category: .cinematic,
            concept: "A dramatic exploration of shadows and high-contrast lighting in a city environment.",
            mastery: "Key light positioned at 45 degrees to create a Rembrandt lighting effect, emphasizing jawline structure."
        ),
        Portrait(
            id: "port_3",
            imageName: "Golden Hour Muse",
            title: "Golden Hour Muse",
            category: .vintage,
            concept: "Warming tones and lens flare used to evoke a nostalgic, sun-drenched memory.",
            mastery: "Shot with a vintage 50mm prime lens at f/1.4 to achieve a soft bokeh and natural chromatic aberration."
        ),
        Portrait(
            id: "port_4",
            imageName: "Modern Elegance",
            title: "Modern Elegance",
            category: .editorial,
            concept: "Clean lines and bold colors for a high-fashion aesthetic.",
            mastery: "Utilized a silver beauty dish for punchy highlights and crisp shadow transitions."
        ),
        Portrait(
            id: "port_5",
            imageName: "Whispering Shadows",
            title: "Whispering Shadows",
            category: .cinematic,
            concept: "Low-key lighting design to create a sense of mystery and introspection.",
            mastery: "Gridded softbox used to direct light precisely on the subject, preventing spill onto the dark background."
        )
    ]
}
