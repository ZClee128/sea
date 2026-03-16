import SwiftUI

struct PortraitDetailView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    let portrait: Portrait
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero Image
                Image(portrait.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(0)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(portrait.title)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                            
                            Text(portrait.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            favoritesManager.toggleFavorite(id: portrait.id)
                        }) {
                            if #available(iOS 14.0, *) {
                                Image(systemName: favoritesManager.isFavorite(id: portrait.id) ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(favoritesManager.isFavorite(id: portrait.id) ? .red : .black)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Concept Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb")
                            Text("The Concept")
                                .font(.headline)
                        }
                        
                        Text(portrait.concept)
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    
                    // Mastery Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera")
                            Text("Technical Mastery")
                                .font(.headline)
                        }
                        
                        Text(portrait.mastery)
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                    }
                }
                .padding(24)
            }
        }
    }
}

struct PortraitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PortraitDetailView(portrait: ZayoData.portraits[0])
                .environmentObject(FavoritesManager())
        }
    }
}
