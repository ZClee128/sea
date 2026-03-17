import Foundation

struct VideoModel: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let videoUrl: String
    let thumbnailUrl: String
    let duration: String
    
    // Mock Data Generator using public royalty-free video URLs for demonstration
    static let mockData: [VideoModel] = [
        VideoModel(
            id: "v1",
            title: "Mastering Natural Light",
            description: "Learn how to use window light and natural outdoor lighting to create stunning, soft portraits without expensive gear.",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            thumbnailUrl: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=800&auto=format&fit=crop",
            duration: "03:15"
        ),
        VideoModel(
            id: "v2",
            title: "Dynamic Posing Walkthrough",
            description: "A complete guide to directing your subject to move naturally, avoiding stiff poses and capturing authentic moments.",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            thumbnailUrl: "https://images.unsplash.com/photo-1558223326-0e0ea6302e1c?q=80&w=800&auto=format&fit=crop",
            duration: "04:22"
        ),
        VideoModel(
            id: "v3",
            title: "Studio Lighting Basics",
            description: "Understand the fundamentals of key, fill, and rim lights to sculpt your subject's face beautifully in a controlled studio environment.",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            thumbnailUrl: "https://images.unsplash.com/photo-1598448375084-306fc172ba54?q=80&w=800&auto=format&fit=crop",
            duration: "05:40"
        ),
        VideoModel(
            id: "v4",
            title: "Editing for Soft Skin Tones",
            description: "Post-processing techniques to professionally retouch portraits while maintaining skin texture and natural color grading.",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            thumbnailUrl: "https://images.unsplash.com/photo-1621252179027-94459d278660?q=80&w=800&auto=format&fit=crop",
            duration: "02:50"
        )
    ]
}
