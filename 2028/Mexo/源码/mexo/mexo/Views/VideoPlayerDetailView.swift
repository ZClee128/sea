import SwiftUI
import AVKit
import Combine

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        controller.allowsPictureInPicturePlayback = true
        if #available(iOS 14.2, *) {
            controller.canStartPictureInPictureAutomaticallyFromInline = true
        } else {
            // Fallback on earlier versions
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

// 1. Specialized Manager for the Player Lifecycle
@available(iOS 14.0, *)
class VideoPlayerManager: NSObject, ObservableObject {
    @Published var player: AVQueuePlayer?
    @Published var aspectRatio: CGFloat = 16/9
    private var looper: AVPlayerLooper?
    private var sizeObserver: NSKeyValueObservation?
    
    func setup(videoUrl: String) {
        // Configure Global Audio Session every time we play
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }
        
        let extensions = ["mp4", "mov", "m4v"]
        var finalUrl: URL?
        
        for ext in extensions {
            if let path = Bundle.main.path(forResource: videoUrl, ofType: ext) {
                finalUrl = URL(fileURLWithPath: path)
                break
            }
        }
        
        if finalUrl == nil {
            finalUrl = URL(string: videoUrl)
        }
        
        guard let url = finalUrl else { return }
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Observe size to calculate aspect ratio
        sizeObserver = playerItem.observe(\.presentationSize, options: [.initial, .new]) { [weak self] item, change in
            DispatchQueue.main.async {
                let size = item.presentationSize
                if size.width > 0 && size.height > 0 {
                    self?.aspectRatio = size.width / size.height
                }
            }
        }
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Native Looping
        self.looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        // Background Policy (iOS 15+)
        if #available(iOS 15.0, *) {
            queuePlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        queuePlayer.allowsExternalPlayback = true
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
        
        self.player = queuePlayer
    }
    
    func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        looper = nil
        sizeObserver?.invalidate()
        sizeObserver = nil
    }
}

@available(iOS 14.0, *)
struct VideoPlayerDetailView: View {
    let video: VideoModel
    @StateObject private var manager = VideoPlayerManager()
    
    var body: some View {
        if #available(iOS 14.0, *) {
            VStack(spacing: 0) {
                // Video Player Area
                if let player = manager.player {
                    VideoPlayerView(player: player)
                        .aspectRatio(manager.aspectRatio, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .edgesIgnoringSafeArea(.horizontal)
                } else {
                    Color.black
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)))
                }
                
                // Video Information
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(video.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "clock")
                            Text(video.duration)
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text("Description")
                            .font(.headline)
                        
                        Text(video.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                manager.setup(videoUrl: video.videoUrl)
            }
            .onDisappear {
                // IMPORTANT: Use Application State to decide if we should actually stop
                // If backgrounding, ApplicationState will be .background or .inactive
                // If we are .active, it means the user actually clicked 'Back'
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if UIApplication.shared.applicationState == .active {
                        manager.stop()
                    }
                }
            }
        } else {
            Text("Requires iOS 14+")
        }
    }
}

// Previews
struct VideoPlayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                VideoPlayerDetailView(video: VideoModel.mockData[0])
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
