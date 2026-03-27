import Foundation
import Combine

final class SavedStore: ObservableObject {
    static let shared = SavedStore()

    @Published private(set) var savedIDs: Set<String> = []

    private let key = "savedArtItemIDs"

    private init() {
        if let stored = UserDefaults.standard.array(forKey: key) as? [String] {
            savedIDs = Set(stored)
        }
    }

    func toggle(_ item: ArtItem) {
        let id = item.id.uuidString
        if savedIDs.contains(id) {
            savedIDs.remove(id)
        } else {
            savedIDs.insert(id)
        }
        UserDefaults.standard.set(Array(savedIDs), forKey: key)
    }

    func isSaved(_ item: ArtItem) -> Bool {
        savedIDs.contains(item.id.uuidString)
    }

    var savedItems: [ArtItem] {
        sampleArtItems.filter { savedIDs.contains($0.id.uuidString) }
    }
}
