import SwiftUI

@available(iOS 15.0, *)
struct MediaGalleryView: View {
    let mediaItems: [MediaItem]
    @State private var currentIndex = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<mediaItems.count, id: \.self) { index in
                let item = mediaItems[index]
                if item.type == .image {
                    AsyncImage(url: URL(string: item.urlString)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                // Added subtle pinch to zoom using simple scaleEffect
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let newScale = value.magnitude
                                            if newScale > 1.0 {
                                                scale = newScale
                                            }
                                        }
                                        .onEnded { _ in
                                            withAnimation {
                                                scale = 1.0
                                            }
                                        }
                                )
                        } else {
                            ProgressView()
                        }
                    }
                    .tag(index)
                } else {
                    VideoPlayerView(urlString: item.urlString)
                        .scaledToFit()
                        .tag(index)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: mediaItems.count > 1 ? .always : .never))
        .background(Color.black.ignoresSafeArea())
    }
}
