import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager = FavoritesManager.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.98, blue: 0.96)
                .edgesIgnoringSafeArea(.bottom)
            
            let favoriteItems = FashionData.sampleItems.filter { favoritesManager.isFavorite(id: $0.id) }
            
            if favoriteItems.isEmpty {
                EmptyStateView(
                    icon: "heart.slash",
                    title: "No Favorites Yet",
                    message: "Explore and save styles you love to see them here!"
                )
            } else {
                PhotosGridView(items: favoriteItems)
            }
        }
        .navigationBarTitle("My Favorites", displayMode: .inline)
    }
}



struct PhotosGridView: View {
    let items: [FashionItem]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(items) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        HStack(spacing: 12) {
                            Group {
                                if let uiImage = UIImage(named: item.imageName) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray.opacity(0.2)
                                }
                            }
                            .frame(width: 80, height: 100)
                            .clipped()
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Text(item.category)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
        }
    }
}



struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
