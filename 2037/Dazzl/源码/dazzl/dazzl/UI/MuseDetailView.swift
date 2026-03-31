import SwiftUI
import AVKit

@available(iOS 15.0, *)
struct MuseDetailView: View {
    let muse: Muse
    @EnvironmentObject var dataStore: MuseDataStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showDownloadAlert = false
    @State private var isDownloading = false
    @State private var alertMessage = ""
    @State private var isPlaying = true
    @State private var showFullScreenVideo = false
    @State private var showToast = false
    @State private var toastText = ""
    @State private var player: AVPlayer?
    @State private var showShop = false
    
    // Computed property for easy access to favorite status
    private var isCurrentlyFavorited: Bool {
        dataStore.muses.first(where: { $0.id == muse.id })?.isFavorite ?? false
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 1. Content Layer (ScrollView)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header area placeholder (Video is absolute positioned below)
                    ZStack(alignment: .topLeading) {
                        if muse.videoUrl == nil {
                            Image(muse.imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: 500)
                                .clipped()
                        } else {
                            // Maintain space for the absolute-positioned video
                            Color.clear.frame(height: 500)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    
                    if !showFullScreenVideo {
                        VStack(alignment: .leading, spacing: 25) {
                            // Basic Info
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
                            }
                            
                            // Action Bar
                            HStack(spacing: 20) {
                                DetailActionButton(
                                    icon: isCurrentlyFavorited ? "heart.fill" : "heart",
                                    label: isCurrentlyFavorited ? "Saved" : "Favorite",
                                    color: isCurrentlyFavorited ? .pink : .white
                                ) {
                                    withAnimation {
                                        dataStore.toggleFavorite(for: muse.id)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                                
                                DetailActionButton(
                                    icon: isDownloading ? "ellipsis.circle" : "arrow.down.circle.fill",
                                    label: isDownloading ? "Saving..." : "Download",
                                    color: isDownloading ? .gray : .blue
                                ) {
                                    downloadAndSaveImage()
                                }
                                
                                DetailActionButton(icon: "square.and.arrow.up.fill", label: "Ref Link", color: .green) {
                                    shareMuse()
                                }
                            }
                            
                            // Professional Analysis Section
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "pencil.and.outline")
                                        .foregroundColor(.blue)
                                    Text("Professional Analysis")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                    Spacer()
                                    if dataStore.isUnlocked(muse.id) {
                                        Text("UNLOCKED")
                                            .font(.caption2.bold())
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                
                                if dataStore.isUnlocked(muse.id) {
                                    VStack(alignment: .leading, spacing: 20) {
                                        AnalysisRow(title: "Lighting Setup", icon: "lightbulb.fill", content: muse.lightingTip)
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            Label("Color Palette", systemImage: "paintbrush.fill")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.gray)
                                            HStack(spacing: 12) {
                                                ForEach(muse.palette, id: \.self) { hex in
                                                    Circle()
                                                        .fill(Color(hex: hex))
                                                        .frame(width: 35, height: 35)
                                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                                }
                                            }
                                        }
                                        
                                        AnalysisRow(title: "Technical Setup", icon: "camera.fill", content: "Recommended: \(muse.category == .ethereal ? "35mm f/1.4" : "50mm f/1.8") for optimal depth of field and sharpness.")
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.04))
                                    .cornerRadius(15)
                                } else {
                                    Button(action: {
                                        if dataStore.spendCoins(20, for: muse.id) {
                                            toastText = "Analysis Unlocked!"
                                            showToast = true
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        } else {
                                            toastText = "Insufficient Coins"
                                            showToast = true
                                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showToast = false }
                                    }) {
                                        VStack(spacing: 15) {
                                            Image(systemName: "lock.fill")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                            Text("Unlock Professional Insights")
                                                .font(.headline)
                                            Text("Spend 20 Coins to reveal the lighting map, color theory, and technical recommendations.")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                            
                                            HStack {
                                                Image(systemName: "sparkles")
                                                Text("Unlock for 20 Coins")
                                            }
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 25)
                                            .padding(.vertical, 12)
                                            .background(Color.blue)
                                            .cornerRadius(25)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 35)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(20)
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                                    }
                                }
                            }
                        }
                        .padding()
                        .transition(.opacity)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .disabled(showFullScreenVideo)
            
