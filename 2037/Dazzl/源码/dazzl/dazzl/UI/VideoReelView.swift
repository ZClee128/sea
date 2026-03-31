import SwiftUI
import AVKit

@available(iOS 14.0, *)
struct VideoReelView: View {
    @EnvironmentObject var dataStore: MuseDataStore
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let firstMuse = dataStore.muses.first(where: { $0.videoUrl != nil }) {
                VideoPlayerWrapper(url: URL(string: firstMuse.videoUrl!)!)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("@\(firstMuse.name)")
                                .font(.headline).bold()
                                .foregroundColor(.white)
                            Text("Atmospheric Muse - \(firstMuse.category.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack(spacing: 20) {
                            ActionButton(icon: "heart.fill", label: "Save")
                            ActionButton(icon: "square.and.arrow.up", label: "Share")
                        }
                        .padding()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    )
                }
            } else {
                Text("Loading immersive visuals...")
                    .foregroundColor(.gray)
            }
        }
    }
}

@available(iOS 14.0, *)
struct ActionButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
        }
    }
}

struct VideoPlayerWrapper: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        player.play()
        
        // Loop video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
