//
//  DiscoveryView.swift
//  vibble
//

import SwiftUI
import AVFoundation
import UIKit

@available(iOS 14.0, *)
struct DiscoveryView: View {
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // 过滤掉黑名单用户的视频
            let filteredVideos = mockVideos.filter { !FriendManager.shared.isBlocked($0.userName) }
            
            VibbleVerticalPager(videos: filteredVideos, currentIndex: $currentIndex)
                .ignoresSafeArea()
        }
    }
}

// MARK: - 分页组件 (增加精准播放控制)

@available(iOS 14.0, *)
struct VibbleVerticalPager: UIViewControllerRepresentable {
    let videos: [Video]
    @Binding var currentIndex: Int
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        pager.dataSource = context.coordinator
        pager.delegate = context.coordinator
        
        if let firstVC = context.coordinator.viewController(at: 0) {
            pager.setViewControllers([firstVC], direction: .forward, animated: false)
        }
        
        return pager
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: VibbleVerticalPager
        
        init(_ parent: VibbleVerticalPager) {
            self.parent = parent
            super.init()
        }
        
        func viewController(at index: Int) -> UIViewController? {
            guard index >= 0 && index < parent.videos.count else { return nil }
            
            // 实时感知 currentIndex，只有当前页才真正渲染播放逻辑
            let playerView = VideoPlayerView(video: parent.videos[index], pageIndex: index, activeIndex: parent.$currentIndex)
            let vc = UIHostingController(rootView: playerView)
            vc.view.backgroundColor = .black
            vc.view.tag = index
            return vc
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            return self.viewController(at: index - 1)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let index = viewController.view.tag
            return self.viewController(at: index + 1)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed, let visibleVC = pageViewController.viewControllers?.first {
                parent.currentIndex = visibleVC.view.tag
            }
        }
    }
}

// MARK: - 视频播放器视图 (增加激活状态判断)

@available(iOS 14.0, *)
struct VideoPlayerView: View {
    let video: Video
    let pageIndex: Int
    @Binding var activeIndex: Int
    
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var showReportSheet = false
    @StateObject private var friendManager = FriendManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Color.black.ignoresSafeArea()
                VideoThumbnailView(videoName: video.videoName).ignoresSafeArea()
                
                // 只有当自己是当前活跃页面时，才展示播放层
                if player != nil {
                    PlayerViewContainer(player: player).ignoresSafeArea()
                }
            }
            .onTapGesture { togglePlay() }
            
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4), .black.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                .frame(height: 350)
                .allowsHitTesting(false)
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("@\(video.userName)").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                    Text(video.description).font(.system(size: 16)).foregroundColor(.white).lineLimit(3)
                    HStack(spacing: 8) {
                        Image(systemName: "music.note")
                        Text("\(video.dramaTitle) OST").font(.system(size: 14))
                    }.foregroundColor(.white.opacity(0.8))
                }
                .padding(.leading, 20)
                .padding(.bottom, 35)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack(spacing: 32) {
                    ZStack(alignment: .bottom) {
                        Circle().fill(Theme.Gradients.primaryGradient).frame(width: 52, height: 52)
                            .overlay(Text(String(video.userName.first!)).foregroundColor(.white).bold())
                        let isFollowing = friendManager.isFollowing(video.userName)
                        Button(action: { withAnimation(.spring()) { friendManager.toggleFollow(video.userName) } }) {
                            Image(systemName: isFollowing ? "checkmark.circle.fill" : "plus.circle.fill")
                                .font(.system(size: 20)).foregroundColor(isFollowing ? Theme.accent : Theme.primary).background(Color.white.clipShape(Circle()))
                        }
                        .offset(y: 8)
                    }
                    .padding(.bottom, 15)
                    
                    // 替换为举报按钮 (App Store 审核必备)
                    Button(action: { 
                        print("Report tapped")
                        showReportSheet = true 
                    }) {
                        SidebarButton(icon: "exclamationmark.bubble.fill", label: "Report")
                            .contentShape(Rectangle()) // 扩大点击区域
                    }
                    .zIndex(10) // 确保在最上层
                    
                    ZStack {
                        Circle().fill(Color.black.opacity(0.8)).frame(width: 48, height: 48)
                        Circle().fill(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .top, endPoint: .bottom)).frame(width: 32, height: 32)
                        Image(systemName: "music.note").font(.system(size: 14)).foregroundColor(.white)
                    }
                    .rotationEffect(.degrees(isPlaying ? 360 : 0))
                    .animation(isPlaying ? Animation.linear(duration: 4).repeatForever(autoreverses: false) : .default)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportView(targetUsername: video.userName)
        }
        .onAppear { checkAndPlay() }
        .onDisappear { stopPlayer() }
        .onChange(of: activeIndex) { _ in checkAndPlay() } // 监听索引变化
    }
    
    private func checkAndPlay() {
        if activeIndex == pageIndex {
            setupPlayer()
        } else {
            stopPlayer()
        }
    }
    
    private func togglePlay() {
        guard let player = player else { return }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
    }
    
    private func setupPlayer() {
        guard player == nil else {
            player?.play()
            isPlaying = true
            return
        }
        
        let url = Bundle.main.url(forResource: video.videoName, withExtension: "mp4") ??
                  Bundle.main.url(forResource: video.videoName, withExtension: "mp4", subdirectory: "mp4")
        
        if let url = url {
            let newPlayer = AVPlayer(url: url)
            newPlayer.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem, queue: .main) { _ in
                newPlayer.seek(to: .zero)
                newPlayer.play()
            }
            self.player = newPlayer
            newPlayer.play()
            isPlaying = true
        }
    }
    
    private func stopPlayer() {
        player?.pause()
        player = nil
        isPlaying = false
    }
}

// MARK: - 基础组件

struct PlayerViewContainer: UIViewRepresentable {
    let player: AVPlayer?
    func makeUIView(context: Context) -> PlayerUIView { return PlayerUIView() }
    func updateUIView(_ uiView: PlayerUIView, context: Context) { uiView.player = player }
}

class PlayerUIView: UIView {
    var player: AVPlayer? { get { return (layer as! AVPlayerLayer).player } set { (layer as! AVPlayerLayer).player = newValue } }
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    override init(frame: CGRect) {
        super.init(frame: frame)
        (layer as! AVPlayerLayer).videoGravity = .resizeAspectFill
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

@available(iOS 14.0, *)
struct SidebarButton: View {
    let icon: String; let label: String; var activeColor: Color = .white
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 30)).foregroundColor(activeColor).shadow(color: .black.opacity(0.3), radius: 5)
            Text(label).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
        }
    }
}
