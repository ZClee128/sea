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
            issueNumber: "Issue Vol. 102",
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
            issueNumber: "Issue Vol. 102",
            isPremium: false,
            coinPrice: 0
        ),
        PhotoModel(
            id: "3",
            imageUrl: "editorial_minimalist_white",
            category: "Minimalist",
            title: "Pure Horizons",
            subtitle: "A study in monochromatic elegance and architectural silhouettes.",
            stylingTags: ["White", "Minimalist", "Structure"],
            poseTips: [
                PoseTip(title: "Vertical Alignment", description: "Align the subject's posture with architectural lines for a balanced, high-end feel."),
                PoseTip(title: "Soft Shadows", description: "Use subtle shadows to define the subject without breaking the clean aesthetic.")
            ],
            issueNumber: "Issue Vol. 101",
            isPremium: true,
            coinPrice: 99
        ),
        PhotoModel(
            id: "4",
            imageUrl: "editorial_golden_velvet",
            category: "Luxury",
            title: "Velvet Royalty",
            subtitle: "Rich textures and regal tones defining the new era of fashion.",
            stylingTags: ["Velvet", "Gold", "Luxury"],
            poseTips: [
                PoseTip(title: "Texture Contrast", description: "Pair smooth skin tones with the rough texture of velvet for visual depth."),
                PoseTip(title: "Regal Posture", description: "Keep shoulders back and chin slightly up to convey a sense of authority and grace.")
            ],
            issueNumber: "Issue Vol. 101",
            isPremium: true,
            coinPrice: 149
        ),
        PhotoModel(
            id: "5",
            imageUrl: "editorial_urban_chic",
            category: "Street",
            title: "Metropolis Chic",
            subtitle: "Redefining urban style through a lens of cinematic light and shadow.",
            stylingTags: ["Urban", "Blazer", "Daylight"],
            poseTips: [
                PoseTip(title: "Stride Action", description: "Capture the moment between steps for a dynamic, life-filled street aesthetic."),
                PoseTip(title: "Ambient Reflections", description: "Use glass storefronts to add layers and depth to your street compositions.")
            ],
            issueNumber: "Issue Vol. 100",
            isPremium: false,
            coinPrice: 0
        ),
        PhotoModel(
            id: "6",
            imageUrl: "editorial_ethereal_lace",
            category: "Artistic",
            title: "Ethereal Lace",
            subtitle: "A delicate dance of light through intricate patterns and soft movements.",
            stylingTags: ["Lace", "Soft Focus", "Ethereal"],
            poseTips: [
                PoseTip(title: "Motion Blur", description: "Use a slightly slower shutter to capture the fluid movement of the fabric."),
                PoseTip(title: "Backlit Patterns", description: "Position light behind the lace to highlight the intricate needlework.")
            ],
            issueNumber: "Issue Vol. 100",
            isPremium: true,
            coinPrice: 199
        ),
        PhotoModel(
            id: "7",
            imageUrl: "editorial_modern_sculptural",
            category: "Avant-Garde",
            title: "Sculpted Form",
            subtitle: "When fashion meets architecture in a monochrome geometric world.",
            stylingTags: ["Monochrome", "Geometric", "Hard Light"],
            poseTips: [
                PoseTip(title: "Angular Shapes", description: "Instruct the subject to create sharp angles with limbs to match the geometric background."),
                PoseTip(title: "Chiaroscuro", description: "Embrace the harsh divide between light and dark for a dramatic, sculptural effect.")
            ],
            issueNumber: "Issue Vol. 99",
            isPremium: true,
            coinPrice: 129
        ),
        PhotoModel(
            id: "8",
            imageUrl: "editorial_natural_serenity",
            category: "Natural",
            title: "Nature's Serenity",
            subtitle: "Finding peace and elegance in the raw beauty of the outdoors.",
            stylingTags: ["Nature", "Linen", "Natural Light"],
            poseTips: [
                PoseTip(title: "Soft Engagement", description: "A gentle smile or a gaze just off-camera creates a warm, approachable feeling."),
                PoseTip(title: "Organic Framing", description: "Use leaves and branches in the foreground to create a natural frame around the subject.")
            ],
            issueNumber: "Issue Vol. 99",
            isPremium: false,
            coinPrice: 0
        ),
        PhotoModel(
            id: "9",
            imageUrl: "Candid Moments",
            category: "Candid",
            title: "Neon Dreams",
            subtitle: "The vibrant neon pulse of a city that never sleeps.",
            stylingTags: ["Neon", "Night", "Vibrant"],
            poseTips: [
                PoseTip(title: "Reflected Color", description: "Allow the neon light to spill onto the subject's face for a stylized, colorful look."),
                PoseTip(title: "Low Light Focus", description: "Ensure the eyes are sharp even in challenging low-light environments.")
            ],
            issueNumber: "Issue Vol. 98",
            isPremium: true,
            coinPrice: 79
        ),
        PhotoModel(
            id: "10",
            imageUrl: "Vivid Urbanism",
            category: "Vibrant",
            title: "Urban Pulse",
            subtitle: "Capturing the high-velocity energy of modern street style.",
            stylingTags: ["Street Style", "Action", "Energy"],
            poseTips: [
                PoseTip(title: "Candid Energy", description: "Shoot continuously to catch the genuine, unposed energy of the street."),
                PoseTip(title: "Urban Texture", description: "Incorporate graffiti or brickwork to ground the high-fashion styling in reality.")
            ],
            issueNumber: "Issue Vol. 98",
            isPremium: true,
            coinPrice: 89
        )
    ]
}
