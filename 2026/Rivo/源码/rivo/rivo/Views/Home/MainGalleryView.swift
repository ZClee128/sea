import SwiftUI

struct MainGalleryView: View {
    @ObservedObject private var data = DanceData()
    @State private var selectedCategory: String = "All"
    
    let categories = ["All", "Ballet", "Contemporary", "Street"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? Color.blue : Color(UIColor.secondarySystemBackground))
                                    .foregroundColor(selectedCategory == cat ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                // Grid (iOS 13 Compatible)
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<(filteredMoves.count + 1) / 2, id: \.self) { rowIndex in
                            HStack(spacing: 16) {
                                NavigationLink(destination: DanceDetailView(move: filteredMoves[rowIndex * 2])) {
                                    GalleryItemView(move: filteredMoves[rowIndex * 2])
                                }
                                
                                if rowIndex * 2 + 1 < filteredMoves.count {
                                    NavigationLink(destination: DanceDetailView(move: filteredMoves[rowIndex * 2 + 1])) {
                                        GalleryItemView(move: filteredMoves[rowIndex * 2 + 1])
                                    }
                                } else {
                                    Spacer()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Rivo Inspiration", displayMode: .inline)
        }
    }
    
    var filteredMoves: [DanceMove] {
        if selectedCategory == "All" {
            return data.moves
        }
        return data.moves.filter { $0.category == selectedCategory }
    }
}

struct GalleryItemView: View {
    let move: DanceMove

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                // Actual Image
                Image(move.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
                    .background(Color(UIColor.secondarySystemBackground))
                
                // Gradient for text visibility
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(move.category)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Text(move.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(12)
            }
        }
    }
}
