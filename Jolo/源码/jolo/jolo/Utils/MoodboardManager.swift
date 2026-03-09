import Foundation

class MoodboardManager {
    static let shared = MoodboardManager()
    private let storageKey = "vogueVibeMoodboardItems"
    
    private init() {}
    
    func getSavedItems() -> [FeedItem] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        do {
            let items = try JSONDecoder().decode([FeedItem].self, from: data)
            return items
        } catch {
            print("Failed to decode saved items: \(error)")
            // If schema changed and decoding failed, gracefully clear old corrupted data
            UserDefaults.standard.removeObject(forKey: storageKey)
            return []
        }
    }
    
    func saveItem(_ item: FeedItem) {
        var currentItems = getSavedItems()
        if !currentItems.contains(where: { $0.id == item.id }) {
            currentItems.insert(item, at: 0)
            save(items: currentItems)
        }
    }
    
    func removeItem(withId id: String) {
        var currentItems = getSavedItems()
        currentItems.removeAll { $0.id == id }
        save(items: currentItems)
    }
    
    func isSaved(id: String) -> Bool {
        return getSavedItems().contains(where: { $0.id == id })
    }
    
    private func save(items: [FeedItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
