import Foundation

struct MockData {
    // Generate some deterministic placeholder URLs so they load reliably.
    static func imageUrl(seed: String, width: Int = 800, height: Int = 1200) -> String {
        return "https://picsum.photos/seed/\(seed)/\(width)/\(height)"
    }
    
    static var looks: [Look] = [
        Look(
            id: "1",
            author: "sumo_street",
            authorAvatar: imageUrl(seed: "avatar1", width: 200, height: 200),
            description: "Tokyo street style 2026. Heavy layers and tactical gear.",
            category: .streetwear,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look1_a", width: 800, height: 1000), aspectRatio: 0.8),
                MediaItem(type: .image, urlString: imageUrl(seed: "look1_b", width: 800, height: 1000), aspectRatio: 0.8)
            ],
            likes: 1205,
            isVideoCover: false
        ),
        Look(
            id: "2",
            author: "vintage_vibes",
            authorAvatar: imageUrl(seed: "avatar2", width: 200, height: 200),
            description: "90s oversized fit. Always a classic look for the weekend. Using some old wash denim.",
            category: .vintage,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look2_a", width: 800, height: 800), aspectRatio: 1.0),
                MediaItem(type: .image, urlString: imageUrl(seed: "look2_b", width: 800, height: 800), aspectRatio: 1.0),
                MediaItem(type: .image, urlString: imageUrl(seed: "look2_c", width: 800, height: 800), aspectRatio: 1.0)
            ],
            likes: 853,
            isVideoCover: false
        ),
        Look(
            id: "3",
            author: "tech_ninja",
            authorAvatar: imageUrl(seed: "avatar3", width: 200, height: 200),
            description: "Rain or shine. Tactical aesthetic showcasing waterproofing.",
            category: .techwear,
            mediaItems: [
                MediaItem(type: .video, urlString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", aspectRatio: 0.56)
            ],
            likes: 2100,
            isVideoCover: true
        ),
        Look(
            id: "4",
            author: "y2k_angel",
            authorAvatar: imageUrl(seed: "avatar4", width: 200, height: 200),
            description: "Cyberpunk neon lights matching the Y2K aesthetic.",
            category: .y2k,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look4", width: 800, height: 1200), aspectRatio: 0.67)
            ],
            likes: 342,
            isVideoCover: false
        ),
        Look(
            id: "5",
            author: "minimal_boy",
            authorAvatar: imageUrl(seed: "avatar5", width: 200, height: 200),
            description: "Clean lines and neutral tones.",
            category: .minimalist,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look5", width: 800, height: 1000), aspectRatio: 0.8),
                MediaItem(type: .video, urlString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", aspectRatio: 0.56)
            ],
            likes: 932,
            isVideoCover: false
        ),
        Look(
            id: "6",
            author: "urban_explore",
            authorAvatar: imageUrl(seed: "avatar6", width: 200, height: 200),
            description: "City wanderer outfit today. High mobility and breathability.",
            category: .streetwear,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look6_a", width: 1000, height: 800), aspectRatio: 1.25),
                MediaItem(type: .image, urlString: imageUrl(seed: "look6_b", width: 800, height: 800), aspectRatio: 1.0)
            ],
            likes: 450,
            isVideoCover: false
        ),
        Look(
            id: "7",
            author: "retro_future",
            authorAvatar: imageUrl(seed: "avatar7", width: 200, height: 200),
            description: "Mixing the old with the modern elements.",
            category: .y2k,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look7", width: 800, height: 1200), aspectRatio: 0.67)
            ],
            likes: 129,
            isVideoCover: false
        ),
        Look(
            id: "8",
            author: "gorpcore_pro",
            authorAvatar: imageUrl(seed: "avatar8", width: 200, height: 200),
            description: "Mountain ready, city steady. Salomon and Arc'teryx daily.",
            category: .techwear,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look8_a", width: 800, height: 1000), aspectRatio: 0.8),
                MediaItem(type: .image, urlString: imageUrl(seed: "look8_b", width: 800, height: 1000), aspectRatio: 0.8)
            ],
            likes: 3105,
            isVideoCover: false
        ),
        Look(
            id: "9",
            author: "thrift_god",
            authorAvatar: imageUrl(seed: "avatar9", width: 200, height: 200),
            description: "Found this 1980s band tee for $2 today.",
            category: .vintage,
            mediaItems: [
                MediaItem(type: .video, urlString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", aspectRatio: 0.56)
            ],
            likes: 902,
            isVideoCover: true
        ),
        Look(
            id: "10",
            author: "chic_simple",
            authorAvatar: imageUrl(seed: "avatar10", width: 200, height: 200),
            description: "Less is more. A white tee and tailored trousers.",
            category: .minimalist,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look10_a", width: 800, height: 1000), aspectRatio: 0.8)
            ],
            likes: 85,
            isVideoCover: false
        ),
        Look(
            id: "11",
            author: "skate_punk",
            authorAvatar: imageUrl(seed: "avatar11", width: 200, height: 200),
            description: "Ready for the session.",
            category: .streetwear,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look11_a", width: 800, height: 800), aspectRatio: 1.0),
                MediaItem(type: .image, urlString: imageUrl(seed: "look11_b", width: 800, height: 800), aspectRatio: 1.0)
            ],
            likes: 540,
            isVideoCover: false
        ),
        Look(
            id: "12",
            author: "matrix_reborn",
            authorAvatar: imageUrl(seed: "avatar12", width: 200, height: 200),
            description: "All black leather looking straight out of a movie.",
            category: .techwear,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look12", width: 800, height: 1200), aspectRatio: 0.67)
            ],
            likes: 1234,
            isVideoCover: false
        ),
        Look(
            id: "13",
            author: "y2k_prince",
            authorAvatar: imageUrl(seed: "avatar13", width: 200, height: 200),
            description: "Baggy vibes. Stars and stripes.",
            category: .y2k,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look13", width: 800, height: 800), aspectRatio: 1.0)
            ],
            likes: 199,
            isVideoCover: false
        ),
        Look(
            id: "14",
            author: "classic_mens",
            authorAvatar: imageUrl(seed: "avatar14", width: 200, height: 200),
            description: "Suiting up with a casual twist.",
            category: .minimalist,
            mediaItems: [
                MediaItem(type: .image, urlString: imageUrl(seed: "look14_a", width: 800, height: 1000), aspectRatio: 0.8),
                MediaItem(type: .image, urlString: imageUrl(seed: "look14_b", width: 800, height: 1000), aspectRatio: 0.8)
            ],
            likes: 876,
            isVideoCover: false
        )
    ]
}
