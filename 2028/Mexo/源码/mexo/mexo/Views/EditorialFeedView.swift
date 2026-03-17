import SwiftUI

@available(iOS 14.0, *)
struct EditorialFeedView: View {
    let photos: [PhotoModel] = PhotoModel.mockData
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedPhoto: PhotoModel?
    @State private var showingUnlockAlert = false
    @State private var showingStore = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    // Header / Masthead
                    VStack(spacing: 8) {
                        Text("MEXO")
                            .font(.system(size: 48, weight: .black, design: .serif))
                            .italic()
                            .tracking(8)
                        
                        Text("PORTRAIT ESTHETICS MAGAZINE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(4)
                        
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.clear, .primary.opacity(0.3), .clear]), startPoint: .leading, endPoint: .trailing))
                            .frame(height: 1)
                            .padding(.horizontal, 60)
                    }
                    .padding(.top, 40)
                    
                    // Featured Carousel
                    VStack(alignment: .leading, spacing: 15) {
                        Text("FEATURED EDITORIALS")
                            .font(.system(size: 12, weight: .heavy))
                            .tracking(2)
                            .padding(.horizontal, 25)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(photos.prefix(2)) { photo in
                                    MagazineCardWrapper(photo: photo, selectedPhoto: $selectedPhoto, showingUnlockAlert: $showingUnlockAlert) {
                                        FeaturedMagazineCard(photo: photo)
                                            .frame(width: UIScreen.main.bounds.width - 50)
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                    }
                    
                    // Main Feed
                    VStack(alignment: .leading, spacing: 25) {
                        Text("LATEST ISSUES")
                            .font(.system(size: 12, weight: .heavy))
                            .tracking(2)
                            .padding(.horizontal, 25)
                        
                        VStack(spacing: 30) {
                            ForEach(photos.dropFirst(2)) { photo in
                                MagazineCardWrapper(photo: photo, selectedPhoto: $selectedPhoto, showingUnlockAlert: $showingUnlockAlert) {
                                    EditorialMagazineCard(photo: photo)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingUnlockAlert) {
                Alert(
                    title: Text("Unlock Content"),
                    message: Text("Would you like to unlock this premium magazine for \(selectedPhoto?.coinPrice ?? 0) coins?"),
                    primaryButton: .default(Text("Unlock")) {
                        if let photo = selectedPhoto {
                            if storeManager.unlockContent(id: photo.id, price: photo.coinPrice) {
                                // Success
                            } else {
                                showingStore = true
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingStore) {
                StoreView()
            }
        }
    }
}



struct PremiumLockOverlay: View {
    let price: Int
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                    Text("\(price)")
                        .fontWeight(.bold)
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(8)
            }
        }
    }
}

struct FeaturedMagazineCard: View {
    let photo: PhotoModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                Image(photo.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 500)
                    .clipped()
                
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                
                if #available(iOS 14.0, *) {
                    if photo.isPremium && !StoreManager.shared.isContentUnlocked(id: photo.id) {
                        PremiumLockOverlay(price: photo.coinPrice)
                    }
                }
                
                // Issue Tag
                if #available(iOS 14.0, *) {
                    Text(photo.issueNumber.uppercased())
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.7))
                        .overlay(Rectangle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                        .padding(25)
                }
            }
            .cornerRadius(0)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    ForEach(photo.stylingTags, id: \.self) { tag in
                        Text(tag.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                Text(photo.title.uppercased())
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                
                Text(photo.subtitle)
                    .font(.body)
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 25)
            .padding(.top, 10)
        }
    }
}

@available(iOS 14.0, *)
struct MagazineCardWrapper<Content: View>: View {
    let photo: PhotoModel
    @Binding var selectedPhoto: PhotoModel?
    @Binding var showingUnlockAlert: Bool
    let content: () -> Content
    
    @StateObject private var storeManager = StoreManager.shared
    @State private var navigateToDetail = false
    
    var body: some View {
        ZStack {
            // Invisible NavigationLink
            NavigationLink(destination: PhotoDetailView(photo: photo), isActive: $navigateToDetail) {
                EmptyView()
            }
            
            Button(action: {
                if photo.isPremium && !storeManager.isContentUnlocked(id: photo.id) {
                    selectedPhoto = photo
                    showingUnlockAlert = true
                } else {
                    navigateToDetail = true
                }
            }) {
                content()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct EditorialMagazineCard: View {
    let photo: PhotoModel
    
    var body: some View {
        HStack(spacing: 20) {
            Image(photo.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 180)
                .cornerRadius(2)
                .clipped()
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 2, y: 2)
                .overlay(
                    Group {
                        if #available(iOS 14.0, *) {
                            if photo.isPremium && !StoreManager.shared.isContentUnlocked(id: photo.id) {
                                PremiumLockOverlay(price: photo.coinPrice)
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                )
            
            VStack(alignment: .leading, spacing: 8) {
                if #available(iOS 14.0, *) {
                    Text(photo.category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                } else {
                    // Fallback on earlier versions
                }
                
                Text(photo.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(photo.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                Spacer()
                
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Pose Analysis")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct EditorialFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                EditorialFeedView()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
