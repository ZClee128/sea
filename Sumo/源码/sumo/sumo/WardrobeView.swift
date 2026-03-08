import SwiftUI

@available(iOS 15.0, *)
struct WardrobeView: View {
    @EnvironmentObject var appState: AppStateManager

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
                        // Image item
                        Group {
                            if let localName = firstMedia.localImageName {
                                Image(localName)
                                    .resizable()
                                    .scaledToFill()
                            } else if let urlString = firstMedia.urlString, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Rectangle().fill(Color.gray.opacity(0.2))
                                    }
                                }
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.width / firstMedia.aspectRatio)
                        .clipped()
                    } else {
                        // Video item: show coverImageName with play icon overlay
                        ZStack {
                            if let cover = firstMedia.coverImageName {
                                Image(cover)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.width / firstMedia.aspectRatio)
                                    .clipped()
                            } else {
                                Color.black
                                    .frame(width: geometry.size.width, height: geometry.size.width / firstMedia.aspectRatio)
                            }
                            Image(systemName: "play.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.85))
                                .shadow(radius: 4)
                        }
                    }

                    // Multi-item badge
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
            .frame(height: (UIScreen.main.bounds.width / 2 - 24) / CGFloat(firstMedia.aspectRatio))
            .cornerRadius(12)
        } else {
            EmptyView()
        }
    }
}
