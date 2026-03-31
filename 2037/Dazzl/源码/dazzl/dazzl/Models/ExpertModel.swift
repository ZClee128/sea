import Foundation
import Combine

struct Expert: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let specialty: String
    let avatar: String // Using systemImage or local image names
    let bio: String
    let rating: Double
    let activeSessions: Int
    
    static let samples: [Expert] = [
        Expert(id: UUID(), name: "Aura", specialty: "Ethereal Lighting", avatar: "sparkles", bio: "Master of diffused morning light and dreamlike bokeh effects.", rating: 4.9, activeSessions: 128),
        Expert(id: UUID(), name: "Neon", specialty: "Cyberpunk Geometry", avatar: "bolt.fill", bio: "Expert in high-contrast neon palettes and hard directional lighting.", rating: 4.8, activeSessions: 94),
        Expert(id: UUID(), name: "Vogue", specialty: "Urban Fashion", avatar: "building.2.fill", bio: "Specializes in high-street fashion photography and skyscraper shadows.", rating: 5.0, activeSessions: 215),
        Expert(id: UUID(), name: "Retro", specialty: "Vintage Aesthetics", avatar: "camera.on.rectangle.fill", bio: "Expert in film grain simulation and golden era cinematography.", rating: 4.7, activeSessions: 82),
        Expert(id: UUID(), name: "Luna", specialty: "Night Photography", avatar: "moon.stars.fill", bio: "Celestial grace and atmospheric low-light techniques.", rating: 4.9, activeSessions: 156),
        Expert(id: UUID(), name: "Glitch", specialty: "Digital Art", avatar: "cpu.fill", bio: "Imperfection as beauty. Specialized in glitch and chromatic aberration.", rating: 4.6, activeSessions: 67),
        Expert(id: UUID(), name: "Street", specialty: "Candid Moments", avatar: "figure.walk", bio: "Capturing the rhythm of the city with technical precision.", rating: 4.8, activeSessions: 112),
        Expert(id: UUID(), name: "Classic", specialty: "B&W Portraits", avatar: "person.fill.viewfinder", bio: "Timeless elegance and tonal contrast for monochrome masterpieces.", rating: 4.9, activeSessions: 143)
    ]
}

class ExpertDataStore: ObservableObject {
    @Published var experts: [Expert] = Expert.samples
}
