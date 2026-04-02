import AVFoundation

// VideoPlayerView.swift is now superseded by VideoPlaybackManager.
// The presentVideoFullscreen free function below is kept for compatibility,
// but RecipeDetailView calls VideoPlaybackManager.shared.presentLoopingVideo() instead.

@available(iOS 14.2, *)
func presentVideoFullscreen(url: URL, steps: [String] = []) {
    VideoPlaybackManager.shared.presentLoopingVideo(url: url, steps: steps)
}
