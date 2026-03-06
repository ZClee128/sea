import SwiftUI

@available(iOS 15.0, *)
struct LookDetailView: View {
    let look: Look
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Media Gallery
                MediaGalleryView(mediaItems: look.mediaItems)
                    // Calculate height based on first item aspect ratio to keep it looking nice
                    // Or default to square if missing
                    .frame(height: UIScreen.main.bounds.width / CGFloat(look.mediaItems.first?.aspectRatio ?? 1.0))
                
                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        AsyncImage(url: URL(string: look.authorAvatar)) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Image(systemName: "person.circle.fill").foregroundColor(.gray)
                            }
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(look.author)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Posted in ")
                                .foregroundColor(.secondary) +
                            Text(look.category.rawValue)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                appState.toggleSave(look: look)
                            }
                        }) {
                            Image(systemName: appState.isSaved(look: look) ? "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(appState.isSaved(look: look) ? .primary : .secondary)
                                .padding(8)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Circle())
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
                                print("Reported look \(look.id) from \(look.author)")
                            }) {
                                Label("Report", systemImage: "exclamationmark.bubble")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.secondary)
                                .font(.title2)
                                .padding(8)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    
                    Text(look.description)
                        .font(.body)
                        .lineSpacing(4)
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(look.likes) likes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
