//
//  MasterclassView.swift
//  tego
//

import SwiftUI

@available(iOS 15.0, *)
struct MasterclassView: View {
    let videos = MockData.videos
    
    enum ActiveSheet: Identifiable {
        case coinStore
        case videoPlayer(URL)
        
        var id: Int {
            switch self {
            case .coinStore: return 0
            case .videoPlayer: return 1
            }
        }
    }
    
    @State private var activeSheet: ActiveSheet?
    @State private var showingUnlockAlert = false
    @State private var pendingVideo: VideoClass? = nil
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let unlockCost = 50
    
    func isLocked(_ video: VideoClass) -> Bool {
        guard video.isPro else { return false }
        if #available(iOS 15, *) {
            return !StoreManager.shared.isUnlocked(video.id.uuidString)
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Learn from the world's best aesthetic photographers and models.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ForEach(videos) { video in
                        VideoCard(video: video, isLocked: isLocked(video))
                            .onTapGesture {
                                if isLocked(video) {
                                    pendingVideo = video
                                    showingUnlockAlert = true
                                } else {
                                    if let url = Bundle.main.url(forResource: video.title, withExtension: "mp4") {
                                        activeSheet = .videoPlayer(url)
                                    } else {
                                        errorMessage = "Video file not found in App Bundle: \(video.title).mp4\n\nPlease ensure 'Target Membership' is checked for this file in Xcode."
                                        showingError = true
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitle(Text("Masterclass"))
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .coinStore:
                    CoinStoreView()
                case .videoPlayer(let url):
                    AVPlayerView(url: url)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .alert(isPresented: $showingUnlockAlert) {
                if #available(iOS 15, *) {
                    return Alert(
                        title: Text("Unlock \(pendingVideo?.title ?? "")"),
                        message: Text("Spend \(unlockCost) coins to unlock? (Balance: \(StoreManager.shared.coins) coins)"),
                        primaryButton: .default(Text("Unlock for \(unlockCost) coins")) {
                            if let video = pendingVideo {
                                if StoreManager.shared.unlockItem(video.id.uuidString, cost: unlockCost) {
                                    if let url = Bundle.main.url(forResource: video.title, withExtension: "mp4") {
                                        activeSheet = .videoPlayer(url)
                                    }
                                } else {
                                    activeSheet = .coinStore
                                }
                            }
                        },
                        secondaryButton: .cancel(Text("Get Coins")) {
                            activeSheet = .coinStore
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Upgrade Required"),
                        message: Text("In-app purchases require iOS 15 or later."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .alert("Playback Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}


struct VideoCard: View {
    let video: VideoClass
    let isLocked: Bool // Add this property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Image(video.title)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                if isLocked {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("50")
                                    .bold()
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(12)
                        }
                        Spacer()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(video.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(video.duration)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
