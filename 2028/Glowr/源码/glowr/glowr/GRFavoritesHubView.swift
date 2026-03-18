import SwiftUI
import Combine

class GRFavoritesControl: ObservableObject {
    static let shared = GRFavoritesControl()
    @Published var favoriteIds: Set<UUID> = []
    
    func toggleFavorite(_ modelId: UUID) {
        if favoriteIds.contains(modelId) {
            favoriteIds.remove(modelId)
        } else {
            favoriteIds.insert(modelId)
        }
    }
}

struct GRFavoritesHubView: View {
    @ObservedObject var favorites = GRFavoritesControl.shared
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("COLLECTION")
                        .font(.system(size: 38, weight: .black, design: .serif))
                        .tracking(5)
                        .foregroundColor(.black)
                    Text("YOUR CURATED SELECTION")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.gray)
                }
                .padding()
                
                let favModels = GRModelRegistry.samples.filter { favorites.favoriteIds.contains($0.id) }
                
                if favModels.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 60))
                            .foregroundColor(.black.opacity(0.1))
                        Text("Your collection is empty")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add models you love to your professional collection for quick reference.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(0..<(favModels.count + 1) / 2, id: \.self) { rowIndex in
                                HStack(spacing: 20) {
                                    NavigationLink(destination: GRProfileDetailView(model: favModels[rowIndex * 2])) {
                                        GRCollectionGridTile(model: favModels[rowIndex * 2])
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if rowIndex * 2 + 1 < favModels.count {
                                        NavigationLink(destination: GRProfileDetailView(model: favModels[rowIndex * 2 + 1])) {
                                            GRCollectionGridTile(model: favModels[rowIndex * 2 + 1])
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct GRCollectionGridTile: View {
    let model: GRModelProfile
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(0.75, contentMode: .fit)
                    .cornerRadius(12)
                
                Image(model.imageNames.first ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    Text(model.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(model.agency)
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding()
                .shadow(radius: 5)
            }
        }
    }
}
