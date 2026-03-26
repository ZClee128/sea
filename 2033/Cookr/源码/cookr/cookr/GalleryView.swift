import SwiftUI
struct GalleryView: View {
    @ObservedObject private var coinManager = CoinManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Cookr")
                            .font(.system(size: 40, weight: .black, design: .serif))
                            .foregroundColor(.primary)
                        Text("Global Gastronomy Insight")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    ForEach(RecipeData.samples) { recipe in
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
                .padding(.bottom, 30)
            }
            .navigationBarTitle("Discover", displayMode: .inline)
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // In a real app we'd load from Assets or Bundle
            // For now, we'll try to load from the Images folder
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 220)
                .clipped()
                .cornerRadius(16)
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            if recipe.isPremium && !CoinManager.shared.isUnlocked(recipe.id) {
                                if #available(iOS 14.0, *) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                        .padding(4)
                                        .background(Color.black.opacity(0.6))
                                        .foregroundColor(.yellow)
                                        .cornerRadius(4)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                            
                            if #available(iOS 14.0, *) {
                                Text(recipe.category.uppercased())
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        Spacer()
                    }
                    .padding(12)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                if #available(iOS 14.0, *) {
                    Text(recipe.title)
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.bold)
                } else {
                    // Fallback on earlier versions
                }

                Text(recipe.story)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal)
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
