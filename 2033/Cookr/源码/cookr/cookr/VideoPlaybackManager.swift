import AVFoundation
import AVKit
import UIKit

/// Manages background video/audio playback including loop and AVAudioSession configuration.
@available(iOS 14.2, *)
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
            // Pure .playback mode is best for Picture-in-Picture stability
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
    }

    /// Present a looping fullscreen player using AVQueuePlayer + AVPlayerLooper.
    func presentLoopingVideo(url: URL, steps: [String] = []) {
        // Prepare audio session before playback starts
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
        
        // Critical for PiP
        vc.allowsPictureInPicturePlayback = true
        vc.canStartPictureInPictureAutomaticallyFromInline = true
        
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
            
            // Start audio instructions if enabled
            if self.backgroundEnabled && !steps.isEmpty {
                SpeechManager.shared.speakSteps(steps)
            }
        }

        setupObservers()
    }

    // MARK: - Observers

    private func setupObservers() {
        // Remove previous observers
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers = []

        // We only need to ensure the player keeps playing if PiP is NOT active 
        // but the user wants background audio only. 
        // If PiP IS active, the system handles the playback.
        
        let bgObs = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            // Redundant manual play calls removed to avoid PiP conflicts
            // if backgroundEnabled is true, the session is already .playback
            // and the system will handle continuation if policy is .continuesIfPossible
            if !self.backgroundEnabled {
                self.queuePlayer?.pause()
                SpeechManager.shared.stop()
            }
        }

        let fgObs = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            if self?.backgroundEnabled == false {
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
        
        SpeechManager.shared.stop() // Stop TTS as well
        
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
@available(iOS 14.2, *)
class LoopingPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
    
    private var isPiPCurrentlyActive = false
    private var isRestoringFromPiP = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // MARK: - AVPlayerViewControllerDelegate
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        isPiPCurrentlyActive = true
        isRestoringFromPiP = false
    }
    
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        isPiPCurrentlyActive = false
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Mark that we are in the process of restoring, so viewDidDisappear doesn't kill the player
        isRestoringFromPiP = true
        
        // Get the current view controller and restore the player if it was hidden
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let root = window.rootViewController {
            
            var top = root
            while let presented = top.presentedViewController {
                if presented === self { break }
                top = presented
            }
            
            if top.presentedViewController === self {
                // Already presented, just signal success
                completionHandler(true)
                self.isRestoringFromPiP = false
            } else {
                // Re-present if it was somehow dismissed (less common for modal but safe)
                top.present(self, animated: true) {
                    completionHandler(true)
                    self.isRestoringFromPiP = false
                }
            }
        } else {
            completionHandler(false)
            self.isRestoringFromPiP = false
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Guard against stopping playback during PiP or restoration transitions
        if isBeingDismissed && !isPiPCurrentlyActive && !isRestoringFromPiP {
            VideoPlaybackManager.shared.stop()
        }
    }
}
