import SwiftUI

@available(iOS 14.0, *)
struct FavoritesView: View {
    @ObservedObject private var manager = FavoritesManager.shared
    
    var body: some View {
        NavigationView {
            Group {
                if manager.favorites.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No favorites yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Tap the heart icon on any recipe\nto save it here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(manager.favorites) { recipe in
                                if #available(iOS 15.0, *) {
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeRow(recipe: recipe)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    private let key = "favoriteTitles"

    @Published var favorites: [Recipe] = []

    private init() {
        // Restore from UserDefaults on launch
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        favorites = RecipeData.samples.filter { saved.contains($0.title) }
    }

    func toggle(_ recipe: Recipe) {
        if isFavorite(recipe) {
            favorites.removeAll { $0.title == recipe.title }
        } else {
            favorites.append(recipe)
        }
        save()
    }

    func isFavorite(_ recipe: Recipe) -> Bool {
        favorites.contains(where: { $0.title == recipe.title })
    }

    private func save() {
        UserDefaults.standard.set(favorites.map { $0.title }, forKey: key)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View { if #available(iOS 14.0, *) {
        FavoritesView()
    } else {
        // Fallback on earlier versions
    } }
}
