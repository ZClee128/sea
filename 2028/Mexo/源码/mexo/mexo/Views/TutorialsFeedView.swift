import SwiftUI

@available(iOS 14.0, *)
struct TutorialsFeedView: View {
    let tutorials: [VideoModel] = VideoModel.mockData
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedVideo: VideoModel?
    @State private var showingUnlockAlert = false
    @State private var showingStore = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LEARN")
                                .font(DesignTokens.Typography.caption())
                                .tracking(4)
                                .foregroundColor(DesignTokens.Colors.accent)
                            
                            Text("PORTRAIT MASTERCLASS")
                                .font(DesignTokens.Typography.headline(28))
                                .foregroundColor(DesignTokens.Colors.primary)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 40)
                        
                        // Video List
                        VStack(spacing: 25) {
                            ForEach(tutorials) { video in
                                Button(action: {
                                    if video.isPremium && !storeManager.isContentUnlocked(id: video.id) {
                                        selectedVideo = video
                                        showingUnlockAlert = true
                                    } else {
                                        selectedVideo = video
                                        // Navigate to detail would happen here
                                    }
                                }) {
                                    PremiumVideoRow(video: video)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingUnlockAlert) {
                Alert(
                    title: Text("Unlock Masterclass"),
                    message: Text("Access this professional tutorial for \(selectedVideo?.coinPrice ?? 0) coins."),
                    primaryButton: .default(Text("Unlock")) {
                        if let video = selectedVideo {
                            if storeManager.unlockContent(id: video.id, price: video.coinPrice) {
                                // Success
                            } else {
                                showingStore = true
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingStore) {
                StoreView()
            }
        }
    }
}

@available(iOS 14.0, *)
struct PremiumVideoRow: View {
    let video: VideoModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(video.thumbnailUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()
                
                // Play Icon Overlay
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HStack {
                    if video.isPremium && !StoreManager.shared.isContentUnlocked(id: video.id) {
                        PremiumLockTag(price: video.coinPrice)
                    }
                    Spacer()
                    Text(video.duration)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(VisualEffectBlur(blurStyle: .systemThinMaterialLight).clipShape(Capsule()))
                        .foregroundColor(DesignTokens.Colors.primary)
                }
                .padding(12)
            }
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.category.uppercased())
                    .font(DesignTokens.Typography.caption(10))
                    .fontWeight(.bold)
                    .foregroundColor(DesignTokens.Colors.accent)
                
                Text(video.title)
                    .font(DesignTokens.Typography.headline(18))
                    .foregroundColor(DesignTokens.Colors.primary)
                
                Text(video.description)
                    .font(DesignTokens.Typography.body(14))
                    .foregroundColor(DesignTokens.Colors.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
    }
}

@available(iOS 14.0, *)
struct TutorialsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialsFeedView()
    }
}
