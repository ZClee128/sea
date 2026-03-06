import SwiftUI

@available(iOS 15.0, *)
struct FeedItemCell: View {
    let look: Look
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                AsyncImage(url: URL(string: look.authorAvatar)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        Image(systemName: "person.circle.fill").foregroundColor(.gray)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(look.author)
                        .font(.headline)
                    Text(look.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {
                    withAnimation {
                        appState.toggleSave(look: look)
                    }
                }) {
                    Image(systemName: appState.isSaved(look: look) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(appState.isSaved(look: look) ? .primary : .secondary)
                        .font(.title3)
                }
                
                // UGC Compliance Menu
                Menu {
                    Button(role: .destructive, action: {
                        withAnimation {
                            appState.blockUser(look.author)
                        }
                    }) {
                        Label("Block User", systemImage: "nosign")
                    }
                    
                    Button(role: .destructive, action: {
                        // Dummy report action, in a real app this hits an API
                        print("Reported look \(look.id) from \(look.author)")
                    }) {
                        Label("Report", systemImage: "exclamationmark.bubble")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .font(.title3)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            
            // Media Content
            if let firstMedia = look.mediaItems.first {
                GeometryReader { geometry in
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
                                            .overlay(ProgressView())
                                    }
                                }
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.width / firstMedia.aspectRatio)
                        .clipped()
                    } else {
                        // Video: show cover image + play icon overlay in the feed
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
                                .font(.system(size: 52))
                                .foregroundColor(.white.opacity(0.85))
                                .shadow(radius: 4)
                        }
                    }
                }
                // Calculate height based on aspect ratio
                .frame(height: UIScreen.main.bounds.width / CGFloat(firstMedia.aspectRatio))
            }
            
            // Description & Likes
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(look.likes)")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if look.mediaItems.count > 1 {
                        Image(systemName: "square.stack.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 4)
                
                Text(look.author)
                    .fontWeight(.bold) +
                Text(" \(look.description)")
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.vertical, 8)
    }
}
