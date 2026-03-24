import SwiftUI

@available(iOS 14.0, *)
struct FashionDetailView: View {
    let item: FashionItem
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isAddedToInspirations = false
    @State private var showAddedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Large Image Header
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(LinearGradient(gradient: Gradient(colors: [NeonCouture.primary, NeonCouture.secondary]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .aspectRatio(0.8, contentMode: .fill)
                        .overlay(
                            Image(item.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        )
                    
                    // Custom Back Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(.top, 50)
                    .padding(.leading, 20)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Titles
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title.uppercased())
                                .font(.system(size: 32, weight: .black, design: .serif))
                                .foregroundColor(.black)
                            
                            Text(item.subtitle)
                                .font(.headline)
                                .foregroundColor(NeonCouture.secondary)
                        }
                        
                        Spacer()
                        
                        // Designer Chat Button
                        NavigationLink(destination: DesignerChatView()) {
                            VStack(spacing: 4) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.title3)
                                Text("CHAT")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(NeonCouture.primary)
                            .padding(12)
                            .background(Circle().stroke(NeonCouture.primary.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Divider()
                        .background(NeonCouture.primary.opacity(0.2))
                    
                    // Description
                    Text("THE STORY")
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Text(item.description)
                        .font(.body)
                        .lineSpacing(6)
                        .foregroundColor(.black.opacity(0.8))
                    
                    // Interaction Section (Style Tips)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("STYLE NOTES")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            StyleTag(text: "Futuristic")
                            StyleTag(text: "Editorial")
                            StyleTag(text: "High-Tech")
                        }
                    }
                    .padding(.top, 10)
                    
                    // Action Button
                    Button(action: {
                        isAddedToInspirations.toggle()
                        if isAddedToInspirations {
                            showAddedAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: isAddedToInspirations ? "heart.fill" : "heart")
                            Text(isAddedToInspirations ? "ADDED TO INSPIRATIONS" : "ADD TO INSPIRATIONS")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(isAddedToInspirations ? NeonCouture.secondary : NeonCouture.primary)
                                .neonGlow(color: isAddedToInspirations ? NeonCouture.secondary : NeonCouture.primary)
                        )
                    }
                    .padding(.top, 20)
                    .alert(isPresented: $showAddedAlert) {
                        Alert(
                            title: Text("Inspiration Saved"),
                            message: Text("\(item.title) has been added to your digital mood board."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .padding(24)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .background(NeonCouture.background.ignoresSafeArea(.all, edges: .top))
    }
}

struct StyleTag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().stroke(NeonCouture.secondary.opacity(0.5), lineWidth: 1))
            .foregroundColor(NeonCouture.secondary)
    }
}
