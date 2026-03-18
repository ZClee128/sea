import SwiftUI
import AVKit
import Combine
import MediaPlayer

struct TutorialVideo: Identifiable {
    let id: String // Use title or slug as ID for easier persistence
    let title: String
    let duration: String
    let difficulty: String
    let videoFileName: String?
    let thumbnailName: String?
    let description: String
    let tools: [String]
    let learningPoints: [String]
    let isPremium: Bool
    let price: Int // Cost in coins
}

struct VideoTutorialListView: View {
    @ObservedObject var storeManager = StoreManager.shared
    
    let tutorials = [
        TutorialVideo(
            id: "winged-liner",
            title: "Mastering the Winged Liner",
            duration: "00:16",
            difficulty: "Intermediate",
            videoFileName: "Mastering the Winged Liner",
            thumbnailName: "Mastering the Winged Liner",
            description: "Learn the secrets to the perfect, sharp winged eyeliner every time.",
            tools: ["Angled Liner Brush", "Gel Eyeliner", "Micellar Water"],
            learningPoints: ["Choosing the right eyeliner formula", "The 'dot-to-dot' connection method", "Correcting mistakes without starting over", "Matching wings on both eyes"],
            isPremium: false,
            price: 0
        ),
        TutorialVideo(
            id: "morning-routine",
            title: "The 5-Minute Morning Routine",
            duration: "00:21",
            difficulty: "Beginner",
            videoFileName: "The 5-Minute Morning Routine",
            thumbnailName: "The 5-Minute Morning Routine",
            description: "Quick and easy steps for a refreshed look when you're short on time.",
            tools: ["BB Cream", "Mascara", "Tinted Lip Balm"],
            learningPoints: ["Even skin tone with minimal product", "Instantly brightening tired eyes", "Natural lip enhancement for all day wear"],
            isPremium: true,
            price: 50
        ),
        TutorialVideo(
            id: "contouring",
            title: "Contouring for Beginners",
            duration: "00:13",
            difficulty: "Beginner",
            videoFileName: "Contouring for Beginners",
            thumbnailName: "Contouring for Beginners",
            description: "A step-by-step guide to defining your features naturally.",
            tools: ["Contour Stick", "Blending Sponge", "Setting Powder"],
            learningPoints: ["Identifying your face shape", "Placement for natural shadows", "Blending techniques to avoid muddy looks"],
            isPremium: true,
            price: 30
        )
    ]
    
    var body: some View {
        NavigationView {
            List(tutorials) { video in
                NavigationLink(destination: VideoPlayerDetailView(video: video)) {
                    HStack(spacing: 15) {
                        ZStack {
                            if let thumb = video.thumbnailName {
                                Image(thumb)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 60)
                                    .cornerRadius(12)
                                    .clipped()
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(RevoDesign.primary.opacity(0.1))
                                    .frame(width: 100, height: 60)
                            }
                            
                            if video.isPremium && !StoreManager.shared.isUnlocked(videoID: video.id) {
                                if #available(iOS 14.0, *) {
                                    Image(systemName: "lock.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                } else {
                                    // Fallback on earlier versions
                                }
                            } else {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white.opacity(0.8))
                                    .shadow(radius: 2)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(video.title)
                                    .font(.headline)
                                    .foregroundColor(RevoDesign.text)
                                if video.isPremium && !StoreManager.shared.isUnlocked(videoID: video.id) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundColor(RevoDesign.primary)
                                }
                            }
                            
                            HStack {
                                Text(video.duration)
                                Text("•")
                                Text(video.difficulty)
                                if video.isPremium && !StoreManager.shared.isUnlocked(videoID: video.id) {
                                    Text("•")
                                    Text("\(video.price) Coins")
                                        .foregroundColor(RevoDesign.primary)
                                        .bold()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(RevoDesign.textSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Tutorials", displayMode: .inline)
            .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        }
        .forceLightMode()
    }
}

class GlobalPlayerManager: ObservableObject {
    static let shared = GlobalPlayerManager()
    
    @Published var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var nowPlayingInfo: [String: Any] = [:]
    
    private init() {
        setupNotifications()
    }
    
    func setupPlayer(video: TutorialVideo) {
        guard let url = Bundle.main.url(forResource: video.videoFileName ?? "", withExtension: "mp4") else { return }
        
        // Cleanup existing player if any
        cleanup()
        
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Background-friendly settings
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
        queuePlayer.allowsExternalPlayback = true
        
        // Setup Audio Session for background playback
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .moviePlayback, options: [.allowBluetooth, .allowAirPlay])
        try? audioSession.setActive(true)
        
        self.looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.player = queuePlayer
        
        setupRemoteCommandCenter()
        setupNowPlayingInfo(video: video)
        
        queuePlayer.play()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func handleBackground() {
        // Some players auto-pause when backgrounded, so we force-play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.player?.play()
        }
    }
    
    @objc private func handleForeground() {
        self.player?.play()
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    player?.play()
                }
            }
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            return .success
        }
    }
    