            // 2. Video Layer
            if let videoName = muse.videoUrl {
                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        VideoPlayerWrapper(name: videoName, museID: muse.id, isPlaying: isPlaying, player: player)
                            .frame(width: UIScreen.main.bounds.width, height: showFullScreenVideo ? UIScreen.main.bounds.height : 500)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                        
                        if !showFullScreenVideo {
                            HStack {
                                Button(action: {
                                    dataStore.updateBackgroundPlay(!dataStore.isBackgroundPlayEnabled)
                                    toastText = dataStore.isBackgroundPlayEnabled ? "Background Play: ON" : "Background Play: OFF"
                                    showToast = true
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { showToast = false }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: dataStore.isBackgroundPlayEnabled ? "headphones" : "speaker.slash.fill")
                                        Text(dataStore.isBackgroundPlayEnabled ? "Ready" : "Paused")
                                            .font(.caption2.bold())
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Capsule())
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showFullScreenVideo = true
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }) {
                                    Image(systemName: "viewfinder")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.black.opacity(0.4))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        } else {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showFullScreenVideo = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(.top, 50)
                            .padding(.trailing, 20)
                        }
                    }
                    if !showFullScreenVideo { Spacer() }
                }
                .ignoresSafeArea(edges: .top)
                .zIndex(10)
            }
            
            // 3. Back Button
            if !showFullScreenVideo {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 50)
                .padding(.leading, 20)
                .zIndex(25)
            }
            
            // 4. Toast
            VStack {
                if showToast {
                    Text(toastText)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(25)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 40)
                    
                    if toastText == "Insufficient Coins" {
                        Button("Go to Shop") {
                            showShop = true
                            showToast = false
                        }
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                    }
                }
                Spacer()
            }
            .animation(.spring(), value: showToast)
            .zIndex(30)
            
            // 5. Loading
            if isDownloading {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 20) {
                            ProgressView().tint(.white).scaleEffect(1.5)
                            Text("Saving Reference...").foregroundColor(.white)
                        }
                        .padding(30)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                    )
                    .zIndex(40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if player == nil, let videoName = muse.videoUrl {
                if let path = Bundle.main.path(forResource: videoName, ofType: "mp4") {
                    let url = URL(fileURLWithPath: path)
                    player = AVPlayer(url: url)
                    dataStore.activeVideoID = muse.id
                }
            }
        }
        .onDisappear {
            isPlaying = false
            player?.pause()
            player = nil
            dataStore.activeVideoID = nil
        }
        .sheet(isPresented: $showShop) {
            CoinShopView()
        }
        .alert(isPresented: $showDownloadAlert) {
            Alert(title: Text("Saved"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func downloadAndSaveImage() {
        guard !isDownloading else { return }
        isDownloading = true
        if let image = UIImage(named: muse.imageUrl) {
            let saver = ImageSaver { success, _ in
                self.isDownloading = false
                if success {
                    self.alertMessage = "Reference for \(muse.name) saved to gallery."
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                self.showDownloadAlert = true
            }
            saver.writeToPhotoAlbum(image: image)
        }
    }
    
    private func shareMuse() {
        let items = ["Check out \(muse.name) on Dazzl Reference Lab"]
        let sheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let root = UIApplication.shared.windows.first?.rootViewController {
            root.present(sheet, animated: true)
        }
    }
}

// MARK: - Helpers
@available(iOS 14.0, *)
struct AnalysisRow: View {
    let title: String
    let icon: String
    let content: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon).font(.subheadline.bold()).foregroundColor(.gray)
            Text(content).font(.system(size: 15)).foregroundColor(.white.opacity(0.85)).lineSpacing(4)
        }
    }
}


class ImageSaver: NSObject {
    var completion: (Bool, Error?) -> Void
    init(completion: @escaping (Bool, Error?) -> Void) { self.completion = completion }
    func writeToPhotoAlbum(image: UIImage) { UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil) }
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion(error == nil, error)
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
                Image(systemName: icon).font(.title2).foregroundColor(color)
                Text(label).font(.caption).foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
