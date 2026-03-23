import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    @EnvironmentObject var settings: UserSettings
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        controller.showsPlaybackControls = true
        
        context.coordinator.player = player
        context.coordinator.controller = controller
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            if context.coordinator.enableBackgroundLoop || UIApplication.shared.applicationState == .active {
                player.seek(to: .zero)
                player.play()
            }
        }
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
            
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
            
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        context.coordinator.enableBackgroundLoop = settings.backgroundAudioLoop
    }
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        weak var controller: AVPlayerViewController?
        var enableBackgroundLoop: Bool = false
        var wasPlaying: Bool = false
        
        @objc func didEnterBackground() {
            guard enableBackgroundLoop else {
                player?.pause()
                return
            }
            
            wasPlaying = (player?.rate != 0 && player?.error == nil)
            if wasPlaying {
                // Detaching the player from AVPlayerViewController forces video rendering to stop
                // but crucially prevents the AV framework from auto-pausing the AVPlayer's audio.
                controller?.player = nil
                player?.play()
            }
        }
        
        @objc func willEnterForeground() {
            guard enableBackgroundLoop else { return }
            if wasPlaying {
                // Reattach the player back to the view controller
                controller?.player = player
                player?.play()
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
