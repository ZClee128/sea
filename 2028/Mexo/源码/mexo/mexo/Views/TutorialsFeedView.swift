import SwiftUI

@available(iOS 14.0, *)
struct TutorialsFeedView: View {
    let videos: [VideoModel] = VideoModel.mockData
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedVideo: VideoModel?
    @State private var showingUnlockAlert = false
    @State private var showingStore = false
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(videos) { video in
                            VideoRowWrapper(video: video, selectedVideo: $selectedVideo, showingUnlockAlert: $showingUnlockAlert) {
                                VideoRowView(video: video)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                            }
                            Divider().padding(.leading, 172)
                        }
                    }
                }
                .navigationTitle("Tutorials")
                .alert(isPresented: $showingUnlockAlert) {
                    Alert(
                        title: Text("Unlock Tutorial"),
                        message: Text("Would you like to unlock this premium video for \(selectedVideo?.coinPrice ?? 0) coins?"),
                        primaryButton: .default(Text("Unlock")) {
                            if let video = selectedVideo {
                                if storeManager.unlockContent(id: video.id, price: video.coinPrice) {
                                    // Success
                                } else {
                                    showingStore = true
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .sheet(isPresented: $showingStore) {
                    StoreView()
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

@available(iOS 14.0, *)
struct VideoRowWrapper<Content: View>: View {
    let video: VideoModel
    @Binding var selectedVideo: VideoModel?
    @Binding var showingUnlockAlert: Bool
    let content: () -> Content
    
    @StateObject private var storeManager = StoreManager.shared
    @State private var navigateToDetail = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: VideoPlayerDetailView(video: video), isActive: $navigateToDetail) {
                EmptyView()
            }
            
            Button(action: {
                if video.isPremium && !storeManager.isContentUnlocked(id: video.id) {
                    selectedVideo = video
                    showingUnlockAlert = true
                } else {
                    navigateToDetail = true
                }
            }) {
                content()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct VideoRowView: View {
    let video: VideoModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Thumbnail
            ZStack {
                Image(video.thumbnailUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 90)
                    .cornerRadius(8)
                    .clipped()
                
                if #available(iOS 14.0, *) {
                    if video.isPremium && !StoreManager.shared.isContentUnlocked(id: video.id) {
                        Color.black.opacity(0.3)
                            .frame(width: 140, height: 90)
                            .cornerRadius(8)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                            Text("\(video.coinPrice)")
                                .font(.caption2)
                                .fontWeight(.black)
                        }
                        .foregroundColor(.white)
                    } else {
                        // Play Icon Overlay
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                } else {
                    // Fallback on earlier versions
                }
                
                // Duration Label
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if #available(iOS 14.0, *) {
                            Text(video.duration)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                                .padding(4)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                .frame(width: 140, height: 90)
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(video.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
    }
}

struct TutorialsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            TutorialsFeedView()
        } else {
            // Fallback on earlier versions
        }
    }
}
