import SwiftUI
import Combine

struct FullScreenImageView: View {
    let urlString: String
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            RemoteImageForFullScreen(urlString: urlString)
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { val in
                            let delta = val / self.lastScale
                            self.lastScale = val
                            self.scale = self.scale * delta
                        }
                        .onEnded { _ in
                            self.lastScale = 1.0
                            if self.scale < 1.0 {
                                withAnimation {
                                    self.scale = 1.0
                                    self.offset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { val in
                            if self.scale > 1.0 {
                                self.offset = CGSize(
                                    width: self.lastOffset.width + val.translation.width,
                                    height: self.lastOffset.height + val.translation.height
                                )
                            } else {
                                // Swipe down to dismiss
                                if val.translation.height > 0 {
                                    self.offset = CGSize(width: 0, height: val.translation.height)
                                }
                            }
                        }
                        .onEnded { val in
                            if self.scale > 1.0 {
                                self.lastOffset = self.offset
                            } else {
                                if val.translation.height > 100 {
                                    withAnimation {
                                        self.isPresented = false
                                    }
                                } else {
                                    withAnimation {
                                        self.offset = .zero
                                    }
                                }
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        if self.scale > 1.0 {
                            self.scale = 1.0
                            self.offset = .zero
                            self.lastOffset = .zero
                        } else {
                            self.scale = 2.0
                        }
                    }
                }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct RemoteImageForFullScreen: View {
    @ObservedObject private var loader: ImageLoader
    let localImage: UIImage?
    
    init(urlString: String) {
        if let image = UIImage(named: urlString) {
            self.localImage = image
            _loader = ObservedObject(wrappedValue: ImageLoader(urlString: "")) // Dummy
        } else {
            self.localImage = nil
            _loader = ObservedObject(wrappedValue: ImageLoader(urlString: urlString))
        }
    }
    
    var body: some View {
        Group {
            if let localImg = localImage {
                Image(uiImage: localImg)
                    .resizable()
            } else if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ActivityIndicator()
            }
        }
        .onDisappear {
            loader.cancel()
        }
    }
}
