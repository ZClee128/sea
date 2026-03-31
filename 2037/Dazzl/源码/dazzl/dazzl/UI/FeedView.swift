import SwiftUI

@available(iOS 15.0, *)
struct FeedView: View {
    @EnvironmentObject var dataStore: MuseDataStore
    @State private var selectedCategory: MuseCategory = .ethereal
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category Picker
                    categoryPicker()
                        .padding(.vertical, 8)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(dataStore.muses.filter { $0.category == selectedCategory }) { muse in
                                NavigationLink(destination: MuseDetailView(muse: muse)) {
                                    MuseCard(muse: muse)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Dazzl Muses")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func categoryPicker() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MuseCategory.allCases) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? Color.white : Color.white.opacity(0.1))
                        .foregroundColor(selectedCategory == category ? Color.black : Color.white)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

@available(iOS 15.0, *)
struct MuseCard: View {
    let muse: Muse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: muse.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 220)
                        .overlay(ProgressView().tint(.white))
                }
                .cornerRadius(16)
                
                if muse.videoUrl != nil {
                    Image(systemName: "video.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            
            Text(muse.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(muse.category.rawValue)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
