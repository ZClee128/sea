import SwiftUI

@available(iOS 15.0, *)
struct WardrobeView: View {
    @EnvironmentObject var appState: AppStateManager
    
    // Masonry-like grid layout
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if appState.savedLooks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Your Wardrobe is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Save your favorite looks from Discover to build your personal collection.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(appState.savedLooks) { look in
                                NavigationLink(destination: LookDetailView(look: look)) {
                                    WardrobeGridItem(look: look)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Wardrobe")
        }
    }
}

@available(iOS 15.0, *)
struct WardrobeGridItem: View {
    let look: Look
    
    var body: some View {
        if let firstMedia = look.mediaItems.first {
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    if firstMedia.type == .image {
                        Group {
                            if let localName = firstMedia.localImageName {
                                Image(localName)
                                    .resizable()
                                    .scaledToFill()
                            } else if let urlString = firstMedia.urlString, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                }
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.width / firstMedia.aspectRatio)
                        .clipped()
                    } else if firstMedia.urlString != nil || firstMedia.localImageName != nil {
                        // Just show a static thumbnail or simple color for Wardrobe grid to save resources
                        // In a real app we might extract the first frame
                        ZStack {
                            Color.black
                            Image(systemName: "play.circle")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.width / firstMedia.aspectRatio)
                    } else {
                        Color.black.frame(width: geometry.size.width, height: geometry.size.width / firstMedia.aspectRatio)
                    }
                    
                    if look.mediaItems.count > 1 {
                        Image(systemName: "square.stack.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
            }
            // Estimate height based on aspect ratio
            .frame(height: (UIScreen.main.bounds.width / 2 - 24) / CGFloat(firstMedia.aspectRatio))
            .cornerRadius(12)
        } else {
            EmptyView()
        }
    }
}
