import Foundation

struct PoseTip: Identifiable, Codable {
    var id: UUID? = UUID()
    let title: String
    let description: String
}

struct PhotoModel: Identifiable, Codable {
    let id: String
    let imageUrl: String
    let category: String
    let title: String          // Added for Magazine Title
    let subtitle: String       // Added for Editorial Subtitle
    let stylingTags: [String]   // Added for Fashion/Styling context
    let poseTips: [PoseTip]
    let issueNumber: String    // Added for Magazine Issue context
    var isPremium: Bool = false
    var coinPrice: Int = 0
    
    // Mock Data Generator with Magazine Context
    static let mockData: [PhotoModel] = [
        PhotoModel(
            id: "1",
            imageUrl: "Golden Hour Glow",
            category: "Editorial",
            title: "Golden Hour Glow",
            subtitle: "Mastering the warmth of natural light in cinematic portraiture.",
            stylingTags: ["Cinematic", "Warm Tones", "Sunset"],
            poseTips: [
                PoseTip(title: "Lens Flare Control", description: "Position the sun partially behind the subject to create beautiful rays without losing detail."),
                PoseTip(title: "Golden Skin Tones", description: "Adjust white balance slightly towards the warm side to enhance the sunset glow.")
            ],
            issueNumber: "Issue Vol. 24",
            isPremium: false,
            coinPrice: 0
        ),
        PhotoModel(
            id: "2",
            imageUrl: "Noir Elegance",
            category: "Studio",
            title: "The Noir Aesthetic",
            subtitle: "Exploring high-contrast shadows and minimalist studio compositions.",
            stylingTags: ["Monochrome", "High Contrast", "Moody"],
            poseTips: [
                PoseTip(title: "Rembrandt Lighting", description: "Position your light at a 45-degree angle to create the classic light triangle on the cheek."),
                PoseTip(title: "Negative Space", description: "Use deep shadows to frame the subject and draw focus to the eyes.")
            ],
            issueNumber: "Issue Vol. 24",
            isPremium: false,
            coinPrice: 0
        ),
        PhotoModel(
            id: "3",
            imageUrl: "Candid Moments",
            category: "Street",
            title: "City Neon Dreams",
            subtitle: "Capturing the vibrant energy of night-time urban environments.",
            stylingTags: ["Neon", "Night", "Urban"],
            poseTips: [
                PoseTip(title: "Slow Shutter Motion", description: "Use a slightly slower shutter speed to capture background movement while keeping the subject sharp."),
                PoseTip(title: "Color Contrast", description: "Find neon signs with complementary colors (e.g., blue and orange) to make the image pop.")
            ],
            issueNumber: "Issue Vol. 23",
            isPremium: true,
            coinPrice: 99
        ),
        PhotoModel(
            id: "4",
            imageUrl: "Vivid Urbanism",
            category: "Avant-Garde",
            title: "Modern Vibrancy",
            subtitle: "A bold take on traditional fashion covers with avant-garde styling.",
            stylingTags: ["Fashion", "Vibrant", "Modern"],
            poseTips: [
                PoseTip(title: "Bold Expressions", description: "Encourage the subject to use strong, non-traditional facial expressions to match the high-fashion vibe."),
                PoseTip(title: "Styling Focal Point", description: "Identify the key piece of clothing or accessory and ensure it is highlighted by the lighting.")
            ],
            issueNumber: "Issue Vol. 23",
            isPremium: true,
            coinPrice: 149
        )
    ]
}
