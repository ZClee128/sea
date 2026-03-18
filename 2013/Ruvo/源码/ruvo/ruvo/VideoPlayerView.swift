import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    var videoURL: URL
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settingsManager = SettingsManager.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            AVVideoPlayerRepresentable(videoURL: videoURL)
                .edgesIgnoringSafeArea(.all)
            
            // Dynamic Background Playback Indicator
            HStack {
                Image(systemName: settingsManager.enableBackgroundPlayback ? "pip.enter" : "pip.exit")
                Text(settingsManager.enableBackgroundPlayback ? "Supports Background Playback" : "Background Playback Disabled")
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding(.top, 20)
            
            // Close Button
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
        }
    }
}

struct AVVideoPlayerRepresentable: UIViewControllerRepresentable {
    var videoURL: URL
    
    class Coordinator: NSObject {
        var player: AVQueuePlayer?
        var looper: AVPlayerLooper?
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let playerItem = AVPlayerItem(url: videoURL)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        context.coordinator.player = queuePlayer
        context.coordinator.looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        controller.player = queuePlayer
        controller.showsPlaybackControls = true
        
        // Background Playback Logic
        let isBackgroundEnabled = UserDefaults.standard.object(forKey: "enable_background_playback") as? Bool ?? true
        
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
        queuePlayer.allowsExternalPlayback = true
        
        if isBackgroundEnabled {
            if #available(iOS 15.0, *) {
                queuePlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            }
        } else {
            if #available(iOS 15.0, *) {
                queuePlayer.audiovisualBackgroundPlaybackPolicy = .pauses
            }
        }
        
        queuePlayer.play()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
