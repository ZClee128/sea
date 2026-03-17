import SwiftUI
import AVKit

struct VideoPlayerDetailView: View {
    let video: VideoModel
    @State private var player: AVPlayer?
    
    var body: some View {
        if #available(iOS 14.0, *) {
            VStack(spacing: 0) {
                // Video Player Area
                if let player = player {
                    if #available(iOS 14.0, *) {
                        VideoPlayer(player: player)
                            .frame(height: 250)
                            .edgesIgnoringSafeArea(.horizontal)
                            .onAppear {
                                player.play()
                            }
                            .onDisappear {
                                player.pause()
                            }
                    } else {
                        Text("Video player requires iOS 14+")
                            .frame(height: 250)
                            .background(Color.black)
                            .foregroundColor(.white)
                    }
                } else {
                    if #available(iOS 14.0, *) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 250)
                            .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)))
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                // Video Information
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if #available(iOS 14.0, *) {
                            Text(video.title)
                                .font(.title2)
                                .fontWeight(.bold)
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                            Text(video.duration)
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text("Description")
                            .font(.headline)
                        
                        Text(video.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupPlayer()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setupPlayer() {
        if let url = URL(string: video.videoUrl) {
            player = AVPlayer(url: url)
        }
    }
}

// Previews
struct VideoPlayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VideoPlayerDetailView(video: VideoModel.mockData[0])
        }
    }
}
