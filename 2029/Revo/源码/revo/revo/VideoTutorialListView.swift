import SwiftUI
import AVKit
import Combine
import MediaPlayer

struct TutorialVideo: Identifiable {
    let id: String
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
    // For text-only tutorials (no video file)
    let steps: [String]
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
            price: 0,
            steps: []
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
            price: 50,
            steps: []
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
            price: 30,
            steps: []
        ),
        TutorialVideo(
            id: "flawless-base",
            title: "Flawless Foundation Application",
            duration: "~10 min read",
            difficulty: "Beginner",
            videoFileName: nil,
            thumbnailName: nil,
            description: "Build a seamless, skin-like base that lasts all day without looking cakey.",
            tools: ["Foundation Brush", "Blending Sponge", "Setting Powder", "Primer"],
            learningPoints: ["Choosing the right foundation shade", "Priming for longevity", "Layering for buildable coverage", "Setting for a matte or dewy finish"],
            isPremium: false,
            price: 0,
            steps: [
                "Start with clean, moisturized skin. Apply a pea-sized amount of primer to your T-zone and any large pores.",
                "Pump a small amount of foundation onto the back of your hand. Start from the center of your face and blend outward.",
                "Use a damp blending sponge in a stippling (bounce) motion to press the foundation into your skin for a seamless finish.",
                "Build coverage only where needed—under eyes, redness, blemishes—by applying a second thin layer.",
                "Use a small brush to blend foundation into the hairline, jawline, and neck for a natural transition.",
                "Lock everything in with a light dusting of translucent setting powder, focusing on the T-zone."
            ]
        ),
        TutorialVideo(
            id: "bold-red-lip",
            title: "The Perfect Bold Lip",
            duration: "~8 min read",
            difficulty: "Intermediate",
            videoFileName: nil,
            thumbnailName: nil,
            description: "Master the art of applying a bold red or berry lip without smudging or bleeding.",
            tools: ["Lip Liner", "Lip Brush", "Matte Lipstick", "Concealer"],
            learningPoints: ["Preparing lips for color", "Lining and defining lip shape", "Applying pigment with precision", "Making bold color last all day"],
            isPremium: false,
            price: 0,
            steps: [
                "Exfoliate lips with a damp cloth or sugar scrub. Apply a thin layer of lip balm and let it absorb for 2 minutes.",
                "Wipe off excess balm. Using a lip liner that matches your lipstick, outline just outside your natural lip line.",
                "Fill in the entire lip with the liner to create a base that helps your lipstick last longer.",
                "Apply your lipstick with a lip brush for precision. Start from the center and work outward to the corners.",
                "Blot with a single tissue, then reapply a second coat for deeper, longer-wearing color.",
                "Use a small concealer brush to clean up the edges for a sharp, professional finish."
            ]
        ),
        TutorialVideo(
            id: "smokey-eye",
            title: "Classic Smokey Eye",
            duration: "~12 min read",
            difficulty: "Advanced",
            videoFileName: nil,
            thumbnailName: nil,
            description: "Create a sultry, blended smokey eye that flatters every eye shape.",
            tools: ["Eyeshadow Palette (Black/Grey)", "Crease Brush", "Blending Brush", "Kohl Liner"],
            learningPoints: ["Blocking out the basic shadow shape", "How to blend without losing intensity", "Tightlining for depth", "Keeping skin clean from fallout"],
            isPremium: false,
            price: 0,
            steps: [
                "Apply an eyeshadow primer to your lids to ensure pigment stays vibrant all night.",
                "Using a flat shader brush, pack a medium grey shadow over the entire lid up to the crease.",
                "Dip a crease brush into a dark charcoal or black shadow. Blend it into the crease using a windshield-wiper motion.",
                "Smudge a dark shadow or kohl pencil under the lower lash line to connect the top and bottom of the eye.",
                "Use a clean blending brush to soften any harsh edges in circular motions.",
                "Add a pop of shimmer or light highlight to the inner corner of the eye to brighten and open up the look.",
                "Apply several coats of mascara, or add false lashes to complete the dramatic look."
            ]
        ),
        TutorialVideo(
            id: "natural-brows",
            title: "Natural-Looking Brows",
            duration: "~7 min read",
            difficulty: "Beginner",
            videoFileName: nil,
            thumbnailName: nil,
            description: "Fill and shape your brows to look full and natural—never drawn on.",
            tools: ["Brow Pencil", "Spoolie Brush", "Clear Brow Gel"],
            learningPoints: ["Mapping your ideal brow shape", "Hair-stroke technique for realism", "Blending for a natural finish", "Setting brows in place"],
            isPremium: false,
            price: 0,
            steps: [
                "Brush brows upward with a spoolie to reveal their natural shape and any sparse areas.",
                "Use your pencil to mark the start, arch, and tail of your ideal brow based on your bone structure.",
                "Using light, hair-like upward strokes, fill in sparse areas. Do not draw a solid line.",
                "Blend the pencil with the spoolie brush to soften and integrate the product with your natural hairs.",
                "If needed, use a tiny bit of concealer below and above the brow bone to sharpen the shape.",
                "Finish with clear brow gel brushed through in the direction of hair growth."
            ]
        ),
        TutorialVideo(
            id: "dewy-skin",
            title: "Glass Skin: The Dewy Look",
            duration: "~10 min read",
            difficulty: "Intermediate",
            videoFileName: nil,
            thumbnailName: nil,
            description: "Achieve the coveted glass skin effect: luminous, hydrated, and radiant.",
            tools: ["Hyaluronic Serum", "Lightweight Foundation", "Liquid Highlighter", "Setting Spray"],
            learningPoints: ["Skincare prep is everything", "Choosing the right base products", "Layering highlight strategically", "Avoiding powder for a dewy finish"],
            isPremium: false,
            price: 0,
            steps: [
                "Apply a hydrating serum with hyaluronic acid to clean skin and let it absorb fully—do not skip this step.",
                "Mix one drop of liquid highlighter into your lightweight foundation to create a luminous base.",
                "Apply the mixture with a damp sponge using gentle tapping motions (no rubbing) to preserve the glow.",
                "Skip setting powder entirely. Instead, gently pat—do not rub—any excess with a clean dry sponge.",
                "Apply liquid highlighter with your fingertip to the high points: tops of cheekbones, bridge of nose, brow bone, and cupid's bow.",
                "Finish with two generous spritzes of a hydrating setting spray for a lasting dewy seal."
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            List(tutorials) { video in
                NavigationLink(destination: destinationView(for: video)) {
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
                                Image(systemName: "doc.text.fill")
                                    .font(.title)
                                    .foregroundColor(RevoDesign.primary.opacity(0.5))
                            }
                            
                            if video.videoFileName != nil {
                                if video.isPremium && !StoreManager.shared.isUnlocked(videoID: video.id) {
                                    Image(systemName: "lock.fill")
                                        .font(.callout)
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                } else if video.videoFileName != nil {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white.opacity(0.8))
                                        .shadow(radius: 2)
                                }
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
    
    @ViewBuilder
    private func destinationView(for video: TutorialVideo) -> some View {
        if video.videoFileName != nil {
            VideoPlayerDetailView(video: video)
        } else {
            TutorialStepDetailView(video: video)
        }
    }
}

// MARK: - Step-based Tutorial Detail View (for text tutorials)
struct TutorialStepDetailView: View {
    let video: TutorialVideo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header banner
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(RevoDesign.premiumGradient)
                        .frame(height: 160)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // Original Content badge
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                            Text("Original Content by Revo")
                                .font(.caption)
                                .bold()
                        }
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        
                        Text(video.title)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        DifficultyBadge(text: video.difficulty)
                        Text(video.duration)
                            .font(.caption)
                            .foregroundColor(RevoDesign.textSecondary)
                    }
                    
                    Text(video.description)
                        .font(.body)
                        .foregroundColor(RevoDesign.textSecondary)
                        .padding(.top, 4)
                    
                    // Tools
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
                    
                    // What you'll learn
                    if !video.learningPoints.isEmpty {
                        Divider().padding(.vertical, 5)
                        Text("What You'll Learn")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(video.learningPoints, id: \.self) { point in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(RevoDesign.primary)
                                    Text(point)
                                        .font(.subheadline)
                                        .foregroundColor(RevoDesign.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Step-by-step
                    if !video.steps.isEmpty {
                        Divider().padding(.vertical, 5)
                        Text("Step-by-Step Guide")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(0..<video.steps.count, id: \.self) { index in
                                StepRow(number: index + 1, text: video.steps[index])
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
    }
}

struct DifficultyBadge: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.caption)
            .bold()
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(RevoDesign.primary)
            .cornerRadius(5)
    }
}

struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(RevoDesign.primary)
                    .frame(width: 28, height: 28)
                Text("\(number)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(RevoDesign.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Global Player Manager
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
        
        cleanup()
        
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
        queuePlayer.allowsExternalPlayback = true
        
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

// MARK: - Video Player Detail View
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
                    ZStack(alignment: .topTrailing) {
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
                        
                        // Original Content badge
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                            Text("Original Content")
                                .font(.caption)
                                .bold()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.55))
                        .cornerRadius(20)
                        .padding(.trailing, 24)
                        .padding(.top, 8)
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
                    
                    DifficultyBadge(text: video.difficulty)
                    
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
            if UIApplication.shared.applicationState == .active {
                playerManager.cleanup()
            }
        }
    }
}

// MARK: - Unified Player Container
struct UnifiedPlayerContainer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.allowsPictureInPicturePlayback = true
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
