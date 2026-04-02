import Foundation
import Combine
import SwiftUI

@available(iOS 15.0, *)
class GalleryManager: ObservableObject {
    static let shared = GalleryManager()
    
    @Published var compositions: [InspoComposition] = []
    private let fileName = "Gallery.json"
    
    private init() {
        loadGallery()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    func saveComposition(muse: MuseItem, quote: String, fontIndex: Int, textColorHex: String, opacity: Double) {
        let newComposition = InspoComposition(
            muse: muse,
            quote: quote,
            fontIndex: fontIndex,
            textColorHex: textColorHex,
            overlayOpacity: opacity
        )
        
        compositions.insert(newComposition, at: 0)
        saveToDisk()
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(compositions)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save gallery: \(error)")
        }
    }
    
    func loadGallery() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            compositions = try JSONDecoder().decode([InspoComposition].self, from: data)
        } catch {
            print("Failed to load gallery: \(error)")
        }
    }
    
    func deleteComposition(at indexSet: IndexSet) {
        compositions.remove(atOffsets: indexSet)
        saveToDisk()
    }
    
    // FEATURED TEMPLATES
    func getFeaturedTemplates(muses: [MuseItem]) -> [StudioTemplate] {
        guard muses.count >= 3 else { return [] }
        return [
            StudioTemplate(
                title: "Dawn Harmony",
                muse: muses[0],
                quote: "Dawn is a reminder of rebirth.",
                fontIndex: 0,
                textColorHex: "#FFFFFF",
                overlayOpacity: 0.3
            ),
            StudioTemplate(
                title: "Forest Solitude",
                muse: muses[1],
                quote: "The trees are my oldest friends.",
                fontIndex: 2,
                textColorHex: "#F0FFF0",
                overlayOpacity: 0.5
            ),
            StudioTemplate(
                title: "Urban Clarity",
                muse: muses[2],
                quote: "Geometry in the chaos.",
                fontIndex: 1,
                textColorHex: "#ADD8E6",
                overlayOpacity: 0.4
            )
        ]
    }
}
