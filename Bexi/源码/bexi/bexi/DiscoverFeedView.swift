import SwiftUI

@available(iOS 14.0, *)
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

@available(iOS 14.0, *)
struct MediaCardView: View {
    let item: MediaItem
    @EnvironmentObject var storageManager: StorageManager
    @State private var isFullScreenPresented = false
    
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
                
                Menu {
                    Button(action: {
                        storageManager.reportItem(urlString: item.urlString)
                    }) {
                        Label("Report Content", systemImage: "flag")
                    }
                    Button(action: {
                        storageManager.blockAuthor(author: item.author)
                    }) {
                        Label("Block Author (\(item.author))", systemImage: "nosign")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
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
                
                Spacer(minLength: 30)
            }
        }
        .navigationBarTitle("Post", displayMode: .inline)
        .navigationBarItems(trailing: Menu {
            Button(action: {
                storageManager.reportItem(urlString: item.urlString)
                presentationMode.wrappedValue.dismiss()
            }) {
                Label("Report Content", systemImage: "flag")
            }
            Button(action: {
                storageManager.blockAuthor(author: item.author)
                presentationMode.wrappedValue.dismiss()
            }) {
                Label("Block Author (\(item.author))", systemImage: "nosign")
            }
        } label: {
            Image(systemName: "ellipsis")
        })
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
    if #available(iOS 14.0, *) {
        DiscoverFeedView()
            .environmentObject(StorageManager())
    } else {
        // Fallback on earlier versions
    }
}
