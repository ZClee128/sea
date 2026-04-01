import SwiftUI
import AVFoundation
import Combine

class VideoThumbnailManager: ObservableObject {
    @Published var thumbnails: [String: UIImage] = [:]
    private var cache = NSCache<NSString, UIImage>()
    
    static let shared = VideoThumbnailManager()
    
    func getThumbnail(for resourceName: String) {
        // Check cache first
        if let cachedImage = cache.object(forKey: resourceName as NSString) {
            DispatchQueue.main.async {
                self.thumbnails[resourceName] = cachedImage
            }
            return
        }
        
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "mp4") else {
            print("Thumbnail Error: Video file \(resourceName).mp4 not found in bundle.")
            return
        }
        
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.apertureMode = .encodedPixels
        
        let time = CMTimeMake(value: 1, timescale: 60) // First frame
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: imageRef)
                
                // Cache it
                self.cache.setObject(thumbnail, forKey: resourceName as NSString)
                
                DispatchQueue.main.async {
                    self.thumbnails[resourceName] = thumbnail
                }
            } catch {
                print("Thumbnail Error: Failed to generate thumbnail for \(resourceName): \(error.localizedDescription)")
            }
        }
    }
}
