import SwiftUI

struct NailDesign: Identifiable {
    let id: UUID
    let name: String
    let category: String
    let imageName: String
    let description: String
    let isTrending: Bool
    let isPremium: Bool
    let price: Int
    
    init(id: UUID = UUID(), name: String, category: String, imageName: String, description: String, isTrending: Bool, isPremium: Bool = false, price: Int = 0) {
        self.id = id
        self.name = name
        self.category = category
        self.imageName = imageName
        self.description = description
        self.isTrending = isTrending
        self.isPremium = isPremium
        self.price = price
    }
}

@available(iOS 14.0, *)
struct InspirationView: View {
    let designs = [
        NailDesign(name: "Bridal White", category: "Wedding", imageName: "Bridal White", description: "Elegant white nails for your special day.", isTrending: true),
        NailDesign(name: "Midnight Blue", category: "Modern", imageName: "Midnight Blue", description: "Deep blue with starry accents.", isTrending: true),
        NailDesign(name: "Golden Leaf", category: "Artistic", imageName: "Golden Leaf", description: "Hand-painted golden leaves on matte base.", isTrending: true, isPremium: true, price: 15),
        NailDesign(name: "Minimalist Pink", category: "Daily", imageName: "Minimalist Pink", description: "Soft pink for everyday elegance.", isTrending: false),
        NailDesign(name: "Crystal Quartz", category: "Artistic", imageName: "Crystal Quartz", description: "Transparent with iridescent flakes.", isTrending: false),
        NailDesign(name: "Velvet Red", category: "Classic", imageName: "Velvet Red", description: "Rich, deep red with a velvet finish.", isTrending: false, isPremium: true, price: 10),
        NailDesign(name: "Lavender Mist", category: "Spring", imageName: "Lavender Mist", description: "Light purple with soft gradients.", isTrending: false),
        NailDesign(name: "Chrome Silver", category: "Futuristic", imageName: "Chrome Silver", description: "High-shine mirror finish silver.", isTrending: false, isPremium: true, price: 10),
        NailDesign(name: "Forest Green", category: "Nature", imageName: "Forest Green", description: "Dark green with gold foil accents.", isTrending: false),
        NailDesign(name: "Pastel Rainbow", category: "Playful", imageName: "Pastel Rainbow", description: "Soft pastel shades on each finger.", isTrending: false)
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 160))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Trending Section
                    Text("Trending Now")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(designs.filter { $0.isTrending }) { design in
                                NavigationLink(destination: NailDetailView(design: design)) {
                                    TrendingCard(design: design)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // All Inspirations
                    Text("Explore More")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if #available(iOS 14.0, *) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(designs.filter { !$0.isTrending }) { design in
                                NavigationLink(destination: NailDetailView(design: design)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(design.imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .frame(height: 180)
                                                .cornerRadius(15)
                                                .clipped()
                                            
                                            if design.isPremium && !StoreManager.shared.isUnlocked(design.name) {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.white)
                                                    .padding(6)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Circle())
                                                    .padding(6)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(design.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(design.category)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Fallback for iOS 13 for the grid layout
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(designs.filter { !$0.isTrending }) { design in
                                NavigationLink(destination: NailDetailView(design: design)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(design.imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .frame(height: 180)
                                                .cornerRadius(15)
                                                .clipped()
                                            
                                            if design.isPremium && !StoreManager.shared.isUnlocked(design.name) {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.white)
                                                    .padding(6)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Circle())
                                                    .padding(6)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(design.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(design.category)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Inspiration")
        }
    }
}

struct TrendingCard: View {
    let design: NailDesign
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pink.opacity(0.1))
                    .frame(width: 240, height: 150)
                
                Image(design.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 240, height: 150)
                    .cornerRadius(20)
                    .clipped()
                
                if design.isPremium && !StoreManager.shared.isUnlocked(design.name) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            Text(design.name)
                .font(.headline)
            Text(design.category)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 240)
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        InspirationView()
    } else {
        // Fallback on earlier versions
    }
}
