//
//  BackgroundPlaybackManager.swift
//  monti
//
//  Created by zclee on 24/06/2026.
//
//  Uses a player stack to automatically pause the previous video when a new
//  VideoPlayerWrapper appears, and resume it when the new one disappears.
//

import Foundation
import AVKit
import Combine

final class BackgroundPlaybackManager: NSObject, ObservableObject {

    // MARK: - Singleton
    static let shared = BackgroundPlaybackManager()

    // MARK: - Published State
    @Published var isBackgroundPlaybackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBackgroundPlaybackEnabled, forKey: "BackgroundPlaybackEnabled")
        }
    }

    // MARK: - Player Stack Entry
    private struct PlayerEntry {
        weak var player: AVPlayer?
        weak var viewController: AVPlayerViewController?
    }

    /// Stack of active players. Top = currently playing. Below = paused.
    private var playerStack: [PlayerEntry] = []

    // MARK: - Init
    private override init() {
        isBackgroundPlaybackEnabled = UserDefaults.standard.bool(forKey: "BackgroundPlaybackEnabled")
        super.init()
        setupNotifications()
    }

    // MARK: - Public API

    /// Called when a new VideoPlayerWrapper starts playing.
    /// Pauses the previous active player and pushes the new one to the top.
    func register(player: AVPlayer, viewController: AVPlayerViewController) {
        // Pause currently active player (top of stack)
        playerStack.last?.player?.pause()

        // Push new entry
        let entry = PlayerEntry(player: player, viewController: viewController)
        playerStack.append(entry)
    }

    /// Called when a VideoPlayerWrapper disappears (e.g. pop detail → back to list).
    /// Removes this player from the stack and resumes whatever is now on top.
    func unregister(player: AVPlayer) {
        // Remove this player from the stack
        playerStack.removeAll { $0.player === player || $0.player == nil }

        // Resume the now-top player (e.g. list banner video)
        if let top = playerStack.last, let activePlayer = top.player {
            top.viewController?.player = activePlayer
            activePlayer.play()
        }
    }

    /// Pause the currently active (top) player — used when switching away from Reels tab.
    func pauseTop() {
        playerStack.last?.player?.pause()
    }

    /// Resume the currently active (top) player — used when switching back to Reels tab.
    func resumeTop() {
        if let top = playerStack.last, let player = top.player {
            top.viewController?.player = player
            player.play()
        }
    }

    // MARK: - Background / Foreground Handling

    func handleEnterBackground() {
        guard let top = playerStack.last, let player = top.player else { return }
        if isBackgroundPlaybackEnabled {
            // Detach from view so iOS doesn't suspend audio pipeline
            top.viewController?.player = nil
            player.play()
        } else {
            player.pause()
        }
    }

    func handleEnterForeground() {
        guard let top = playerStack.last,
              let player = top.player,
              let vc = top.viewController else { return }
        vc.player = player
        if isBackgroundPlaybackEnabled {
            player.play()
        }
    }

    // MARK: - App Lifecycle Notifications

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        handleEnterBackground()
    }

    @objc private func appWillEnterForeground() {
        handleEnterForeground()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
