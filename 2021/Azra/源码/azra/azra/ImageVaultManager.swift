import UIKit

class ImageVaultManager {
    static let shared = ImageVaultManager()
    private let fileManager = FileManager.default
    
    private init() {}
    
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveImage(_ image: UIImage, withName name: String) -> Bool {
        guard let data = image.pngData() else { return false }
        let fileURL = documentsDirectory.appendingPathComponent("\(name).png")
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return false
        }
    }
    
    func loadImages() -> [(name: String, image: UIImage)] {
        var images: [(name: String, image: UIImage)] = []
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for url in fileURLs where url.pathExtension == "png" {
                if let imageData = try? Data(contentsOf: url),
                   let image = UIImage(data: imageData) {
                    let name = url.deletingPathExtension().lastPathComponent
                    images.append((name: name, image: image))
                }
            }
        } catch {
            print("Error loading images: \(error.localizedDescription)")
        }
        
        // Return sorted by name (which will usually be timestamp if formatted as such)
        return images.sorted { $0.name > $1.name }
    }
    
    func deleteImage(named name: String) -> Bool {
        let fileURL = documentsDirectory.appendingPathComponent("\(name).png")
        do {
            try fileManager.removeItem(at: fileURL)
            return true
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
            return false
        }
    }
}
