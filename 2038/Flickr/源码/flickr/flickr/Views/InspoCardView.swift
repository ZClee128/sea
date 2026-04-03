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
        NavigationView {
            VStack(spacing: 0) {
                if let muse = selectedMuse {
                    VStack(spacing: 20) {
                        // The Card Preview (The Exportable Area)
                        ZStack {
                            Color.clear
                                .aspectRatio(1, contentMode: .fill)
                                .overlay(
                                    Image(muse.imageName)
                                        .resizable()
                                        .scaledToFill()
                                )
                                .clipped()
                                .cornerRadius(24)
                            
                            // Dimming Overlay
                            Color.black.opacity(overlayOpacity)
                                .cornerRadius(24)
                            
                            VStack(spacing: 24) {
                                Image(systemName: "quote.opening")
                                    .font(.system(size: 32))
                                    .foregroundColor(textColor)
                                
                                Text(quote)
                                    .font(.system(size: 26, weight: .bold, design: fontStyles[selectedFontIndex]))
                                    .foregroundColor(textColor)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding()
                        }
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 550 : 380, maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 550 : 380) 
                        .padding(.top, 16)
                        .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 12)
                        
                        // Customization Tools
                        VStack(spacing: 20) {
                            // Text Color & Randomize
                            HStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(colors, id: \.self) { color in
                                            Circle()
                                                .fill(color)
                                                .frame(width: 25, height: 25)
                                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                                .onTapGesture {
                                                    withAnimation { textColor = color }
                                                    triggerHaptic()
                                                }
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: randomize) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.black)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                            
                            // Quote Chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(quotes, id: \.self) { q in
                                        Button(action: { 
                                            quote = q 
                                            triggerHaptic()
                                        }) {
                                            Text(q)
                                                .font(.system(size: 14, weight: .medium))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(quote == q ? Color.black : Color(.systemGray6))
                                                .foregroundColor(quote == q ? .white : .black)
                                                .cornerRadius(25)
                                                .fixedSize(horizontal: true, vertical: false) // Prevent horizontal squishing/overlap
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                            
                            // Export Button
                            HStack(spacing: 12) {
                                Button(action: {
                                    selectedFontIndex = (selectedFontIndex + 1) % fontStyles.count
                                    triggerHaptic()
                                }) {
                                    Image(systemName: "textformat")
                                        .font(.system(size: 18))
                                        .padding(14)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: exportCard) {
                                    HStack(spacing: 8) {
                                        Text("EXPORT CARD")
                                        Text("(10")
                                        Image(systemName: "circle.circle.fill")
                                            .foregroundColor(.yellow)
                                        Text(")")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14) // Slimmed down vertical padding
                                    .background(Color.black)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: { selectedMuse = nil }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 18))
                                        .padding(14)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 24) // Final iPad buffer to avoid Tab Bar overlap
                        
                        Spacer()
                    }
                } else {
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
            }
            .navigationBarHidden(true)
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
