import SwiftUI

@available(iOS 15.0, *)
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
                                .cornerRadius(20)
                            
                            // Dimming Overlay
                            Color.black.opacity(overlayOpacity)
                                .cornerRadius(20)
                            
                            VStack(spacing: 16) {
                                Image(systemName: "quote.opening")
                                    .font(.title)
                                    .foregroundColor(textColor)
                                
                                Text(quote)
                                    .font(.system(size: 26, weight: .bold, design: fontStyles[selectedFontIndex]))
                                    .foregroundColor(textColor)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .shadow(radius: 5)
                            }
                            .padding()
                        }
                        .padding()
                        .shadow(radius: 12)
                        
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
                                                .font(.caption)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(quote == q ? Color.black : Color(.systemGray6))
                                                .foregroundColor(quote == q ? .white : .black)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Export Button
                            HStack(spacing: 16) {
                                Button(action: {
                                    selectedFontIndex = (selectedFontIndex + 1) % fontStyles.count
                                    triggerHaptic()
                                }) {
                                    Image(systemName: "textformat")
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                                
                                Button(action: exportCard) {
                                    Text("EXPORT CARD")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.black)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: { selectedMuse = nil }) {
                                    Image(systemName: "xmark")
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        if isShowingSuccess {
                            Text("Card Exported to Gallery")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(20)
                                .transition(.opacity)
                        }
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
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
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
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenStudioWithMuse"))) { notification in
            if let muse = notification.object as? MuseItem {
                selectedMuse = muse
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
                saver.writeToPhotoAlbum(image: image)
                
                withAnimation {
                    isShowingSuccess = true
                }
                triggerHapticSuccess()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { isShowingSuccess = false }
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
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: 800, height: 800)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

@available(iOS 15.0, *)
struct InspoCardView_Previews: PreviewProvider {
    static var previews: some View {
        InspoCardView()
    }
}
