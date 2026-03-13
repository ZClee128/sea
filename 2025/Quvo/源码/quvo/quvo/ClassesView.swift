import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    let url: URL
    @State private var player: AVQueuePlayer?
    
    var body: some View {
        VideoPlayerController(player: $player, url: url)
            .onDisappear {
                // Only pause if the user is actually navigating away, not just backgrounding
                if UIApplication.shared.applicationState == .active {
                    player?.pause()
                }
            }
    }
}

struct VideoPlayerController: UIViewControllerRepresentable {
    @Binding var player: AVQueuePlayer?
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = true
        
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Setup Looper for horizontal looping
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        context.coordinator.looper = looper
        context.coordinator.player = queuePlayer
        context.coordinator.controller = controller
        
        controller.player = queuePlayer
        queuePlayer.play()
        
        // Listen for background/foreground to handle the "Disconnect Trick"
        NotificationCenter.default.addObserver(context.coordinator, 
                                               selector: #selector(Coordinator.handleBackground), 
                                               name: UIApplication.willResignActiveNotification, 
                                               object: nil)
        NotificationCenter.default.addObserver(context.coordinator, 
                                               selector: #selector(Coordinator.handleForeground), 
                                               name: UIApplication.didBecomeActiveNotification, 
                                               object: nil)
        
        DispatchQueue.main.async {
            self.player = queuePlayer
        }
        
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
        
        @objc func handleBackground() {
            // Disconnect player from controller to prevent AVPlayerViewController from auto-pausing
            controller?.player = nil
            // Force resume playback in case the detach caused a minor pause
            player?.play()
        }
        
        @objc func handleForeground() {
            // Reattach when coming back to foreground
            controller?.player = player
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

struct VideoModel: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let url: String
    let isPremium: Bool
    let price: Int
}

struct ClassesView: View {
    @ObservedObject var appState = AppState.shared
    @State private var videoToUnlock: VideoModel? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let defaultVideos: [VideoModel] = [
        VideoModel(title: "Yoga for Beginners", duration: "00:16", url: Bundle.main.path(forResource: "Yoga for Beginners", ofType: "mp4") ?? "", isPremium: false, price: 0),
        VideoModel(title: "Full Body Morning Flow", duration: "00:13", url: Bundle.main.path(forResource: "Full Body Morning Flow", ofType: "mp4") ?? "", isPremium: false, price: 0),
        VideoModel(title: "Core Strengthening", duration: "00:15", url: Bundle.main.path(forResource: "Core Strengthening", ofType: "mp4") ?? "", isPremium: true, price: 20),
        VideoModel(title: "Deep Stretch & Relax", duration: "00:17", url: Bundle.main.path(forResource: "Deep Stretch & Relax", ofType: "mp4") ?? "", isPremium: true, price: 30)
    ]
    
    var body: some View {
        NavigationView {
            List(defaultVideos) { video in
                if let path = video.url as String?, !path.isEmpty {
                    let isUnlocked = !video.isPremium || appState.unlockedContent.contains(video.title)
                    
                    if isUnlocked {
                        // Unlocked or Free Video
                        NavigationLink(destination: VideoPlayerView(url: URL(fileURLWithPath: path)).navigationBarTitle(Text(video.title), displayMode: .inline)) {
                            VideoRow(video: video, isUnlocked: true)
                        }
                    } else {
                        // Locked Premium Video
                        Button(action: {
                            videoToUnlock = video
                            if appState.coinBalance >= video.price {
                                alertMessage = "Unlock '\(video.title)' for \(video.price) Coins?"
                            } else {
                                alertMessage = "You need \(video.price) Coins to unlock this class. Go to Settings -> Coin Balance to purchase more."
                            }
                            showAlert = true
                        }) {
                            VideoRow(video: video, isUnlocked: false)
                        }
                        .foregroundColor(.primary) // prevent button from tinting the whole row blue
                    }
                }
            }
            .navigationBarTitle("Classes")
            .alert(isPresented: $showAlert) {
                if let video = videoToUnlock, appState.coinBalance >= video.price {
                    return Alert(
                        title: Text("Unlock Class"),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Unlock")) {
                            appState.coinBalance -= video.price
                            appState.unlockedContent.append(video.title)
                        },
                        secondaryButton: .cancel()
                    )
                } else {
                    return Alert(
                        title: Text("Insufficient Coins"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

struct VideoRow: View {
    let video: VideoModel
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                if let uiImage = UIImage(named: "\(video.title).jpg") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 60)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .clipped()
                } else {
                    Color(.systemGray5)
                        .frame(width: 80, height: 60)
                        .cornerRadius(8)
                }
                
                if isUnlocked {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.white.opacity(0.8))
                } else {
                    // Lock Overlay
                    Color.black.opacity(0.4)
                        .frame(width: 80, height: 60)
                        .cornerRadius(8)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(video.title).font(.headline)
                Text(video.duration).font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !isUnlocked {
                HStack(spacing: 4) {
                    Text("\(video.price)")
                        .fontWeight(.bold)
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 5)
    }
}
