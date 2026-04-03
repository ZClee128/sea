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
    
    // Ambient Lighting State
    @State private var selectedFilterIndex: Int = 0
    @State private var isFlashActive = false
    @State private var clockColor: Color = .white
    @State private var selectedFontIndex: Int = 0
    @State private var isShowingSuccess = false
    
    let fontStyles: [Font.Design] = [.default, .serif, .monospaced, .rounded]
    let colors: [Color] = [.white, .yellow, .orange, .pink, .purple, .cyan]
    let filters: [(name: String, color: Color, opacity: Double)] = [
        ("Natural", .clear, 0),
        ("Warm Dawn", .orange.opacity(0.15), 0.2),
        ("Midnight", .blue.opacity(0.2), 0.4),
        ("Golden", .yellow.opacity(0.1), 0.15),
        ("Vivid", .purple.opacity(0.1), 0.2)
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    if let muse = selectedMuse {
                        // Use Split layout ONLY if width is substantial (e.g. > 550)
                        if geometry.size.width > 550 {
                            HStack(spacing: 0) {
                                previewSection(muse: muse)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(geometry.size.width * 0.05)
                                    .background(Color.black)
                                
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 32) {
                                        Text("Bespoke Customization")
                                            .font(.system(size: 24, weight: .bold, design: .serif))
                                            .padding(.top, 40)
                                        
                                        customizationSection()
                                        
                                        Spacer(minLength: 50)
                                        
                                        Button(action: {
                                            withAnimation {
                                                selectedMuse = nil
                                                scale = 1.0
                                                offset = .zero
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "arrow.left.circle.fill")
                                                Text("Change Muse")
                                            }
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(30)
                                }
                                .frame(width: 320)
                                .background(Color(.systemGray6))
                            }
                        } else {
                            // Vertical Layout for iPhone or Narrow iPad Window
                            ScrollView {
                                VStack(spacing: 30) {
                                    previewSection(muse: muse)
                                        .frame(height: geometry.size.height * 0.7) // FORCE 70% OF SCREEN HEIGHT
                                    
                                    VStack(spacing: 20) {
                                        customizationSection()
                                        
                                        Button(action: {
                                            withAnimation {
                                                scale = 1.0
                                                offset = .zero
                                                selectedMuse = nil
                                            }
                                        }) {
                                            Text("Cancel and Return")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 20)
                                .frame(width: geometry.size.width)
                            }
                        }
                    } else {
                        museGalleryView()
                    }
                    
                    // Camera Flash Animation
                    if isFlashActive {
                        Color.white.ignoresSafeArea()
                            .transition(.opacity)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func previewSection(muse: MuseItem) -> some View {
        ZStack {
            // THE STABLE 9:16 CONTAINER
            ZStack {
                // 1. Fixed Aspect Background
                Color.black
                
                // 2. The Image (which fills the box)
                Image(muse.imageName)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(scale)
                    .offset(offset)
                    .overlay(filters[selectedFilterIndex].color)
                    .hueRotation(.degrees(selectedFilterIndex == 4 ? 45 : 0))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height)
                            }
                            .onEnded { _ in lastOffset = offset }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in scale = lastScale * value }
                            .onEnded { _ in lastScale = scale }
                    )
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                
                // 3. Mock iOS Lock Screen Overlay
                VStack {
                    Spacer().frame(height: 50)
                        .allowsHitTesting(false)
                    
                    VStack(spacing: 4) {
                        Text(Date(), style: .time)
                            .font(.system(size: 64, weight: .thin, design: fontStyles[selectedFontIndex]))
                            .foregroundColor(clockColor)
                            .minimumScaleFactor(0.5)
                        
                        Text("Wednesday, April 1")
                            .font(.system(size: 16, weight: .medium, design: fontStyles[selectedFontIndex]))
                            .foregroundColor(clockColor)
                    }
                    .shadow(radius: 5)
                    .allowsHitTesting(false)
                    
                    Spacer()
                        .allowsHitTesting(false)
                    
                    // BOTTOM ACTION
                    HStack {
                        Button(action: {
                            triggerHaptic()
                            withAnimation {
                                selectedFilterIndex = (selectedFilterIndex + 1) % filters.count
                            }
                        }) {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(Image(systemName: "sun.max.fill").foregroundColor(.white).font(.system(size: 18)))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            .aspectRatio(9/16, contentMode: .fit) // FORCE 9:16 AND FIT INSIDE PARENT
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.4), radius: 15)
            .clipped()
            
            // Success Toast
            if isShowingSuccess {
                VStack {
                    Text("HD PRESET SAVED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Capsule().fill(Color.black.opacity(0.8)))
                        .padding(.top, 40)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    @ViewBuilder
    private func customizationSection() -> some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("COLOR PALETTE")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 28, height: 28)
                                .overlay(Circle().stroke(Color.black, lineWidth: 1.5).opacity(clockColor == color ? 1 : 0))
                                .onTapGesture {
                                    withAnimation { clockColor = color }
                                    triggerHaptic()
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    selectedFontIndex = (selectedFontIndex + 1) % fontStyles.count
                    triggerHaptic()
                }) {
                    HStack {
                        Image(systemName: "textformat")
                        Text("Cycle Typography")
                        Spacer()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { saveWallpaper() }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("SAVE HD PRESET")
                    }
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func museGalleryView() -> some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Bespoke Wall Studio")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                    
                    Text("Deconstruct and realign your aesthetic perspective.")
                        .font(.system(size: 15, design: .serif))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
                
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(assetManager.muses) { muse in
                        Button(action: { 
                            withAnimation { selectedMuse = muse }
                            triggerHaptic()
                        }) {
                            VStack(alignment: .leading, spacing: 12) {
                                Image(muse.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .aspectRatio(9/16, contentMode: .fill) // ENSURE GRID ITEMS HAVE RATIO
                                    .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200)
                                    .clipped()
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                                
                                Text(muse.title)
                                    .font(.system(size: 12, weight: .bold, design: .serif))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 100)
        }
    }
    
    private func saveWallpaper() {
        if let muse = selectedMuse {
            // RENDER ONLY THE IMAGE + FILTER (without UI)
            let exportView = ZStack {
                Image(muse.imageName)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(scale)
                    .offset(offset)
                    .overlay(filters[selectedFilterIndex].color)
                    .hueRotation(.degrees(selectedFilterIndex == 4 ? 45 : 0))
            }
            .frame(width: 1284, height: 2778) // Standard high-res vertical (iPhone Pro Max size)
            .clipped()
            
            // Snapshot the view to a UIImage
            if let image = exportView.asUIImage() {
                let saver = PhotoSaver()
                saver.writeToPhotoAlbum(image: image) { error in
                    if error == nil {
                        withAnimation { isShowingSuccess = true }
                        triggerHapticSuccess()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { isShowingSuccess = false }
                        }
                    }
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

// MARK: - Snapshot Extension (iOS 15 Compatibility)
extension View {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
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
