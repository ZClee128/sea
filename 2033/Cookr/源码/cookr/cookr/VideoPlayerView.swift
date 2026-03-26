import AVFoundation

// VideoPlayerView.swift is now superseded by VideoPlaybackManager.
// The presentVideoFullscreen free function below is kept for compatibility,
// but RecipeDetailView calls VideoPlaybackManager.shared.presentLoopingVideo() instead.

func presentVideoFullscreen(url: URL) {
    VideoPlaybackManager.shared.presentLoopingVideo(url: url)
}
