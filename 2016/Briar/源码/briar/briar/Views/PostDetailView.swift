import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PostDetailView: View {
    let post: Post
    @State private var isFavorite: Bool = false
    @State private var showShareSheet = false
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(post.category.rawValue.uppercased())
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(post.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                        Text(post.author)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(post.date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 8)
                    
                    Text(post.content)
                        .font(.system(size: 17 * settings.fontSizeMultiplier))
                        .foregroundColor(Color(UIColor.darkGray))
                        .lineSpacing(6)
                    
                    Divider().padding(.vertical, 8)
                    
                    if let videoUrl = post.videoURLString {
                        Text("Featured Video")
                            .font(.headline)
                        
                        VideoPlayerView(urlStr: videoUrl)
                            .frame(height: 220)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: HStack(spacing: 20) {
            Button(action: { showShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.black)
            }
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                    .foregroundColor(isFavorite ? .red : .black)
            }
        })
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [post.title])
        }
        .onAppear {
            loadFavoriteStatus()
            trackHistory()
        }
    }
    
    func toggleFavorite() {
        var favs = UserDefaults.standard.stringArray(forKey: "FavoritePosts") ?? []
        if isFavorite {
            favs.removeAll { $0 == post.id }
        } else {
            favs.append(post.id)
        }
        UserDefaults.standard.set(favs, forKey: "FavoritePosts")
        isFavorite.toggle()
    }
    
    func loadFavoriteStatus() {
        let favs = UserDefaults.standard.stringArray(forKey: "FavoritePosts") ?? []
        isFavorite = favs.contains(post.id)
    }
    
    func trackHistory() {
        var history = UserDefaults.standard.stringArray(forKey: "HistoryPosts") ?? []
        history.removeAll { $0 == post.id }
        history.insert(post.id, at: 0)
        if history.count > 20 { history = Array(history.prefix(20)) }
        UserDefaults.standard.set(history, forKey: "HistoryPosts")
    }
}
