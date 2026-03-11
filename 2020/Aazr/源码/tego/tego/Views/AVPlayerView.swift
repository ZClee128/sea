import SwiftUI
import AVKit

struct AVPlayerView: UIViewRepresentable {
    let url: URL

    class PlayerUIView: UIView {
        private var playerLayer = AVPlayerLayer()
        private var player: AVPlayer?

        init(url: URL) {
            super.init(frame: .zero)

            // 1. MUST set the audio session to playback so it ignores the silent switch & lock screen
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)

            // 2. Initialize Player
            player = AVPlayer(url: url)
            player?.actionAtItemEnd = .none // Tells AVPlayer NOT to pause at the end of the video

            // 3. Setup Layer
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspectFill
            layer.addSublayer(playerLayer)

            player?.play()

            // 4. Handle looping
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }

            // =========================================================================
            // THE ULTIMATE FIX FOR iOS BACKGROUND VIDEO PAUSING
            // =========================================================================
            // iOS will ALWAYS forcefully pause an AVPlayer when the App goes to the background
            // IF that player is currently attached to a visible CALayer (AVPlayerLayer/VideoPlayer).
            // To prevent this: we completely detach the player from the UI layer the millisecond
            // the app is backgrounded. It becomes pure audio and keeps playing. We put it back
            // together when the app comes back to the foreground.

            NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                // Unlink player from the layer so iOS doesn't sleep the player
                self?.playerLayer.player = nil
            }

            NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                // Relink the player to the layer to restore the video picture
                self?.playerLayer.player = self?.player
                // Ensure it's still playing (just in case)
                self?.player?.play()
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }

        func dismantle() {
            player?.pause()
            NotificationCenter.default.removeObserver(self)
            playerLayer.removeFromSuperlayer()
        }
    }

    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(url: url)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}

    static func dismantleUIView(_ uiView: PlayerUIView, coordinator: ()) {
        uiView.dismantle()
    }
}
