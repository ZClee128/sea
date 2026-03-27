import SwiftUI

// MARK: - Data Models

struct ArtTechnique: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let level: String
    let description: String
    let gradient: [Color]
    let tips: [String]
}

struct ColorPalette: Identifiable {
    let id = UUID()
    let name: String
    let mood: String
    let colors: [String]   // hex strings
}

struct ArtistSpotlight: Identifiable {
    let id = UUID()
    let name: String
    let specialty: String
    let bio: String
    let emoji: String
    let accentColor: Color
    let works: Int
    let years: Int
}

// MARK: - Static Data

let artTechniques: [ArtTechnique] = [
    ArtTechnique(
        icon: "🎨",
        title: "Color Theory",
        level: "Beginner",
        description: "Master the relationships between colors to create harmony, contrast, and mood in your digital artworks.",
        gradient: [Color(red: 0.55, green: 0.1, blue: 0.8), Color(red: 0.9, green: 0.3, blue: 0.5)],
        tips: [
            "Use complementary colors for maximum contrast.",
            "Analogous palettes create natural, harmonious scenes.",
            "Desaturated mid-tones keep focal points punchy.",
            "Warm light + cool shadows = convincing 3D depth."
        ]
    ),
    ArtTechnique(
        icon: "✏️",
        title: "Composition",
        level: "Intermediate",
        description: "Learn how to guide the viewer's eye across the canvas using balance, rhythm, and the rule of thirds.",
        gradient: [Color(red: 0.1, green: 0.4, blue: 0.8), Color(red: 0.0, green: 0.7, blue: 0.9)],
        tips: [
            "Place subjects on rule-of-thirds intersections.",
            "Leading lines draw the eye to the focal point.",
            "Negative space can be as powerful as the subject.",
            "Odd numbers of elements feel natural and balanced."
        ]
    ),
    ArtTechnique(
        icon: "💡",
        title: "Lighting & Shadow",
        level: "Intermediate",
        description: "Understand how light behaves on surfaces to add realism, drama, and three-dimensionality to your CGI scenes.",
        gradient: [Color(red: 0.9, green: 0.6, blue: 0.0), Color(red: 0.9, green: 0.2, blue: 0.1)],
        tips: [
            "Decide on one primary light source first.",
            "Rim lights separate subjects from dark backgrounds.",
            "Ambient occlusion adds contact shadow realism.",
            "Over-lit scenes lose drama — embrace shadow."
        ]
    ),
    ArtTechnique(
        icon: "🌊",
        title: "Texture & Material",
        level: "Advanced",
        description: "Create convincing surfaces through PBR (physically based rendering) workflows, displacement maps, and micro-detail.",
        gradient: [Color(red: 0.0, green: 0.5, blue: 0.4), Color(red: 0.1, green: 0.8, blue: 0.5)],
        tips: [
            "Roughness maps control how light scatters on surfaces.",
            "Normal maps fake surface detail without extra geometry.",
            "Overlap UV seams in inconspicuous areas.",
            "Reference real-world materials for photorealism."
        ]
    ),
    ArtTechnique(
        icon: "📐",
        title: "Perspective",
        level: "Beginner",
        description: "Build believable environments with correct one-, two-, and three-point perspective techniques.",
        gradient: [Color(red: 0.4, green: 0.1, blue: 0.6), Color(red: 0.8, green: 0.4, blue: 0.9)],
        tips: [
            "Identify vanishing points before sketching architecture.",
            "Low horizon lines feel epic and dramatic.",
            "Foreshortening makes figures more dynamic.",
            "Grid overlays help check perspective accuracy quickly."
        ]
    ),
    ArtTechnique(
        icon: "👤",
        title: "Character Design",
        level: "Advanced",
        description: "Craft memorable characters through silhouette, proportion, and storytelling through visual design alone.",
        gradient: [Color(red: 0.7, green: 0.1, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.0)],
        tips: [
            "Strong silhouette = instantly recognizable character.",
            "Primary, secondary, and tertiary shapes add hierarchy.",
            "Color coding helps players/viewers read roles at a glance.",
            "Exaggerate physical traits to communicate personality."
        ]
    )
]

