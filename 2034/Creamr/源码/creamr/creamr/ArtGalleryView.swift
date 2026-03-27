import SwiftUI
import UIKit

// MARK: - Data Model
struct ArtItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let category: String
    let description: String
    let tags: [String]
    let viewCount: String
    let year: String
    let style: String
    let resolution: String
    var isFavorited: Bool = false
}

// MARK: - Sample Data
let sampleArtItems: [ArtItem] = [
    ArtItem(
        imageName: "art_celestial", title: "Celestial Nebula Muse", category: "Cosmos",
        description: "A guardian of the stars, born from the heart of a dying nebula. Her crystalline armor resonates with the hum of the cosmos, and her gaze can chart the fate of entire galaxies. Rendered with volumetric light simulation and ray-traced crystal refraction at 4K resolution.",
        tags: ["Cosmos", "Crystal", "Ethereal", "Sci-Fi"],
        viewCount: "12.4k", year: "2024", style: "3D Render", resolution: "4K"
    ),
    ArtItem(
        imageName: "art_forest", title: "Emerald Forest Spirit", category: "Nature",
        description: "Ancient as the first tree, she weaves her will through root and leaf. The forest breathes at her command, and the creatures of the wild bow to her gentle sovereignty. Hand-painted textures blended with photorealistic foliage shaders and particle-based pollen systems.",
        tags: ["Nature", "Fantasy", "Magic", "Fairy"],
        viewCount: "8.7k", year: "2023", style: "Digital Paint", resolution: "2K"
    ),
    ArtItem(
        imageName: "art_cyber", title: "Cybernetic Night Gaze", category: "Cyber",
        description: "In a rain-soaked megalopolis of neon and chrome, she stands as the last bastion between humanity and the machine uprising. Her augmented eyes see through every lie. Built with procedural neon shaders, motion-blur compositing, and subsurface-scattering skin.",
        tags: ["Cyberpunk", "Neon", "Futuristic", "Tech"],
        viewCount: "21.1k", year: "2024", style: "CGI / VFX", resolution: "4K"
    ),
    ArtItem(
        imageName: "art_ocean", title: "Abyssal Sea Enchantress", category: "Ocean",
        description: "From the deepest trench, she calls the tides and commands the leviathans. Her song can calm a storm or shatter a fleet. The ocean holds no secrets from her. Created with fluid simulation, bioluminescent particle systems, and deep-sea caustic lighting.",
        tags: ["Ocean", "Fantasy", "Mystical", "Dark"],
        viewCount: "5.3k", year: "2023", style: "Concept Art", resolution: "HD"
    ),
    ArtItem(
        imageName: "art_flame", title: "Eternal Flame Dancer", category: "Fire",
        description: "She was born in a volcano's heart and dances with jets of solar plasma. She does not burn — she is the fire, ancient and undying. Achieved using Houdini pyro simulation, real-time ember particles, and ACES film-grade color grading.",
        tags: ["Fire", "Power", "Epic", "Fantasy"],
        viewCount: "18.9k", year: "2024", style: "VFX Sim", resolution: "4K"
    ),
    ArtItem(
        imageName: "art_aurora", title: "Aurora Dream Weaver", category: "Cosmos",
        description: "She paints the polar skies with ribbons of light, her canvas the very atmosphere. Every night she spins dreams into the hearts of those who look up. Volumetric atmosphere shaders simulate authentic borealis particle dispersion with spectral color mapping.",
        tags: ["Aurora", "Light", "Dreams", "Sky"],
        viewCount: "9.2k", year: "2023", style: "Matte Paint", resolution: "2K"
    )
]

let artCategories = ["All", "Cosmos", "Nature", "Cyber", "Ocean", "Fire"]

// MARK: - Share Sheet UIKit Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Gallery View
@available(iOS 15.0, *)
struct ArtGalleryView: View {
    @State private var selectedCategory = "All"
    @State private var favoriteIDs = Set<UUID>()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @ObservedObject private var savedStore = SavedStore.shared

