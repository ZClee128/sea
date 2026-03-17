import SwiftUI

struct TutorialsFeedView: View {
    let videos: [VideoModel] = VideoModel.mockData
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                List(videos) { video in
                    NavigationLink(destination: VideoPlayerDetailView(video: video)) {
                        VideoRowView(video: video)
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Tutorials")
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

struct VideoRowView: View {
    let video: VideoModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Thumbnail
            ZStack {
                if #available(iOS 15.0, *) {
                    AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 140, height: 90)
                    .cornerRadius(8)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 90)
                        .cornerRadius(8)
                }
                
                // Play Icon Overlay
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                // Duration Label
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if #available(iOS 14.0, *) {
                            Text(video.duration)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                                .padding(4)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                .frame(width: 140, height: 90)
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(video.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
    }
}

struct TutorialsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialsFeedView()
    }
}
