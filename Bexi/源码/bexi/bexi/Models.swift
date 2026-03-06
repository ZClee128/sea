import Foundation
import Combine
import SwiftUI

struct MediaItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var urlString: String
    var isVideo: Bool
    var videoUrlString: String?
    var author: String
    var avatarUrlString: String?
    var description: String = ""
    var tags: [String] = []
    var createdAt: Date = Date()
}

struct Moodboard: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var items: [MediaItem] = []
    var createdAt: Date = Date()
}

// Storage Manager for iOS 13+
class StorageManager: ObservableObject {
    @Published var savedItems: [MediaItem] = []
    @Published var moodboards: [Moodboard] = []
    @Published var reportedItems: [String] = []
    @Published var blockedAuthors: [String] = []
    @Published var hasAcceptedTerms: Bool = false
    @Published var coins: Int = 0 {
        didSet {
            UserDefaults.standard.set(coins, forKey: coinsKey)
        }
    }
    
    // UserDefaults keys
    private let savedItemsKey = "bexi_saved_items"
    private let moodboardsKey = "bexi_moodboards"
    private let termsKey = "bexi_has_accepted_terms"
    private let coinsKey = "bexi_user_coins"
    private let reportedItemsKey = "bexi_reported_items"
    private let blockedAuthorsKey = "bexi_blocked_authors"
    