    private func setupNowPlayingInfo(video: TutorialVideo) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = video.title
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        if let thumb = video.thumbnailName, let image = UIImage(named: thumb) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        looper = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

struct VideoPlayerDetailView: View {
    let video: TutorialVideo
    @ObservedObject var playerManager = GlobalPlayerManager.shared
    @ObservedObject var storeManager = StoreManager.shared
    @State private var showingPurchaseAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video Player or Locked State
                if !video.isPremium || storeManager.isUnlocked(videoID: video.id) {
                    if let player = playerManager.player {
                        UnifiedPlayerContainer(player: player)
                            .frame(height: 250)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(RevoDesign.secondary)
                                .frame(height: 250)
                            VStack {
                                Image(systemName: "video.slash")
                                    .font(.largeTitle)
                                Text("Video Loading...")
                                    .font(.headline)
                            }
                            .foregroundColor(RevoDesign.primary)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Locked View
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(RevoDesign.secondary.opacity(0.5))
                            .frame(height: 250)
                        
                        VStack(spacing: 15) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 40))
                                .foregroundColor(RevoDesign.primary)
                            
                            Text("Premium Tutorial")
                                .font(.headline)
                            
                            Button(action: {
                                if storeManager.spendCoins(video.price) {
                                    storeManager.unlockVideo(videoID: video.id)
                                    playerManager.setupPlayer(video: video)
                                } else {
                                    showingPurchaseAlert = true
                                }
                            }) {
                                Text("Unlock for \(video.price) Coins")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(RevoDesign.premiumGradient)
                                    .cornerRadius(10)
                            }
                            
                            NavigationLink(destination: CoinStoreView()) {
                                Text("Get More Coins")
                                    .font(.caption)
                                    .foregroundColor(RevoDesign.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showingPurchaseAlert) {
                        Alert(
                            title: Text("Insufficient Coins"),
                            message: Text("You need \(video.price) coins to unlock this tutorial. Please top up in the store."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(video.title)
                        .font(.headline)
                        .foregroundColor(RevoDesign.text)
                    
                    Text(video.difficulty.uppercased())
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(RevoDesign.primary)
                        .cornerRadius(5)
                    
                    Text(video.description)
                        .font(.body)
                        .foregroundColor(RevoDesign.textSecondary)
                        .padding(.top, 10)
                    
                    Text("Tools Required")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(video.tools, id: \.self) { tool in
                                Text(tool)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(RevoDesign.secondary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    Text("In this video, you will learn:")
                        .font(.headline)
                        .foregroundColor(RevoDesign.text)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(video.learningPoints, id: \.self) { point in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(RevoDesign.primary)
                                Text(point)
                                    .font(.subheadline)
                                    .foregroundColor(RevoDesign.textSecondary)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(Text(video.title), displayMode: .inline)
        .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        .forceLightMode()
        .onAppear {
            if !video.isPremium || storeManager.isUnlocked(videoID: video.id) {
                playerManager.setupPlayer(video: video)
            }
        }
        .onDisappear {
            // Only cleanup if we're actually navigating away, not just backgrounding
            if UIApplication.shared.applicationState == .active {
                playerManager.cleanup()
            }
        }
    }
}

// Unified Player using AVPlayerViewController for best background performance
struct UnifiedPlayerContainer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.allowsPictureInPicturePlayback = true
        // Important: video Gravity
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
