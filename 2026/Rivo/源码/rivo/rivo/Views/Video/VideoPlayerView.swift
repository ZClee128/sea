import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoName: String
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    
    var body: some View {
        VideoPlayerRepresentable(player: $player, looper: $looper, videoName: videoName)
            .onDisappear {
                player?.pause()
                player = nil
                looper = nil
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct VideoPlayerRepresentable: UIViewRepresentable {
    @Binding var player: AVQueuePlayer?
    @Binding var looper: AVPlayerLooper?
    let videoName: String
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        
        if let path = Bundle.main.path(forResource: videoName, ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            
            let queuePlayer = AVQueuePlayer(playerItem: item)
            let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            
            view.setPlayer(queuePlayer)
            
            // Background playback configuration
            queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
            queuePlayer.automaticallyWaitsToMinimizeStalling = false
            queuePlayer.allowsExternalPlayback = true
            
            DispatchQueue.main.async {
                self.player = queuePlayer
                self.looper = playerLooper
            }
            
            queuePlayer.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

class PlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var internalPlayer: AVPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspect
        layer.addSublayer(playerLayer)
        
        // Listen for background/foreground to detach/attach player
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setPlayer(_ player: AVPlayer) {
        self.internalPlayer = player
        playerLayer.player = player
    }
    
    @objc private func didEnterBackground() {
        // Detach player from layer to prevent automatic pause by iOS
        playerLayer.player = nil
    }
    
    @objc private func willEnterForeground() {
        // Re-attach player to layer
        playerLayer.player = internalPlayer
        internalPlayer?.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
