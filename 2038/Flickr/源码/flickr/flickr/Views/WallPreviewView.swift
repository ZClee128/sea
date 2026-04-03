import SwiftUI

@available(iOS 15.0, *)
struct WallPreviewView: View {
    @StateObject var assetManager = AssetManager()
    @State private var selectedMuse: MuseItem?
    
    // Interactivity State
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // Customization State
    @State private var clockColor: Color = .white
    @State private var selectedFontIndex: Int = 0
    @State private var isShowingSuccess = false
    
    let fontStyles: [Font.Design] = [.default, .serif, .monospaced, .rounded]
    let colors: [Color] = [.white, .yellow, .orange, .pink, .purple, .cyan]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let muse = selectedMuse {
                    ZStack {
                        // Interactive Background
                        ZStack {
                            Image(muse.imageName)
                                .resizable()
                                .scaledToFill()
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            offset = CGSize(width: lastOffset.width + value.translation.width,
                                                            height: lastOffset.height + value.translation.height)
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                        }
                                )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        
                        // Mock iOS Lock Screen Overlay
                        VStack {
                            Spacer().frame(height: 80)
                            
                            Text(Date(), style: .time)
                                .font(.system(size: 85, weight: .thin, design: fontStyles[selectedFontIndex]))
                                .foregroundColor(clockColor)
                                .shadow(radius: 10)
                            
                            Text("Wednesday, April 1")
                                .font(.system(size: 22, weight: .medium, design: fontStyles[selectedFontIndex]))
                                .foregroundColor(clockColor)
                                .shadow(radius: 10)
                            
                            Spacer()
                            
                            HStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "flashlight.off.fill").foregroundColor(.white))
                                
                                Spacer()
                                
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: "camera.fill").foregroundColor(.white))
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 60)
                        }
                        .allowsHitTesting(false) // Let gestures pass through to the background
                        
                        // Success Toast
                        if isShowingSuccess {
                            Text("Wallpaper Saved to Studio")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(20)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { isShowingSuccess = false }
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .cornerRadius(44)
                    .padding()
                    .shadow(radius: 20)
                    
                    // Customization Toolbar
                    VStack(spacing: 16) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                        .onTapGesture {
                                            withAnimation { clockColor = color }
                                            triggerHaptic()
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                selectedFontIndex = (selectedFontIndex + 1) % fontStyles.count
                                triggerHaptic()
                            }) {
                                Image(systemName: "textformat")
                                    .font(.title3)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                            }
                            
                            Button(action: {
                                saveWallpaper()
                            }) {
                                Text("SAVE PRESET")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    scale = 1.0
                                    offset = .zero
                                    selectedMuse = nil
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Bespoke Wall Studio")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .padding(.top)
                            
                            Text("Craft your perfect aesthetic alignment. Drag to reposition, pinch to scale, and customize the clock to match your muse.")
                                .font(.system(size: 16, design: .serif))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(assetManager.muses) { muse in
                                    Button(action: { 
                                        withAnimation { selectedMuse = muse }
                                        triggerHaptic()
                                    }) {
                                        VStack(alignment: .leading) {
                                        Color.gray.opacity(0.1)
                                            .aspectRatio(9/16, contentMode: .fill)
                                            .overlay(
                                                Image(muse.imageName)
                                                    .resizable()
                                                    .scaledToFill()
                                            )
                                            .clipped()
                                            .cornerRadius(16)
                                            
                                            Text(muse.title)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .padding(.top, 4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func saveWallpaper() {
        if let muse = selectedMuse {
            let image = UIImage(named: muse.imageName) ?? UIImage(systemName: "photo")!
            let saver = PhotoSaver()
            saver.writeToPhotoAlbum(image: image) { error in
                if error == nil {
                    withAnimation { isShowingSuccess = true }
                    triggerHapticSuccess()
                }
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func triggerHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

class PhotoSaver: NSObject {
    var completionHandler: ((Error?) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage, completion: @escaping (Error?) -> Void) {
        self.completionHandler = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Save error: \(error.localizedDescription)")
            completionHandler?(error)
        } else {
            print("Successfully saved to photos!")
            completionHandler?(nil)
        }
    }
}

@available(iOS 15.0, *)
struct WallPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        WallPreviewView()
    }
}
