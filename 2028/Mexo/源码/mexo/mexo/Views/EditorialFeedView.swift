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
                VStack(spacing: 30) {
                    // Header / Masthead
                    VStack(spacing: 8) {
                        Text("MEXO")
                            .font(.system(size: 44, weight: .black, design: .serif))
                            .tracking(4)
                        
                        Text("PORTRAIT ESTHETICS MAGAZINE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        Divider()
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // Top Spotlight (Large Feature)
                    if let first = photos.first {
                        MagazineCardWrapper(photo: first, selectedPhoto: $selectedPhoto, showingUnlockAlert: $showingUnlockAlert) {
                            FeaturedMagazineCard(photo: first)
                        }
                    }
                    
                    // Regular Feed with staggered look
                    VStack(spacing: 40) {
                        ForEach(photos.dropFirst()) { photo in
                            MagazineCardWrapper(photo: photo, selectedPhoto: $selectedPhoto, showingUnlockAlert: $showingUnlockAlert) {
                                EditorialMagazineCard(photo: photo)
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
                if #available(iOS 14.0, *) {
                    StoreView()
                }
            }
        }
    }
    
    private func handlePhotoSelection(_ photo: PhotoModel) {
        if photo.isPremium && !storeManager.isContentUnlocked(id: photo.id) {
            selectedPhoto = photo
            showingUnlockAlert = true
        } else {
            // Already unlocked or free - let NavigationLink handle via Tag/Selection
            // Actually, simplified approach: we can use a Programmatic NavigationLink or just wrap the card in Button.
            // Let's use a hidden NavigationLink for simplicity.
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
                    .frame(height: 450)
                    .clipped()
                
                if #available(iOS 14.0, *) {
                    if photo.isPremium && !StoreManager.shared.isContentUnlocked(id: photo.id) {
                        PremiumLockOverlay(price: photo.coinPrice)
                    }
                } else {
                    // Fallback on earlier versions
                }
                
                // Issue Tag
                if #available(iOS 14.0, *) {
                    Text(photo.issueNumber.uppercased())
                        .font(.caption2)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .padding(20)
                } else {
                    // Fallback on earlier versions
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ForEach(photo.stylingTags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                
                Text(photo.title.uppercased())
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                
                Text(photo.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal)
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
                .frame(width: 150, height: 200)
                .cornerRadius(4)
                .clipped()
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
