import Foundation
import Combine

struct DanceVideo: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let duration: String
    let difficulty: String
    let description: String
    let fileName: String
    let unlockCost: Int
    var isUnlocked: Bool
}

class VideoData: ObservableObject {
    @Published var videos: [DanceVideo] = [
        DanceVideo(title: "Ballet Basics", category: "Ballet", duration: "00:07", difficulty: "Beginner", description: "Master the fundamental positions and movements of classical ballet.", fileName: "Ballet Basics", unlockCost: 0, isUnlocked: true),
        DanceVideo(title: "Contemporary Flow", category: "Contemporary", duration: "00:14", difficulty: "Intermediate", description: "Explore fluid transitions and expressive ground work techniques.", fileName: "Contemporary Flow", unlockCost: 10, isUnlocked: false),
        DanceVideo(title: "Street Style Foundation", category: "Street", duration: "00:16", difficulty: "Beginner", description: "Learn the core toprock and downrock patterns of urban dance.", fileName: "Street Style Foundation", unlockCost: 15, isUnlocked: false)
    ]
}
