import SwiftUI

// Extension to chunk array for iOS 13 grid fallback
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

// Extension to support HEX colors
extension Color {
    static let customCyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct VideoListView: View {
    @EnvironmentObject var stageData: StageDataRepository
    @State private var reportedVideo: StuntVideo? = nil
    
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Stage Combat", "Pose Choreography", "Acrobatic Stunts"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.10)
                    .edgesIgnoringSafeArea(.all)
                
                if stageData.videos.isEmpty {
                    Text("No Rehearsal Reels available")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // 1. Highlight Top Banner (At least 2/3 height of screen)
                            let mainVideo = stageData.videos[0]
                            VStack(alignment: .leading, spacing: 12) {
                                ZStack(alignment: .bottomLeading) {
                                    // Live player wrapper as background
                                    VideoPlayerWrapper(videoUrl: mainVideo.videoUrl)
                                        .frame(height: UIScreen.main.bounds.height * 0.60) // Around 2/3 of normal screen bounds
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                                    
                                    // Custom visual indicators showing it is a stunt layout
                                    HStack {
                                        Text("LIVE REHEARSAL")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.red)
                                            .cornerRadius(4)
                                            .padding(16)
                                        Spacer()
                                        
                                        Text(mainVideo.stageCategory.uppercased())
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.15))
                                            .cornerRadius(4)
                                            .padding(16)
                                    }
                                    .frame(maxHeight: .infinity, alignment: .top)
                                    
                                    // Bottom Text Overlay on top of player
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.9)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 180)
                                    .cornerRadius(16)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(mainVideo.title)
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(2)
                                        
                                        HStack(spacing: 12) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "sparkles")
                                                    .foregroundColor(.yellow)
                                                Text("Complexity \(mainVideo.actionComplexity)")
                                            }
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "doc.text.fill")
                                                    .foregroundColor(.customCyan)
                                                Text("\(mainVideo.moveSequenceCount) seqs")
                                            }
                                            
                                            Spacer()
                                            
                                            NavigationLink(destination: VideoDetailView(video: mainVideo)) {
                                                HStack(spacing: 4) {
                                                    Text("Breakdown")
                                                    Image(systemName: "arrow.right.circle.fill")
                                                }
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                                            }
                                        }
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(20)
                                }
                                .frame(height: UIScreen.main.bounds.height * 0.60)
                            }
                            .padding(.horizontal, 16)
                            .contextMenu {
                                Button(action: {
                                    self.reportedVideo = mainVideo
                                }) {
                                    Text("Report Video")
                                    Image(systemName: "flag")
                                }
                            }
                            
                            // 2. Section Title & Category Filter Row
                            VStack(alignment: .leading, spacing: 14) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Choreography Catalog")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Agility logs and stage combat rehearsals")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(categories, id: \.self) { cat in
                                            Button(action: {
                                                self.selectedCategory = cat
                                            }) {
                                                Text(cat)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(selectedCategory == cat ? .white : .gray)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        selectedCategory == cat ?
                                                        Color(red: 1.00, green: 0.00, blue: 0.50) :
                                                        Color.white.opacity(0.06)
                                                    )
                                                    .cornerRadius(15)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            
                            // 3. Double-Column Video Grid (iOS 13 safe layout)
                            let otherVideos = Array(stageData.videos.dropFirst())
                            let filteredVideos = otherVideos.filter { selectedCategory == "All" || $0.stageCategory == selectedCategory }
                            
                            if filteredVideos.isEmpty {
                                Text("No reels matching \(selectedCategory)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 40)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                let chunkedVideos = filteredVideos.chunked(into: 2)
                                VStack(spacing: 16) {
                                    ForEach(0..<chunkedVideos.count, id: \.self) { rowIndex in
                                        HStack(spacing: 16) {
                                            ForEach(chunkedVideos[rowIndex]) { video in
                                                NavigationLink(destination: VideoDetailView(video: video)) {
                                                    VideoGridCard(video: video)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .contextMenu {
                                                    Button(action: {
                                                        self.reportedVideo = video
                                                    }) {
                                                        Text("Report Video")
                                                        Image(systemName: "flag")
                                                    }
                                                }
                                            }
                                            
                                            // Empty spacer to fill row if single item remains
                                            if chunkedVideos[rowIndex].count < 2 {
                                                Spacer()
                                                    .frame(maxWidth: .infinity)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 30)
                            }
                            
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Monti Reels"), displayMode: .inline)
            .sheet(item: $reportedVideo) { video in
                ReportView(
                    targetType: .video,
                    targetName: video.creator,
                    targetContent: video.title + "\n" + video.description,
                    onSubmit: { reason in
                        self.stageData.reportVideo(id: video.id)
                        self.reportedVideo = nil
                    },
                    onCancel: {
                        self.reportedVideo = nil
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Double column grid card widget
struct VideoGridCard: View {
    @EnvironmentObject var stageData: StageDataRepository
    let video: StuntVideo
    
    var isLocked: Bool {
        video.isPremium && !stageData.unlockedVideoIDs.contains(video.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .center) {
                // Gradient thumbnail placeholder with icon
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: video.thumbnailGradientStart), Color(hex: video.thumbnailGradientEnd)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                .cornerRadius(12)
                
                if isLocked {
                    // Lock overlay symbol
                    VStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                        
                        Text("🔒 20 COINS")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                    }
                } else {
                    // Play overlay symbol
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                
                // Category tag overlay
                Text(video.stageCategory)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text(video.creator)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9))
                            .foregroundColor(.yellow)
                        Text("\(video.actionComplexity)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
            .environmentObject(StageDataRepository())
    }
}
