import SwiftUI
import AVKit

@available(iOS 14.0, *)
struct VideoReelView: View {
    @EnvironmentObject var dataStore: MuseDataStore
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let firstMuse = dataStore.muses.first(where: { $0.videoUrl != nil }) {
                VideoPlayerWrapper(name: firstMuse.videoUrl!, museID: firstMuse.id)
                    .ignoresSafeArea()
                    .onAppear { dataStore.activeVideoID = firstMuse.id }
                    .onDisappear { dataStore.activeVideoID = nil }
                
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("@\(firstMuse.name)")
                                .font(.headline).bold()
                                .foregroundColor(.white)
                            Text("Atmospheric Muse - \(firstMuse.category.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack(spacing: 20) {
                            ActionButton(icon: "heart.fill", label: "Save")
                            ActionButton(icon: "square.and.arrow.up", label: "Share")
                        }
                        .padding()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    )
                }
            } else {
                Text("Loading immersive visuals...")
                    .foregroundColor(.gray)
            }
        }
    }
}

@available(iOS 14.0, *)
struct ActionButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
        }
    }
}

struct VideoPlayerWrapper: UIViewControllerRepresentable {
    let name: String
    let museID: UUID
    var isPlaying: Bool = true
    var player: AVPlayer? = nil // Optional shared player
    @EnvironmentObject var dataStore: MuseDataStore
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        var loopObserver: NSObjectProtocol? // Token for looping observer
        weak var dataStore: MuseDataStore?
        var museID: UUID?
        var isPlaying: Bool = true
        var isBackgroundPlayEnabled: Bool = true
        
        @objc func handleBackground() {
            if !isBackgroundPlayEnabled {
                player?.pause()
            }
        }
        
        @objc func handleForeground() {
            guard let ds = dataStore, let mid = museID else { return }
            let shouldPlay = isPlaying && (ds.activeVideoID == mid)
            if shouldPlay {
                player?.play()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        context.coordinator.isBackgroundPlayEnabled = dataStore.isBackgroundPlayEnabled
        context.coordinator.dataStore = dataStore
        context.coordinator.museID = museID
        context.coordinator.isPlaying = isPlaying
        
        // Use the provided shared player or create a new one
        let currentPlayer: AVPlayer?
        if let sharedPlayer = player {
            currentPlayer = sharedPlayer
        } else if let path = Bundle.main.path(forResource: name, ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            currentPlayer = AVPlayer(url: url)
        } else {
            currentPlayer = nil
        }
        
        if let player = currentPlayer {
            context.coordinator.player = player
            controller.player = player
            controller.showsPlaybackControls = true
            controller.videoGravity = .resizeAspectFill
            player.play()
            
            // Looping observer with weak reference
            let token = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
            context.coordinator.loopObserver = token
            
            // Background / Foreground observers
            NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.handleBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.handleForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        context.coordinator.isBackgroundPlayEnabled = dataStore.isBackgroundPlayEnabled
        context.coordinator.isPlaying = isPlaying
        
        let shouldPlay = isPlaying && (dataStore.activeVideoID == museID)
        
        if shouldPlay {
            uiViewController.player?.play()
        } else {
            uiViewController.player?.pause()
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        // Explicitly clear observers and items to prevent leaks or freezes
        if let token = coordinator.loopObserver {
            NotificationCenter.default.removeObserver(token)
            coordinator.loopObserver = nil
        }
        
        uiViewController.player?.pause()
        uiViewController.player?.replaceCurrentItem(with: nil) // Break item link
        uiViewController.player = nil
        
        coordinator.player?.pause()
        coordinator.player = nil
        
        NotificationCenter.default.removeObserver(coordinator)
    }
}
