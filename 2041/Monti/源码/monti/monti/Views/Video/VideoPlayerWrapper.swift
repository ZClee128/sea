//
//  VideoPlayerWrapper.swift
//  monti
//
//  Created by zclee on 24/06/2026.
//

import SwiftUI
import AVKit

/// SwiftUI wrapper for AVPlayerViewController.
///
/// Each instance owns its own AVPlayer (independent playback).
/// On appear → registers with BackgroundPlaybackManager (pauses previous player).
/// On disappear → unregisters (resumes previous player, e.g. list banner).
struct VideoPlayerWrapper: UIViewControllerRepresentable {
    let videoUrl: String

    // MARK: - Coordinator
    class Coordinator: NSObject {
        var currentUrl: String?
        var player: AVPlayer?
        var loopObserver: NSObjectProtocol?

        deinit {
            if let obs = loopObserver {
                NotificationCenter.default.removeObserver(obs)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspectFill
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        guard context.coordinator.currentUrl != videoUrl else { return }
        context.coordinator.currentUrl = videoUrl

        // Remove previous loop observer
        if let obs = context.coordinator.loopObserver {
            NotificationCenter.default.removeObserver(obs)
            context.coordinator.loopObserver = nil
        }

        let url: URL?
        if let localPath = Bundle.main.path(forResource: videoUrl, ofType: "mp4") {
            url = URL(fileURLWithPath: localPath)
        } else {
            url = URL(string: videoUrl)
        }

        guard let resolvedURL = url else {
            uiViewController.player = nil
            return
        }

        let player = AVPlayer(url: resolvedURL)
        context.coordinator.player = player

        // Seamless loop
        context.coordinator.loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        uiViewController.player = player
        player.play()

        // Register: pauses the previous active player, pushes this one to stack top
        BackgroundPlaybackManager.shared.register(player: player, viewController: uiViewController)
    }

    // MARK: - Cleanup on disappear
    /// Called automatically by SwiftUI when this view is removed from the hierarchy
    /// (e.g. user pops back from detail → list banner resumes automatically).
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        // Pause this player
        coordinator.player?.pause()

        // Unregister from stack → BackgroundPlaybackManager resumes the player below
        if let player = coordinator.player {
            BackgroundPlaybackManager.shared.unregister(player: player)
        }

        // Clean up loop observer
        if let obs = coordinator.loopObserver {
            NotificationCenter.default.removeObserver(obs)
            coordinator.loopObserver = nil
        }

        uiViewController.player = nil
    }
}
