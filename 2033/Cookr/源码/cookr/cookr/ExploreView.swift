import SwiftUI

// Cuisine categories
struct CuisineCategory: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
    let recipes: [Recipe]
}

@available(iOS 14.0, *)
struct ExploreView: View {
    let categories: [CuisineCategory] = [
        CuisineCategory(name: "Italian", emoji: "🍝", color: Color.orange,
                        recipes: RecipeData.samples.filter { $0.category == "Main Course" }),
        CuisineCategory(name: "Desserts", emoji: "🍰", color: Color.pink,
                        recipes: RecipeData.samples.filter { $0.category == "Dessert" }),
        CuisineCategory(name: "Healthy", emoji: "🥗", color: Color.green,
                        recipes: RecipeData.samples.filter { $0.category == "Healthy Main" }),
        CuisineCategory(name: "All Recipes", emoji: "🌍", color: Color.blue,
                        recipes: RecipeData.samples),
    ]
    
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty { return RecipeData.samples }
        return RecipeData.samples.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Search bar with dismiss button
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        if #available(iOS 15.0, *) {
                            TextField("Search recipes...", text: $searchText)
                                .onSubmit { hideKeyboard() }
                        } else {
                            // Fallback on earlier versions
                        }
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                hideKeyboard()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    if searchText.isEmpty {
                        // Categories
                        Text("Browse by Category")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(categories) { category in
                                NavigationLink(destination: CategoryRecipesView(category: category)) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(category.color.opacity(0.15))
                                        VStack(spacing: 8) {
                                            Text(category.emoji)
                                                .font(.system(size: 44))
                                            Text(category.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            Text("\(category.recipes.count) recipes")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 20)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Search results
                        Text("\(filteredRecipes.count) results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        ForEach(filteredRecipes) { recipe in
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
                }
                .padding(.top)
                .padding(.bottom, 30)
            }
            .onTapGesture { hideKeyboard() }
            .navigationTitle("Explore")
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

@available(iOS 14.0, *)
struct CategoryRecipesView: View {
    let category: CuisineCategory
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(category.recipes) { recipe in
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
        .navigationTitle(category.name)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View { if #available(iOS 14.0, *) {
        ExploreView()
    } else {
        // Fallback on earlier versions
    } }
}
