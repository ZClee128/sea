import Foundation

struct Recipe: Identifiable, Hashable {
    var id: String { title }
    let title: String
    let category: String
    let imageName: String
    let story: String
    let ingredients: [String]
    let steps: [String]
    let videoURL: String? // nil means no video available
    var isPremium: Bool = false
    var chefName: String = "Chef"
}
