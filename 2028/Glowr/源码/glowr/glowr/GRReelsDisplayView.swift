import SwiftUI
import AVKit

struct GRReelsDisplayView: View {
    @State private var selectedVideo: GRRunwayReel?
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(GRReelRegistry.samples) { video in
                            Button(action: { selectedVideo = video }) {
                                GRReelFeedCell(video: video)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedVideo) { video in
            GRReelPlaybackOverlay(video: video)
        }
    }
    
    var header: some View {
        VStack(alignment: .leading) {
            Text("REELS")
                .font(.system(size: 38, weight: .black, design: .serif))
                .tracking(5)
                .foregroundColor(.black)
            Text("FASHION TRENDS")
                .font(.caption)
                .tracking(2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct GRReelFeedCell: View {
    let video: GRRunwayReel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                // Video Thumbnail
                Image(video.thumbnailName)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(15)
                    .clipped()
                    .overlay(Color.black.opacity(0.1))
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                if #available(iOS 14.0, *) {
                    Text(video.duration)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .padding(12)
                } else {
                    // Fallback on earlier versions
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Text(video.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct GRReelPlaybackOverlay: View {
    let video: GRRunwayReel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let url = Bundle.main.url(forResource: video.videoFileName, withExtension: "mp4") {
                AVPlayerControllerWrapper(url: url)
                    .edgesIgnoringSafeArea(.all)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Video file not found")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(video.videoFileName + ".mp4")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3).clipShape(Circle()))
            }
            .padding()
        }
    }
}

struct AVPlayerControllerWrapper: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVQueuePlayer(url: url)
        
        // Ensure audio session is correctly set every time a player is created
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
        
        // Essential for background playback
        player.allowsExternalPlayback = true
        player.preventsDisplaySleepDuringVideoPlayback = true
        
        context.coordinator.player = player
        context.coordinator.controller = controller
        context.coordinator.looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        
        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        player.play()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var looper: AVPlayerLooper?
        var player: AVQueuePlayer?
        weak var controller: AVPlayerViewController?
        
        override init() {
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(handleDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        
        @objc func handleDidEnterBackground() {
            // Detach player from controller to keep audio playing in background
            controller?.player = nil
        }
        
        @objc func handleWillEnterForeground() {
            // Re-attach player when returning to foreground
            controller?.player = player
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
