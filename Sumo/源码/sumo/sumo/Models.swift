import Foundation

enum LookCategory: String, CaseIterable, Codable, Hashable {
    case streetwear = "Streetwear"
    case vintage = "Vintage"
    case y2k = "Y2K"
    case techwear = "Techwear"
    case minimalist = "Minimalist"
}

enum MediaType: String, Codable {
    case image
    case video
}

struct MediaItem: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    let type: MediaType
    let urlString: String?        // remote URL for image/video
    let localImageName: String?   // xcassets image name
    let localVideoName: String?   // bundle .mp4 filename
    let coverImageName: String?   // xcassets thumbnail shown in feed
    let aspectRatio: Double // width / height
}

struct Look: Identifiable, Codable, Hashable {
    let id: String
    let author: String
    let authorAvatar: String
    let description: String
    let category: LookCategory
    let mediaItems: [MediaItem]
    let likes: Int
    let isVideoCover: Bool
    
    // For Equatable/Hashable
    static func == (lhs: Look, rhs: Look) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
