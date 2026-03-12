import SwiftUI
import AVKit
import Combine

class VideoPlayerManager: ObservableObject {
    static let shared = VideoPlayerManager() // Singleton for easy iOS 13 lifecycle matching
    
    @Published var player = AVPlayer()
    
    func playVideo(url: URL) {
        player.pause()
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func stop() {
        player.pause()
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    @ObservedObject var playerManager: VideoPlayerManager
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = playerManager.player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player != playerManager.player {
            uiViewController.player = playerManager.player
        }
    }
}

// Data model for our video list
struct InspiringVideo: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let urlString: String
}

struct VideoFeedView: View {
// Using sample public space videos for demonstration
    let videos = [
        InspiringVideo(title: "The Art of War", subtitle: "Strategic mastery insights", urlString: "\(Bundle.main.url(forResource: "The Art of War", withExtension: "mp4")!)"),
        InspiringVideo(title: "Stoic Resilience", subtitle: "Endure and conquer all", urlString: "\(Bundle.main.url(forResource: "Stoic Resilience", withExtension: "mp4")!)"),
        InspiringVideo(title: "Mind of a General", subtitle: "Tactical reflections on power", urlString: "\(Bundle.main.url(forResource: "Mind of a General", withExtension: "mp4")!)")
    ]
    
    @State private var selectedVideo: InspiringVideo?
    @ObservedObject private var playerManager = VideoPlayerManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Video Player Area
                if let currentVideo = selectedVideo {
                    VStack {
                        VideoPlayerView(playerManager: playerManager)
                            .frame(height: 250)
                            .background(Color.black)
                        
                        Text(currentVideo.title)
                            .font(.headline)
                            .padding(.top, 8)
                        Text(currentVideo.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    }
                    .background(Color(UIColor.systemBackground))
                    .shadow(radius: 2)
                } else {
                    VStack {
                        Image(systemName: "play.tv")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Select a video to listen & watch")
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                }
                
                // Bottom List Area
                List(videos) { video in
                    Button(action: {
                        self.selectedVideo = video
                        self.playerManager.playVideo(url: URL(string: video.urlString)!)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(video.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(video.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedVideo?.id == video.id {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationBarTitle("Inspiration", displayMode: .inline)
            .onAppear {
                if selectedVideo == nil {
                    let first = videos.first!
                    selectedVideo = first
                    playerManager.playVideo(url: URL(string: first.urlString)!)
                }
            }
            .onDisappear {
                playerManager.stop()
            }
        }
    }
}
