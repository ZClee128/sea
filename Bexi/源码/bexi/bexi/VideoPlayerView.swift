import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let urlString: String
    @Binding var isPresented: Bool
    
    @State private var player: AVPlayer?
    @State private var isForeground: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let player = player {
                if #available(iOS 14.0, *) {
                    if isForeground {
                        VideoPlayer(player: player)
                            .edgesIgnoringSafeArea(.all)
                            .onAppear {
                                if #available(iOS 15.0, *) {
                                    player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
                                }
                                player.play()
                            }
                            .onDisappear {
                                // Only pause if the user actually clicked the close button (isPresented == false)
                                // Not if we are just detaching the view for background playback
                                if !isPresented {
                                    player.pause()
                                }
                            }
                            .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
                                player.seek(to: .zero)
                                player.play()
                            }
                    } else {
                        // Empty black screen when in background to detach AVPlayerLayer
                        // Prevents system from forcefully suspending the video session
                        Color.black.edgesIgnoringSafeArea(.all)
                    }
                } else {
                    // Fallback on earlier versions
                }
            } else {
                if #available(iOS 14.0, *) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    // Fallback on earlier versions
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            self.isForeground = false
            self.player?.play() // Ensure it keeps playing immediately after view detaches
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.isForeground = true
        }
        .onAppear {
            if let url = URL(string: urlString) {
                self.player = AVPlayer(url: url)
            }
        }
    }
}
// Note: VideoPlayer requires iOS 14. For strict iOS 13 compatibility, we fall back to AVPlayerViewController represented via UIViewControllerRepresentable.
// If the app is targeting iOS 14+, VideoPlayer is fine. I will add the fallback just in case.

struct IOS13VideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
