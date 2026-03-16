import SwiftUI
import Combine

struct VideoListView: View {
    @ObservedObject private var videoData = VideoData()
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingAlert = false
    @State private var alertMsg = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<videoData.videos.count, id: \.self) { index in
                    let video = videoData.videos[index]
                    if video.isUnlocked {
                        NavigationLink(destination: VideoPlayerView(videoName: video.fileName)) {
                            VideoRowView(video: video)
                        }
                    } else {
                        Button(action: {
                            if storeManager.spend(amount: video.unlockCost) {
                                videoData.videos[index].isUnlocked = true
                            } else {
                                alertMsg = "Not enough coins. Please visit the shop in Settings."
                                showingAlert = true
                            }
                        }) {
                            HStack {
                                VideoRowView(video: video)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Dance Tutorials")
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Insufficient Balance"), message: Text(alertMsg), dismissButton: .default(Text("OK")))
        }
    }
}

struct VideoRowView: View {
    let video: DanceVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail
            ZStack(alignment: .bottomTrailing) {
                if let uiImage = UIImage(contentsOfFile: Bundle.main.path(forResource: video.fileName, ofType: "jpg") ?? "") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (UIScreen.main.bounds.width - 40), height: 180)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Image(video.fileName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (UIScreen.main.bounds.width - 40), height: 180)
                        .clipped()
                        .cornerRadius(12)
                        .background(Color.white.opacity(0.1))
                }
                
                HStack {
                    if !video.isUnlocked {
                        if #available(iOS 16.0, *) {
                            HStack(spacing: 4) {
                                Image(systemName: "hexagon.fill")
                                Text("\(video.unlockCost)")
                            }
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(6)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(6)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: video.isUnlocked ? "play.circle.fill" : "lock.fill")
                            .foregroundColor(.white)
                        Text(video.duration)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                }
                .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if #available(iOS 14.0, *) {
                        Text(video.category)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    Spacer()
                    
                    if #available(iOS 14.0, *) {
                        Text(video.difficulty)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                Text(video.title)
                    .font(.headline)
                
                Text(video.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
    }
}
