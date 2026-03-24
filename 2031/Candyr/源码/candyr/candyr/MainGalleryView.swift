import SwiftUI

struct FashionItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    var description: String = "A cutting-edge piece from the Candyr collection, pushing the boundaries of digital couture and futuristic aesthetics."
}

@available(iOS 14.0, *)
struct MainGalleryView: View {
    @State private var selectedCategory: String = "Avant-Garde"
    
    let spotlightItems = [
        FashionItem(title: "Neon Pulse", subtitle: "2026 Couture Collection", imageName: "Neon Pulse", description: "A high-intensity showcase of bioluminescent fabrics and reactive structural elements that pulse in sync with the wearer's biometric data."),
        FashionItem(title: "Iridescent Flow", subtitle: "Digital Avant-Garde", imageName: "Iridescent Flow", description: "A fluid, ever-changing silhouette crafted from smart-liquid silk that refracts light into a spectrum of impossible colors."),
        FashionItem(title: "LED Runway", subtitle: "Future of Fabrics", imageName: "LED Runway", description: "Integrating microscopic LED arrays into carbon-fiber weave, this piece turns the human body into a canvas for dynamic digital patterns.")
    ]
    
    let feedItems = [
        FashionItem(title: "Cyber Bloom", subtitle: "Synthetic Organics", imageName: "Cyber Bloom", description: "3D-printed organic shapes that mimic the growth of deep-sea flora, using synthetic biological polymers."),
        FashionItem(title: "Void Silk", subtitle: "Obsidian Aesthetics", imageName: "Void Silk", description: "Crafted from materials that absorb 99% of visible light, accented by razor-thin cyan fiber optics."),
        FashionItem(title: "Plasma Weave", subtitle: "Electric Energy", imageName: "Plasma Weave", description: "A high-voltage design featuring encapsulated ionic gas that glow with internal electrical storms."),
        FashionItem(title: "Neural Lace", subtitle: "Cerebral Accessories", imageName: "Neural Lace", description: "Intricate headwear that interfaces with the user's focus, changing its structural complexity in real-time."),
        FashionItem(title: "Kinetic Mesh", subtitle: "Dynamic Motion", imageName: "Kinetic Mesh", description: "Aerodynamic mesh that shifts its transparency and color based on the velocity of movement."),
        FashionItem(title: "Liquid Chrome", subtitle: "Mirror Reality", imageName: "Liquid Chrome", description: "A solid-to-liquid transformation effect that reflects the surrounding environment in hyper-realistic fidelity."),
        FashionItem(title: "Binary Veil", subtitle: "Digital Identity", imageName: "Binary Veil", description: "A semi-transparent cloak that encodes the wearer's digital footprint into shifting pixelated patterns."),
        FashionItem(title: "Solar Flare", subtitle: "Thermal Radiance", imageName: "Solar Flare", description: "Utilizing heat-reactive pigments to display radiant orange and gold gradients inspired by solar phenomena."),
        FashionItem(title: "Zenith Carbon", subtitle: "Ultralight Structural", imageName: "Zenith Carbon", description: "The pinnacle of structural fashion, using aeronautical carbon fiber to create gravity-defying shapes."),
        FashionItem(title: "Aqua Circuit", subtitle: "Hydrophilic Tech", imageName: "Aqua Circuit", description: "Water-reactive circuitry that activates cooling systems and glowing blue paths when exposed to moisture.")
    ]
    
    let categories = ["Avant-Garde", "Cyber Couture", "Liquid Silk", "Neo-Retro", "Digital Weave"]
    
    @State private var showingRadar = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // 1. Featured Spotlight (Hero)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SPOTLIGHT")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(NeonCouture.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(spotlightItems) { item in
                                    NavigationLink(destination: FashionDetailView(item: item)) {
                                        SpotlightCard(item: item)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 1.5 STYLE RADAR PROMO (NEW FUNCTIONAL MODULE)
                    Button(action: {
                        showingRadar = true
                    }) {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("STYLE RADAR")
                                    .font(.system(.caption, design: .monospaced))
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(4)
                                
                                Text("Discover Your Neural Style Match")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Let our AI analyze your frequency.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .neonGlow(color: .white)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LinearGradient(gradient: Gradient(colors: [NeonCouture.primary, NeonCouture.secondary]), startPoint: .leading, endPoint: .trailing))
                                .neonGlow()
                        )
                    }
                    .padding(.horizontal)
                    .fullScreenCover(isPresented: $showingRadar) {
                        StyleRadarView()
                    }
                    
                    // 2. Categories (Chips)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EXPLORE STYLE")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(NeonCouture.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .font(.system(size: 14, weight: .medium))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(selectedCategory == category ? NeonCouture.primary : Color.clear)
                                            )
                                            .background(
                                                Capsule()
                                                    .stroke(NeonCouture.primary.opacity(0.3), lineWidth: 1)
                                            )
                                            .foregroundColor(selectedCategory == category ? .white : NeonCouture.primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 3. Main Collections Feed
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DAILY FEED: \(selectedCategory.uppercased())")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(NeonCouture.secondary)
                            .padding(.horizontal)
                        
                        if #available(iOS 14.0, *) {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 16, alignment: .top),
                                    GridItem(.flexible(), spacing: 16, alignment: .top)
                                ],
                                spacing: 24
                            ) {
                                ForEach(feedItems) { item in
                                    NavigationLink(destination: FashionDetailView(item: item)) {
                                        GalleryCard(item: item)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 24) {
                                ForEach(feedItems.prefix(5)) { item in
                                    NavigationLink(destination: FashionDetailView(item: item)) {
                                        GalleryCard(item: item)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Candyr Runway")
            .background(NeonCouture.background.edgesIgnoringSafeArea(.all))
        }
    }
}

struct SpotlightCard: View {
    let item: FashionItem
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                // Background Gradient OR Image
                RoundedRectangle(cornerRadius: 30)
                    .fill(LinearGradient(gradient: Gradient(colors: [NeonCouture.primary, NeonCouture.secondary]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 300, height: 400)
                    .shadow(color: NeonCouture.primary.opacity(0.4), radius: 15, x: 0, y: 10)
                
                // Real Image
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .cornerRadius(30)
                
                // Dark Gradient Overlay for text readability
                RoundedRectangle(cornerRadius: 30)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]), startPoint: .bottom, endPoint: .center))
                    .frame(width: 300, height: 400)
                
                // Content Overlay
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 28, weight: .black, design: .serif))
                        .foregroundColor(.white)
                    Text(item.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(24)
            }
        }
    }
}

@available(iOS 14.0, *)
struct GalleryCard: View {
    let item: FashionItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Area with forced ratio
            ZStack(alignment: .topTrailing) {
                // Background placeholder that defines the shape and size
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.gray.opacity(0.05))
                    .aspectRatio(0.75, contentMode: .fill) // Enforce ratio here
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(NeonCouture.primary.opacity(0.1), lineWidth: 1)
                    )
                
                // Real Image (safely handled)
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .layoutPriority(-1) // Ensure it doesn't push the container
                    .cornerRadius(18)
                
                // Accent dot
                Circle()
                    .fill(NeonCouture.accent)
                    .frame(width: 8, height: 8)
                    .padding(10)
            }
            .clipped()
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(item.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct MainGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            MainGalleryView()
        } else {
            // Fallback on earlier versions
        }
    }
}
