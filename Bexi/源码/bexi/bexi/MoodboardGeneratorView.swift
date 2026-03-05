import SwiftUI

struct MoodboardGeneratorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storageManager: StorageManager
    
    @State private var selectedItems: Set<UUID> = []
    @State private var generatedImage: UIImage? = nil
    @State private var showingCoinAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if generatedImage != nil {
                    // Step 2: Show result
                    Image(uiImage: generatedImage!)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    Button(action: {
                        saveToPhotos()
                    }) {
                        Text("Save to Photos")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
                    
                } else {
                    // Step 1: Pick items
                    Text("Select 2 to 4 images to create a Moodboard")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(chunked(items: storageManager.savedItems, into: 3), id: \.self.description) { chunk in
                                HStack(spacing: 10) {
                                    ForEach(chunk) { item in
                                        ZStack(alignment: .topTrailing) {
                                            RemoteImage(urlString: item.urlString)
                                                .aspectRatio(1, contentMode: .fill)
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .clipped()
                                                .cornerRadius(8)
                                                .opacity(selectedItems.contains(item.id) ? 0.7 : 1.0)
                                                .onTapGesture {
                                                    toggleSelection(item.id)
                                                }
                                            
                                            if selectedItems.contains(item.id) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .padding(6)
                                                    .background(Circle().fill(Color.white))
                                                    .padding(4)
                                            }
                                        }
                                    }
                                    if chunk.count < 3 {
                                        ForEach(0..<(3 - chunk.count), id: \.self) { _ in
                                            Color.clear.frame(minWidth: 0, maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Button(action: {
                        if storageManager.coins >= 10 {
                            generateMoodboard()
                        } else {
                            showingCoinAlert = true
                        }
                    }) {
                        Text("Generate (Cost: 10 Coins)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedItems.count >= 2 && selectedItems.count <= 4 ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(selectedItems.count < 2 || selectedItems.count > 4)
                    .padding()
                }
            }
            .navigationBarTitle("Moodboard", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $showingCoinAlert) {
                Alert(
                    title: Text("Not Enough Coins"),
                    message: Text("Generating a moodboard costs 10 coins. Please recharge in the Profile tab."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func toggleSelection(_ id: UUID) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            if selectedItems.count < 4 {
                selectedItems.insert(id)
            }
        }
    }
    
    private func chunked(items: [MediaItem], into size: Int) -> [[MediaItem]] {
        stride(from: 0, to: items.count, by: size).map {
            Array(items[$0 ..< Swift.min($0 + size, items.count)])
        }
    }
    
    private func generateMoodboard() {
        // Find selected urls
        let urls = storageManager.savedItems
            .filter { selectedItems.contains($0.id) }
            .map { $0.urlString }
            
        // Download these specific images synchronously just for collage (simplification)
        // In a real app we would show a loading spinner while downloading.
        DispatchQueue.global(qos: .userInitiated).async {
            var images: [UIImage] = []
            for urlString in urls {
                // Check local assets first
                if let localImg = UIImage(named: urlString) {
                    images.append(localImg)
                } else if let url = URL(string: urlString), let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    // Fallback to network download
                    images.append(img)
                }
            }
            
            guard !images.isEmpty else { return }
            
            // Simple grid stitch horizontally
            let width = images.reduce(CGFloat(0)) { $0 + $1.size.width }
            let height = images.map { $0.size.height }.max() ?? 0
            let finalSize = CGSize(width: width, height: height + 100)
            
            UIGraphicsBeginImageContextWithOptions(finalSize, false, 0.0)
            
            var currentX: CGFloat = 0
            for img in images {
                img.draw(in: CGRect(x: currentX, y: 0, width: img.size.width, height: img.size.height))
                currentX += img.size.width
            }
            
            // Draw watermark
            let text = "Bexi Moodboard" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            text.draw(at: CGPoint(x: (finalSize.width - textSize.width) / 2, y: finalSize.height - 80), withAttributes: attributes)
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                self.storageManager.coins -= 10
                self.generatedImage = result
            }
        }
    }
    
    private func saveToPhotos() {
        if let image = generatedImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            // Register it in the app's local storage to reflect in Profile count
            let selectedMediaItems = storageManager.savedItems.filter { selectedItems.contains($0.id) }
            let newMoodboard = Moodboard(title: "My Moodboard", items: selectedMediaItems)
            storageManager.saveMoodboard(newMoodboard)
            
            presentationMode.wrappedValue.dismiss()
        }
    }
}
