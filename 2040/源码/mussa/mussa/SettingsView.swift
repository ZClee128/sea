import SwiftUI

@available(iOS 14.0, *)
struct SettingsView: View {
    @ObservedObject var privacyManager: PrivacyManager
    @ObservedObject var auraStore: AuraStore
    @EnvironmentObject var audio: AudioManager

    @State private var showingPrivacy = false
    @State private var showingStore = false

    var body: some View {
        NavigationView {
            List {

                // ── Credits ───────────────────────────────────────────────
                Section(header: Text("Balance")) {
                    HStack {
                        Image(systemName: "pentagon.fill")
                            .foregroundColor(.yellow)
                        Text("My Credits")
                        Spacer()
                        Text("\(auraStore.userCoins)")
                            .bold()
                            .foregroundColor(.aiPurple)
                    }
                    Button(action: { showingStore = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.aiPurple)
                            Text("Get More Credits")
                                .foregroundColor(.aiPurple)
                                .bold()
                        }
                    }
                }

                // ── Studio Ambience ───────────────────────────────────────
                Section(header: Text("Studio Ambience")) {

                    // Master Toggle
                    HStack {
                        Image(systemName: "headphones")
                            .foregroundColor(.aiPurple)
                            .frame(width: 28)
                        Text("Immersive Audio")
                        Spacer()
                        Toggle("", isOn: Binding<Bool>(
                            get: { self.audio.isPlaying },
                            set: { on in
                                if on { self.audio.audioPlay() } else { self.audio.audioPause() }
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .aiPurple))
                    }

                    // Track selector
                    if audio.isPlaying {
                        ForEach(audio.tracks.indices, id: \.self) { i in
                            Button(action: { self.audio.audioPlay(trackIndex: i) }) {
                                HStack {
                                    Image(systemName: audio.tracks[i].icon)
                                        .foregroundColor(i == audio.currentTrackIndex ? .aiPurple : .secondary)
                                        .frame(width: 28)
                                    Text(audio.tracks[i].name)
                                        .foregroundColor(i == audio.currentTrackIndex ? .aiPurple : .primary)
                                    Spacer()
                                    if i == audio.currentTrackIndex {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.aiPurple)
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                            }
                        }
                    }

                    // Volume Slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13))
                            Slider(
                                value: Binding<Double>(
                                    get: { Double(self.audio.volume) },
                                    set: { self.audio.audioSetVolume(Float($0)) }
                                ),
                                in: 0...1
                            )
                            .accentColor(.aiPurple)
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13))
                        }
                        
                        // Debug Test Button
                        Button(action: { self.audio.playTestSound() }) {
                            HStack {
                                Image(systemName: "waveform.path.badge.plus")
                                    .font(.system(size: 14))
                                Text("Test Audio System")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("Play Beep")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.aiPurple.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // ── App Information ───────────────────────────────────────
                Section(header: Text("App Information")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Mussa")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }

                // ── Legal ─────────────────────────────────────────────────
                Section(header: Text("Legal")) {
                    Button(action: { showingPrivacy = true }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacy) {
                PrivacyView(privacyManager: privacyManager, showAgreeButton: false)
            }
            .sheet(isPresented: $showingStore) {
                CoinStoreView(auraStore: auraStore)
            }
        }
    }
}
