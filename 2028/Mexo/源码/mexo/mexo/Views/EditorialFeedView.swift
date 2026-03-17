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
            ZStack {
                DesignTokens.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Header / Masthead
                        VStack(spacing: 8) {
                            Text("MEXO")
                                .font(.system(size: 64, weight: .black, design: .serif))
                                .italic()
                                .tracking(12)
                                .foregroundColor(DesignTokens.Colors.primary)
                            
                            Text("PORTRAIT AESTHETICS MAGAZINE")
                                .font(DesignTokens.Typography.caption())
                                .fontWeight(.bold)
                                .foregroundColor(DesignTokens.Colors.accent)
                                .tracking(6)
                            
                            DesignTokens.Colors.accent
                                .frame(width: 80, height: 2)
                                .padding(.top, 10)
                        }
                        .padding(.top, 60)
                        
                        // Featured Section
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("FEATURED EDITORIALS")
                                    .font(DesignTokens.Typography.caption())
                                    .fontWeight(.heavy)
                                    .tracking(2)
                                    .foregroundColor(DesignTokens.Colors.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 25)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 25) {
                                    ForEach(photos.prefix(3)) { photo in
                                        MagazineCardWrapper(photo: photo, selectedPhoto: $selectedPhoto, showingUnlockAlert: $showingUnlockAlert) {
                                            PremiumFeaturedCard(photo: photo)
                                        }
                                    }
                                }
                                .padding(.horizontal, 25)
                            }
                        }
                        
                        // Latest Issues Grid
                        VStack(alignment: .leading, spacing: 30) {
                            Text("LATEST ISSUES")
                                .font(DesignTokens.Typography.caption())
                                .fontWeight(.heavy)
                                .tracking(2)
                                .foregroundColor(DesignTokens.Colors.secondary)
                                .padding(.horizontal, 25)
                            
                            LazyVStack(spacing: 40) {
                                ForEach(photos.dropFirst(3)) { photo in
                                    MagazineCardWrapper(photo: photo, selectedPhoto: $selectedPhoto, showingUnlockAlert: $showingUnlockAlert) {
                                        PremiumEditorialCard(photo: photo)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingUnlockAlert) {
                Alert(
                    title: Text("Unlock Premium Content"),
                    message: Text("Access this exclusive editorial for \(selectedPhoto?.coinPrice ?? 0) coins."),
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

@available(iOS 14.0, *)
struct PremiumFeaturedCard: View {
    let photo: PhotoModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ZStack(alignment: .bottomLeading) {
                Image(photo.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 320, height: 450)
                    .clipped()
                
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(photo.issueNumber.uppercased())
                        .font(DesignTokens.Typography.caption(10))
                        .fontWeight(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignTokens.Colors.accent)
                        .foregroundColor(.white)
                    
                    Text(photo.title.uppercased())
                        .font(DesignTokens.Typography.title(24))
                        .foregroundColor(.white)
                }
                .padding(20)
                
                if photo.isPremium && !StoreManager.shared.isContentUnlocked(id: photo.id) {
                    VStack {
                        HStack {
                            Spacer()
                            PremiumLockTag(price: photo.coinPrice)
                        }
                        Spacer()
                    }
                    .padding(15)
                }
            }
            .cornerRadius(0)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 15)
        }
    }
}

@available(iOS 14.0, *)
struct PremiumEditorialCard: View {
    let photo: PhotoModel
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack(alignment: .topTrailing) {
                Image(photo.imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 200)
                    .clipped()
                    .cornerRadius(4)
                
                if photo.isPremium && !StoreManager.shared.isContentUnlocked(id: photo.id) {
                    PremiumLockTag(price: photo.coinPrice)
                        .padding(8)
                }
            }
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(photo.category.uppercased())
                    .font(DesignTokens.Typography.caption(10))
                    .fontWeight(.bold)
                    .foregroundColor(DesignTokens.Colors.accent)
                
                Text(photo.title)
                    .font(DesignTokens.Typography.headline(20))
                    .foregroundColor(DesignTokens.Colors.primary)
                    .lineLimit(2)
                
                Text(photo.subtitle)
                    .font(DesignTokens.Typography.body(14))
                    .foregroundColor(DesignTokens.Colors.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Label("View Analysis", systemImage: "sparkles")
                        .font(DesignTokens.Typography.caption(11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(DesignTokens.Colors.accent)
                        .cornerRadius(20)
                }
            }
            .padding(.vertical, 5)
            
            Spacer()
        }
        .padding(.horizontal, 25)
    }
}

@available(iOS 14.0, *)
struct PremiumLockTag: View {
    let price: Int
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
            Text("\(price)")
                .fontWeight(.bold)
        }
        .font(.system(size: 10))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight))
        .foregroundColor(DesignTokens.Colors.accent)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.1), radius: 5)
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

@available(iOS 14.0, *)
struct EditorialFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EditorialFeedView()
    }
}
