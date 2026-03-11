import SwiftUI
import AVFoundation
import Combine

// MARK: - UIView backed by AVPlayerLayer (avoids AVKit's built-in background pause)

class PlayerLayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - Coordinator: owns player + handles background-only auto-resume

class PlayerCoordinator: NSObject {
    let player: AVQueuePlayer
    var looper: AVPlayerLooper?

    private var bgObserver: NSObjectProtocol?
    private var fgObserver: NSObjectProtocol?
    private var kvoToken: NSKeyValueObservation?

    // Track whether the app is in background so we know not to stop playback on view disappear
    private(set) var isInBackground = false

    init(url: URL) {
        let item = AVPlayerItem(url: url)
        self.player = AVQueuePlayer()
        super.init()
        self.looper = AVPlayerLooper(player: player, templateItem: item)
        setupObservers()
        player.play()
    }

    deinit {
        kvoToken?.invalidate()
        if let o = bgObserver { NotificationCenter.default.removeObserver(o) }
        if let o = fgObserver { NotificationCenter.default.removeObserver(o) }
    }

    private func setupObservers() {
        // When entering background: mark flag and ensure audio keeps playing
        bgObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.isInBackground = true
            self?.player.play()          // fight AVFoundation's auto-pause
        }

        // When returning to foreground: resume and clear flag
        fgObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.isInBackground = false
            self?.player.play()
        }

        // KVO: ONLY re-play if we're in background (don't fight user-initiated pauses)
        kvoToken = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            guard let self = self, self.isInBackground else { return }
            if player.timeControlStatus == .paused {
                DispatchQueue.main.async { player.play() }
            }
        }
    }

    func stop() {
        player.pause()
        player.seek(to: .zero)
    }
}

// MARK: - UIViewRepresentable

struct AVPlayerLayerView: UIViewRepresentable {
    let coordinator: PlayerCoordinator

    func makeUIView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.playerLayer.player = coordinator.player
        view.playerLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: PlayerLayerView, context: Context) {}
}

// MARK: - CoordinatorHolder keeps player alive across SwiftUI re-renders

class CoordinatorHolder: ObservableObject {
    @Published var coordinator: PlayerCoordinator?

    func setup(urlString: String?, localVideoName: String?) {
        guard coordinator == nil else { return }
        let url: URL?
        if let local = localVideoName {
            url = Bundle.main.url(
                forResource: (local as NSString).deletingPathExtension,
                withExtension: (local as NSString).pathExtension
            )
        } else if let remote = urlString {
            url = URL(string: remote)
        } else {
            url = nil
        }
        guard let url = url else { return }
        coordinator = PlayerCoordinator(url: url)
    }

    func stop() {
        coordinator?.stop()
    }
}

// MARK: - Public VideoPlayerView

@available(iOS 15.0, *)
struct VideoPlayerView: View {
    let urlString: String?
    let localVideoName: String?

    @StateObject private var holder = CoordinatorHolder()

    var body: some View {
        ZStack {
            if let coord = holder.coordinator {
                AVPlayerLayerView(coordinator: coord)
            } else {
                Color.black
            }
        }
        .onAppear {
            holder.setup(urlString: urlString, localVideoName: localVideoName)
            holder.coordinator?.player.play()
        }
        .onDisappear {
            // Only stop if the user navigated away (not if app went to background)
            let appIsInBackground = holder.coordinator?.isInBackground ?? false
            if !appIsInBackground {
                holder.stop()
            }
        }
    }
}