let colorPalettes: [ColorPalette] = [
    ColorPalette(name: "Nebula Dream",  mood: "Cosmic · Ethereal",
                 colors: ["#1A0A2E", "#3B1F5E", "#7B2FBE", "#C77DFF", "#E0AAFF"]),
    ColorPalette(name: "Emerald Depths", mood: "Nature · Serene",
                 colors: ["#042A14", "#1B5E20", "#2E7D32", "#4CAF50", "#A5D6A7"]),
    ColorPalette(name: "Cyberpunk Neon", mood: "Futuristic · Electric",
                 colors: ["#0D0D0D", "#00FFC8", "#FF2079", "#FFE600", "#4C00FF"]),
    ColorPalette(name: "Ocean Abyss",   mood: "Deep · Mysterious",
                 colors: ["#000814", "#001D3D", "#003566", "#006494", "#0096C7"]),
    ColorPalette(name: "Flame Forge",   mood: "Intense · Powerful",
                 colors: ["#1A0000", "#6A0500", "#C62828", "#FF6D00", "#FFD54F"])
]

let artistSpotlights: [ArtistSpotlight] = [
    ArtistSpotlight(
        name: "Aleksi Briclot",
        specialty: "Fantasy CGI & Concept Art",
        bio: "Known for his cosmic fantasy illustrations, Aleksi has created iconic artwork for Magic: The Gathering and Marvel comics. His work blends traditional painting techniques with cutting-edge digital rendering.",
        emoji: "🌌", accentColor: Color(red: 0.5, green: 0.1, blue: 0.8), works: 400, years: 18
    ),
    ArtistSpotlight(
        name: "Wlop",
        specialty: "Digital Painting & Character Art",
        bio: "Chinese digital artist whose ethereal, luminous style has gained tens of millions of followers worldwide. Mastering the interplay between light and skin translucency in digital media.",
        emoji: "✨", accentColor: Color(red: 0.8, green: 0.3, blue: 0.5), works: 250, years: 12
    ),
    ArtistSpotlight(
        name: "Android Jones",
        specialty: "Psychedelic 3D & Visionary Art",
        bio: "Pioneer of the 'electrobemism' movement — a fusion of algorithms, sacred geometry, and light. His immersive installations have been projected onto the Taj Mahal and Burning Man.",
        emoji: "🎆", accentColor: Color(red: 0.1, green: 0.6, blue: 0.9), works: 600, years: 20
    )
]

let dailyInspiration: [(quote: String, author: String)] = [
    ("Every artist was first an amateur.", "Ralph Waldo Emerson"),
    ("Creativity is intelligence having fun.", "Albert Einstein"),
    ("The purpose of art is washing the dust of daily life off our souls.", "Pablo Picasso"),
    ("Art enables us to find ourselves and lose ourselves at the same time.", "Thomas Merton"),
    ("Color is a power which directly influences the soul.", "Wassily Kandinsky"),
    ("I dream my painting and then I paint my dream.", "Vincent Van Gogh"),
    ("Learn the rules like a pro, so you can break them like an artist.", "Pablo Picasso")
]

// MARK: - Technique Detail View
@available(iOS 15.0, *)
struct TechniqueDetailView: View {
    let technique: ArtTechnique
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero gradient header
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        gradient: Gradient(colors: technique.gradient),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .frame(height: 200)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(technique.icon).font(.system(size: 48))
                        Text(technique.title)
                            .font(.title).fontWeight(.bold).foregroundColor(.white)
                        Text(technique.level)
                            .font(.caption).foregroundColor(.white.opacity(0.75))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(.white.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .padding(20)
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text(technique.description)
                        .font(.body).foregroundColor(.secondary)
                        .padding(.top, 20)

                    Divider()

                    Text("Pro Tips").font(.headline).fontWeight(.bold)

                    ForEach(technique.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(technique.gradient[0])
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            Text(tip).font(.subheadline).foregroundColor(.primary)
                        }
                    }
                }
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Color Hex to SwiftUI Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Palette Card
@available(iOS 15.0, *)
struct PaletteCard: View {
    let palette: ColorPalette
    @State private var copiedHex: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(palette.name).font(.subheadline).fontWeight(.semibold)
            Text(palette.mood).font(.caption).foregroundColor(.secondary)

            HStack(spacing: 0) {
                ForEach(palette.colors, id: \.self) { hex in
                    Color(hex: hex)
                        .frame(height: 44)
                        .overlay(
                            copiedHex == hex
                                ? Image(systemName: "checkmark").foregroundColor(.white).font(.caption)
                                : nil
                        )
                        .onTapGesture {
                            UIPasteboard.general.string = hex
                            withAnimation { copiedHex = hex }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation { copiedHex = nil }
                            }
                        }
                }
            }
            .cornerRadius(10)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text("Tap any swatch to copy hex").font(.caption2).foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Artist Card
