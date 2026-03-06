import Foundation

struct MockData {
    // Helper – only used for avatar thumbnails which remain remote
    static func imageUrl(seed: String, width: Int = 200, height: Int = 200) -> String {
        return "https://picsum.photos/seed/\(seed)/\(width)/\(height)"
    }

    // Convenience: create a local-image MediaItem
    static func img(_ name: String, ar: Double = 0.8) -> MediaItem {
        MediaItem(type: .image, urlString: nil, localImageName: name,
                  localVideoName: nil, coverImageName: nil, aspectRatio: ar)
    }

    // Convenience: create a local-video MediaItem
    static func vid(_ filename: String, cover: String, ar: Double = 0.5625) -> MediaItem {
        MediaItem(type: .video, urlString: nil, localImageName: nil,
                  localVideoName: filename, coverImageName: cover, aspectRatio: ar)
    }

    static var looks: [Look] = [
        Look(
            id: "1",
            author: "sumo_street",
            authorAvatar: imageUrl(seed: "avatar1"),
            description: "Tokyo street style 2026. Heavy layers and tactical gear.",
            category: .streetwear,
            mediaItems: [img("mock_1"), img("mock_2")],
            likes: 1205,
            isVideoCover: false
        ),
        Look(
            id: "2",
            author: "vintage_vibes",
            authorAvatar: imageUrl(seed: "avatar2"),
            description: "90s oversized fit. Always a classic look for the weekend.",
            category: .vintage,
            mediaItems: [img("mock_3", ar: 1.0), img("mock_4", ar: 1.0), img("mock_5", ar: 1.0)],
            likes: 853,
            isVideoCover: false
        ),
        Look(
            id: "3",
            author: "tech_ninja",
            authorAvatar: imageUrl(seed: "avatar3"),
            description: "Rain or shine. Tactical aesthetic showcasing waterproofing.",
            category: .techwear,
            mediaItems: [vid("ootd1.mp4", cover: "ootd1_cover", ar: 9/16)],
            likes: 2100,
            isVideoCover: true
        ),
        Look(
            id: "4",
            author: "y2k_angel",
            authorAvatar: imageUrl(seed: "avatar4"),
            description: "Cyberpunk neon lights matching the Y2K aesthetic.",
            category: .y2k,
            mediaItems: [img("mock_6", ar: 0.67)],
            likes: 342,
            isVideoCover: false
        ),
        Look(
            id: "5",
            author: "minimal_boy",
            authorAvatar: imageUrl(seed: "avatar5"),
            description: "Clean lines and neutral tones.",
            category: .minimalist,
            mediaItems: [img("mock_7"), vid("ootd1.mp4", cover: "ootd1_cover", ar: 9/16)],
            likes: 932,
            isVideoCover: false
        ),
        Look(
            id: "6",
            author: "urban_explore",
            authorAvatar: imageUrl(seed: "avatar6"),
            description: "City wanderer outfit today. High mobility and breathability.",
            category: .streetwear,
            mediaItems: [img("mock_8", ar: 1.25), img("mock_9", ar: 1.0)],
            likes: 450,
            isVideoCover: false
        ),
        Look(
            id: "7",
            author: "retro_future",
            authorAvatar: imageUrl(seed: "avatar7"),
            description: "Mixing the old with the modern elements.",
            category: .y2k,
            mediaItems: [img("mock_10", ar: 0.67)],
            likes: 129,
            isVideoCover: false
        ),
        Look(
            id: "8",
            author: "gorpcore_pro",
            authorAvatar: imageUrl(seed: "avatar8"),
            description: "Mountain ready, city steady. Salomon and Arc'teryx daily.",
            category: .techwear,
            mediaItems: [img("mock_11"), img("mock_12")],
            likes: 3105,
            isVideoCover: false
        ),
        Look(
            id: "9",
            author: "thrift_god",
            authorAvatar: imageUrl(seed: "avatar9"),
            description: "Found this 1980s band tee for $2 today.",
            category: .vintage,
            mediaItems: [vid("ootd1.mp4", cover: "ootd1_cover", ar: 9/16)],
            likes: 902,
            isVideoCover: true
        ),
        Look(
            id: "10",
            author: "chic_simple",
            authorAvatar: imageUrl(seed: "avatar10"),
            description: "Less is more. A white tee and tailored trousers.",
            category: .minimalist,
            mediaItems: [img("mock_13")],
            likes: 85,
            isVideoCover: false
        ),
        Look(
            id: "11",
            author: "skate_punk",
            authorAvatar: imageUrl(seed: "avatar11"),
            description: "Ready for the session.",
            category: .streetwear,
            mediaItems: [img("mock_14", ar: 1.0), img("mock_15", ar: 1.0)],
            likes: 540,
            isVideoCover: false
        ),
        Look(
            id: "12",
            author: "matrix_reborn",
            authorAvatar: imageUrl(seed: "avatar12"),
            description: "All black leather looking straight out of a movie.",
            category: .techwear,
            mediaItems: [img("mock_16", ar: 0.67)],
            likes: 1234,
            isVideoCover: false
        ),
        Look(
            id: "13",
            author: "y2k_prince",
            authorAvatar: imageUrl(seed: "avatar13"),
            description: "Baggy vibes. Stars and stripes.",
            category: .y2k,
            mediaItems: [img("mock_1", ar: 1.0)],
            likes: 199,
            isVideoCover: false
        ),
        Look(
            id: "14",
            author: "classic_mens",
            authorAvatar: imageUrl(seed: "avatar14"),
            description: "Suiting up with a casual twist.",
            category: .minimalist,
            mediaItems: [img("mock_2"), img("mock_3")],
            likes: 876,
            isVideoCover: false
        )
    ]
}
