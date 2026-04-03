import SwiftUI
import AVFoundation
import AVKit

@available(iOS 14.0, *)
struct FocusView: View {
    @StateObject var assetManager = AssetManager()
    @StateObject var thumbnailManager = VideoThumbnailManager.shared
    @State private var selectedSession: FocusSession?
    @AppStorage("isBackgroundPlaybackEnabled") var isBackgroundPlaybackEnabled = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Immersive Focus")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .padding(.horizontal)
                    
                    Text("Select a session to find your center. These curated visual moments are designed for mindful breathing and aesthetic reflection.")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ForEach(assetManager.focusSessions) { session in
                        Button(action: { 
                            withAnimation {
                                selectedSession = session 
                            }
                        }) {
                            ZStack(alignment: .bottomLeading) {
                                // Dynamic Thumbnail
                                Group {
                                    if let thumb = thumbnailManager.thumbnails[session.videoURL] {
                                        Image(uiImage: thumb)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.1))
                                            .onAppear {
                                                thumbnailManager.getThumbnail(for: session.videoURL)
                                            }
                                    }
                                }
                                .aspectRatio(16/9, contentMode: .fill)
                                .frame(height: 220)
                                .clipped()
                                .cornerRadius(20)
                                .overlay(
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.white)
                                        .padding(15)
                                        .background(Circle().fill(Color.black.opacity(0.3)).blur(radius: 5))
                                )
                                
                                LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .bottom, endPoint: .top)
                                    .cornerRadius(20)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(session.title)
                                            .font(.system(size: 22, weight: .bold, design: .serif))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if isBackgroundPlaybackEnabled {
                                            HStack(spacing: 4) {
                                                Image(systemName: "sparkles")
                                                Text("Background Play")
                                            }
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.2))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    Text(session.mantra)
                                        .font(.system(size: 14, design: .serif))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(20)
                            }
                            .contentShape(Rectangle())
                        }
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer(minLength: 40)
                    
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.4))
                        Text("New sessions added weekly")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedSession) { session in
                FullscreenPlayer(session: session)
            }
        }
    }
}

@available(iOS 14.0, *)
struct FullscreenPlayer: View {
    let session: FocusSession
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isBackgroundPlaybackEnabled") var isBackgroundPlaybackEnabled = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Resolve local URL
            if let localUrl = Bundle.main.url(forResource: session.videoURL, withExtension: "mp4") {
                VideoPlayerContainer(url: localUrl)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Content Loading...")
                    .foregroundColor(.white)
            }
            
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.2)))
                    }
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: isBackgroundPlaybackEnabled ? "play.circle.fill" : "pause.circle.fill")
                        Text(isBackgroundPlaybackEnabled ? "Background ON" : "Background OFF")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text(session.mantra)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    
                    Text("Focus on your breath...")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 60)
            }
        }
    }
}

@available(iOS 14.0, *)
struct VideoPlayerContainer: UIViewControllerRepresentable {
    let url: URL
    @AppStorage("isBackgroundPlaybackEnabled") var isBackgroundPlaybackEnabled = true
    
    class Coordinator: NSObject {
        var tokens: [NSObjectProtocol] = []
        var player: AVPlayer?
        weak var playerViewController: AVPlayerViewController? // Reference to the controller
        
        deinit {
            for token in tokens {
                NotificationCenter.default.removeObserver(token)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        context.coordinator.player = player
        context.coordinator.playerViewController = controller
        
        player.actionAtItemEnd = .none
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        player.play()
        
        let loopToken = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        // Background Lifecycle handling
        let bgToken = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak player, weak controller] _ in
            if UserDefaults.standard.bool(forKey: "isBackgroundPlaybackEnabled") {
                // IMPORTANT: Detach player the view controller but let it keep playing
                controller?.player = nil
                player?.play() // Ensure it keeps playing
            } else {
                player?.pause()
            }
        }
        
        let fgToken = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak player, weak controller] _ in
            // Re-attach the player to the controller to see the video again
            if let p = player {
                controller?.player = p
                p.play()
            }
        }
        
        context.coordinator.tokens = [loopToken, bgToken, fgToken]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        // Force stop and cleanup
        coordinator.player?.pause()
        coordinator.player = nil
        uiViewController.player?.pause()
        uiViewController.player = nil
        
        for token in coordinator.tokens {
            NotificationCenter.default.removeObserver(token)
        }
        coordinator.tokens.removeAll()
    }
}

@available(iOS 14.0, *)
struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}