@available(iOS 15.0, *)
struct ArtistCard: View {
    let artist: ArtistSpotlight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                // Avatar circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [artist.accentColor, artist.accentColor.opacity(0.5)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 54, height: 54)
                    Text(artist.emoji).font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(artist.name).font(.headline).fontWeight(.bold)
                    Text(artist.specialty).font(.caption).foregroundColor(.secondary)
                }
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(artist.works)+").font(.headline).fontWeight(.bold).foregroundColor(artist.accentColor)
                    Text("works").font(.caption2).foregroundColor(.secondary)
                }
            }

            Text(artist.bio).font(.subheadline).foregroundColor(.secondary).lineLimit(4)

            HStack(spacing: 16) {
                Label("\(artist.years) years", systemImage: "calendar").font(.caption).foregroundColor(.secondary)
                Spacer()
                Label("\(artist.works)+ artworks", systemImage: "photo.stack").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
    }
}

// MARK: - Discover View
@available(iOS 15.0, *)
struct DiscoverView: View {
    @State private var selectedLevel = "All"
    let levels = ["All", "Beginner", "Intermediate", "Advanced"]

    private var todayInspiration: (quote: String, author: String) {
        let index = Calendar.current.component(.weekday, from: Date()) % dailyInspiration.count
        return dailyInspiration[index]
    }

    private var filteredTechniques: [ArtTechnique] {
        selectedLevel == "All" ? artTechniques : artTechniques.filter { $0.level == selectedLevel }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Daily Inspiration ──────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        sectionHeader("☀️ Daily Inspiration")

                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.08, green: 0.02, blue: 0.22),
                                    Color(red: 0.4, green: 0.05, blue: 0.6)
                                ]),
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                Image(systemName: "quote.opening")
                                    .font(.title).foregroundColor(.white.opacity(0.4))
                                Text(todayInspiration.quote)
                                    .font(.title3).fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("— \(todayInspiration.author)")
                                    .font(.caption).foregroundColor(.white.opacity(0.7))
                            }
                            .padding(20)
                        }
                        .frame(minHeight: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .purple.opacity(0.3), radius: 12, x: 0, y: 6)
                    }

                    // ── Art Techniques ─────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("🖌 Art Techniques")

                        // Level filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(levels, id: \.self) { level in
                                    Button(action: { withAnimation(.spring()) { selectedLevel = level } }) {
                                        Text(level)
                                            .font(.caption).fontWeight(.semibold)
                                            .foregroundColor(selectedLevel == level ? .white : .primary)
                                            .padding(.horizontal, 14).padding(.vertical, 7)
                                            .background(selectedLevel == level ? Color.purple : Color(.systemGray5))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }

                        // Technique cards
                        ForEach(filteredTechniques) { technique in
                            NavigationLink(destination: TechniqueDetailView(technique: technique)) {
                                HStack(spacing: 14) {
                                    // Icon circle
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(
                                                LinearGradient(colors: technique.gradient,
                                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                            .frame(width: 52, height: 52)
                                        Text(technique.icon).font(.title3)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(technique.title)
                                            .font(.subheadline).fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text(technique.description)
                                            .font(.caption).foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(technique.level)
                                            .font(.caption2).fontWeight(.medium)
                                            .foregroundColor(levelColor(technique.level))
                                            .padding(.horizontal, 8).padding(.vertical, 3)
                                            .background(levelColor(technique.level).opacity(0.12))
                                            .cornerRadius(8)
                                        Image(systemName: "chevron.right")
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                }
                                .padding(14)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    // ── Color Palettes ─────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("🎨 Color Palettes")
                        Text("Tap any swatch to copy the hex code")
                            .font(.caption).foregroundColor(.secondary)

                        ForEach(colorPalettes) { palette in
                            PaletteCard(palette: palette)
                        }
                    }

                    // ── Artist Spotlight ───────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader("⭐️ Artist Spotlight")

                        ForEach(artistSpotlights) { artist in
                            ArtistCard(artist: artist)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2).fontWeight(.bold)
    }

    private func levelColor(_ level: String) -> Color {
        switch level {
        case "Beginner":     return .green
        case "Intermediate": return .orange
        case "Advanced":     return .red
        default:             return .gray
        }
    }
}
