import SwiftUI
import AVKit
import Combine

class VideoPlayerManager: ObservableObject {
    static let shared = VideoPlayerManager() // Singleton for easy iOS 13 lifecycle matching
    
    @Published var player = AVPlayer()
    
    init() {
        // Observe when the video finishes playing to loop it
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] notification in
            // Ensure the notification is for the currently playing item
            if let currentItem = notification.object as? AVPlayerItem, currentItem == self?.player.currentItem {
                self?.player.seek(to: .zero)
                self?.player.play()
            }
        }
    }
    
    func playVideo(url: URL) {
        player.pause()
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func stop() {
        player.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    @ObservedObject var playerManager: VideoPlayerManager
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = playerManager.player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        
        // Detach player on background to prevent AVPlayerViewController from auto-pausing the video
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak controller] _ in
            controller?.player = nil
        }
        
        // Reattach player on foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak controller] _ in
            controller?.player = VideoPlayerManager.shared.player
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if UIApplication.shared.applicationState != .background {
            if uiViewController.player != playerManager.player {
                uiViewController.player = playerManager.player
            }
        }
    }
}

struct InspiringVideo: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let urlString: String
    let isPremium: Bool // Added to determine if it requires a purchase
}

struct VideoFeedView: View {
// Using sample public space videos for demonstration
    let videos = [
        InspiringVideo(title: "The Art of War", subtitle: "Strategic mastery insights", urlString: "\(Bundle.main.url(forResource: "The Art of War", withExtension: "mp4")!)", isPremium: false),
        InspiringVideo(title: "Stoic Resilience", subtitle: "Endure and conquer all", urlString: "\(Bundle.main.url(forResource: "Stoic Resilience", withExtension: "mp4")!)", isPremium: true),
        InspiringVideo(title: "Mind of a General", subtitle: "Tactical reflections on power", urlString: "\(Bundle.main.url(forResource: "Mind of a General", withExtension: "mp4")!)", isPremium: true)
    ]
    
    @State private var selectedVideo: InspiringVideo?
    @ObservedObject private var playerManager = VideoPlayerManager.shared
    
    // Premium State
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var unlockedVideos: Set<String> = []
    @State private var videoToUnlock: InspiringVideo?
    @State private var showCoinPrompt = false
    @State private var showInsufficientFunds = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Video Player Area
                if let currentVideo = selectedVideo {
                    VStack {
                        VideoPlayerView(playerManager: playerManager)
                            .frame(height: 250)
                            .background(Color.black)
                        
                        Text(currentVideo.title)
                            .font(.headline)
                            .padding(.top, 8)
                        Text(currentVideo.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    }
                    .background(Color(UIColor.systemBackground))
                    .shadow(radius: 2)
                } else {
                    VStack {
                        Image(systemName: "play.tv")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Select a video to listen & watch")
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                }
                
                // Bottom List Area
                List(videos) { video in
                    Button(action: {
                        if video.isPremium && !unlockedVideos.contains(video.title) {
                            // Prompt to unlock
                            self.videoToUnlock = video
                            self.showCoinPrompt = true
                        } else {
                            // Play if free or already unlocked
                            self.selectedVideo = video
                            self.playerManager.playVideo(url: URL(string: video.urlString)!)
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(video.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(video.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            if video.isPremium && !unlockedVideos.contains(video.title) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.orange)
                            } else if selectedVideo?.id == video.id {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        .opacity(video.isPremium && !unlockedVideos.contains(video.title) ? 0.6 : 1.0)
                    }
                }
            }
            .navigationBarTitle("Inspiration", displayMode: .inline)
            .onAppear {
                loadUnlockedVideos()
                if selectedVideo == nil {
                    let first = videos.first!
                    selectedVideo = first
                    playerManager.playVideo(url: URL(string: first.urlString)!)
                }
            }
            .onDisappear {
                playerManager.stop()
            }
            .alert(isPresented: Binding<Bool>(
                get: { showCoinPrompt || showInsufficientFunds },
                set: { _ in }
            )) {
                if showCoinPrompt {
                    return Alert(
                        title: Text("Unlock Premium Video"),
                        message: Text("Unlock '\(videoToUnlock?.title ?? "")' for 50 coins? You currently have \(storeManager.coinBalance) coins."),
                        primaryButton: .default(Text("Pay 50 Coins")) {
                            if storeManager.deductCoins(50) {
                                showCoinPrompt = false
                                if let vid = videoToUnlock {
                                    var currentUnlocks = unlockedVideos
                                    currentUnlocks.insert(vid.title)
                                    unlockedVideos = currentUnlocks
                                    UserDefaults.standard.set(Array(currentUnlocks), forKey: "UnlockedVideos")
                                    
                                    // Auto play after unlock
                                    self.selectedVideo = vid
                                    self.playerManager.playVideo(url: URL(string: vid.urlString)!)
                                }
                            } else {
                                showCoinPrompt = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.showInsufficientFunds = true
                                }
                            }
                        },
                        secondaryButton: .cancel() {
                            showCoinPrompt = false
                            videoToUnlock = nil
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Insufficient Coins"),
                        message: Text("You need 50 coins to unlock this video. Please visit the Premium Store in the Settings tab to top up."),
                        dismissButton: .default(Text("OK")) {
                            showInsufficientFunds = false
                        }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loadUnlockedVideos() {
        if let saved = UserDefaults.standard.stringArray(forKey: "UnlockedVideos") {
            self.unlockedVideos = Set(saved)
        }
    }
}
