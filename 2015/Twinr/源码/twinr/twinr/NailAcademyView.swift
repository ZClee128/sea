import SwiftUI
import AVFoundation

struct AcademyItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let type: ItemType
    let content: String // Video URL or Article Text
    
    enum ItemType {
        case video, article
    }
}

@available(iOS 14.0, *)
struct NailAcademyView: View {
    let items = [
        AcademyItem(title: "Gel Polish Masterclass", subtitle: "Video • 00:13", icon: "play.circle.fill", type: .video, content: "Gel Polish Masterclass"),
        AcademyItem(title: "Perfect Hand Hydration", subtitle: "Article • 2 min read", icon: "drop.fill", type: .article, content: "Keep your hands hydrated by applying cuticle oil and hand cream daily. This prevents skin from drying out and keeps nails strong. Consistency is key for long-lasting results."),
        AcademyItem(title: "French Manicure Tips", subtitle: "Video • 00:18", icon: "play.circle.fill", type: .video, content: "French Manicure Tips"),
        AcademyItem(title: "Nail Strengthening Guide", subtitle: "Article • 3 min read", icon: "shield.fill", type: .article, content: "To strengthen your nails, consider using a high-quality nail hardener and avoiding excessive exposure to harsh chemicals like dish soap or acetone."),
        AcademyItem(title: "Safe Removal Process", subtitle: "Article • 5 min read", icon: "scissors", type: .article, content: "Never peel or scrape off your gel or acrylic nails. Always soak them off properly in acetone to avoid damaging the natural nail bed."),
        AcademyItem(title: "Stencils for Beginners", subtitle: "Video • 00:10", icon: "play.circle.fill", type: .video, content: "Stencils for Beginners")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Learn & Care")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(items) { item in
                        NavigationLink(destination: AcademyDetailView(item: item)) {
                            HStack(spacing: 15) {
                                if item.type == .video {
                                    ZStack(alignment: .bottomTrailing) {
                                        Image(item.title)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 70)
                                            .cornerRadius(12)
                                            .clipped()
                                        
                                        Text("Original")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(Color.pink)
                                            .cornerRadius(4)
                                            .padding(4)
                                    }
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 100, height: 70)
                                        
                                        Image(systemName: item.icon)
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(item.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Nail Academy")
        }
    }
}

@available(iOS 14.0, *)
struct AcademyDetailView: View {
    let item: AcademyItem
    @State private var player: AVPlayer? = nil
    @State private var isLooping: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if item.type == .video {
                    if let videoURL = Bundle.main.url(forResource: item.content, withExtension: "mp4") {
                        LegacyVideoPlayer(url: videoURL, player: $player, isLooping: $isLooping)
                            .frame(height: 250)
                            .cornerRadius(15)
                            .onDisappear {
                                player?.pause()
                            }
                        
                        Toggle(isOn: $isLooping) {
                            HStack {
                                Image(systemName: "repeat")
                                Text("Loop Playback")
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                    } else {
                        ZStack {
                            Image(item.title)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .overlay(Color.black.opacity(0.3))
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                        .cornerRadius(15)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue.opacity(0.1))
                            .frame(height: 200)
                        Image(systemName: item.icon)
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(item.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if item.type == .video {
                            Text("ORIGINAL")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.pink))
                        }
                    }
                    
                    Text(item.subtitle)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text(item.type == .video ? "Tutorial Description" : "Article Content")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(item.content)
                        .font(.body)
                        .lineSpacing(6)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

