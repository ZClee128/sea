import SwiftUI
import Combine

struct StyleBoardView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var favoritePortraits: [Portrait] {
        ZayoData.portraits.filter { favoritesManager.isFavorite(id: $0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if favoritePortraits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("Your Style Board is empty")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Discover portraits in the Gallery and tap the heart to save your favorites here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        if #available(iOS 14.0, *) {
                            LazyVStack(spacing: 24) {
                                ForEach(favoritePortraits) { portrait in
                                    NavigationLink(destination: PortraitDetailView(portrait: portrait)) {
                                        PortraitCard(portrait: portrait)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 24)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
            }
            .navigationBarTitle("Style Board", displayMode: .inline)
        }
    }
}

struct StyleBoardView_Previews: PreviewProvider {
    static var previews: some View {
        StyleBoardView()
            .environmentObject(FavoritesManager())
    }
}
