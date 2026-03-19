import Foundation
import Combine

struct MatchHistoryItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    let designName: String
    let category: String
    let imageName: String
    let occasion: String
    let mood: String
    
    init(id: UUID = UUID(), date: Date = Date(), designName: String, category: String, imageName: String, occasion: String, mood: String) {
        self.id = id
        self.date = date
        self.designName = designName
        self.category = category
        self.imageName = imageName
        self.occasion = occasion
        self.mood = mood
    }
}

class MatchHistoryManager: ObservableObject {
    static let shared = MatchHistoryManager()
    
    @Published var history: [MatchHistoryItem] = []
    
    private let storageKey = "style_match_history"
    
    init() {
        loadHistory()
    }
    
    func saveMatch(design: NailDesign, occasion: String, mood: String) {
        let newItem = MatchHistoryItem(
            designName: design.name,
            category: design.category,
            imageName: design.imageName,
            occasion: occasion,
            mood: mood
        )
        
        history.insert(newItem, at: 0)
        // Keep only the last 10 matches
        if history.count > 10 {
            history = Array(history.prefix(10))
        }
        
        saveToDisk()
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([MatchHistoryItem].self, from: data) {
            history = decoded
        }
    }
    
    func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
