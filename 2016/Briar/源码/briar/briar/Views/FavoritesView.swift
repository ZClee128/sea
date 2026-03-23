import SwiftUI

struct FavoritesView: View {
    @State private var favoritePosts: [Post] = []
    
    var body: some View {
        NavigationView {
            Group {
                if favoritePosts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No saved posts yet.")
                            .font(.headline)
                        Text("Bookmark your favorite entertainment!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(favoritePosts) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                HStack(spacing: 16) {
                                    Rectangle()
                                        .fill(Color(UIColor.secondarySystemBackground))
                                        .frame(width: 80, height: 60)
                                        .cornerRadius(8)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(post.category.rawValue)
                                            .font(.system(size: 10))
                                            .foregroundColor(.blue)
                                        Text(post.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(2)
                                        Text(post.author)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("Bookmarks")
            .onAppear(perform: loadFavorites)
        }
    }
    
    func loadFavorites() {
        let favIDs = UserDefaults.standard.stringArray(forKey: "FavoritePosts") ?? []
        favoritePosts = mockPosts.filter { favIDs.contains($0.id) }
    }
}
