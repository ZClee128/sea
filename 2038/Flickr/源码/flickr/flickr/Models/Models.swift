import Foundation

struct MuseItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let title: String
    let imageName: String
    let description: String
    let category: String
    let isEditorialFeatured: Bool
    var videoURL: String? = nil
    
    // Rich Detail Fields
    var story: String = ""
    var aestheticAttributes: [String] = []
    var colorPalette: [String] = [] // Hex codes
    var location: String = "Digital Archive"
    var isPremium: Bool = false
}

struct FocusSession: Identifiable {
    var id: UUID = UUID()
    let title: String
    let videoURL: String
    let mantra: String
}

struct ChatMessage: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let text: String
    let sender: MessageSender
    let timestamp: Date
}

enum MessageSender: String, Codable {
    case me
    case partner
}

struct ChatSession: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let partner: MuseItem
    var lastMessage: String
    var messages: [ChatMessage]
    var isBlocked: Bool = false
}

struct CoinPackage: Identifiable, Hashable {
    let id: String // Product ID
    let name: String
    let amount: Int
    let price: String
}
