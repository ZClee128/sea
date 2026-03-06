import SwiftUI

struct DiscoverFeedView: View {
    // Mock Data for the feed
    let mockData: [MediaItem] = [
        MediaItem(urlString: "c1.jpeg", isVideo: true, videoUrlString: "c1.mp4", author: "Bexi Creator"),
        MediaItem(urlString: "c2.jpeg", isVideo: true, videoUrlString: "c2.mp4", author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_8", isVideo: false, author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_7", isVideo: false, author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_6", isVideo: false, author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_5", isVideo: false, author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_4", isVideo: false, author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_3", isVideo: false, author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_2", isVideo: false, author: "Bexi Creator"),
        MediaItem(urlString: "cosplay_1", isVideo: false, author: "Bexi Creator")
    ]
    @EnvironmentObject var storageManager: StorageManager
    
    // Split data into two columns for a masonry look
    var filteredData: [MediaItem] {
        mockData.filter { item in
            !storageManager.reportedItems.contains(item.urlString) &&
            !storageManager.blockedAuthors.contains(item.author)
        }
    }
    
    var leftColumnData: [MediaItem] {
        filteredData.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }
    
    var rightColumnData: [MediaItem] {
        filteredData.enumerated().compactMap { $0.offset % 2 != 0 ? $0.element : nil }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(leftColumnData, id: \.id) { item in
                            MediaCardView(item: item)
                        }
                    }
                    
                    VStack(spacing: 10) {
                        ForEach(rightColumnData, id: \.id) { item in
                            MediaCardView(item: item)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Discover")
        }
    }
}

struct MediaCardView: View {
    let item: MediaItem
    @EnvironmentObject var storageManager: StorageManager
    @State private var isFullScreenPresented = false
    @State private var showingActionSheet = false
    
    var isSaved: Bool {
        storageManager.isSaved(urlString: item.urlString)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if #available(iOS 14.0, *) {
                ZStack(alignment: .topTrailing) {
                    RemoteImage(urlString: item.urlString)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            isFullScreenPresented = true
                        }
                    
                    if item.isVideo {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(8)
                            .shadow(radius: 2)
                    }
                }
                .fullScreenCover(isPresented: $isFullScreenPresented) {
                    if item.isVideo, let videoName = item.videoUrlString, let url = Bundle.main.url(forResource: (videoName as NSString).deletingPathExtension, withExtension: (videoName as NSString).pathExtension) {
                        VideoPlayerView(urlString: url.absoluteString, isPresented: $isFullScreenPresented)
                    } else {
                        FullScreenImageView(urlString: item.urlString, isPresented: $isFullScreenPresented)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
            // Interaction Bar
            HStack {
                Button(action: {
                    toggleSave()
                }) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundColor(isSaved ? .red : .primary)
                }
                
                Spacer()
                
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(
                        title: Text("Options"),
                        message: Text("Manage this content"),
                        buttons: [
                            .destructive(Text("Report Content")) {
                                storageManager.reportItem(urlString: item.urlString)
                            },
                            .destructive(Text("Block Author (\(item.author))")) {
                                storageManager.blockAuthor(author: item.author)
                            },
                            .cancel()
                        ]
                    )
                }
                
                Spacer()
                
                Button(action: {
                    // Quick save trigger if not saved
                    if !isSaved {
                        toggleSave()
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 4)
            .padding(.bottom, 12)
        }
    }
    
    private func toggleSave() {
        if isSaved {
            storageManager.removeItem(urlString: item.urlString)
        } else {
            storageManager.saveItem(item)
        }
    }
}

#Preview {
    DiscoverFeedView()
        .environmentObject(StorageManager())
}