    var filteredItems: [ArtItem] {
        sampleArtItems.filter {
            (selectedCategory == "All" || $0.category == selectedCategory) &&
            (searchText.isEmpty || $0.title.lowercased().contains(searchText.lowercased()))
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    searchBar
                    heroBanner
                    categoryStrip
                    if !savedStore.savedItems.isEmpty {
                        myCollectionSection
                    }
                    sectionHeader(title: "Featured Works", subtitle: "\(filteredItems.count) illustrations")
                    artGrid
                }
            }
            .navigationBarTitle("Creamr", displayMode: .inline)
            // Dismiss keyboard when tapping outside
            .onTapGesture { isSearchFocused = false }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search art, styles, themes...", text: $searchText)
                .font(.subheadline)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit { isSearchFocused = false }
            if !searchText.isEmpty {
                Button(action: { searchText = ""; isSearchFocused = false }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Hero Banner
    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5, green: 0, blue: 0.5, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.2, blue: 0.5, alpha: 1))]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .cornerRadius(18)

            VStack(alignment: .leading, spacing: 4) {
                Text("✨ Daily Muse")
                    .font(.caption).fontWeight(.semibold).foregroundColor(.white.opacity(0.8))
                Text("Ethereal\nDigital Art")
                    .font(.title).fontWeight(.bold).foregroundColor(.white).lineLimit(2)
                Text("Curated fantasy illustrations")
                    .font(.caption).foregroundColor(.white.opacity(0.7))
            }
            .padding()

            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "sparkles").font(.system(size: 40)).foregroundColor(.white.opacity(0.4))
                    Image(systemName: "star.fill").font(.system(size: 20)).foregroundColor(.yellow.opacity(0.6))
                }
                .padding()
            }
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }

    // MARK: - Category Strip
    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(artCategories, id: \.self) { cat in
                    Button(action: { selectedCategory = cat; isSearchFocused = false }) {
                        Text(cat)
                            .font(.subheadline).fontWeight(.medium)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(selectedCategory == cat ? Color.pink : Color(.systemGray6))
                            .foregroundColor(selectedCategory == cat ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal).padding(.vertical, 14)
        }
    }

    // MARK: - My Collection Section
    private var myCollectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("My Collection").font(.headline).fontWeight(.bold)
                    Text("\(savedStore.savedItems.count) saved").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "bookmark.fill").foregroundColor(.orange)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(savedStore.savedItems) { item in
                        NavigationLink(destination: ArtDetailView(item: item)) {
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack(alignment: .topTrailing) {
                                    LinearGradient(gradient: Gradient(colors: collectionColors(for: item.category)),
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .frame(width: 110, height: 100).cornerRadius(12)
                                    Image(systemName: colIcon(for: item.category))
                                        .font(.system(size: 28)).foregroundColor(.white.opacity(0.35))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    Image(systemName: "bookmark.fill")
                                        .font(.system(size: 14)).foregroundColor(.orange).padding(8)
                                }
                                Text(item.title).font(.caption).fontWeight(.medium)
                                    .foregroundColor(.primary).lineLimit(2).frame(width: 110, alignment: .leading)
                            }
                            .frame(width: 110)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
    }

    private func collectionColors(for cat: String) -> [Color] {
        switch cat {
        case "Cosmos": return [Color(#colorLiteral(red:0.1,green:0,blue:0.4,alpha:1)), Color(#colorLiteral(red:0.4,green:0.1,blue:0.7,alpha:1))]
        case "Nature": return [Color(#colorLiteral(red:0,green:0.3,blue:0.1,alpha:1)), Color(#colorLiteral(red:0.2,green:0.6,blue:0.3,alpha:1))]
        case "Cyber":  return [Color(#colorLiteral(red:0.05,green:0.05,blue:0.2,alpha:1)), Color(#colorLiteral(red:0.4,green:0,blue:0.6,alpha:1))]
        case "Ocean":  return [Color(#colorLiteral(red:0,green:0.2,blue:0.5,alpha:1)), Color(#colorLiteral(red:0,green:0.6,blue:0.8,alpha:1))]
        case "Fire":   return [Color(#colorLiteral(red:0.5,green:0.1,blue:0,alpha:1)), Color(#colorLiteral(red:1,green:0.4,blue:0,alpha:1))]
        default:       return [Color(#colorLiteral(red:0.4,green:0,blue:0.3,alpha:1)), Color(#colorLiteral(red:0.8,green:0.2,blue:0.5,alpha:1))]
        }
    }
    private func colIcon(for cat: String) -> String {
        switch cat {
        case "Cosmos": return "sparkles"; case "Nature": return "leaf.fill"
        case "Cyber": return "cpu"; case "Ocean": return "drop.fill"
        case "Fire": return "flame.fill"; default: return "wand.and.stars"
        }
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).fontWeight(.bold)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal).padding(.bottom, 8)
    }

    // MARK: - Art Grid
    private var artGrid: some View {
        VStack(spacing: 12) {
            let rows = stride(from: 0, to: filteredItems.count, by: 2).map {
                Array(filteredItems[$0..<min($0 + 2, filteredItems.count)])
            }
            ForEach(rows, id: \.first?.id) { row in
                HStack(spacing: 12) {
                    ForEach(row) { item in
                        NavigationLink(destination: ArtDetailView(item: item)) {
                            ArtCard(item: item, isFavorited: favoriteIDs.contains(item.id)) {
                                if favoriteIDs.contains(item.id) { favoriteIDs.remove(item.id) }
                                else { favoriteIDs.insert(item.id) }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    if row.count < 2 { Spacer().frame(maxWidth: .infinity) }
                }
            }
        }
        .padding(.horizontal).padding(.bottom, 20)
    }
}

// MARK: - Art Card
@available(iOS 15.0, *)
struct ArtCard: View {
    let item: ArtItem
    let isFavorited: Bool
    let onFavorite: () -> Void

    var body: some View {
        // Compute explicit pixel size: (screen - 16*2 padding - 12 gap) / 2 cols
        let w = (UIScreen.main.bounds.width - 44) / 2
        let h = w / 0.72
        return ZStack(alignment: .bottomLeading) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: w, height: h)
                // clipShape ensures all 4 corners are clipped (not just outer corner)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Bottom gradient + title
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 85)
                    .overlay(
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(.white).lineLimit(2)
                            Text(item.category)
                                .font(.caption2).foregroundColor(.white.opacity(0.75))
                        }
                        // padding(.bottom, 22) ensures text clears the 14pt corner radius
                        .padding(.horizontal, 10).padding(.bottom, 22),
                        alignment: .bottomLeading
                    )
            }
            .frame(width: w, height: h)

            // Favorite button
            Button(action: onFavorite) {
                Image(systemName: isFavorited ? "heart.fill" : "heart")
                    .font(.system(size: 14))
                    .foregroundColor(isFavorited ? .pink : .white)
                    .padding(6)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            .frame(width: w, height: h, alignment: .topTrailing)
            .padding(10)
        }
        .frame(width: w, height: h)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(Rectangle())
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    func gradientColors(for category: String) -> [Color] {
        switch category {
        case "Cosmos": return [Color(#colorLiteral(red: 0.1, green: 0.0, blue: 0.4, alpha: 1)), Color(#colorLiteral(red: 0.4, green: 0.1, blue: 0.7, alpha: 1))]
        case "Nature": return [Color(#colorLiteral(red: 0.0, green: 0.3, blue: 0.1, alpha: 1)), Color(#colorLiteral(red: 0.2, green: 0.6, blue: 0.3, alpha: 1))]
        case "Cyber":  return [Color(#colorLiteral(red: 0.05, green: 0.05, blue: 0.2, alpha: 1)), Color(#colorLiteral(red: 0.4, green: 0.0, blue: 0.6, alpha: 1))]
        case "Ocean":  return [Color(#colorLiteral(red: 0.0, green: 0.2, blue: 0.5, alpha: 1)), Color(#colorLiteral(red: 0.0, green: 0.6, blue: 0.8, alpha: 1))]
        case "Fire":   return [Color(#colorLiteral(red: 0.5, green: 0.1, blue: 0.0, alpha: 1)), Color(#colorLiteral(red: 1.0, green: 0.4, blue: 0.0, alpha: 1))]
        default:       return [Color(#colorLiteral(red: 0.4, green: 0.0, blue: 0.3, alpha: 1)), Color(#colorLiteral(red: 0.8, green: 0.2, blue: 0.5, alpha: 1))]
        }
    }

    func iconName(for category: String) -> String {
        switch category {
        case "Cosmos": return "sparkles"
        case "Nature": return "leaf.fill"
        case "Cyber":  return "cpu"
        case "Ocean":  return "drop.fill"
        case "Fire":   return "flame.fill"
        default:       return "wand.and.stars"
        }
    }
}

// MARK: - Detail View
@available(iOS 15.0, *)
struct ArtDetailView: View {
    let item: ArtItem
    @State private var isFavorited = false
    @State private var showShareSheet = false
    @State private var showSavedToast = false
    @State private var showChat = false
    @ObservedObject private var savedStore = SavedStore.shared

    private var isSaved: Bool { savedStore.isSaved(item) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                artHero

                // Action bar
                actionBar
                    .padding()
                    .background(Color(.systemBackground))

                Divider()

                // Body content
                VStack(alignment: .leading, spacing: 14) {
                    Text("About This Piece")
                        .font(.headline).fontWeight(.bold)

                    Text(item.description)
                        .font(.body).foregroundColor(.secondary).lineSpacing(5)

                    Text("Tags")
                        .font(.headline).fontWeight(.bold).padding(.top, 6)

                    FlowTagView(tags: item.tags)

                    // Stats — unique per artwork
                    HStack(spacing: 0) {
                        statBox(value: item.resolution, label: "Resolution")
                        Divider().frame(height: 40)
                        statBox(value: item.style, label: "Medium")
                        Divider().frame(height: 40)
                        statBox(value: item.year, label: "Year")
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.top, 4)

                    // Chat CTA
                    chatEntryButton

                    // Related
                    Text("More in \(item.category)")
                        .font(.headline).fontWeight(.bold).padding(.top, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sampleArtItems.filter { $0.category == item.category && $0.id != item.id }.prefix(4)) { related in
                                NavigationLink(destination: ArtDetailView(item: related)) {
                                    RelatedCard(item: related)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
            }
            // Prevent horizontal overflow from scaledToFill image
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["Check out this amazing digital art: \(item.title) — Creamr App 🎨✨"])
        }
        .overlay(savedToast, alignment: .top)
        .background(
            NavigationLink(destination: ArtChatView(artItem: item), isActive: $showChat) {
                EmptyView()
            }
        )
    }

    // MARK: - Hero
    private var artHero: some View {
        let w = UIScreen.main.bounds.width
        return ZStack(alignment: .bottomLeading) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: w, height: 340)  // explicit pixels, no expansion
                .clipped()

            // Bottom gradient for text legibility
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                           startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.category.uppercased())
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.black.opacity(0.3)).cornerRadius(6)

                Text(item.title)
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
            }
            .padding()
        }
        .frame(width: w, height: 340)
    }

    // MARK: - Action Bar
    private var actionBar: some View {
        HStack(spacing: 20) {
            actionButton(icon: isFavorited ? "heart.fill" : "heart", label: "Like", color: isFavorited ? .pink : .gray) {
                isFavorited.toggle()
            }
            actionButton(icon: "square.and.arrow.up", label: "Share", color: .blue) {
                showShareSheet = true
            }
            actionButton(icon: isSaved ? "bookmark.fill" : "bookmark", label: isSaved ? "Saved" : "Save", color: isSaved ? .orange : .gray) {
                savedStore.toggle(item)
                if savedStore.isSaved(item) {
                    showSavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showSavedToast = false }
                    }
                }
            }
            Spacer()
            Text("🔥 \(item.viewCount) views").font(.caption).foregroundColor(.secondary)
        }
    }

    // MARK: - Chat Entry
    private var chatEntryButton: some View {
        Button(action: { showChat = true }) {
            HStack(spacing: 12) {
                ZStack {
                    LinearGradient(colors: [.pink.opacity(0.7), .purple.opacity(0.8)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .clipShape(Circle())
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.white).font(.system(size: 16))
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Chat about this artwork")
                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                    Text("Join the conversation ✨")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary).font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Saved Toast
    @ViewBuilder
    private var savedToast: some View {
        if showSavedToast {
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill").foregroundColor(.orange)
                Text("Saved to your collection!").font(.subheadline).fontWeight(.medium)
            }
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
            .padding(.top, 50)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Helper Views
    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
                Text(label).font(.caption2).foregroundColor(.secondary)
            }
        }
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).fontWeight(.bold)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
    }

    func heroColors(for category: String) -> [Color] {
        switch category {
        case "Cosmos": return [Color(#colorLiteral(red: 0.05, green: 0.0, blue: 0.3, alpha: 1)), Color(#colorLiteral(red: 0.5, green: 0.1, blue: 0.8, alpha: 1))]
        case "Nature": return [Color(#colorLiteral(red: 0.0, green: 0.25, blue: 0.05, alpha: 1)), Color(#colorLiteral(red: 0.15, green: 0.55, blue: 0.2, alpha: 1))]
        case "Cyber":  return [Color(#colorLiteral(red: 0.02, green: 0.02, blue: 0.15, alpha: 1)), Color(#colorLiteral(red: 0.35, green: 0.0, blue: 0.55, alpha: 1))]
        case "Ocean":  return [Color(#colorLiteral(red: 0.0, green: 0.15, blue: 0.4, alpha: 1)), Color(#colorLiteral(red: 0.0, green: 0.5, blue: 0.75, alpha: 1))]
        case "Fire":   return [Color(#colorLiteral(red: 0.4, green: 0.05, blue: 0.0, alpha: 1)), Color(#colorLiteral(red: 0.95, green: 0.35, blue: 0.0, alpha: 1))]
        default:       return [Color(#colorLiteral(red: 0.35, green: 0.0, blue: 0.25, alpha: 1)), Color(#colorLiteral(red: 0.75, green: 0.15, blue: 0.45, alpha: 1))]
        }
    }

    func iconName(for category: String) -> String {
        switch category {
        case "Cosmos": return "sparkles"
        case "Nature": return "leaf.fill"
        case "Cyber":  return "cpu"
        case "Ocean":  return "drop.fill"
        case "Fire":   return "flame.fill"
        default:       return "wand.and.stars"
        }
    }
}

// MARK: - Related Card
@available(iOS 15.0, *)
struct RelatedCard: View {
    let item: ArtItem
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: cardColors(for: item.category)),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 120, height: 110).cornerRadius(12)
                Image(systemName: rcIconName(for: item.category)).font(.system(size: 30)).foregroundColor(.white.opacity(0.4))
            }
            Text(item.title).font(.caption).fontWeight(.medium).foregroundColor(.primary).frame(width: 120, alignment: .leading).lineLimit(2)
        }
        .frame(width: 120)
    }
    func cardColors(for category: String) -> [Color] {
        switch category {
        case "Cosmos": return [.purple.opacity(0.8), .blue.opacity(0.9)]
        case "Nature": return [.green.opacity(0.7), .teal.opacity(0.9)]
        case "Cyber":  return [.indigo.opacity(0.9), .purple.opacity(0.8)]
        case "Ocean":  return [.blue.opacity(0.7), .cyan.opacity(0.9)]
        case "Fire":   return [.orange.opacity(0.9), .red.opacity(0.8)]
        default:       return [.pink.opacity(0.7), .purple.opacity(0.9)]
        }
    }
    func rcIconName(for category: String) -> String {
        switch category {
        case "Cosmos": return "sparkles"; case "Nature": return "leaf.fill"
        case "Cyber": return "cpu"; case "Ocean": return "drop.fill"
        case "Fire": return "flame.fill"; default: return "wand.and.stars"
        }
    }
}

// MARK: - Flow Tag View
struct FlowTagView: View {
    let tags: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let chunked = stride(from: 0, to: tags.count, by: 2).map { Array(tags[$0..<min($0+2, tags.count)]) }
            ForEach(chunked, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { tag in
                        Text("# \(tag)")
                            .font(.caption).fontWeight(.medium)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.pink.opacity(0.12))
                            .foregroundColor(.pink).cornerRadius(20)
                    }
                }
            }
        }
    }
}
