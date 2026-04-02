import Foundation
import Combine
import SwiftUI

@available(iOS 15.0, *)
class ArchiveManager: ObservableObject {
    static let shared = ArchiveManager()
    
    @Published var archives: [MoodboardArchive] = []
    private let fileName = "MoodboardArchives.json"
    
    private init() {
        loadArchives()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    func saveArchive(muses: [MuseItem], keywords: String) {
        let newArchive = MoodboardArchive(muses: muses, keywords: keywords)
        archives.insert(newArchive, at: 0)
        saveToDisk()
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(archives)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save archives: \(error)")
        }
    }
    
    func loadArchives() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            archives = try JSONDecoder().decode([MoodboardArchive].self, from: data)
        } catch {
            print("Failed to load archives: \(error)")
        }
    }
    
    func deleteArchive(at indexSet: IndexSet) {
        archives.remove(atOffsets: indexSet)
        saveToDisk()
    }
}
