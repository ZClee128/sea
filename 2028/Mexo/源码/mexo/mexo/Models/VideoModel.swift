import Foundation

struct VideoModel: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let videoUrl: String
    let thumbnailUrl: String
    let duration: String
    var isPremium: Bool = false
    var coinPrice: Int = 0
    
    // Mock Data Generator with local assets
    static let mockData: [VideoModel] = [
        VideoModel(
            id: "v1",
            title: "Mastering Natural Light",
            description: "Learn how to use window light and natural outdoor lighting to create stunning, soft portraits without expensive gear.",
            videoUrl: "Mastering Natural Light",
            thumbnailUrl: "Mastering Natural Light",
            duration: "00:20",
            isPremium: false,
            coinPrice: 0
        ),
        VideoModel(
            id: "v2",
            title: "Dynamic Posing Walkthrough",
            description: "A complete guide to directing your subject to move naturally, avoiding stiff poses and capturing authentic moments.",
            videoUrl: "Dynamic Posing Walkthrough",
            thumbnailUrl: "Dynamic Posing Walkthrough",
            duration: "00:13",
            isPremium: false,
            coinPrice: 0
        ),
        VideoModel(
            id: "v3",
            title: "Studio Lighting Basics",
            description: "Understand the fundamentals of key, fill, and rim lights to sculpt your subject's face beautifully in a controlled studio environment.",
            videoUrl: "Studio Lighting Basics",
            thumbnailUrl: "Studio Lighting Basics",
            duration: "00:09",
            isPremium: true,
            coinPrice: 199
        ),
        VideoModel(
            id: "v4",
            title: "Editing for Soft Skin Tones",
            description: "Post-processing techniques to professionally retouch portraits while maintaining skin texture and natural color grading.",
            videoUrl: "Editing for Soft Skin Tones",
            thumbnailUrl: "Editing for Soft Skin Tones",
            duration: "00:17",
            isPremium: true,
            coinPrice: 299
        )
    ]
}
