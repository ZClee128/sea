import SwiftUI
import AVKit
import MediaPlayer

struct GRReelsDisplayView: View {
    @State private var selectedVideo: GRRunwayReel?
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(GRReelRegistry.samples) { video in
                            Button(action: { selectedVideo = video }) {
                                GRReelFeedCell(video: video)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedVideo) { video in
            if #available(iOS 14.0, *) {
                GRReelPlaybackOverlay(video: video)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    var header: some View {
        VStack(alignment: .leading) {
            Text("REELS")
                .font(.system(size: 38, weight: .black, design: .serif))
                .tracking(5)
                .foregroundColor(.black)
            Text("FASHION TRENDS")
                .font(.caption)
                .tracking(2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct GRReelFeedCell: View {
    let video: GRRunwayReel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                // Video Thumbnail
                Image(video.thumbnailName)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(15)
                    .clipped()
                    .overlay(Color.black.opacity(0.1))
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
                if #available(iOS 14.0, *) {
                    Text(video.duration)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .padding(12)
                } else {
                    // Fallback on earlier versions
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Text(video.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
    }
}

@available(iOS 14.0, *)
struct GRReelPlaybackOverlay: View {
    let video: GRRunwayReel
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("backgroundAudioEnabled") private var backgroundAudioEnabled = true
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let url = Bundle.main.url(forResource: video.videoFileName, withExtension: "mp4") {
                AVPlayerControllerWrapper(url: url, title: video.title, description: video.description)
                    .edgesIgnoringSafeArea(.all)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Video file not found")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(video.videoFileName + ".mp4")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3).clipShape(Circle()))
                    }
                }
                Spacer()
                
                // 根据设置开关动态显示
                HStack {
                    Image(systemName: backgroundAudioEnabled ? "waveform" : "waveform.slash")
                        .foregroundColor(.white.opacity(0.7))
                    Text(backgroundAudioEnabled ? "Background Audio Enabled" : "Background Audio Disabled")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(8)
                .background(BlurView(style: .systemThinMaterialDark))
                .cornerRadius(20)
                .padding(.bottom, 40)
            }
            .padding()
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct AVPlayerControllerWrapper: UIViewControllerRepresentable {
    let url: URL
    let title: String
    let description: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        // 1. 先配置音频会话（必须在创建 player 之前）
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
        
        // 2. 正确的 AVQueuePlayer + looper 初始化方式
        let templateItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        player.allowsExternalPlayback = true
        player.preventsDisplaySleepDuringVideoPlayback = true
        
        // 3. 先注册远程控制命令（在 NowPlaying 之前注册）
        setupRemoteCommands(player: player)
        
        // 4. 把播放器存入 coordinator, 并开始 KVO 监听
        context.coordinator.player = player
        context.coordinator.controller = controller
        context.coordinator.title = title
        context.coordinator.looper = AVPlayerLooper(player: player, templateItem: templateItem)
        context.coordinator.startObserving(player: player)
        
        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        player.play()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.stopObserving()
        coordinator.player?.pause()
        coordinator.player = nil
        coordinator.looper = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        // 释放远程控制命令
        MPRemoteCommandCenter.shared().playCommand.removeTarget(nil)
        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func setupRemoteCommands(player: AVPlayer) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            player.play()
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ in
            player.pause()
            return .success
        }
    }
    
    class Coordinator: NSObject {
        var looper: AVPlayerLooper?
        var player: AVQueuePlayer?
        weak var controller: AVPlayerViewController?
        var title: String = ""
        private var timeControlObservation: NSKeyValueObservation?
        
        override init() {
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(handleDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        
        func startObserving(player: AVQueuePlayer) {
            timeControlObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
                guard let self = self else { return }
                if player.timeControlStatus == .playing {
                    self.updateNowPlayingInfo(player: player)
                }
            }
        }
        
        func stopObserving() {
            timeControlObservation?.invalidate()
            timeControlObservation = nil
        }
        
        func updateNowPlayingInfo(player: AVPlayer) {
            var nowPlayingInfo = [String: Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
            nowPlayingInfo[MPMediaItemPropertyArtist] = "Glowr · Fashion Reels"
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            if let duration = player.currentItem?.duration, duration.isNumeric {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
            }
            DispatchQueue.main.async {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
        
        @objc func handleDidEnterBackground() {
            if UserDefaults.standard.bool(forKey: "backgroundAudioEnabled") {
                // 先更新 NowPlaying，再把 player 从 controller 分离（保证后台继续播放）
                if let player = player { updateNowPlayingInfo(player: player) }
                controller?.player = nil
            } else {
                player?.pause()
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            }
        }
        
        @objc func handleWillEnterForeground() {
            controller?.player = player
        }
        
        deinit {
            stopObserving()
            NotificationCenter.default.removeObserver(self)
        }
    }
}
