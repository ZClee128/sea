import SwiftUI
import AVKit

struct LegacyVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    @Binding var player: AVPlayer?
    @Binding var isLooping: Bool
    
    class Coordinator: NSObject {
        var parent: LegacyVideoPlayer
        var loopObserver: Any?
        var bgObserver: Any?
        var fgObserver: Any?
        
        init(_ parent: LegacyVideoPlayer) {
            self.parent = parent
        }
        
        func setupLooping(for player: AVPlayer) {
            if let obs = loopObserver { NotificationCenter.default.removeObserver(obs) }
            // Listen for any item ending, and check if it's our player's item
            loopObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak player] notification in
                guard let player = player, 
                      let currentItem = player.currentItem,
                      let endedItem = notification.object as? AVPlayerItem,
                      currentItem == endedItem else { return }
                
                if self.parent.isLooping {
                    player.seek(to: .zero)
                    player.play()
                } else {
                    // Explicitly stop if looping is OFF
                    player.pause()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let newPlayer = AVPlayer(url: url)
        
        if #available(iOS 15.0, *) {
            newPlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        context.coordinator.setupLooping(for: newPlayer)
        
        // Advanced workaround: Disconnect player on backgrounding to prevent system auto-pause
        context.coordinator.bgObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak controller] _ in
            if self.isLooping {
                // If looping is ON, disconnect player to let it keep playing in background
                controller?.player = nil
            } else {
                // If looping is OFF, explicitly pause it
                controller?.player?.pause()
            }
        }
        context.coordinator.fgObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak controller, weak newPlayer] _ in
            controller?.player = newPlayer
        }
        
        DispatchQueue.main.async {
            self.player = newPlayer
        }
        controller.player = newPlayer
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Sync context's coordinator parent to have latest binding access
        context.coordinator.parent = self
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        uiViewController.player?.pause()
        uiViewController.player = nil
        
        // Clean up all observers
        if let obs = coordinator.loopObserver { NotificationCenter.default.removeObserver(obs) }
        if let obs = coordinator.bgObserver { NotificationCenter.default.removeObserver(obs) }
        if let obs = coordinator.fgObserver { NotificationCenter.default.removeObserver(obs) }
        
        DispatchQueue.main.async {
            coordinator.parent.player = nil
        }
    }
}
