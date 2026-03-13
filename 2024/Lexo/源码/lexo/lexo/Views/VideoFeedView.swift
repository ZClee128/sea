import SwiftUI
import AVKit

struct VideoFeedView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(mockVideos) { video in
                        VideoLinkWrapper(appState: appState, video: video)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Tutorials")
        }
    }
}

struct VideoLinkWrapper: View {
    @ObservedObject var appState: AppState
    let video: VideoModel
    
    @State private var showUnlockAlert = false
    @State private var showStoreSheet = false
    @State private var navigate = false
    
    var isUnlocked: Bool {
        !video.isPremium || appState.unlockedVideos.contains(video.id)
    }
    
    var body: some View {
        ZStack {
            NavigationLink(destination: VideoPlayerView(video: video), isActive: $navigate) {
                EmptyView()
            }
            
            Button(action: {
                if isUnlocked {
                    navigate = true
                } else {
                    showUnlockAlert = true
                }
            }) {
                VideoCardView(video: video, isUnlocked: isUnlocked)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .alert(isPresented: $showUnlockAlert) {
            Alert(
                title: Text("Premium Tutorial"),
                message: Text("Unlock this tutorial for \(video.coinCost) coins?\nYour Balance: \(appState.totalCoins)"),
                primaryButton: .default(Text("Unlock")) {
                    if appState.totalCoins >= video.coinCost {
                        // 扣除金币并记录解锁
                        appState.totalCoins -= video.coinCost
                        appState.unlockedVideos.append(video.id)
                        // 解锁后直接进入
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navigate = true
                        }
                    } else {
                        // 金币不足，引导至充值商城
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showStoreSheet = true
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showStoreSheet) {
            NavigationView {
                if #available(iOS 14.0, *) {
                    StoreView(appState: appState)
                        .navigationBarItems(trailing: Button("Close") {
                            showStoreSheet = false
                        })
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}

struct VideoCardView: View {
    let video: VideoModel
    var isUnlocked: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景视频封面图 (支持直观读取目录中的 jpg 素材)
            if let uiImage = UIImage(named: "\(video.imageName).jpg") ?? UIImage(named: video.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
            } else {
                Color.black.opacity(0.8)
                    .frame(height: 220)
                    .cornerRadius(16)
            }
            
            // 底部遮罩以便文字清晰可见
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
                .cornerRadius(16)
            
            // 播放图标和时长
            VStack {
                Spacer()
                if isUnlocked {
                    HStack {
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 5)
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.yellow)
                            Text("\(video.coinCost) Coins")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .fontWeight(.bold)
                        }
                        .padding(15)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        Spacer()
                    }
                }
                Spacer()
            }
            
            // 视频信息
            VStack(alignment: .leading, spacing: 6) {
                if #available(iOS 14.0, *) {
                    Text(video.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                } else {
                    // Fallback on earlier versions
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(video.duration)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
        }
    }
}

struct VideoPlayerView: View {
    let video: VideoModel
    private let player: AVPlayer
    
    @State private var isShowingShareSheet = false
    
    init(video: VideoModel) {
        self.video = video
        if let url = URL(string: video.urlString) {
            self.player = AVPlayer(url: url)
            self.player.actionAtItemEnd = .none
        } else {
            self.player = AVPlayer()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 视频播放器区域
            VideoPlayerControllerRepresentable(player: player)
                .frame(maxHeight: 300)
                .edgesIgnoringSafeArea(.top)
                .background(Color.black)
            
            // 视频介绍及关联信息
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(video.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(video.duration)")
                        Spacer()
                        if #available(iOS 14.0, *) {
                            Label("Pro Styling", systemImage: "star.fill")
                                .foregroundColor(.accentColor)
                                .font(.subheadline)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    Text("Watch this highly requested tutorial for professional styling and techniques. Practice matching these tones and follow along for optimal results.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundColor(.primary.opacity(0.9))
                    
                    Spacer(minLength: 40)
                    
                    // Call to Action 伪装提升活跃度
                    Button(action: {
                        isShowingShareSheet = true
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Tutorial")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $isShowingShareSheet) {
                ActivityView(activityItems: ["Check out this amazing styling tutorial on Lexo: \(video.title)"])
            }
            
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .onDisappear {
            player.pause()
        }
        .onAppear {
            player.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
    }
}

class PlayerViewControllerCoordinator: NSObject {
    var player: AVPlayer?
    weak var controller: AVPlayerViewController?
    
    @objc func didEnterBackground() {
        // Disconnect player from UI to let audio continue in background
        controller?.player = nil
    }
    
    @objc func willEnterForeground() {
        // Reconnect player to UI when coming back
        if let controller = controller, controller.player == nil {
            controller.player = player
        }
    }
}

// Wrapping AVPlayerViewController for SwiftUI usage (iOS 13+ compatible)
struct VideoPlayerControllerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeCoordinator() -> PlayerViewControllerCoordinator {
        return PlayerViewControllerCoordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        // 确保视频按照比例缩放适应不裁剪
        controller.videoGravity = .resizeAspect
        
        context.coordinator.player = player
        context.coordinator.controller = controller
        
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(PlayerViewControllerCoordinator.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(PlayerViewControllerCoordinator.willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No update needed
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: PlayerViewControllerCoordinator) {
        NotificationCenter.default.removeObserver(coordinator)
    }
}

// Wrapping UIActivityViewController for native Share Sheet (iOS 13+ compatible)
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
