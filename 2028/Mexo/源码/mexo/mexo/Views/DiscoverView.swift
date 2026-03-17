import SwiftUI

@available(iOS 14.0, *)
struct DiscoverView: View {
    let photos: [PhotoModel] = PhotoModel.mockData
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("EXPLORE COLLECTIONS")
                            .font(DesignTokens.Typography.caption())
                            .fontWeight(.heavy)
                            .tracking(2)
                            .foregroundColor(DesignTokens.Colors.secondary)
                            .padding(.horizontal, 25)
                            .padding(.top, 20)
                            
                        LazyVGrid(columns: columns, spacing: 25) {
                            ForEach(photos) { photo in
                                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                    PremiumPhotoCard(photo: photo)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

@available(iOS 14.0, *)
struct PremiumPhotoCard: View {
    let photo: PhotoModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                Image(photo.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .cornerRadius(8)
                    .clipped()
                
                if photo.isPremium && !StoreManager.shared.isContentUnlocked(id: photo.id) {
                    PremiumLockTag(price: photo.coinPrice)
                        .padding(8)
                }
            }
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(photo.category.uppercased())
                    .font(DesignTokens.Typography.caption(9))
                    .fontWeight(.bold)
                    .foregroundColor(DesignTokens.Colors.accent)
                
                Text(photo.title)
                    .font(DesignTokens.Typography.headline(14))
                    .foregroundColor(DesignTokens.Colors.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
    }
}

@available(iOS 14.0, *)
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
