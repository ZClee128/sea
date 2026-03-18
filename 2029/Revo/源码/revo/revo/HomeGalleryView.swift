import SwiftUI

struct MakeupLook: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let imageName: String
    let description: String
    let products: [String]
    let steps: [String]
}

struct HomeGalleryView: View {
    let looks = [
        MakeupLook(name: "Bridal Elegance", category: "Bridal", imageName: "bridal_makeup_look", 
                   description: "A timeless, soft champagne glow for your special day.",
                   products: ["Champagne Shimmer Eyeshadow", "Soft Peach Blush", "Hydrating Lip Gloss"],
                   steps: ["Prep skin with moisturizer", "Apply light foundation", "Sweep peach blush on cheeks", "Finish with gloss"]),
        MakeupLook(name: "Avant-Garde Art", category: "Artistic", imageName: "avant_garde_makeup", 
                   description: "Bold geometric patterns and neon highlights for high-fashion editorial.",
                   products: ["Neon Eyeliner Palette", "Graphic Black Liner", "Stark White Eye Base"],
                   steps: ["Map out shapes with pencil", "Fill with neon pigments", "Sharpen edges with concealer"]),
        MakeupLook(name: "Daily Sunshine", category: "Daily", imageName: "daily_glow_makeup", 
                   description: "A fresh, sun-kissed look perfect for everyday natural beauty.",
                   products: ["Sheer Tinted Moisturizer", "Clear Brow Gel", "Lip Oil"],
                   steps: ["Apply tint", "Brush up brows", "Dab lip oil"]),
        MakeupLook(name: "Evening Glamour", category: "Evening", imageName: "evening_red_lips", 
                   description: "Classic Hollywood red lips and smokey eyes for an unforgettable night.",
                   products: ["Ruby Red Matte Lipstick", "Slate Smokey Palette", "Volumizing Mascara"],
                   steps: ["Create smokey eye", "Apply bold red lip", "Add double coat of mascara"]),
        MakeupLook(name: "Golden Hour", category: "Evening", imageName: "evening_glow", 
                   description: "Deep bronzed tones that catch the sunset light.",
                   products: ["Liquid Bronze Highlighter", "Terracotta Shadow", "Bronze Lip Liner"],
                   steps: ["Apply bronzer to high points", "Blend terracotta into crease"]),
        MakeupLook(name: "Rose Garden", category: "Daily", imageName: "rose_look", 
                   description: "Soft pink and mauve tones for a feminine garden party look.",
                   products: ["Soft Rose Blush", "Mauve Satin Lipstick", "Rose Gold Shimmer"],
                   steps: ["Apply rose blush", "Tap shimmer onto lids"]),
        MakeupLook(name: "Midnight Smoke", category: "Evening", imageName: "midnight_look", 
                   description: "Intense black and silver smokey eye for ultimate drama.",
                   products: ["Black Smudge Pencil", "Silver Metallic Pigment", "Faux Mink Lashes"],
                   steps: ["Smudge black liner", "Pat silver in center", "Apply lashes"]),
        MakeupLook(name: "Pastel Dream", category: "Artistic", imageName: "pastel_look", 
                   description: "Soft lavender and mint green clouds for a whimsical vibe.",
                   products: ["Lavender Matte Shadow", "Mint Eyeliner", "White Mascara"],
                   steps: ["Blend lavender over lid", "Add mint liner wing"])
    ]
    
    @State private var selectedCategory = "All"
    let categories = ["All", "Bridal", "Daily", "Evening", "Artistic"]
    
    private var filteredLooks: [MakeupLook] {
        looks.filter { selectedCategory == "All" || $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: { selectedCategory = cat }) {
                                    Text(cat)
                                            .font(.subheadline)
                                            .bold()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if #available(iOS 14.0, *) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(filteredLooks) { look in
                                GalleryItem(look: look)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(filteredLooks) { look in
                                GalleryItem(look: look)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationBarTitle("Revo Explore", displayMode: .inline)
            .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        }
        .forceLightMode()
    }
}

struct GalleryItem: View {
    let look: MakeupLook
    
    var body: some View {
        NavigationLink(destination: LookDetailView(look: look)) {
            VStack(alignment: .leading) {
                ZStack {
                    if !look.imageName.isEmpty {
                        Color.clear
                            .aspectRatio(0.8, contentMode: .fill)
                            .overlay(
                                Image(look.imageName)
                                    .resizable()
                                    .scaledToFill()
                            )
                            .clipped()
                            .cornerRadius(15)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(RevoDesign.secondary)
                            .aspectRatio(0.8, contentMode: .fit)
                        
                        Image(systemName: "photo.fill")
                            .foregroundColor(RevoDesign.primary.opacity(0.3))
                            .font(.largeTitle)
                    }
                }
                
                Text(look.name)
                    .font(.headline)
                    .foregroundColor(RevoDesign.text)
                    .padding(.top, 5)
                
                Text(look.category)
                    .font(.caption)
                    .foregroundColor(RevoDesign.textSecondary)
            }
        }
    }
}

struct LookDetailView: View {
    let look: MakeupLook
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    if !look.imageName.isEmpty {
                        Image(look.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 350)
                            .clipped()
                    } else {
                        Rectangle().fill(RevoDesign.secondary).frame(height: 350)
                        Image(systemName: "sparkles").font(.system(size: 80)).foregroundColor(RevoDesign.primary.opacity(0.2))
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(look.category.uppercased())
                        .font(.caption)
                        .bold()
                        .foregroundColor(RevoDesign.primary)
                    
                    Text(look.name)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(RevoDesign.text)
                    
                    Text(look.description)
                        .font(.body)
                        .foregroundColor(RevoDesign.textSecondary)
                    
                    Divider().padding(.vertical)
                    
                    // Products Involved
                    Text("Products Recommended")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(look.products, id: \.self) { product in
                            HStack {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                    .foregroundColor(RevoDesign.primary)
                                Text(product)
                                    .font(.subheadline)
                                    .foregroundColor(RevoDesign.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RevoDesign.secondary.opacity(0.5))
                    .cornerRadius(10)
                    
                    // Step by Step
                    Text("Application Guide")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(0..<look.steps.count, id: \.self) { index in
                        HighlightRow(title: "Step \(index + 1)", detail: look.steps[index])
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(Text(look.name), displayMode: .inline)
        .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        .forceLightMode()
    }
}

struct HighlightRow: View {
    let title: String
    let detail: String
    
    var body: some View {
        HStack(alignment: .top) {
            Circle()
                .fill(RevoDesign.primary)
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(RevoDesign.text)
                Text(detail)
                    .font(.footnote)
                    .foregroundColor(RevoDesign.textSecondary)
            }
        }
    }
}
