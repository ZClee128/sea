import Foundation

struct VideoLesson {
    let id: String
    let title: String
    let subtitle: String
    let videoUrlString: String
    let thumbnailName: String
    let duration: String
    let isPremium: Bool // If true, requires coins
    
    var isUnlocked: Bool {
        if !isPremium { return true }
        return UserDefaults.standard.bool(forKey: "unlocked_\(id)")
    }
    
    func unlock() {
        UserDefaults.standard.set(true, forKey: "unlocked_\(id)")
    }
}
