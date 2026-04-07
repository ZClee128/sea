import SwiftUI

/// A moment of urban lifestyle curated by the community.
struct UrbanMoment: Identifiable, Codable {
    var id = UUID()
    let title: String
    let rhythm: String
    let location: String
    let colorHex: String // Codable friendly
    var isVideo: Bool = false
    var videoUrl: String = ""
    var number: String = "01"
    
    // Enriched Fields
    var curatorName: String = "Urban Curator"
    var curatorBio: String = "Discovering the hidden soul of the city, one moment at a time."
    var fullDescription: String = ""
    var tags: [String] = ["Urban", "Lifestyle", "Modern"]
    var discoverySpots: [DiscoverySpot] = []
    
    var color: Color {
        // Simple mapping for demo colors
        if colorHex.contains("pink") { return .pink.opacity(0.1) }
        if colorHex.contains("blue") { return .blue.opacity(0.1) }
        if colorHex.contains("green") { return .green.opacity(0.1) }
        if colorHex.contains("purple") { return .purple.opacity(0.1) }
        if colorHex.contains("orange") { return .orange.opacity(0.1) }
        return .gray.opacity(0.1)
    }
}

/// A specific physical spot linked to a moment.
struct DiscoverySpot: Identifiable, Codable {
    var id = UUID()
    let title: String
    let imageName: String
    let category: String
    
    // Visual Content
    var imageData: Data? = nil
    
    // Economy Fields
    var isBoosted: Bool = false
    var boostCount: Int = 0
}

/// A task or item in the urban life planner.
struct PlannerItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}

/// A poetic quote for the gallery.
struct LifestyleQuote: Identifiable, Codable {
    var id = UUID()
    let text: String
    let author: String
}
