import SwiftUI

@available(iOS 14.0, *)
struct InspirationsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Using a subset of items to mock a "Saved" collection
    let savedItems = [
        FashionItem(title: "Neon Pulse", subtitle: "2026 Couture", imageName: "Neon Pulse", description: "Saved on Oct 20, 2026"),
        FashionItem(title: "Cyber Bloom", subtitle: "Organic Tech", imageName: "Cyber Bloom", description: "Saved on Oct 21, 2026"),
        FashionItem(title: "Void Silk", subtitle: "Obsidian", imageName: "Void Silk", description: "Saved on Oct 22, 2026")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(NeonCouture.primary)
                }
                
                Spacer()
                
                Text("MY MOOD BOARD")
                    .font(.system(size: 18, weight: .black, design: .serif))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(NeonCouture.primary)
            }
            .padding()
            .background(Color.white)
            
            if savedItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No inspirations saved yet.")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Explore the gallery and heart your favorite pieces to build your digital mood board.")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                        ForEach(savedItems) { item in
                            VStack(alignment: .leading, spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.gray.opacity(0.1))
                                        .aspectRatio(1.0, contentMode: .fill)
                                    
                                    Image(item.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .aspectRatio(1.0, contentMode: .fill)
                                        .cornerRadius(15)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 14, weight: .bold))
                                    Text(item.subtitle)
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .background(NeonCouture.background.edgesIgnoringSafeArea(.all))
    }
}
