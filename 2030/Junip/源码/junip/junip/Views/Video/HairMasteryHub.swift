import SwiftUI
import AVKit
internal import Combine
import MediaPlayer

enum MasteryType {
    case video, article
}

struct MasteryItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let type: MasteryType
    let iconName: String
    var url: String = "https://www.w3schools.com/html/mov_bbb.mp4"
    var isPremium: Bool = false
}

@available(iOS 14.0, *)
struct HairMasteryHub: View {
    @StateObject private var coinManager = CoinManager.shared
    @State private var showingUnlockPrompt = false
    @State private var showingCoinStore = false
    @State private var itemToUnlock: MasteryItem? = nil
    
    let items = [
        MasteryItem(id: "art_blowout", title: "The Art of the Blowout", subtitle: "8 min Video Masterclass", type: .video, iconName: "play.circle.fill", isPremium: false),
        MasteryItem(id: "summer_care", title: "Essential Summer Care", subtitle: "5 min Read • Pro Tips", type: .article, iconName: "text.alignleft"),
        MasteryItem(id: "root_volume", title: "Mastering Root Volume", subtitle: "12 min Deep Dive", type: .video, iconName: "video.fill", isPremium: true),
        MasteryItem(id: "scalp_101", title: "Scalp Health 101", subtitle: "Expert Guide • PDF", type: .article, iconName: "doc.plaintext.fill"),
        MasteryItem(id: "scalp_detox", title: "Scalp Detox Guide", subtitle: "6 min Read • Wellness", type: .article, iconName: "leaf.fill", isPremium: true),
        MasteryItem(id: "color_protection", title: "Color Protection Secrets", subtitle: "4 min Read • Maintenance", type: .article, iconName: "drop.fill"),
        MasteryItem(id: "winter_hydration", title: "Winter Hydration Ritual", subtitle: "7 min Read • Pro Advice", type: .article, iconName: "snow")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("Mastery Hub")
                        .font(AppTheme.titleSemiBold(size: 34))
                        .foregroundColor(AppTheme.secondary)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    VStack(spacing: 20) {
                        ForEach(items) { item in
                            if item.isPremium && !coinManager.isUnlocked(item.id) {
                                Button(action: {
                                    itemToUnlock = item
                                    showingUnlockPrompt = true
                                }) {
                                    MasteryCard(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                NavigationLink(destination: MasteryContentDetail(item: item)) {
                                    MasteryCard(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .background(AppTheme.background.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .alert(isPresented: $showingUnlockPrompt) {
                Alert(
                    title: Text("Premium Masterclass"),
                    message: Text("Unlock \"\(itemToUnlock?.title ?? "this item")\" for 100 Coins?"),
                    primaryButton: .default(Text("Unlock")) {
                        if let item = itemToUnlock {
                            if coinManager.spendCoins(100) {
                                coinManager.unlockItem(item.id)
                            } else {
                                showingCoinStore = true
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingCoinStore) {
                CoinStoreView()
            }
        }
    }
}


@available(iOS 14.0, *)
struct MasteryCard: View {
    let item: MasteryItem
    @StateObject private var coinManager = CoinManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                // Background cover image
                Image(item.title)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(12)
                    .clipped()
                
                if item.isPremium && !coinManager.isUnlocked(item.id) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding(12)
                        .background(Color.black.opacity(0.6).clipShape(Circle()))
                } else if item.type == .video {
                    Image(systemName: "play.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.4).clipShape(Circle()))
                } else {
                    Image(systemName: item.iconName)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(AppTheme.primary.opacity(0.7).clipShape(Circle()))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.type == .video ? "VIDEO" : "ARTICLE")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(AppTheme.primary)
                
                Text(item.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.secondary)
                    .lineLimit(2)
                
                Text(item.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

@available(iOS 14.0, *)
@available(iOS 14.0, *)
class MasteryPlayerManager: ObservableObject {
    @Published var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    
    func setupPlayer(itemTitle: String) {
        // Prevent re-creating the same player if already loading/playing
        if player != nil { return }
        
        if let url = Bundle.main.url(forResource: itemTitle, withExtension: "mp4") {
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            
            let queuePlayer = AVQueuePlayer(playerItem: item)
            queuePlayer.automaticallyWaitsToMinimizeStalling = false
            queuePlayer.allowsExternalPlayback = true
            queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
            
            self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            self.player = queuePlayer
            queuePlayer.play()
            
            setupNowPlayingInfo(title: itemTitle)
            setupRemoteCommands()
        }
    }
    
    private func setupNowPlayingInfo(title: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Junip Mastery"
        if let image = UIImage(named: title) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteCommands() {
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
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
}

class CustomPlayerViewController: UIViewController {
    var player: AVQueuePlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.clipsToBounds = true
        
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        self.playerLayer = layer
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    @objc func appDidEnterBackground() {
        // Disconnect player from layer to prevent iOS from automatically pausing it in the background
        playerLayer?.player = nil
    }
    
    @objc func appWillEnterForeground() {
        // Reconnect player to layer when coming back to foreground
        playerLayer?.player = player
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@available(iOS 14.0, *)
struct CustomPlayerView: UIViewControllerRepresentable {
    let player: AVQueuePlayer
    
    func makeUIViewController(context: Context) -> CustomPlayerViewController {
        let controller = CustomPlayerViewController()
        controller.player = player
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CustomPlayerViewController, context: Context) {
    }
}

@available(iOS 14.0, *)
struct MasteryContentDetail: View {
    let item: MasteryItem
    @StateObject private var playerManager = MasteryPlayerManager()
    @State private var isBackgroundEnabled = true
    @State private var showingFullScreen = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Section
                ZStack(alignment: .bottomLeading) {
                    if item.type == .video {
                        ZStack {
                            if let player = playerManager.player {
                                CustomPlayerView(player: player)
                                    .frame(height: 300)
                                    .background(Color.black)
                            } else {
                                Image(item.title)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 300)
                                    .clipped()
                            }
                            
                            // Original Badge Overlay
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("JUNIP ORIGINAL")
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.6))
                                        .foregroundColor(AppTheme.primary)
                                        .cornerRadius(4)
                                }
                                Spacer()
                            }
                            .padding(15)
                        }
                        .onAppear {
                            playerManager.setupPlayer(itemTitle: item.title)
                        }
                        .onDisappear { 
                            // Always pause when the view itself disappears (e.g., navigating back)
                            playerManager.pause()
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                            if !isBackgroundEnabled {
                                playerManager.pause()
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                            if isBackgroundEnabled {
                                playerManager.play()
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                            // Always resume when app comes back to foreground
                            playerManager.play()
                        }
                    } else {
                        ZStack(alignment: .center) {
                            Image(item.title)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipped()
                                .background(AppTheme.secondary.opacity(0.1))
                            
                            // Article Icon Overlay
                            Image(systemName: item.iconName)
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(AppTheme.primary.opacity(0.8).clipShape(Circle()))
                                .shadow(radius: 10)
                        }
                    }
                    
                    // Category Badge
                    Text(item.type == .video ? "VIDEO MASTERCLASS" : "PRO ARTICLE")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.primary)
                        .foregroundColor(AppTheme.secondary)
                        .cornerRadius(4)
                        .padding(20)
                }
                
                VStack(alignment: .leading, spacing: 25) {
                    // Title & Control Panel
                    VStack(alignment: .leading, spacing: 15) {
                        Text(item.title)
                            .font(AppTheme.titleSemiBold(size: 32))
                            .foregroundColor(AppTheme.secondary)
                        
                        if item.type == .video {
                            HStack(spacing: 20) {
                                Button(action: { showingFullScreen = true }) {
                                    HStack {
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        Text("Full Screen")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.primary.opacity(0.1))
                                    .foregroundColor(AppTheme.primary)
                                    .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    Toggle(isOn: $isBackgroundEnabled) {
                                        Image(systemName: "headphones")
                                            .foregroundColor(isBackgroundEnabled ? AppTheme.primary : .gray)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
                                    .labelsHidden()
                                    
                                    Text("Background")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 5)
                        } else {
                            HStack {
                                Image(systemName: "clock")
                                Text(item.subtitle)
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 25)
                    
                    Divider()
                    
                    // Main Content
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Expert Overview")
                            .font(.headline)
                        
                        Text("This curated content is designed to elevate your hair care and styling expertise. Our professionals have gathered these techniques through years of salon experience.")
                            .font(AppTheme.bodyRegular(size: 17))
                            .foregroundColor(AppTheme.secondary.opacity(0.8))
                            .lineSpacing(8)
                    }
                    
                    // Highlight Box
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppTheme.primary)
                            Text("Key Takeaways")
                                .font(.headline)
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        HighlightRow(icon: "checkmark.circle.fill", text: "Professional preparation techniques")
                        HighlightRow(icon: "checkmark.circle.fill", text: "Advanced texture management")
                        HighlightRow(icon: "checkmark.circle.fill", text: "Long-lasting finish secrets")
                    }
                    .padding(20)
                    .background(AppTheme.primary.opacity(0.05))
                    .cornerRadius(16)
                    
                    Text("In this guide, we cover the essential steps to maintaining texture and health. Whether you are prepping for a special occasion or just refining your daily routine, these tips will ensure professional results at home.")
                        .font(AppTheme.bodyRegular(size: 17))
                        .foregroundColor(AppTheme.secondary.opacity(0.8))
                        .lineSpacing(8)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 25)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let player = playerManager.player {
                FullScreenPlayerView(player: player)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

class CustomAVPlayerViewController: AVPlayerViewController {
    var storedPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatesNowPlayingInfoCenter = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appDidEnterBackground() {
        self.player = nil
    }
    
    @objc func appWillEnterForeground() {
        self.player = storedPlayer
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@available(iOS 14.0, *)
struct FullScreenPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = CustomAVPlayerViewController()
        controller.player = player
        controller.storedPlayer = player
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct HighlightRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.secondary)
        }
    }
}
