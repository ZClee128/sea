import SwiftUI
import AVKit
import Combine

@available(iOS 15.0, *)
struct VideosView: View {
    // 强制每次选取第一首个视频作为“每日主打”
    @State private var mainVideo: VideoItem? = SampleData.videoItems.first
    @State private var showPremiumAlert = false
    @State private var playMainVideo = false

    // 为填补页面，使用无视频依赖的“图文专栏”
    private var wellnessArticles: [ArticleItem] {
        return SampleData.articles
    }

    @available(iOS 15.0, *)
    var body: some View {
        NavigationView {
            ZStack {
                Color.zBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // ── 每日精选主大卡片 ──
                        if let video = mainVideo {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Daily Featured")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color.zText)
                                    .padding(.horizontal, 16)

                                Button {
                                    playMainVideo = true
                                } label: {
                                    DailyFeaturedCard(video: video)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 16)
                        }

                        // ── 图文专栏：无需任何视频素材 ──
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Wellness Guides")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.zText)
                                Spacer()
                            }
                            .padding(.horizontal, 16)

                            VStack(spacing: 14) {
                                ForEach(wellnessArticles) { article in
                                    NavigationLink(destination: ArticleDetailView(article: article)) {
                                        ArticleRowCard(article: article)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // 底部留白防止遮挡TabBar
                        Spacer().frame(height: 120)
                    }
                }
            }
            .navigationTitle("Wellness")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $playMainVideo) {
                if let video = mainVideo {
                    VideoPlayerSheet(video: video)
                }
            }
            .alert("Premium Feature", isPresented: $showPremiumAlert) {
                Button("Upgrade Now") {
                    // 这里未来对接会员内购
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Unlock the Premium Masterclass catalog to access hundreds of high-quality workouts and personalized plans.")
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Daily Featured Card
@available(iOS 15.0, *)
struct DailyFeaturedCard: View {
    let video: VideoItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景底色固定容器
            Color.zCardBg
                .overlay(
                    VideoThumbnailView(videoName: video.title)
                        .clipped()
                )
                .cornerRadius(20)

            // 下方变暗渐变，让文字更清晰
            LinearGradient(colors: [.clear, Color.black.opacity(0.8)],
                           startPoint: .center, endPoint: .bottom)
                .cornerRadius(20)

            // 中央超大播放按钮
            Image(systemName: "play.circle.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 文字信息区
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("TODAY's WORKOUT")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(video.duration)
                    }
                    .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)

                Text(video.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(video.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding(16)
        }
        .frame(height: 280) // 巨大的卡片极其吸引眼球，弥补数量不足
        .clipped()
        .shadow(color: Color.zPrimary.opacity(0.15), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Video Thumbnail Generator
import AVFoundation

@available(iOS 15.0, *)
struct VideoThumbnailView: View {
    let videoName: String
    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    .overlay(ProgressView())
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }

    private func generateThumbnail() {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else { return }
        
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0.1, preferredTimescale: 60)
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, _, _ in
            if let cgImage = cgImage {
                DispatchQueue.main.async {
                    self.thumbnail = UIImage(cgImage: cgImage)
                }
            }
        }
    }
}

// MARK: - Article Row Card
@available(iOS 15.0, *)
struct ArticleRowCard: View {
    let article: ArticleItem

    var body: some View {
        HStack(spacing: 14) {
            // 封面图 (动态图文封面)
            ZStack {
                LinearGradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: categoryIcon)
                    .font(.system(size: 28))
                    .foregroundColor(Color.green.opacity(0.7))
            }
            .frame(width: 90, height: 70)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.zText)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(article.category)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(Color.green)
                        .cornerRadius(4)
                    
                    Text("· \(article.readTime)")
                        .font(.system(size: 12))
                        .foregroundColor(Color.zTextSub)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
    
    private var categoryIcon: String {
        switch article.category.lowercased() {
        case "nutrition": return "leaf.fill"
        case "recovery": return "bed.double.fill"
        case "mindset", "focus": return "brain.head.profile"
        default: return "book.fill"
        }
    }
}

// MARK: - Video Player ViewModel
import AVFoundation

@available(iOS 15.0, *)
class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    var isBackgroundPlayEnabled: Bool {
        if UserDefaults.standard.object(forKey: "backgroundPlayEnabled") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "backgroundPlayEnabled")
    }
    
    private var timeObserverToken: Any?
    private var backgroundObserver: NSObjectProtocol?
    
    init(videoName: String) {
        setupAudioSession()
        
        // 加载本地视频 (通过 title 寻找 .mp4)
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            let p = AVPlayer(url: url)
            self.player = p
            p.play()
            
            // 监听循环播放
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: p.currentItem, queue: .main) { [weak p] _ in
                p?.seek(to: .zero)
                p?.play()
            }
        }
        
        // 强行监听 App 底层生命周期，无视 SwiftUI 层级传递延迟
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onAppBackgrounded()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    func onAppBackgrounded() {
        if !isBackgroundPlayEnabled {
            player?.pause()
            player?.rate = 0.0
        }
    }
    
    deinit {
        player?.pause()
        if let currentItem = player?.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - Video Player Sheet UI
import AVKit

@available(iOS 15.0, *)
struct VideoPlayerSheet: View {
    let video: VideoItem
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var viewModel: VideoPlayerViewModel
    
    init(video: VideoItem) {
        self.video = video
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(videoName: video.title))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    Text("Local video not found:\\n\(video.title).mp4")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .frame(maxHeight: .infinity)
            }
            
            // Top Overlay Actions
            HStack {
                // Background Indicator
                HStack(spacing: 6) {
                    Image(systemName: viewModel.isBackgroundPlayEnabled ? "play.tv.fill" : "play.slash.fill")
                        .foregroundColor(viewModel.isBackgroundPlayEnabled ? .green : .gray)
                    Text("Background Play: \(viewModel.isBackgroundPlayEnabled ? "ON" : "OFF")")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
                
                Spacer()
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.8))
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 50) // Adjust for safe area directly
            .onChange(of: scenePhase) { newPhase in
                // 双重保险：通过 scenePhase 捕获状态
                if newPhase == .background {
                    viewModel.onAppBackgrounded()
                }
            }
            .onDisappear {
                viewModel.player?.pause()
            }
        }
    }
}
