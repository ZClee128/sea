import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let urlStr: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        if let url = URL(string: urlStr) {
            let player = AVPlayer(url: url)
            playerViewController.player = player
        }
        playerViewController.showsPlaybackControls = true
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No updates needed
    }
}
