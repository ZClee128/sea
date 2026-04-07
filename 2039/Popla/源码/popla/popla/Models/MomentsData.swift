import SwiftUI

/// Shared data source for Popla moments to ensure consistency 
/// across Explore and Planner modules.
struct MomentsData {
    static let all: [UrbanMoment] = [
        UrbanMoment(title: "Morning Glow", rhythm: "Relax", location: "Cafe Urban", colorHex: "pink", number: "01",
            curatorName: "Aiko Tanaka",
            fullDescription: "The first light hits the glass facade of Cafe Urban, creating a dancing pattern of reflections. It's the quietest hour of the day, where the city breathes before the hustle begins.",
            tags: ["Zen", "Coffee", "Light"]),
        
        UrbanMoment(title: "Street Pulse", rhythm: "Energetic", location: "District 9", colorHex: "blue", isVideo: true, videoUrl: "Street Pulse", number: "02",
            curatorName: "Liam West",
            fullDescription: "District 9 is the heartbeat of our urban story. Every corner tells a tale of movement and grit. This video captures the raw energy of the crossing at 6 PM.",
            tags: ["Motion", "City", "Raw"]),
        
        UrbanMoment(title: "Archive Silence", rhythm: "Silent", location: "Library St.", colorHex: "green", number: "03",
            curatorName: "Oliver Reed",
            fullDescription: "In a world of constant noise, the archive is a sanctuary. The scent of old paper and the muffled sound of footsteps create a perfect rhythm for thinking.",
            tags: ["Books", "Sanctuary", "Vintage"]),
            
        UrbanMoment(title: "Neon Echo", rhythm: "Creative", location: "Neon District", colorHex: "purple", isVideo: false, videoUrl: "Night Rhythm", number: "04",
            curatorName: "Sasha Blue",
            fullDescription: "When the sun goes down, the neon lights take over. Modern reflections and deep electronic pulses define this creative corner.",
            tags: ["Neon", "Night", "Cyber"]),
            
        UrbanMoment(title: "River Vibe", rhythm: "Relax", location: "Waterfront", colorHex: "green", isVideo: true, number: "05",
            curatorName: "Aiko Tanaka",
            fullDescription: "Flowing water has its own rhythm. Here at the waterfront, the city slows down and the soul finds its pace again.",
            tags: ["Nature", "River", "Breathe"]),
            
        UrbanMoment(title: "Creative Bloom", rhythm: "Creative", location: "Artist Studio", colorHex: "orange", number: "06",
            curatorName: "Oliver Reed",
            fullDescription: "Where ideas turn into physical reality. A messy desk is the rhythmic heart of a creative life.",
            tags: ["Design", "Minimal", "Craft"])
    ]
}
