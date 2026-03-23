import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var isFavorite: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero Image Placeholder
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
                        .font(.caption)
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
                        .font(.body)
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
        .navigationBarItems(trailing: Button(action: toggleFavorite) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(isFavorite ? .red : .black)
        })
        .onAppear(perform: loadFavoriteStatus)
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
}
