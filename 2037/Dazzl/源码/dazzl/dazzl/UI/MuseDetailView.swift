import SwiftUI
import AVKit

@available(iOS 15.0, *)
struct MuseDetailView: View {
    let muse: Muse
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorited = false
    @State private var showDownloadAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image/Video Header
                    ZStack(alignment: .topLeading) {
                        if let videoUrlString = muse.videoUrl, let url = URL(string: videoUrlString) {
                            VideoPlayerWrapper(url: url)
                                .frame(maxWidth: .infinity)
                                .frame(height: 500)
                                .clipped()
                                .ignoresSafeArea(edges: .top)
                        } else {
                            AsyncImage(url: URL(string: muse.imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 500)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 500)
                                    .overlay(ProgressView().tint(.white))
                            }
                        }
                        
                        // Custom Back Button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.leading, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(muse.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(muse.category.rawValue)
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                        }
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        Text("About this Muse")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text(muse.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)
                        
                        Spacer(minLength: 40)
                        
                        // Action Bar
                        HStack(spacing: 20) {
                            DetailActionButton(
                                icon: isFavorited ? "heart.fill" : "heart",
                                label: isFavorited ? "Saved" : "Favorite",
                                color: isFavorited ? .pink : .white
                            ) {
                                withAnimation { isFavorited.toggle() }
                            }
                            
                            DetailActionButton(icon: "arrow.down.circle.fill", label: "Download", color: .blue) {
                                showDownloadAlert = true
                            }
                            
                            DetailActionButton(icon: "square.and.arrow.up.fill", label: "Ref Link", color: .green) {
                                shareMuse()
                            }
                        }
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showDownloadAlert) {
            Alert(
                title: Text("Download Started"),
                message: Text("The high-resolution reference for \(muse.name) is being saved to your gallery."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func shareMuse() {
        let text = "Check out this aesthetic muse: \(muse.name) #Dazzl"
        let url = URL(string: muse.imageUrl)!
        let sheet = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(sheet, animated: true)
        }
    }
}

@available(iOS 14.0, *)
struct DetailActionButton: View {
    let icon: String
    let label: String
    let color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

