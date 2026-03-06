import SwiftUI

struct DiscoverFeedView: View {
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Trending", "Cosplay", "Gaming", "Style", "Explore"]

    @EnvironmentObject var storageManager: StorageManager
    
    var filteredData: [MediaItem] {
        ContentProvider.items.filter { item in
            let safetyCheck = !storageManager.reportedItems.contains(item.urlString) &&
                              !storageManager.blockedAuthors.contains(item.author)
            let categoryCheck = selectedCategory == "All" || item.tags.contains(selectedCategory.lowercased())
            return safetyCheck && categoryCheck
        }
    }
    
    var leftColumnData: [MediaItem] {
        filteredData.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }
    
    var rightColumnData: [MediaItem] {
        filteredData.enumerated().compactMap { $0.offset % 2 != 0 ? $0.element : nil }
    }
    
    var body: some View {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                                    .fontWeight(.bold)
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
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
            }
            .navigationBarTitle("Discover")
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
                .sheet(isPresented: $isFullScreenPresented) {
                    NavigationView {
                        FeedDetailView(item: item)
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

@available(iOS 14.0, *)
struct FeedDetailView: View {
    let item: MediaItem
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isLiked = false
    @State private var showingActionSheet = false
    @State private var isFollowing = false

    var isSaved: Bool {
        storageManager.isSaved(urlString: item.urlString)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    if let avatar = item.avatarUrlString {
                        RemoteImage(urlString: avatar)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(item.author)
                            .font(.headline)
                        Text(item.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isFollowing.toggle()
                    }) {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(isFollowing ? .primary : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isFollowing ? Color.gray.opacity(0.2) : Color.blue)
                            .cornerRadius(20)
                    }
                }
                .padding()
                
                // Media
                if item.isVideo, let videoName = item.videoUrlString, let url = Bundle.main.url(forResource: (videoName as NSString).deletingPathExtension, withExtension: (videoName as NSString).pathExtension) {
                    VideoPlayerView(urlString: url.absoluteString, isPresented: .constant(true))
                        .frame(height: 400)
                        .clipped()
                } else {
                    RemoteImage(urlString: item.urlString)
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
                
                // Actions
                HStack(spacing: 20) {
                    Button(action: {
                        isLiked.toggle()
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(isLiked ? .red : .primary)
                    }
                    
                    Button(action: {
                        // Focus on comment
                    }) {
                        Image(systemName: "bubble.right")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        toggleSave()
                    }) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.title2)
                            .foregroundColor(isSaved ? .blue : .primary)
                    }
                }
                .padding()
                
                // Content Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(item.likes + (isLiked ? 1 : 0)) likes")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    if !item.description.isEmpty {
                        Text(item.author)
                            .fontWeight(.bold) +
                        Text(" ") +
                        Text(item.description)
                    }
                    
                    if !item.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(item.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                // Comments
                VStack(alignment: .leading, spacing: 18) {
                    Text("Comments (\(item.comments.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if item.comments.isEmpty {
                        Text("No comments yet. Be the first to comment!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(item.comments) { comment in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .bottom) {
                                        Text(comment.author)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        Text(comment.createdAt, style: .relative)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 4)
                                    }
                                    
                                    Text(comment.text)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitle("Post", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            showingActionSheet = true
        }) {
            Image(systemName: "ellipsis")
        })
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Options"),
                message: Text("Manage this content"),
                buttons: [
                    .destructive(Text("Report Content")) {
                        storageManager.reportItem(urlString: item.urlString)
                        presentationMode.wrappedValue.dismiss()
                    },
                    .destructive(Text("Block Author (\(item.author))")) {
                        storageManager.blockAuthor(author: item.author)
                        presentationMode.wrappedValue.dismiss()
                    },
                    .cancel()
                ]
            )
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
