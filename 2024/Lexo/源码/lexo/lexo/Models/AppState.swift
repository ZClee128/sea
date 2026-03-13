import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var hasAgreed: Bool = UserDefaults.standard.bool(forKey: "hasAgreedToTerms") {
        didSet {
            UserDefaults.standard.set(hasAgreed, forKey: "hasAgreedToTerms")
        }
    }
    
    @Published var hasCompletedQuiz: Bool = UserDefaults.standard.bool(forKey: "hasCompletedQuiz") {
        didSet {
            UserDefaults.standard.set(hasCompletedQuiz, forKey: "hasCompletedQuiz")
        }
    }
    
    @Published var favoriteItems: [String] = UserDefaults.standard.stringArray(forKey: "favoriteItems") ?? [] {
        didSet {
            UserDefaults.standard.set(favoriteItems, forKey: "favoriteItems")
        }
    }
    
    @Published var totalCoins: Int = UserDefaults.standard.integer(forKey: "totalCoins") {
        didSet {
            UserDefaults.standard.set(totalCoins, forKey: "totalCoins")
        }
    }
    
    @Published var unlockedVideos: [String] = UserDefaults.standard.stringArray(forKey: "unlockedVideos") ?? [] {
        didSet {
            UserDefaults.standard.set(unlockedVideos, forKey: "unlockedVideos")
        }
    }
}