    init() {
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCoinsPurchased(_:)), name: NSNotification.Name("CoinsPurchased"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleCoinsPurchased(_ notification: Notification) {
        if let userInfo = notification.userInfo, let addedCoins = userInfo["coins"] as? Int {
            DispatchQueue.main.async {
                self.coins += addedCoins
            }
        }
    }
    
    // MARK: - App State
    func acceptTerms() {
        self.hasAcceptedTerms = true
        UserDefaults.standard.set(true, forKey: termsKey)
    }
    
    // MARK: - Saving
    func saveItem(_ item: MediaItem) {
        if !savedItems.contains(where: { $0.id == item.id || $0.urlString == item.urlString }) {
            savedItems.append(item)
            persistSavedItems()
        }
    }
    
    func removeItem(urlString: String) {
        savedItems.removeAll { $0.urlString == urlString }
        persistSavedItems()
    }
    
    func isSaved(urlString: String) -> Bool {
        return savedItems.contains(where: { $0.urlString == urlString })
    }
    
    // MARK: - Safety (Report & Block)
    func reportItem(urlString: String) {
        if !reportedItems.contains(urlString) {
            reportedItems.append(urlString)
            persistSafetyData()
            // Also remove from saved if reported
            removeItem(urlString: urlString)
        }
    }
    
    func blockAuthor(author: String) {
        if !blockedAuthors.contains(author) {
            blockedAuthors.append(author)
            persistSafetyData()
            // Remove any saved items from this author
            savedItems.removeAll { $0.author == author }
            persistSavedItems()
        }
    }
    
    // MARK: - Persistence
    func saveUserImage(image: UIImage, completion: @escaping (MediaItem?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Convert to JPEG
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Get documents directory
            let fileManager = FileManager.default
            guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Create unique filename
            let filename = UUID().uuidString + ".jpg"
            let fileURL = docsDir.appendingPathComponent(filename)
            
            do {
                try data.write(to: fileURL)
                
                // Store only the relative filename. iOS changes the document directory UUID on every launch!
                let newItem = MediaItem(urlString: filename, isVideo: false, author: "Me")
                
                DispatchQueue.main.async {
                    self.saveItem(newItem) // Add to library
                    completion(newItem)
                }
            } catch {
                print("Error saving image: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    func saveMoodboard(_ moodboard: Moodboard) {
        moodboards.append(moodboard)
        persistMoodboards()
    }
    
    private func persistSafetyData() {
        if let data = try? JSONEncoder().encode(reportedItems) {
            UserDefaults.standard.set(data, forKey: reportedItemsKey)
        }
        if let data = try? JSONEncoder().encode(blockedAuthors) {
            UserDefaults.standard.set(data, forKey: blockedAuthorsKey)
        }
    }
    
    private func persistSavedItems() {
        if let data = try? JSONEncoder().encode(savedItems) {
            UserDefaults.standard.set(data, forKey: savedItemsKey)
        }
    }
    
    private func persistMoodboards() {
        if let data = try? JSONEncoder().encode(moodboards) {
            UserDefaults.standard.set(data, forKey: moodboardsKey)
        }
    }
    
    private func loadData() {
        self.hasAcceptedTerms = UserDefaults.standard.bool(forKey: termsKey)
        
        if let data = UserDefaults.standard.data(forKey: savedItemsKey),
           let items = try? JSONDecoder().decode([MediaItem].self, from: data) {
            self.savedItems = items
        }
        
        if let data = UserDefaults.standard.data(forKey: moodboardsKey),
           let boards = try? JSONDecoder().decode([Moodboard].self, from: data) {
            self.moodboards = boards
        }
        
        if let data = UserDefaults.standard.data(forKey: reportedItemsKey),
           let items = try? JSONDecoder().decode([String].self, from: data) {
            self.reportedItems = items
        }
        
        if let data = UserDefaults.standard.data(forKey: blockedAuthorsKey),
           let authors = try? JSONDecoder().decode([String].self, from: data) {
            self.blockedAuthors = authors
        }
        
        self.coins = UserDefaults.standard.integer(forKey: coinsKey)
    }
}

// Pre-loaded content for the application feeds
struct ContentProvider {
    static let items: [MediaItem] = [
        MediaItem(urlString: "c1.jpeg", isVideo: true, videoUrlString: "c1.mp4", author: "Bexi Creator", avatarUrlString: "cosplay_8", description: "First look at our new content! Check it out below.", tags: ["trending", "showcase", "new"]),
        MediaItem(urlString: "c2.jpeg", isVideo: true, videoUrlString: "c2.mp4", author: "Anime Fan", avatarUrlString: "cosplay_7", description: "Trying out a new transition style. Super happy with how it came out!", tags: ["cosplay", "transition", "anime"]),
        MediaItem(urlString: "cosplay_8", isVideo: false, author: "Cosplay Queen", avatarUrlString: "cosplay_8", description: "Latest photoshoot from the convention. The lighting was absolutely perfect.", tags: ["cosplay", "photography", "photoshoot"]),
        MediaItem(urlString: "cosplay_7", isVideo: false, author: "Pro Gamer", avatarUrlString: "cosplay_7", description: "Ready for the next match. Setup is looking clean.", tags: ["gaming", "setup", "pro"]),
        MediaItem(urlString: "cosplay_6", isVideo: false, author: "Game Master", avatarUrlString: "cosplay_6", description: "Finally beat the final boss after 10 hours... My hands are shaking.", tags: ["gaming", "achievement", "boss"]),
        MediaItem(urlString: "cosplay_5", isVideo: false, author: "Style Icon", avatarUrlString: "cosplay_5", description: "OOTD. Mixing some vintage pieces with modern streetwear.", tags: ["style", "fashion", "ootd"]),
        MediaItem(urlString: "cosplay_4", isVideo: false, author: "Creative Mind", avatarUrlString: "cosplay_4", description: "Behind the scenes of my creative process.", tags: ["creative", "bts", "art"]),
        MediaItem(urlString: "cosplay_3", isVideo: false, author: "Adventurer", avatarUrlString: "cosplay_3", description: "Found this hidden gem while exploring the city today.", tags: ["explore", "adventure", "city"]),
        MediaItem(urlString: "cosplay_2", isVideo: false, author: "Tech Geek", avatarUrlString: "cosplay_2", description: "Reviewing the latest gear. Is it worth the hype? Link in bio.", tags: ["tech", "review", "trending"]),
        MediaItem(urlString: "cosplay_1", isVideo: false, author: "Bexi Creator", avatarUrlString: "cosplay_1", description: "Just relaxing and enjoying the vibes.", tags: ["chill", "vibes", "trending"])
    ]
}
