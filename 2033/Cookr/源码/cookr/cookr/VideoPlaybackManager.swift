import AVFoundation
import AVKit
import UIKit

/// Manages background video/audio playback including loop and AVAudioSession configuration.
class VideoPlaybackManager {
    static let shared = VideoPlaybackManager()

    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    private var observers: [NSObjectProtocol] = []

    private var backgroundEnabled: Bool {
        let stored = UserDefaults.standard.object(forKey: "backgroundPlayback")
        return stored == nil ? true : UserDefaults.standard.bool(forKey: "backgroundPlayback")
    }

    // MARK: - Public

    func applyAudioSession(background: Bool) {
        do {
            if background {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            } else {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .moviePlayback)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
    }

    /// Present a looping fullscreen player using AVQueuePlayer + AVPlayerLooper.
    func presentLoopingVideo(url: URL) {
        applyAudioSession(background: backgroundEnabled)

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(items: [item])
        let looper = AVPlayerLooper(player: player, templateItem: item)
        
        player.allowsExternalPlayback = true
        player.preventsDisplaySleepDuringVideoPlayback = true
        
        self.queuePlayer = player
        self.playerLooper = looper

        guard let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
        
        let vc = LoopingPlayerViewController()
        vc.player = player
        vc.modalPresentationStyle = .fullScreen
        
        if #available(iOS 15.0, *) {
            player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        if #available(iOS 16.0, *) {
            vc.allowsVideoFrameAnalysis = false
        }
        
        var top: UIViewController = root
        while let presented = top.presentedViewController { top = presented }

        top.present(vc, animated: true) {
            player.play()
        }

        setupObservers()
    }

    // MARK: - Observers

    private func setupObservers() {
        // Remove previous observers
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers = []

        let bgObs = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.backgroundEnabled {
                // Ensure session is active and correct
                self.applyAudioSession(background: true)
                // Force play after a slightly longer delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.queuePlayer?.play()
                }
            } else {
                self.queuePlayer?.pause()
            }
        }

        let fgObs = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            if !(self?.backgroundEnabled ?? true) {
                self?.queuePlayer?.play()
            }
        }

        observers = [bgObs, fgObs]
    }

    func stop() {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        playerLooper = nil
        queuePlayer = nil
        
        // Remove observers
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers = []
        
        // Deactivate audio session to allow other apps/sounds to resume if needed
        DispatchQueue.global(qos: .background).async {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }
}

/// A specialized controller that stops the shared manager when dismissed.
class LoopingPlayerViewController: AVPlayerViewController {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // If we are being dismissed, stop the player logic
        if isBeingDismissed {
            VideoPlaybackManager.shared.stop()
        }
    }
}
