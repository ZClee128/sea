import AVFoundation

/// Global singleton: AppDelegate → player 的桥梁
class VideoPlaybackManager {
    static let shared = VideoPlaybackManager()
    private init() {}

    /// 强引用，保证 AppDelegate 调用时 player 不被释放
    var currentPlayer: AVQueuePlayer?

    /// app 即将失去焦点（按 Home / 切换 app）
    func handleResignActive() {
        let bgOn = UserDefaults.standard.object(forKey: "backgroundPlayback") as? Bool ?? true
        guard !bgOn else { return }   // 开关打开 → 不做任何事，让系统后台续播

        // 开关关闭 → 暂停并释放音频会话
        currentPlayer?.pause()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// app 回到前台（不自动恢复播放，让用户手动按播放按钮）
    func handleBecomeActive() {
        let bgOn = UserDefaults.standard.object(forKey: "backgroundPlayback") as? Bool ?? true
        guard !bgOn else { return }  // 开关打开 → 不干预

        // 重新激活音频会话，但不调 play()，让用户决定是否继续
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// 关闭全屏视频时清理
    func clearPlayer() {
        currentPlayer?.pause()
        currentPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
