//
//  VideoThumbnailView.swift
//  vibble
//

import SwiftUI
import AVFoundation

class ThumbnailCache {
    static let shared = NSCache<NSString, UIImage>()
}

@available(iOS 14.0, *)
struct VideoThumbnailView: View {
    let videoName: String
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(gradient: Gradient(colors: [Theme.primary.opacity(0.6), Theme.secondary.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color.white.opacity(0.5))
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white)) // iOS 14 兼容
                        }
                    )
            }
        }
        .onAppear {
            generateThumbnailAsync()
        }
    }
    
    private func generateThumbnailAsync() {
        if let cachedImage = ThumbnailCache.shared.object(forKey: videoName as NSString) {
            self.thumbnail = cachedImage
            return
        }
        
        let possibleUrls = [
            Bundle.main.url(forResource: videoName, withExtension: "mp4"),
            Bundle.main.url(forResource: videoName, withExtension: "mp4", subdirectory: "mp4"),
            Bundle.main.url(forResource: videoName, withExtension: nil)
        ]
        
        guard let url = possibleUrls.compactMap({ $0 }).first else { return }
        
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 600, height: 600)
        
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                ThumbnailCache.shared.setObject(uiImage, forKey: videoName as NSString)
                
                DispatchQueue.main.async {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.thumbnail = uiImage
                    }
                }
            } catch {
                print("Thumbnail failed: \(error.localizedDescription)")
            }
        }
    }
}
