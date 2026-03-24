import SwiftUI
import AVKit

struct VideoClip: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let url: String
    let description: String
}

@available(iOS 14.0, *)
struct CoutureClipsView: View {
    @AppStorage("backgroundLoopEnabled") private var backgroundLoopEnabled = true
    
    let spotlightClips = [
        VideoClip(title: "Cyber Awakening", subtitle: "2026 Opening Night", url: "", description: "The full cinematic opening of our digital couture showcase, featuring bioluminescent fabrics and reactive structural elements."),
        VideoClip(title: "The Silk Alchemy", subtitle: "Behind the Scenes", url: "", description: "An exclusive look at the procedural generation and digital weaving process of our latest smart-silk collection.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RUNWAY")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(NeonCouture.secondary)
                        Text("Catwalk Moments")
                            .font(.system(size: 34, weight: .black, design: .serif))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Two Featured Videos
                    ForEach(spotlightClips) { clip in
                        VStack(alignment: .leading, spacing: 18) {
                            LoopingVideoPlayer(resourceName: clip.title)
                                .frame(height: 240)
                                .cornerRadius(24)
                                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(clip.title.uppercased())
                                    .font(.headline)
                                    .foregroundColor(NeonCouture.primary)
                                
                                Text(clip.subtitle)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(clip.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Stay tuned for upcoming collection highlights and exclusive designer interviews.")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .background(NeonCouture.background.edgesIgnoringSafeArea(.all))
        }
    }
}

@available(iOS 14.0, *)
struct LoopingVideoPlayer: View {
    let resourceName: String
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayerView(resourceName: resourceName, player: $player)
    }
}

@available(iOS 14.0, *)
struct VideoPlayerView: UIViewControllerRepresentable {
    let resourceName: String
    @Binding var player: AVPlayer?
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        
        @objc func handleAppResign() {
            let loopEnabled = UserDefaults.standard.bool(forKey: "backgroundLoopEnabled")
            // Default to true if not set, match AppStorage default
            let actualEnabled = UserDefaults.standard.object(forKey: "backgroundLoopEnabled") == nil ? true : loopEnabled
            
            if !actualEnabled {
                player?.pause()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = true
        controller.updatesNowPlayingInfoCenter = true
        
        if let path = Bundle.main.path(forResource: resourceName, ofType: "mp4") {
            let asset = AVAsset(url: URL(fileURLWithPath: path))
            let item = AVPlayerItem(asset: asset)
            let avPlayer = AVPlayer(playerItem: item)
            
            if #available(iOS 15.0, *) {
                avPlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            }
            avPlayer.preventsDisplaySleepDuringVideoPlayback = true
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
                avPlayer.seek(to: .zero)
                avPlayer.play()
            }
            
            // Register for background notifications at the coordinator level
            context.coordinator.player = avPlayer
            NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.handleAppResign), name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.handleAppResign), name: UIApplication.didEnterBackgroundNotification, object: nil)
            
            controller.player = avPlayer
            
            // Refined: ONLY use async for the binding update
            DispatchQueue.main.async {
                self.player = avPlayer
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct CoutureClipsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            CoutureClipsView()
        } else {
            // Fallback on earlier versions
        }
    }
}
