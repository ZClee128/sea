import SwiftUI

@available(iOS 16.0, *)
struct InspoCardView: View {
    @StateObject var assetManager = AssetManager()
    @State private var selectedMuse: MuseItem?
    @State private var quote: String = "Beauty is in the heart of the beholder."
    
    // Customization State
    @State private var selectedFontIndex: Int = 0
    @State private var textColor: Color = .white
    @State private var overlayOpacity: Double = 0.3
    @State private var isShowingSuccess = false
    @State private var showingShop = false
    @ObservedObject var storeManager = StoreManager.shared
    
    let fontStyles: [Font.Design] = [.serif, .default, .monospaced, .rounded]
    let colors: [Color] = [.white, .yellow, .orange, .pink, .purple, .cyan]
    let quotes = [
        "Find harmony in every breath.",
        "Peace is the highest form of beauty.",
        "The muse is within you.",
        "Stillness is the language of the soul.",
        "Radiate aesthetic energy today.",
        "Live with intention and grace."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let isWide = geometry.size.width > 550
            
            NavigationView {
                VStack(spacing: 0) {
                    if let muse = selectedMuse {
                        if isWide {
                            // IPAD SPLIT LAYOUT
                            HStack(spacing: 0) {
                                // LEFT: PREVIEW
                                VStack {
                                    Spacer()
                                    cardPreview(muse: muse)
                                        .frame(maxWidth: geometry.size.width * 0.55)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6).opacity(0.5))
                                
                                // RIGHT: CONTROLLERS
                                ScrollView {
                                    VStack(spacing: 30) {
                                        Text("Customize Design")
                                            .font(.system(size: 20, weight: .bold, design: .serif))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        customizationStack()
                                    }
                                    .padding(30)
                                }
                                .frame(width: 350)
                                .background(Color.white)
                            }
                        } else {
                            // IPHONE VERTICAL LAYOUT
                            VStack(spacing: 0) {
                                cardPreview(muse: muse)
                                    .padding(.top, 20)
                                
                                ScrollView {
                                    customizationStack()
                                        .padding(.vertical, 30)
                                }
                            }
                        }
                    } else {
                        museGalleryView()
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingShop) {
            CoinShopView()
        }
        .overlay(alignment: .top) {
            if isShowingSuccess {
                Text("Card Exported to Gallery")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Capsule().fill(Color.black.opacity(0.9)))
                    .shadow(radius: 10)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenStudioWithMuse"))) { notification in
            if let muse = notification.object as? MuseItem {
                selectedMuse = muse
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LoadComposition"))) { notification in
            if let comp = notification.object as? InspoComposition {
                selectedMuse = comp.muse
                quote = comp.quote
                selectedFontIndex = comp.fontIndex
                textColor = Color(hex: comp.textColorHex)
                overlayOpacity = comp.overlayOpacity
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LoadTemplate"))) { notification in
            if let temp = notification.object as? StudioTemplate {
                selectedMuse = temp.muse
                quote = temp.quote
                selectedFontIndex = temp.fontIndex
                textColor = Color(hex: temp.textColorHex)
                overlayOpacity = temp.overlayOpacity
            }
        }
    }
    
    @ViewBuilder
    private func cardPreview(muse: MuseItem) -> some View {
        ZStack {
            Color.clear
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    Image(muse.imageName)
                        .resizable()
                        .scaledToFill()
                )
                .clipped()
                .cornerRadius(28)
            
            Color.black.opacity(overlayOpacity)
                .cornerRadius(28)
            
            VStack(spacing: 24) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 36))
                    .foregroundColor(textColor)
                
                Text(quote)
                    .font(.system(size: 26, weight: .bold, design: fontStyles[selectedFontIndex]))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .minimumScaleFactor(0.5)
            }
            .padding()
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, 24)
        .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 12)
    }
    
    @ViewBuilder
    private func customizationStack() -> some View {
        VStack(spacing: 30) {
            // Text Color
            VStack(alignment: .leading, spacing: 12) {
                Text("COLOR PALETTE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 38, height: 38)
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    .onTapGesture {
                                        withAnimation { textColor = color }
                                        triggerHaptic()
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: randomize) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                }
            }
            
            // Quote Chips
            VStack(alignment: .leading, spacing: 12) {
                Text("INSPO MESSAGES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quotes, id: \.self) { q in
                            Button(action: { 
                                quote = q 
                                triggerHaptic()
                            }) {
                                Text(q)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(quote == q ? Color.black : Color(.systemGray6))
                                    .foregroundColor(quote == q ? .white : .black)
                                    .cornerRadius(25)
                                    .layoutPriority(1) // FORCE HIGH PRIORITY
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    selectedFontIndex = (selectedFontIndex + 1) % fontStyles.count
                    triggerHaptic()
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "textformat")
                            .font(.system(size: 20))
                        Text("Font")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(width: 65, height: 65)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
                    .foregroundColor(.black)
                }
                
                Button(action: exportCard) {
                    HStack(spacing: 8) {
                        Text("EXPORT CARD")
                        HStack(spacing: 4) {
                            Text("10")
                            Image(systemName: "circle.circle.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(Color.black)
                    .cornerRadius(18)
                }
                
                Button(action: { selectedMuse = nil }) {
                    VStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                        Text("Close")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(width: 65, height: 65)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
                    .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func museGalleryView() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Inspire Studio")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .padding(.top)
                
                Text("Create meaningful compositions. Select a muse to begin your aesthetic journey.")
                    .font(.system(size: 16, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2), spacing: 16) {
                    ForEach(assetManager.muses) { muse in
                        Button(action: { 
                            withAnimation { selectedMuse = muse }
                            triggerHaptic()
                        }) {
                            VStack(alignment: .leading) {
                                Color.gray.opacity(0.1)
                                    .aspectRatio(1, contentMode: .fill)
                                    .overlay(
                                        Image(muse.imageName)
                                            .resizable()
                                            .scaledToFill()
                                    )
                                    .clipped()
                                    .cornerRadius(12)
                                
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
    
    private func randomize() {
        selectedMuse = assetManager.muses.randomElement()
        quote = quotes.randomElement() ?? quote
        selectedFontIndex = Int.random(in: 0..<fontStyles.count)
        textColor = colors.randomElement() ?? .white
        triggerHaptic()
    }
    
    private func exportCard() {
        if let muse = selectedMuse {
            // Spend coins first
            if storeManager.spendCoins(10) {
                // Create the view to snapshot
                let cardToExport = ExportCardView(
                    muse: muse,
                    quote: quote,
                    fontDesign: fontStyles[selectedFontIndex],
                    textColor: textColor,
                    overlayOpacity: overlayOpacity
                )
                
                // Snapshot the view
                let image = cardToExport.snapshot()
                
                let saver = PhotoSaver()
                saver.writeToPhotoAlbum(image: image) { error in
                    if error == nil {
                        // Save to Local Gallery
                        GalleryManager.shared.saveComposition(
                            muse: muse,
                            quote: quote,
                            fontIndex: selectedFontIndex,
                            textColorHex: textColor.toHex() ?? "#FFFFFF",
                            opacity: overlayOpacity
                        )
                        
                        withAnimation {
                            isShowingSuccess = true
                        }
                        triggerHapticSuccess()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { isShowingSuccess = false }
                        }
                    }
                }
            } else {
                // Not enough coins, show shop
                showingShop = true
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

// Separate View for Exporting to ensure clean snapshotting
@available(iOS 16.0, *)
struct ExportCardView: View {
    let muse: MuseItem
    let quote: String
    let fontDesign: Font.Design
    let textColor: Color
    let overlayOpacity: Double
    
    var body: some View {
        ZStack {
            Image(muse.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 800, height: 800) // Fixed high-res size for export
            
            Color.black.opacity(overlayOpacity)
            
            VStack(spacing: 30) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 60))
                    .foregroundColor(textColor)
                
                Text(quote)
                    .font(.system(size: 56, weight: .bold, design: fontDesign))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                    .shadow(radius: 10)
            }
        }
        .frame(width: 800, height: 800)
        .clipped()
    }
    
    @MainActor
    func snapshot() -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 2.0
        return renderer.uiImage ?? UIImage()
    }
}

@available(iOS 16.0, *)
struct InspoCardView_Previews: PreviewProvider {
    static var previews: some View {
        InspoCardView()
    }
}
