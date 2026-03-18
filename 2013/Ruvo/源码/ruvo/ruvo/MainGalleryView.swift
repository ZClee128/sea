import SwiftUI

struct MainGalleryView: View {
    let columns = 2
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Featured Section
                    VStack(alignment: .leading) {
                        Text("Featured")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(MockData.featuredArtworks) { artwork in
                                    NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                                        FeaturedArtworkCard(artwork: artwork)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    
                    // All Resources Section
                    VStack(alignment: .leading) {
                        Text("Browse References")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .padding(.horizontal)
                        
                        let remainingArtworks = Array(MockData.artworks.dropFirst(2))
                        let chunkedArtworks = remainingArtworks.chunked(into: columns)
                        VStack(spacing: 16) {
                            ForEach(0..<chunkedArtworks.count, id: \.self) { rowIndex in
                                HStack(spacing: 16) {
                                    ForEach(chunkedArtworks[rowIndex]) { artwork in
                                        NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                                            ArtworkCardView(artwork: artwork)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    if chunkedArtworks[rowIndex].count < columns {
                                        let emptyCount = columns - chunkedArtworks[rowIndex].count
                                        ForEach(0..<emptyCount, id: \.self) { _ in
                                            Color.clear
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitle(Text("Ruvo Gallery"), displayMode: .large)
        }
    }
}

struct FeaturedArtworkCard: View {
    let artwork: Artwork
    @ObservedObject var unlockedManager = UnlockedManager.shared
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // Image Background
            if let uiImage = UIImage(named: artwork.title) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 280, height: 180)
                    .clipped()
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: artwork.imageName)
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                .frame(width: 280, height: 180)
            }
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(artwork.category.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                
                Text(artwork.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(artwork.artist)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
            
            // Lock Indicator
            if artwork.isPremium && !unlockedManager.isUnlocked(artwork) {
                Image(systemName: "lock.fill")
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(width: 280, height: 180)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct ArtworkCardView: View {
    let artwork: Artwork
    @ObservedObject var unlockedManager = UnlockedManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(named: artwork.title) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 160)
                        .clipped()
                } else {
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: artwork.imageName)
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 160)
                }
                
                // Lock Indicator
                if artwork.isPremium && !unlockedManager.isUnlocked(artwork) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding(6)
                }
            }
            .frame(height: 160)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(artwork.artist)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
    }
}
