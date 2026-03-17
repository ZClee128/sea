import Foundation

struct PoseTip: Identifiable, Codable {
    var id: UUID = UUID()
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
    
    // Mock Data Generator with Magazine Context
    static let mockData: [PhotoModel] = [
        PhotoModel(
            id: "1", 
            imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=800&auto=format&fit=crop", 
            category: "Portrait", 
            title: "Golden Hour Glow",
            subtitle: "Embracing natural warmth in urban settings",
            stylingTags: ["Vintage", "Warm Tones", "Outdoor"],
            poseTips: [
                PoseTip(title: "Direct Eye Contact", description: "Look directly into the lens to establish a strong connection with the viewer."),
                PoseTip(title: "Relaxed Shoulders", description: "Drop your shoulders to avoid looking tense and create a natural look.")
            ],
            issueNumber: "Issue Vol. 12"
        ),
        PhotoModel(
            id: "2", 
            imageUrl: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=800&auto=format&fit=crop", 
            category: "Studio", 
            title: "Noir Elegance",
            subtitle: "The art of shadow and minimalist composition",
            stylingTags: ["Monochrome", "High Contrast", "Minimalist"],
            poseTips: [
                PoseTip(title: "Soft Lighting", description: "Position yourself facing the primary light source for even illumination."),
                PoseTip(title: "Hand Placement", description: "Gently rest hands near the face or neck to add framing and interest.")
            ],
            issueNumber: "Issue Vol. 12"
        ),
        PhotoModel(
            id: "3", 
            imageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=800&auto=format&fit=crop", 
            category: "Casual", 
            title: "Candid Moments",
            subtitle: "Capturing the beauty in everyday simplicity",
            stylingTags: ["Natural", "Street", "Daily"],
            poseTips: [
                PoseTip(title: "Natural Smile", description: "Think of something genuinely funny to capture an authentic expression."),
                PoseTip(title: "Slight Head Tilt", description: "Tilt the head slightly to one side for a softer, more approachable vibe.")
            ],
            issueNumber: "Issue Vol. 11"
        ),
        PhotoModel(
            id: "4", 
            imageUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=800&auto=format&fit=crop", 
            category: "Street Style", 
            title: "Vivid Urbanism",
            subtitle: "Bold colors and dynamic motion in the heart of the city",
            stylingTags: ["Vibrant", "Fashion", "Motion"],
            poseTips: [
                PoseTip(title: "Dynamic Walk", description: "Walk towards the camera naturally to introduce movement and energy."),
                PoseTip(title: "Look Away", description: "Look off-camera to create a candid, storytelling aesthetic.")
            ],
            issueNumber: "Issue Vol. 11"
        )
    ]
}
