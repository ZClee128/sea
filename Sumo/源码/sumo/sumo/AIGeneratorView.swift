import SwiftUI

@available(iOS 15.0, *)
struct AIGeneratorView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var promptText = ""
    @State private var isGenerating = false
    @State private var generatedImageUrl: String? = nil
    @State private var showSavedAlert = false
    
    // Simulate generation with a random new image matching the prompt
    func generateImage() {
        guard !promptText.isEmpty else { return }
        
        isGenerating = true
        generatedImageUrl = nil
        
        // Use pollinations.ai to generate an image based on the prompt text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let encodedPrompt = self.promptText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "fashion"
            // image.pollinations.ai generates images on the fly based on the path
            let randomSeed = Int.random(in: 1...100000)
            self.generatedImageUrl = "https://image.pollinations.ai/prompt/\(encodedPrompt)?width=800&height=1200&seed=\(randomSeed)&nologo=true"
            self.isGenerating = false
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    Text("AI Look Generator")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .padding(.top)
                    
                    Text("Describe your dream outfit and our AI will render it for your Wardrobe.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Prompt")
                            .font(.headline)
                        
                        TextEditor(text: $promptText)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Suggestion Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(["Cyberpunk Y2K", "Vintage 90s skater", "Techwear Ninja", "Minimalist Suit"], id: \.self) { suggestion in
                                    Button(action: {
                                        promptText = suggestion
                                    }) {
                                        Text(suggestion)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.secondary.opacity(0.15))
                                            .foregroundColor(.primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    
                    Button(action: generateImage) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Generating...")
                                    .fontWeight(.bold)
                            } else {
                                Image(systemName: "wand.and.stars")
                                Text("Generate")
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(promptText.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(promptText.isEmpty || isGenerating)
                    .padding(.horizontal)
                    
                    // Result Area
                    if let imageUrl = generatedImageUrl {
                        VStack(spacing: 16) {
                            Text("Your Generated Look")
                                .font(.headline)
                            
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Rectangle().fill(Color.gray.opacity(0.2))
                                        .overlay(ProgressView())
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width - 32, height: (UIScreen.main.bounds.width - 32) * 1.5)
                            .cornerRadius(16)
                            .clipped()
                            .shadow(radius: 10)
                            
                            Button(action: {
                                if let url = generatedImageUrl {
                                    // Create a new look from the AI-generated image
                                    let newLookId = UUID().uuidString
                                    let generatedLook = Look(
                                        id: newLookId,
                                        author: "AI Generation",
                                        authorAvatar: "https://picsum.photos/seed/aiavatar/200/200",
                                        description: "Prompt: \(promptText)",
                                        category: .techwear,
                                        mediaItems: [MediaItem(type: .image, urlString: url, localImageName: nil, localVideoName: nil, coverImageName: nil, aspectRatio: 0.67)],
                                        likes: Int.random(in: 10...500),
                                        isVideoCover: false
                                    )
                                    // Append to in-memory list AND persist so it survives restarts
                                    MockData.looks.append(generatedLook)
                                    appState.saveAIGeneratedLook(generatedLook)
                                    appState.savedLookIDs.insert(newLookId)
                                    showSavedAlert = true
                                }
                            }) {
                                Label("Save to Wardrobe", systemImage: "square.and.arrow.down")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .alert(isPresented: $showSavedAlert) {
                                Alert(title: Text("Saved!"), message: Text("The AI generated look has been added to your Wardrobe."), dismissButton: .default(Text("OK")))
                            }
                        }
                        .padding()
                        .transition(.opacity)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
