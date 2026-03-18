import SwiftUI
import AVKit

struct TutorialVideo: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let difficulty: String
    let videoFileName: String?
    let thumbnailName: String?
    let description: String
    let tools: [String]
    let learningPoints: [String]
}

struct VideoTutorialListView: View {
    let tutorials = [
        TutorialVideo(
            title: "Mastering the Winged Liner",
            duration: "12:45",
            difficulty: "Intermediate",
            videoFileName: "Mastering the Winged Liner",
            thumbnailName: "Mastering the Winged Liner",
            description: "Learn the secrets to the perfect, sharp winged eyeliner every time.",
            tools: ["Angled Liner Brush", "Gel Eyeliner", "Micellar Water"],
            learningPoints: ["Choosing the right eyeliner formula", "The 'dot-to-dot' connection method", "Correcting mistakes without starting over", "Matching wings on both eyes"]
        ),
        TutorialVideo(
            title: "The 5-Minute Morning Routine",
            duration: "05:12",
            difficulty: "Beginner",
            videoFileName: "The 5-Minute Morning Routine",
            thumbnailName: "The 5-Minute Morning Routine",
            description: "Quick and easy steps for a refreshed look when you're short on time.",
            tools: ["BB Cream", "Mascara", "Tinted Lip Balm"],
            learningPoints: ["Even skin tone with minimal product", "Instantly brightening tired eyes", "Natural lip enhancement for all day wear"]
        ),
        TutorialVideo(
            title: "Contouring for Beginners",
            duration: "15:20",
            difficulty: "Beginner",
            videoFileName: "Contouring for Beginners",
            thumbnailName: "Contouring for Beginners",
            description: "A step-by-step guide to defining your features naturally.",
            tools: ["Contour Stick", "Blending Sponge", "Setting Powder"],
            learningPoints: ["Identifying your face shape", "Placement for natural shadows", "Blending techniques to avoid muddy looks"]
        )
    ]
    
    var body: some View {
        NavigationView {
            List(tutorials) { video in
                NavigationLink(destination: VideoPlayerDetailView(video: video)) {
                    HStack(spacing: 15) {
                        ZStack {
                            if let thumb = video.thumbnailName {
                                Image(thumb)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 60)
                                    .cornerRadius(12)
                                    .clipped()
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(RevoDesign.primary.opacity(0.1))
                                    .frame(width: 100, height: 60)
                            }
                            
                            Image(systemName: "play.circle.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(radius: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(video.title)
                                .font(.headline)
                                .foregroundColor(RevoDesign.text)
                            
                            HStack {
                                Text(video.duration)
                                Text("•")
                                Text(video.difficulty)
                            }
                            .font(.caption)
                            .foregroundColor(RevoDesign.textSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Tutorials", displayMode: .inline)
            .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        }
        .forceLightMode()
    }
}

struct VideoPlayerDetailView: View {
    let video: TutorialVideo
    @State private var player: AVPlayer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video Player with Fallback
                if let player = player {
                    if #available(iOS 14.0, *) {
                        VideoPlayer(player: player)
                            .frame(height: 250)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    } else {
                        LegacyVideoPlayer(player: player)
                            .frame(height: 250)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(RevoDesign.secondary)
                            .frame(height: 250)
                        VStack {
                            Image(systemName: "video.slash")
                                .font(.largeTitle)
                            Text("Video Coming Soon")
                                .font(.headline)
                        }
                        .foregroundColor(RevoDesign.primary)
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(video.title)
                        .font(.headline)
                        .foregroundColor(RevoDesign.text)
                    
                    Text(video.difficulty.uppercased())
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(RevoDesign.primary)
                        .cornerRadius(5)
                    
                    Text(video.description)
                        .font(.body)
                        .foregroundColor(RevoDesign.textSecondary)
                        .padding(.top, 10)
                    
                    Text("Tools Required")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(video.tools, id: \.self) { tool in
                                Text(tool)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(RevoDesign.secondary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    Text("In this video, you will learn:")
                        .font(.headline)
                        .foregroundColor(RevoDesign.text)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(video.learningPoints, id: \.self) { point in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(RevoDesign.primary)
                                Text(point)
                                    .font(.subheadline)
                                    .foregroundColor(RevoDesign.textSecondary)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(Text(video.title), displayMode: .inline)
        .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        .forceLightMode()
        .onAppear {
            if let fileName = video.videoFileName,
               let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") {
                self.player = AVPlayer(url: url)
                self.player?.play()
            } else {
                // Fallback or Alert
                print("Video file not found: \(video.videoFileName ?? "nil")")
            }
        }
        .onDisappear {
            player?.pause()
        }
    }
}

// iOS 13 Video Player Fallback
struct LegacyVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
