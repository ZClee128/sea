import SwiftUI

@available(iOS 15.0, *)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Insights")
                }
                .tag(0)
            
            FocusView()
                .tabItem {
                    Image(systemName: "sparkle")
                    Text("Focus")
                }
                .tag(1)
            
            ChatListView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Connect")
                }
                .tag(2)
            
            StudioTabView()
                .tabItem {
                    Image(systemName: "paintpalette.fill")
                    Text("Studio")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.black)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenStudioWithMuse"))) { _ in
            selectedTab = 3
        }
    }
}

@available(iOS 15.0, *)
struct StudioTabView: View {
    @ObservedObject var assetManager = AssetManager()
    @ObservedObject var storeManager = StoreManager.shared
    @StateObject var archiveManager = ArchiveManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // STORE BALANCE HEADER
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Studio Balance")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "circle.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(storeManager.coinBalance) coins")
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                            }
                        }
                        Spacer()
                        
                        NavigationLink(destination: CoinShopView()) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.6))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // QUICK START CARDS
                    Text("Digital Workshop")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        // NEW: Optical Analysis Lab
                        if #available(iOS 16.0, *) {
                            NavigationLink(destination: AestheticScannerView()) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("NEW UTILITY")
                                                .font(.system(size: 10, weight: .black))
                                                .tracking(2)
                                                .foregroundColor(.blue.opacity(0.8))
                                            
                                            Text("Aesthetic Lab")
                                                .font(.system(size: 22, weight: .bold, design: .serif))
                                                .foregroundColor(.white)
                                        }
                                        Spacer()
                                        Image(systemName: "sensor.tag.radiowaves.forward.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("A bespoke optical scanner to deconstruct the Color DNA and structural alignment of your photos.")
                                        .font(.system(size: 14, design: .serif))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(24)
                                .background(
                                    LinearGradient(colors: [Color(hex: "#1A1A1A"), Color(hex: "#333333")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(24)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                            .padding(.bottom, 10)
                        } else {
                            // Fallback on earlier versions
                        }

                        // Lock Screen Card
                        NavigationLink(destination: WallPreviewView()) {
                            StudioCard(
                                title: "Lock Screen Studio",
                                subtitle: "Craft aesthetic wallpapers",
                                icon: "iphone",
                                color: .purple
                            )
                        }
                        
                        // Inspo Card Card
                        if #available(iOS 16.0, *) {
                            NavigationLink(destination: InspoCardView()) {
                                StudioCard(
                                    title: "Inspo Card Studio",
                                    subtitle: "Generate artistic compositions",
                                    icon: "quote.bubble.fill",
                                    color: .blue
                                )
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        // NEW: Moodboard Lab
                        if #available(iOS 16.0, *) {
                            NavigationLink(destination: MoodboardLabView()) {
                                StudioCard(
                                    title: "Moodboard Laboratory",
                                    subtitle: "Free-form visual storytelling",
                                    icon: "square.grid.2x2.fill",
                                    color: .pink
                                )
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        // NEW: Color Story Generator
                        NavigationLink(destination: ColorStoryView()) {
                            StudioCard(
                                title: "Color Story Generator",
                                subtitle: "Aesthetic palette deconstruction",
                                icon: "paintpalette.fill",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // AESTHETIC ARCHIVES
                    if !archiveManager.archives.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Aesthetic Archives")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(archiveManager.archives) { archive in
                                        ArchiveFolderView(archive: archive)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 24)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle("Creative Studio")
            .navigationBarHidden(true)
        }
    }
}

// ARCHIVE PREVIEW COMPONENT
@available(iOS 14.0, *)
struct ArchiveFolderView: View {
    let archive: MoodboardArchive
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading) {
                ZStack {
                    // Stacked effect
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .offset(y: -4)
                        .scaleEffect(0.95)
                    
                    // Main Preview (Grid of items)
                    let totalItems = archive.muses.count + (archive.localImagePaths?.count ?? 0)
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            if totalItems > 0 { ArchiveItemBox(archive: archive, index: 0, size: 60) }
                            if totalItems > 1 { ArchiveItemBox(archive: archive, index: 1, size: 60) }
                        }
                        HStack(spacing: 2) {
                            if totalItems > 2 { ArchiveItemBox(archive: archive, index: 2, size: 60) }
                            if totalItems > 3 { ArchiveItemBox(archive: archive, index: 3, size: 60) }
                        }
                    }
                    .cornerRadius(8)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4)
                }
                .frame(width: 130, height: 130)
                
                Text(archive.keywords.prefix(15) + (archive.keywords.count > 15 ? "..." : ""))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(archive.date, style: .date)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingDetail) {
            if #available(iOS 15.0, *) {
                ArchiveDetailView(archive: archive)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

// HELPER FOR LOADING ASSET OR LOCAL DISK IMAGE
struct ArchiveItemBox: View {
    let archive: MoodboardArchive
    let index: Int
    let size: CGFloat
    
    var body: some View {
        Group {
            if index < archive.muses.count {
                // System Muse Image
                Image(archive.muses[index].imageName)
                    .resizable()
                    .scaledToFill()
            } else if let localPaths = archive.localImagePaths, 
                      (index - archive.muses.count) < localPaths.count {
                // Local Uploaded Image
                let path = localPaths[index - archive.muses.count]
                if #available(iOS 15.0, *) {
                    let url = ArchiveManager.shared.getURLForLocalImage(path)
                    if let uiImage = UIImage(contentsOfFile: url.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.1)
                    }
                } else {
                    // Fallback on earlier versions
                }
            } else {
                // Placeholder
                Color.gray.opacity(index == 0 ? 0.2 : 0.1)
                    .overlay(
                        Group {
                            if index == 0 {
                                if #available(iOS 14.0, *) {
                                    Image(systemName: "photo")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        }
                    )
            }
        }
        .frame(width: size, height: size)
        .frame(maxWidth: size == 60 ? 60 : .infinity) // Specific for folder preview vs detail
        .clipped()
    }
}

@available(iOS 15.0, *)
struct ArchiveDetailView: View {
    let archive: MoodboardArchive
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    let totalItems = archive.muses.count + (archive.localImagePaths?.count ?? 0)
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            if totalItems > 0 { ArchiveItemBox(archive: archive, index: 0, size: 200) }
                            if totalItems > 1 { ArchiveItemBox(archive: archive, index: 1, size: 200) }
                        }
                        HStack(spacing: 4) {
                            if totalItems > 2 { ArchiveItemBox(archive: archive, index: 2, size: 150) }
                            if totalItems > 3 { ArchiveItemBox(archive: archive, index: 3, size: 150) }
                        }
                        
                        if totalItems == 0 {
                            VStack(spacing: 20) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.4))
                                Text("Aesthetic Session Recorded")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 350)
                            .background(Color(.systemGray6))
                        }
                    }
                    .cornerRadius(20)
                    .padding()
                    
                    VStack(spacing: 12) {
                        Text(archive.keywords.uppercased())
                            .font(.system(size: 24, weight: .black, design: .serif))
                            .tracking(8)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Captured on \(archive.date.formatted(date: .long, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Aesthetic Archive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct StudioCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(15)
                .background(Circle().fill(Color.white.opacity(0.2)))
        }
        .padding(24)
        .background(
            LinearGradient(colors: [color.opacity(0.8), color], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

@available(iOS 15.0, *)
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
