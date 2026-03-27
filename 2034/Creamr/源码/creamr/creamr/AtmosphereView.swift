import SwiftUI
import AVKit

// MARK: - Data Model
struct AtmosphereItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let mood: String
}

let atmosphereItems: [AtmosphereItem] = [
    AtmosphereItem(
        title: "Celestial Flow",
        subtitle: "Let the dance of cosmic light carry your mind into stillness.",
        mood: "✦ Focus · Calm"
    ),
    AtmosphereItem(
        title: "Emerald Echo",
        subtitle: "Breathe in the ancient wisdom of the forest's eternal rhythm.",
        mood: "✦ Relax · Peace"
    )
]

// MARK: - Player key
private enum LooperKey { static var key = "looper" }

// MARK: - Fullscreen Video Player
@available(iOS 15.0, *)
struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let title: String
    let backgroundPlayback: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.showsPlaybackControls = true
        vc.videoGravity = .resizeAspect

        // Audio session — .playback allows background, .soloAmbient does NOT
        let category: AVAudioSession.Category = backgroundPlayback ? .playback : .soloAmbient
        let mode: AVAudioSession.Mode = backgroundPlayback ? .moviePlayback : .default
        try? AVAudioSession.sharedInstance().setCategory(category, mode: mode)
        try? AVAudioSession.sharedInstance().setActive(true)

        if let url = Bundle.main.url(forResource: title, withExtension: "mp4") {
            let item = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(playerItem: item)
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            // Retain looper via associated object so it doesn't get released
            objc_setAssociatedObject(queuePlayer, &LooperKey.key, looper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            vc.player = queuePlayer
            queuePlayer.play()

            // Register with global manager (strong ref) so AppDelegate can pause it
            VideoPlaybackManager.shared.currentPlayer = queuePlayer
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    // Called when fullScreenCover is dismissed
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        VideoPlaybackManager.shared.clearPlayer()
        uiViewController.player = nil
    }
}

// MARK: - Video Card
@available(iOS 15.0, *)
struct AtmosphereCard: View {
    let item: AtmosphereItem
    @State private var showPlayer = false
    @AppStorage("backgroundPlayback") private var backgroundPlayback = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { showPlayer = true }) {
                ZStack {
                    Image(item.title)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()

                    Color.black.opacity(0.35)

                    // Play button
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                                .offset(x: 3)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 12)

                    // Mood badge top-right
                    Text(item.mood)
                        .font(.caption2).fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(12)

                    // Background playback hint bottom-right
                    if backgroundPlayback {
                        HStack(spacing: 5) {
                            Image(systemName: "airplayaudio").font(.system(size: 11))
                            Text("Supports background playback").font(.caption2)
                        }
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(12)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .fullScreenCover(isPresented: $showPlayer) {
                ZStack(alignment: .topLeading) {
                    Color.black.ignoresSafeArea()
                    FullscreenVideoPlayer(title: item.title, backgroundPlayback: backgroundPlayback)
                        .ignoresSafeArea()
                    Button(action: { showPlayer = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white, .black.opacity(0.5))
                            .padding(16)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title).font(.title3).fontWeight(.bold)
                Text(item.subtitle)
                    .font(.subheadline).foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 12).padding(.horizontal, 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Atmosphere View
@available(iOS 15.0, *)
struct AtmosphereView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.05, green: 0.02, blue: 0.15),
                                Color(red: 0.22, green: 0.06, blue: 0.38)
                            ]),
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Atmosphere")
                                .font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                            Text("Immersive art in motion · Tap to play")
                                .font(.subheadline).foregroundColor(.white.opacity(0.65))
                        }
                        .padding()
                    }
                    .frame(height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    ForEach(atmosphereItems) { item in
                        AtmosphereCard(item: item)
                    }
                    Spacer(minLength: 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
