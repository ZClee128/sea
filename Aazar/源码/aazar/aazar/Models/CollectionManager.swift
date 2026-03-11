import Foundation

struct ImageCollection: Codable {
    let id: String
    var name: String
    var imageIds: [String]
}

class CollectionManager {
    static let shared = CollectionManager()
    private let defaults = UserDefaults.standard
    private let collectionsKey = "app_collections"
    
    // Auto-migrate old "favorites" to a default "My Favorites" collection if needed
    private init() {
        if collections.isEmpty {
            let legacyFavs = defaults.stringArray(forKey: "favorites") ?? []
            let defaultCollection = ImageCollection(id: UUID().uuidString, name: "My Favorites", imageIds: legacyFavs)
            saveCollections([defaultCollection])
        }
    }
    
    var collections: [ImageCollection] {
        guard let data = defaults.data(forKey: collectionsKey),
              let decoded = try? JSONDecoder().decode([ImageCollection].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func saveCollections(_ newCollections: [ImageCollection]) {
        if let encoded = try? JSONEncoder().encode(newCollections) {
            defaults.set(encoded, forKey: collectionsKey)
        }
    }
    
    func createCollection(name: String) {
        var current = collections
        let newCollection = ImageCollection(id: UUID().uuidString, name: name, imageIds: [])
        current.append(newCollection)
        saveCollections(current)
    }
    
    func deleteCollection(id: String) {
        var current = collections
        current.removeAll { $0.id == id }
        saveCollections(current)
    }
    
    func addImage(_ imageId: String, to collectionId: String) {
        var current = collections
        if let index = current.firstIndex(where: { $0.id == collectionId }) {
            if !current[index].imageIds.contains(imageId) {
                current[index].imageIds.append(imageId)
                saveCollections(current)
            }
        }
    }
    
    func removeImage(_ imageId: String, from collectionId: String) {
        var current = collections
        if let index = current.firstIndex(where: { $0.id == collectionId }) {
            current[index].imageIds.removeAll { $0 == imageId }
            saveCollections(current)
        }
    }
    
    func isImage(_ imageId: String, in collectionId: String) -> Bool {
        if let collection = collections.first(where: { $0.id == collectionId }) {
            return collection.imageIds.contains(imageId)
        }
        return false
    }
}
