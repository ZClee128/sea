//
//  TrailersView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI
import AVKit

// iOS 13 Compatible AVPlayer bridge to SwiftUI
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false // Custom control layout overlays
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

struct TrailersView: View {
    @ObservedObject private var videoManager = VideoManager.shared
    
    var currentTrailer: VideoManager.DramaTrailer {
        videoManager.trailers[videoManager.currentTrailerIndex]
    }
    
    var playerHeight: CGFloat {
        let size = videoManager.videoSize
        if size.width > 0 && size.height > 0 {
            let ratio = size.height / size.width
            if ratio > 1.0 {
                // Vertical video - limit max height to 520 for highly immersive visual spacing (NetEase Cloud style)
                return min(520, (UIScreen.main.bounds.width - 20) * ratio)
            } else {
                // Landscape video - calculate exact widescreen ratio
                return (UIScreen.main.bounds.width - 20) * ratio
            }
        }
        return 280 // Fallback aspect height
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Header
                        ViewHeader(
                             title: "Trailers",
                             subtitle: "Drama Previews"
                        )
                        
                        // Elegant Video Canvas Screen
                        VStack(spacing: 0) {
                            ZStack {
                                // Live Video view
                                VideoPlayerView(player: videoManager.player)
                                    .frame(height: playerHeight)
                                    .cornerRadius(16)
                                    .clipped()
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                
                                // Direct Play/Pause click overlay
                                if !videoManager.isPlaying {
                                    Color.black.opacity(0.3)
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            videoManager.play()
                                        }
                                    
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.9))
                                        .shadow(radius: 5)
                                        .onTapGesture {
                                            videoManager.play()
                                        }
                                } else {
                                    // Hidden tap overlay to pause
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .frame(height: playerHeight)
                                        .onTapGesture {
                                            videoManager.pause()
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        // Metadata Titles Card
                        GlassCard(padding: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(currentTrailer.category.uppercased())
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(Theme.primaryPeach)
                                        .tracking(1.5)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.caption2)
                                            .foregroundColor(Theme.textLight)
                                        Text(currentTrailer.durationText)
                                            .font(.caption2)
                                            .bold()
                                            .foregroundColor(Theme.textMedium)
                                    }
                                }
                                
                                Text(currentTrailer.title)
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Theme.textDark)
                                
                                Text(currentTrailer.dramaTitle)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(Theme.textMedium)
                                
                                Text(currentTrailer.description)
                                    .font(.caption)
                                    .foregroundColor(Theme.textLight)
                                    .lineLimit(3)
                                    .lineSpacing(2)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Timeline & Slider Controls
                        VStack(spacing: 8) {
                            // Custom progress track
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Theme.borderGray)
                                        .frame(height: 5)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Theme.accentGradient)
                                        .frame(width: CGFloat(videoManager.currentTrackProgress) * geo.size.width, height: 5)
                                }
                            }
                            .frame(height: 5)
                            .padding(.horizontal, 30)
                            
                            HStack {
                                Text(videoManager.currentTrackTime)
                                Spacer()
                                Text(videoManager.trackDuration)
                             }
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Theme.textLight)
                            .padding(.horizontal, 30)
                        }
                        .padding(.vertical, 4)
                        
                        // Main Playback Controller buttons
                        HStack(spacing: 28) {
                            // Previous Button
                            Button(action: { videoManager.previousTrack() }) {
                                Image(systemName: "backward.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.textDark)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            // Center Play / Pause Circle Toggle
                            Button(action: { videoManager.togglePlay() }) {
                                Circle()
                                    .fill(Theme.accentGradient)
                                    .frame(width: 65, height: 65)
                                    .overlay(
                                        Image(systemName: videoManager.isPlaying ? "pause.fill" : "play.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .offset(x: videoManager.isPlaying ? 0 : 2)
                                    )
                                    .shadow(color: Theme.accentPink.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            // Next Button
                            Button(action: { videoManager.nextTrack() }) {
                                Image(systemName: "forward.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.textDark)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        
                        // Volume Adjustment control
                        HStack(spacing: 12) {
                            Image(systemName: videoManager.volume == 0 ? "speaker.slash.fill" : "speaker.wave.1.fill")
                                .font(.caption)
                                .foregroundColor(Theme.textMedium)
                                .onTapGesture {
                                    videoManager.volume = videoManager.volume > 0 ? 0.0 : 0.8
                                }
                            
                            Slider(value: $videoManager.volume, in: 0.0...1.0)
                                .accentColor(Theme.primaryPeach)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.caption)
                                .foregroundColor(Theme.textMedium)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 4)
                        
                        // Playlist List
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Curated Clips Playlist (\(videoManager.trailers.count))")
                                .font(.headline)
                                .foregroundColor(Theme.textDark)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 10) {
                                ForEach(0..<videoManager.trailers.count, id: \.self) { index in
                                    let trailer = videoManager.trailers[index]
                                    let isSelected = videoManager.currentTrailerIndex == index
                                    
                                    Button(action: {
                                        let wasPlaying = videoManager.isPlaying
                                        videoManager.pause()
                                        videoManager.loadTrailer(at: index)
                                        if wasPlaying {
                                            videoManager.play()
                                        } else {
                                            videoManager.play() // Auto play on tap
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            // Mini Clip Preview placeholder badge
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(isSelected ? Theme.accentGradient : LinearGradient(colors: [Theme.borderGray], startPoint: .top, endPoint: .bottom))
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Image(systemName: isSelected && videoManager.isPlaying ? "play.circle.fill" : "video.fill")
                                                        .font(.caption)
                                                        .foregroundColor(isSelected ? .white : Theme.textMedium)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(trailer.title)
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundColor(isSelected ? Theme.primaryPeach : Theme.textDark)
                                                    .lineLimit(1)
                                                
                                                Text(trailer.dramaTitle)
                                                    .font(.caption2)
                                                    .foregroundColor(Theme.textMedium)
                                                    .lineLimit(1)
                                            }
                                            
                                            Spacer()
                                            
                                            if isSelected {
                                                Image(systemName: "waveform")
                                                    .font(.headline)
                                                    .foregroundColor(Theme.primaryPeach)
                                            } else {
                                                Text(trailer.durationText)
                                                    .font(.caption2)
                                                    .foregroundColor(Theme.textLight)
                                            }
                                        }
                                        .padding(10)
                                        .background(Color.white)
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(isSelected ? Theme.primaryPeach.opacity(0.3) : Theme.borderGray, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 80)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onDisappear {
            videoManager.pause()
        }
        .preferredColorScheme(.light)
    }
}

struct TrailersView_Previews: PreviewProvider {
    static var previews: some View {
        TrailersView()
    }
}
