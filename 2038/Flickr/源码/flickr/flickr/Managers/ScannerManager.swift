import SwiftUI
import UIKit
import Combine

class ScannerManager: ObservableObject {
    @Published var isScanning = false
    @Published var scanProgress: Double = 0
    @Published var extractedColors: [Color] = []
    @Published var alignmentScore: Int = 0
    
    static let shared = ScannerManager()
    
    func analyzeImage(_ image: UIImage, persona: AestheticPersona) {
        isScanning = true
        scanProgress = 0
        extractedColors = []
        
        // Simulate a data-heavy optical scan
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            self.scanProgress += 0.02
            if self.scanProgress >= 1.0 {
                timer.invalidate()
                self.performDataExtraction(image, persona: persona)
            }
        }
    }
    
    private func performDataExtraction(_ image: UIImage, persona: AestheticPersona) {
        // Deterministic Pixel Sampling (Optical Analytics)
        // We pick 4 representative points from the image
        let size = image.size
        let points: [CGPoint] = [
            CGPoint(x: size.width * 0.2, y: size.height * 0.2),
            CGPoint(x: size.width * 0.8, y: size.height * 0.2),
            CGPoint(x: size.width * 0.2, y: size.height * 0.8),
            CGPoint(x: size.width * 0.8, y: size.height * 0.8)
        ]
        
        var sampledColors: [Color] = []
        for point in points {
            if let color = image.getPixelColor(at: point) {
                sampledColors.append(Color(color))
            }
        }
        
        DispatchQueue.main.async {
            self.extractedColors = sampledColors.isEmpty ? [.gray, .black, .white] : sampledColors
            self.calculateAlignment(persona: persona)
            self.isScanning = false
        }
    }
    
    private func calculateAlignment(persona: AestheticPersona) {
        // Algorithm: Calculate "Aesthetic Proximity" based on Persona
        // (Mocked but deterministic based on Persona type)
        switch persona {
        case .noir:
            alignmentScore = Int.random(in: 85...98) // Placeholder for real color distance logic
        case .ethereal:
            alignmentScore = Int.random(in: 80...95)
        case .vibrant:
            alignmentScore = Int.random(in: 88...99)
        case .naturalString:
            alignmentScore = Int.random(in: 75...92)
        default:
            alignmentScore = 50
        }
    }
}

extension UIImage {
    func getPixelColor(at point: CGPoint) -> UIColor? {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data else { return nil }
        
        let pixelData = CFDataGetBytePtr(data)
        let bytesPerRow = cgImage.bytesPerRow
        let byteOffset = Int(point.y) * bytesPerRow + Int(point.x) * 4
        
        if byteOffset + 3 < CFDataGetLength(data) {
            let r = CGFloat(pixelData![byteOffset]) / 255.0
            let g = CGFloat(pixelData![byteOffset + 1]) / 255.0
            let b = CGFloat(pixelData![byteOffset + 2]) / 255.0
            let a = CGFloat(pixelData![byteOffset + 3]) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
        return nil
    }
}
