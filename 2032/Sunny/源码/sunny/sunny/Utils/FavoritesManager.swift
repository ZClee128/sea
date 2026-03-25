import SwiftUI
import Combine

class FavoritesManager: ObservableObject {
    @Published var favoriteIDs: Set<String> = [] {
        didSet {
            save()
        }
    }
    
    private let saveKey = "favorites_ids"
    
    static let shared = FavoritesManager()
    
    private init() {
        load()
    }
    
    func isFavorite(id: UUID) -> Bool {
        favoriteIDs.contains(id.uuidString)
    }
    
    func toggle(id: UUID) {
        let idString = id.uuidString
        if favoriteIDs.contains(idString) {
            favoriteIDs.remove(idString)
        } else {
            favoriteIDs.insert(idString)
        }
    }
    
    private func save() {
        let array = Array(favoriteIDs)
        UserDefaults.standard.set(array, forKey: saveKey)
    }
    
    private func load() {
        if let array = UserDefaults.standard.stringArray(forKey: saveKey) {
            favoriteIDs = Set(array)
        }
    }
}
