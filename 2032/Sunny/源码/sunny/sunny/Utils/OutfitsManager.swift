import SwiftUI
import Combine

struct SavedOutfit: Identifiable, Codable {
    let id: UUID
    let topPath: String?
    let bottomPath: String?
    let shoesPath: String?
    let date: Date
}

class OutfitsManager: ObservableObject {
    @Published var savedOutfits: [SavedOutfit] = [] {
        didSet {
            save()
        }
    }
    
    private let saveKey = "saved_outfits_list_v2"
    static let shared = OutfitsManager()
    
    private init() {
        load()
    }
    
    func saveOutfit(top: UIImage?, bottom: UIImage?, shoes: UIImage?) {
        let topPath = top != nil ? saveImageToDisk(top!) : nil
        let bottomPath = bottom != nil ? saveImageToDisk(bottom!) : nil
        let shoesPath = shoes != nil ? saveImageToDisk(shoes!) : nil
        
        let newOutfit = SavedOutfit(
            id: UUID(),
            topPath: topPath,
            bottomPath: bottomPath,
            shoesPath: shoesPath,
            date: Date()
        )
        savedOutfits.insert(newOutfit, at: 0)
    }
    
    private func saveImageToDisk(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        try? data.write(to: url)
        return fileName
    }
    
    func getImagePath(_ fileName: String) -> URL {
        getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func deleteOutfit(at offsets: IndexSet) {
        // Option: delete files from disk too
        savedOutfits.remove(atOffsets: offsets)
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(savedOutfits) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([SavedOutfit].self, from: data) {
            savedOutfits = decoded
        }
    }
}

