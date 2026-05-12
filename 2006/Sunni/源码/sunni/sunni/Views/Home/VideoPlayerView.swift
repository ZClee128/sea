//
//  VideoPlayerView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI
import AVKit

@available(iOS 14.0, *)
struct VideoPlayerView: View {
    let videoName: String
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        // Auto-play when view appears
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        player.pause()
                        isPlaying = false
                    }
            } else {
                // Loading or placeholder
                Color.gray.opacity(0.3)
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    )
            }
        }
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        // For demo, we'll use a placeholder
        // In real app, load from URL: AVPlayer(url: URL(string: videoName)!)
        guard let url = Bundle.main.url(forResource: "sample_video", withExtension: "mp4") else {
            // Fallback if no video file exists
            return
        }
        
        player = AVPlayer(url: url)
    }
}

@available(iOS 14.0, *)
struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(videoName: "sample_video")
            .frame(height: 400)
    }
}
