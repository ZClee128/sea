import SwiftUI
import AVFoundation

struct CinemaView: View {
    @EnvironmentObject var coinManager: CoinManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                if #available(iOS 14.0, *) {
                    LazyVStack(spacing: 32) {
                        ForEach(ZayoData.videoPortraits) { video in
                            NavigationLink(destination: CinematicPlayerDetail(video: video)) {
                                VideoThumbnailCard(video: video)
                                    .overlay(
                                        Group {
                                            if !video.isFree && !coinManager.isVideoUnlocked(video.id) {
                                                ZStack {
                                                    Color.black.opacity(0.4)
                                                    Image(systemName: "lock.fill")
                                                        .font(.title)
                                                        .foregroundColor(.white)
                                                }
                                                .cornerRadius(12)
                                            }
                                        }
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                } else {
                    // Fallback on earlier versions
                }
            }
            .navigationBarTitle("Zayo Cinema", displayMode: .inline)
            .navigationBarItems(
                trailing: HStack(spacing: 4) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(coinManager.balance)")
                        .fontWeight(.bold)
                }
            )
        }
    }
}

struct VideoThumbnailCard: View {
    let video: VideoPortrait
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Image(video.title)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .overlay(
                        ZStack {
                            Color.black.opacity(0.1)
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    )
            }
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                
                Text(video.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

struct CinematicPlayerDetail: View {
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var storeManager: StoreManager
    let video: VideoPortrait
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var showingStore = false
    @State private var isVisible = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if #available(iOS 14.0, *) {
            VStack(spacing: 0) {
                if let url = video.resolvedUrl {
                    Group {
                        if video.isFree || coinManager.isVideoUnlocked(video.id) {
                            if let player = player {
                                // Detach player when hidden to avoid system pausing it
                                VideoPlayerView(player: isVisible ? player : AVPlayer())
                            } else {
                                Color.black
                            }
                        } else {
                            // Locked View
                            VStack(spacing: 16) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("This cinematic collection is locked")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    if !coinManager.unlockVideo(id: video.id, cost: video.cost) {
                                        self.showingStore = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "bitcoinsign.circle.fill")
                                        Text("Unlock for \(video.cost) Coins")
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(25)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.9))
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fit)
                    .background(Color.black)
                    .onAppear {
                        self.isVisible = true
                        if video.isFree || coinManager.isVideoUnlocked(video.id) {
                            if self.player == nil {
                                let playerItem = AVPlayerItem(url: url)
                                let queuePlayer = AVQueuePlayer(playerItem: playerItem)
                                queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
                                queuePlayer.automaticallyWaitsToMinimizeStalling = false
                                queuePlayer.volume = 1.0 
                                
                                self.looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
                                self.player = queuePlayer
                            }
                            self.player?.play()
                        }
                    }
                    .onDisappear {
                        if !presentationMode.wrappedValue.isPresented {
                            self.player?.pause()
                            self.player = nil
                            self.looper = nil
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                        self.isVisible = false
                        // Keep playing after a short delay to ensure detachment processed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.player?.play()
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        self.isVisible = true
                        self.player?.play()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { notification in
                        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                              let type = AVAudioSession.InterruptionType(rawValue: typeValue),
                              type == .ended else { return }
                        self.player?.play()
                    }
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(video.title)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                        
                        Divider()
                        
                        Text("About this Clip")
                            .font(.headline)
                        
                        Text(video.description)
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "film")
                                Text("Format: \(video.format)")
                            }
                            HStack {
                                Image(systemName: "timer")
                                Text("Duration: \(video.duration)")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingStore) {
                StoreView()
                    .environmentObject(self.storeManager)
                    .environmentObject(self.coinManager)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct CinemaView_Previews: PreviewProvider {
    static var previews: some View {
        CinemaView()
    }
}
