import SwiftUI
import Combine

@available(iOS 14.0, *)
struct MainTabView: View {
    @ObservedObject var store: AuraStore
    @ObservedObject var privacyManager: PrivacyManager
    @EnvironmentObject var audio: AudioManager

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                if #available(iOS 14.0, *) {
                    HomeView(store: store)
                        .tabItem {
                            Image(systemName: "wand.and.stars")
                            Text("Styles")
                        }
                }

                if #available(iOS 14.0, *) {
                    ExploreView(store: store)
                        .tabItem {
                            Image(systemName: "photo.stack.fill")
                            Text("Gallery")
                        }
                }

                if #available(iOS 14.0, *) {
                    SettingsView(privacyManager: privacyManager, auraStore: store)
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                }
            }
            .accentColor(.aiPurple)

            // ── 迷你播放器浮层（仅在播放时显示）──────────────────────────
            if audio.isPlaying {
                MiniAudioPlayer()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 58)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: audio.isPlaying)
    }
}

// MARK: - Mini Audio Player

@available(iOS 14.0, *)
struct MiniAudioPlayer: View {
    @EnvironmentObject var audio: AudioManager

    var body: some View {
        HStack(spacing: 14) {
            // Track icon
            Image(systemName: audio.currentTrackIcon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.aiPurple)
                .frame(width: 36, height: 36)
                .background(Color.aiPurple.opacity(0.12))
                .clipShape(Circle())

            // Track name
            VStack(alignment: .leading, spacing: 2) {
                Text(audio.currentTrackName)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                Text("Studio Ambience")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Prev
            Button(action: { self.audio.audioPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }

            // Play/Pause
            Button(action: { self.audio.audioToggle() }) {
                Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(
                        LinearGradient(
                            colors: [Color.aiPurple, Color.aiPink],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
            }

            // Next
            Button(action: { self.audio.audioNext() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        )
    }
}
