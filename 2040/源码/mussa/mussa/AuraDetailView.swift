import SwiftUI
import AVKit
import Combine

@available(iOS 14.0, *)
struct AuraDetailView: View {
    let item: AuraItem
    @ObservedObject var store: AuraStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Notice"
    @State private var showVideoFullScreen = false
    
    @StateObject private var videoManager = VideoManager()
    @State private var showingChat = false
    @State private var showingStore = false 
    @State private var showingInsufficientAlert = false
    @State private var showingReport = false // New report state
    
    let chatManager: ChatManager
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 550)
                            .clipped()
                            .overlay(
                                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                            )
                        
                        if item.hasVideo {
                            Button(action: {
                                videoManager.isBackgroundEnabled = store.isBackgroundPlaybackEnabled
                                if videoManager.preparePlayer() {
                                    showVideoFullScreen = true
                                } else {
                                    alertTitle = "Media Missing"
                                    alertMessage = "Please ensure 'ritual_video.mp4' is in bundle."
                                    showingAlert = true
                                }
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 30))
                                        .padding(25)
                                        .background(BlurView(style: .systemUltraThinMaterialLight))
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                    
                                    Text("WATCH CINEMATIC")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundColor(.white)
                                        .tracking(2)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.bottom, 100)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.rarity.uppercased())
                                .font(.system(size: 12, weight: .heavy))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            
                            Text(item.title)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 80)
                    }
                    
                    VStack(alignment: .leading, spacing: 30) {
                        if item.hasVideo {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Background Rituals")
                                            .font(.system(size: 18, weight: .bold))
                                        Text("Keep audio playing even when locked.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $store.isBackgroundPlaybackEnabled)
                                        .labelsHidden()
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                        .onChange(of: store.isBackgroundPlaybackEnabled) { newValue in
                                            videoManager.isBackgroundEnabled = newValue
                                        }
                                }
                                .padding()
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("The \(item.crystalType) Mussa")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(item.museName)
                                    .font(.system(size: 28, weight: .bold))
                            }
                            Spacer()
                            
                            // REPORT BUTTON in Detail View
                            Button(action: { showingReport = true }) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        HStack(spacing: 12) {
                            TagView(text: item.crystalType, icon: "sparkles", color: Color.purple)
                            TagView(text: item.rarity, icon: "crown.fill", color: Color.orange)
                        }
                        .padding(.horizontal, 30)
                        
                        Divider().padding(.horizontal, 30)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aura Essence")
                                .font(.system(size: 20, weight: .bold))
                            Text(item.description)
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                                .lineSpacing(8)
                        }
                        .padding(.horizontal, 30)
                        
                        if store.isUnlocked(item) {
                            VStack(alignment: .leading, spacing: 25) {
                                Text("Generation Secrets").font(.system(size: 22, weight: .bold)).foregroundColor(.blue)
                                HStack(spacing: 12) {
                                    PremiumActionButton(icon: "arrow.down.circle", text: "Save HD") { saveToLibrary() }
                                    PremiumActionButton(icon: "iphone", text: "Wallpaper") { saveToLibrary() }
                                    if item.hasVideo {
                                        PremiumActionButton(icon: "video.circle", text: "Cinematic") { 
                                            videoManager.isBackgroundEnabled = store.isBackgroundPlaybackEnabled
                                            if videoManager.preparePlayer() { showVideoFullScreen = true }
                                        }
                                    }
                                    PremiumActionButton(icon: "message", text: "Chat") { 
                                        showingChat = true
                                    }
                                }
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("AI PROMPT").font(.caption.bold()).foregroundColor(.blue)
                                    Text(item.prompt).font(.system(size: 14, design: .monospaced)).padding().background(Color.blue.opacity(0.05)).cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 30)
                        } else {
                             VStack(spacing: 20) {
                                Image(systemName: "lock.shield.fill").font(.system(size: 40)).foregroundColor(.blue)
                                Text("Unlock Generation Metadata").font(.headline)
                                Button(action: { 
                                    if !store.unlock(item) {
                                        showingInsufficientAlert = true
                                    }
                                }) {
                                    Text("Unlock for \(item.unlockCost) Shards")
                                        .bold().frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(16)
                                }
                            }
                            .padding(25).background(Color(.systemGray6)).cornerRadius(24).padding(.horizontal, 30)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .background(Color.white)
                    .cornerRadius(40, corners: [.topLeft, .topRight])
                    .offset(y: -50)
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left.circle.fill").font(.system(size: 40)).foregroundColor(.white.opacity(0.8)).padding(.top, 50).padding(.leading, 20)
            }
        }
        .alert(isPresented: $showingInsufficientAlert) {
            Alert(
                title: Text("Insufficient Shards"),
                message: Text("You need \(item.unlockCost) shards to unlock this Mussa. Would you like to get more?"),
                primaryButton: .default(Text("Go to Store")) {
                    showingStore = true
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingReport) {
            ReportView(targetName: item.title)
        }
        .sheet(isPresented: $showingStore) {
            CoinStoreView(auraStore: store)
        }
        .sheet(isPresented: $showingChat) {
            ChatView(muse: item, chatManager: chatManager)
        }
        .fullScreenCover(isPresented: $showVideoFullScreen) {
            ZStack(alignment: .topTrailing) {
                Color.black.edgesIgnoringSafeArea(.all)
                DetachmentVideoPlayer(videoManager: videoManager)
                    .edgesIgnoringSafeArea(.all)
                Button(action: { 
                    videoManager.cleanup()
                    showVideoFullScreen = false 
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(25)
                }
            }
        }
    }
    
    func saveToLibrary() {
        guard let image = UIImage(named: item.imageName) else { return }
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            alertTitle = "Success"
            alertMessage = "Saved to gallery!"
            showingAlert = true
        }
        imageSaver.writeToPhotoAlbum(image: image)
    }
}

// MARK: - Video Manager for Background Audio (Keep original)

class VideoManager: ObservableObject {
    @Published var player: AVPlayer?
    var isBackgroundEnabled: Bool = true
    private var cancellables = Set<AnyCancellable>()
    
    func preparePlayer() -> Bool {
        if let url = Bundle.main.url(forResource: "ritual_video", withExtension: "mp4") {
            let newPlayer = AVPlayer(url: url)
            newPlayer.actionAtItemEnd = .none 
            newPlayer.preventsDisplaySleepDuringVideoPlayback = true
            
            NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem)
                .sink { _ in
                    newPlayer.seek(to: .zero)
                    newPlayer.play()
                }
                .store(in: &cancellables)
            
            self.player = newPlayer
            return true
        }
        return false
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        cancellables.removeAll()
    }
}

// MARK: - Detachment Video Player (FIXES LOCK SCREEN STOPPING)

struct DetachmentVideoPlayer: UIViewRepresentable {
    @ObservedObject var videoManager: VideoManager
    
    func makeUIView(context: Context) -> DetachmentUIView {
        let view = DetachmentUIView(videoManager: videoManager)
        return view
    }
    
    func updateUIView(_ uiView: DetachmentUIView, context: Context) {}
}

class DetachmentUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private weak var videoManager: VideoManager?
    
    init(videoManager: VideoManager) {
        self.videoManager = videoManager
        super.init(frame: .zero)
        
        playerLayer.player = videoManager.player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        videoManager.player?.play()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    @objc private func handleBackground() {
        if videoManager?.isBackgroundEnabled == true {
            playerLayer.player = nil
            videoManager?.player?.play() 
        }
    }
    
    @objc private func handleForeground() {
        playerLayer.player = videoManager?.player
        videoManager?.player?.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
