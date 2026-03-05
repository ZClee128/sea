import Foundation
import Combine
import SwiftUI

// Base Data Models
struct MediaItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var urlString: String
    var isVideo: Bool
    var videoUrlString: String?
    var author: String
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
    
    // MARK: - Persistence
    func saveMoodboard(_ moodboard: Moodboard) {
        moodboards.append(moodboard)
        persistMoodboards()
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
        
        self.coins = UserDefaults.standard.integer(forKey: coinsKey)
    }
}
