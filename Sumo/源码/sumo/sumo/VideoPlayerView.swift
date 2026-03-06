import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let urlString: String
    @State private var player: AVPlayer?
    @State private var isPlaying = true
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        if isPlaying {
                            player.play()
                        }
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                Color.black // Placeholder while loading
                    .onAppear {
                        if let url = URL(string: urlString) {
                            let newPlayer = AVPlayer(url: url)
                            // Loop the video
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem, queue: .main) { _ in
                                newPlayer.seek(to: .zero)
                                newPlayer.play()
                            }
                            self.player = newPlayer
                        }
                    }
            }
            
            // Play/Pause overlay button
            Button(action: {
                isPlaying.toggle()
                if isPlaying {
                    player?.play()
                } else {
                    player?.pause()
                }
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
            .opacity(0) // Hide by default, or you can make it fade out after a few seconds
        }
        // Native context menu for fun interaction
        .contextMenu {
            Button(action: {
                isPlaying.toggle()
                if isPlaying {
                    player?.play()
                } else {
                    player?.pause()
                }
            }) {
                Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause" : "play")
            }
        }
    }
}
