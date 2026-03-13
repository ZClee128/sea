import SwiftUI

struct DetailView: View {
    @ObservedObject var appState: AppState
    let picture: PictureModel
    @State private var showingPalette = false
    
    var isFavorite: Bool {
        appState.favoriteItems.contains(picture.id)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Main Image
                Image(picture.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 500)
                    .clipped()
                    .cornerRadius(15)
                    .padding()
                
                // Content area
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        if #available(iOS 14.0, *) {
                            Text(picture.styleTag)
                                .font(.title2)
                                .fontWeight(.bold)
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            toggleFavorite()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isFavorite ? .red : .gray)
                        }
                    }
                    
                    // Anti 4.2 Minimum Functionality Feature: Palette Tool
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Makeup & Inspiration Tools")
                            .font(.headline)
                        
                        Button(action: {
                            withAnimation {
                                showingPalette.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "paintpalette.fill")
                                Text(showingPalette ? "Hide Makeup Palette" : "Get Makeup Palette")
                                Spacer()
                                Image(systemName: showingPalette ? "chevron.up" : "chevron.down")
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                        
                        if showingPalette {
                            HStack {
                                VStack {
                                    Circle()
                                        .fill(Color(hex: picture.lipColorHex))
                                        .frame(width: 50, height: 50)
                                    Text("Primary Lip")
                                        .font(.caption)
                                }
                                
                                VStack {
                                    Circle()
                                        .fill(Color(hex: "F5DEB3"))
                                        .frame(width: 50, height: 50)
                                    Text("Skin Base")
                                        .font(.caption)
                                }
                                
                                VStack {
                                    Circle()
                                        .fill(Color(hex: "8B4513"))
                                        .frame(width: 50, height: 50)
                                    Text("Contour")
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .cornerRadius(10)
                            .transition(.opacity)
                        }
                    }
                    
                    Text("This detailed lookbook entry serves as a reference for hairstyle and makeup application techniques. Practice matching these tones for optimal results.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                    
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("Details", displayMode: .inline)
    }
    
    private func toggleFavorite() {
        var items = appState.favoriteItems
        if let index = items.firstIndex(of: picture.id) {
            items.remove(at: index)
        } else {
            items.append(picture.id)
        }
        appState.favoriteItems = items
    }
}

// Helper for Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
