import SwiftUI

@available(iOS 15.0, *)
struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject private var favManager = FavoritesManager.shared
    @ObservedObject private var coinManager = CoinManager.shared
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(recipe.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .clipped()
                        
                        if let fileName = recipe.videoURL,
                           let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                presentVideoFullscreen(url: url)
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                            }
                            .padding(20)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(recipe.title)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                        
                        Text(recipe.category.uppercased())
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundColor(.accentColor)
                        
                        ZStack {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(recipe.story)
                                    .font(.body)
                                    .lineSpacing(4)
                                
                                Divider()
                                
                                Text("Ingredients")
                                    .font(.headline)
                                
                                ForEach(recipe.ingredients, id: \.self) { ingredient in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                            .foregroundColor(.accentColor)
                                        Text(ingredient)
                                    }
                                }
                                
                                Divider()
                                
                                Text("How to Cook")
                                    .font(.headline)
                                
                                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top) {
                                        Text("\(index + 1).")
                                            .fontWeight(.bold)
                                            .foregroundColor(.accentColor)
                                        Text(step)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            .blur(radius: (recipe.isPremium && !CoinManager.shared.isUnlocked(recipe.id)) ? 8 : 0)
                            
                            if recipe.isPremium && !CoinManager.shared.isUnlocked(recipe.id) {
                                VStack(spacing: 20) {
                                    Image(systemName: "lock.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.yellow)
                                    
                                    Text("Premium Content")
                                        .font(.headline)
                                    
                                    Text("This exclusive recipe requires 30 coins to unlock forever.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                    
                                    Button(action: {
                                        let generator = UINotificationFeedbackGenerator()
                                        if CoinManager.shared.unlockRecipe(recipe.id) {
                                            generator.notificationOccurred(.success)
                                            alertMessage = "Unlock Successful!"
                                            showingAlert = true
                                        } else {
                                            generator.notificationOccurred(.error)
                                            alertMessage = "Not enough coins. Please top up in Settings."
                                            showingAlert = true
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "bitcoinsign.circle.fill")
                                            Text("Unlock for 30 Coins")
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 12)
                                        .background(Color.accentColor)
                                        .cornerRadius(25)
                                    }
                                    
                                    if CoinManager.shared.balance < 30 {
                                        Text("Not enough coins! Buy more in Settings.")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.systemBackground).opacity(0.8))
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // Floating Chat Button
            NavigationLink(destination: ChatView(chefName: recipe.chefName)) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("Chat with \(recipe.chefName)")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(30)
                .shadow(radius: 10)
            }
            .padding(25)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarItems(trailing: Button(action: {
            favManager.toggle(recipe)
        }) {
            Image(systemName: favManager.isFavorite(recipe) ? "heart.fill" : "heart")
                .foregroundColor(.red)
        })
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            RecipeDetailView(recipe: RecipeData.samples[0])
        } else {
            // Fallback on earlier versions
        }
    }
}
