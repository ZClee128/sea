import SwiftUI
import AVKit

struct VideoListView: View {
    let videos = VideoData.sampleVideos
    
    var body: some View {
        NavigationView {
            List {
                ForEach(videos) { video in
                    NavigationLink(destination: VideoPlayerView(video: video)) {
                        VideoCard(video: video)
                            .padding(.vertical, 10)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparatorHidden() // 使用自定义扩展或直接设置
                }

            }
            .listStyle(PlainListStyle())
            .background(Color(red: 0.99, green: 0.98, blue: 0.96).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Video", displayMode: .large)
        }
    }
}

struct VideoCard: View {
    let video: VideoData.VideoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 封面 - 固定高度
            ZStack(alignment: .bottomTrailing) {
                if let uiImage = UIImage(named: video.thumbnailName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                }
                
                // 播放按钮
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 60, height: 60)
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .padding(16)
                
                // 时长
                Text(video.duration)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(5)
                    .padding(12)
            }
            .cornerRadius(18)
            
            // 信息
            VStack(alignment: .leading, spacing: 8) {
                Text(video.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack {
                    Text(video.category)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("•").foregroundColor(.gray)
                    
                    Text("\(video.views) views")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
            .padding(14)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 4)
    }
}

struct VideoPlayerView: View {
    let video: VideoData.VideoItem
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var isPlaying = true
    @State private var isViewVisible = false
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let player = player {
                NativeVideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                        isPlaying.toggle()
                    }
            } else {
                Text("Loading...")
                    .foregroundColor(.white)
            }
            
            // 播放状态叠加层
            if !isPlaying {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white.opacity(0.8))
                    .onTapGesture {
                        player?.play()
                        isPlaying = true
                    }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        player?.pause()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.top, 60)
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear { 
            isViewVisible = true
            setupPlayer() 
        }
        .onDisappear { 
            isViewVisible = false
            player?.pause() 
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if !SettingsManager.shared.backgroundPlaybackEnabled || !isViewVisible {
                player?.pause()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if SettingsManager.shared.backgroundPlaybackEnabled && isPlaying && isViewVisible {
                // 进入后台后再次确认播放，延迟一下避开系统切环境的瞬间
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    player?.play()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if isPlaying && isViewVisible {
                player?.play()
            }
        }
    }

    
    func setupPlayer() {
        var url: URL?
        if let bundleUrl = Bundle.main.url(forResource: video.videoName, withExtension: "mp4") {
            url = bundleUrl
        } else {
            url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        }
        
        guard let finalUrl = url else { return }
        let playerItem = AVPlayerItem(url: finalUrl)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
        
        // 使用 AVPlayerLooper 实现真正的无缝循环
        self.looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.player = queuePlayer
        
        queuePlayer.play()
    }

}

// iOS13兼容的VideoPlayer - 使用 AVPlayerLayer 以支持更稳健的后台播放
struct NativeVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView(player: player)
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.updatePlayer(player)
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePlayer(_ player: AVPlayer) {
        if playerLayer.player !== player {
            playerLayer.player = player
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}



struct VideoData {
    struct VideoItem: Identifiable {
        let id = UUID()
        let title: String
        let thumbnailName: String
        let videoName: String
        let duration: String
        let category: String
        let views: Int
    }
    
    static let sampleVideos: [VideoItem] = [
        VideoItem(
            title: "Spring Fashion Trends",
            thumbnailName: "Spring Fashion Trends",
            videoName: "fashion_video_01",
            duration: "0:15",
            category: "Trends",
            views: 18500
        ),
        VideoItem(
            title: "Beauty Tutorial",
            thumbnailName: "Beauty Tutorial",
            videoName: "fashion_video_02",
            duration: "0:15",
            category: "Beauty",
            views: 12300
        )
    ]
}

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
