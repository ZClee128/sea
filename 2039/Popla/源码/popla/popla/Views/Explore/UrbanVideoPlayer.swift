import SwiftUI
import AVKit
import Combine

/// Manages a single AVPlayer instance for seamless playback across different views.
class PlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying: Bool = true {
        didSet {
            if isPlaying {
                player?.play()
            } else {
                player?.pause()
            }
        }
    }
    
    private var observerToken: Any?
    
    func setup(videoUrl: String) {
        // Prevent double initialization
        if player != nil { return }
        
        var url: URL?
        if let mp4Path = Bundle.main.path(forResource: videoUrl, ofType: "mp4") {
            url = URL(fileURLWithPath: mp4Path)
        } else if let movPath = Bundle.main.path(forResource: videoUrl, ofType: "mov") {
            url = URL(fileURLWithPath: movPath)
        }
        
        guard let finalUrl = url else { return }
        let newPlayer = AVPlayer(url: finalUrl)
        
        // Setup Looping
        observerToken = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main) { _ in
                newPlayer.seek(to: .zero)
                newPlayer.play()
            }
        
        self.player = newPlayer
        
        if isPlaying {
            newPlayer.play()
        }
    }
    
    func cleanup() {
        player?.pause()
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token)
        }
        player = nil
        observerToken = nil
    }
    
    deinit {
        cleanup()
    }
}

/// A high-performance, lightweight video renderer for iOS 13.
/// It projects an existing AVPlayer instance onto a layer, allowing for
/// seamless player sharing across multiple views.
struct UrbanVideoPlayer: UIViewRepresentable {
    let player: AVPlayer?
    @EnvironmentObject var appSettings: AppSettings
    
    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.appSettings = appSettings
        view.player = player 
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        // ALWAYS update settings and references
        uiView.appSettings = appSettings
        uiView.player = player
        
        // CRITICAL: If audio is playing but layer is empty, force re-attach
        // This handles cases where the view was covered by a fullScreenCover
        if uiView.playerLayer.player == nil && player != nil {
            uiView.playerLayer.player = player
        }
        
        // Pulse playback to ensure rendering resumes
        if let p = player, p.rate > 0 {
            uiView.playerLayer.player = nil
            uiView.playerLayer.player = p
        }
    }
    
    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: ()) {
        uiView.cleanup()
    }
}

/// Custom UIView with self-contained background/foreground logic
class PlayerContainerView: UIView {
    var appSettings: AppSettings?
    weak var player: AVPlayer?
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            // Visible: Observe notifications
            NotificationCenter.default.addObserver(self, selector: #selector(handleEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            // Critical re-sync on window move
            if playerLayer.player == nil && player != nil {
                playerLayer.player = player
            }
            playerLayer.player?.play()
        } else {
            // Hidden: Cleanup observers
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc private func handleEnterBackground() {
        if let settings = appSettings, settings.isBackgroundPlaybackEnabled {
            playerLayer.player = nil // DETACH visual layer
        } else {
            playerLayer.player?.pause()
        }
    }
    
    @objc private func handleWillEnterForeground() {
        // ALWAYS re-attach the player to the visual layer when foregrounding
        if playerLayer.player == nil && player != nil {
            playerLayer.player = player
        }
        playerLayer.player?.play()
    }
    
    func cleanup() {
        playerLayer.player?.pause()
        playerLayer.player = nil
        NotificationCenter.default.removeObserver(self)
    }
}
