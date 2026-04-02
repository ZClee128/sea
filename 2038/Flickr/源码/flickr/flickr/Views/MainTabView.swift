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
                        NavigationLink(destination: InspoCardView()) {
                            StudioCard(
                                title: "Inspo Card Studio",
                                subtitle: "Generate artistic compositions",
                                icon: "quote.bubble.fill",
                                color: .blue
                            )
                        }
                        
                        // NEW: Moodboard Lab
                        NavigationLink(destination: MoodboardLabView()) {
                            StudioCard(
                                title: "Moodboard Laboratory",
                                subtitle: "Free-form visual storytelling",
                                icon: "square.grid.2x2.fill",
                                color: .pink
                            )
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
                    if !ArchiveManager.shared.archives.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Aesthetic Archives")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(ArchiveManager.shared.archives) { archive in
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
                    
                    // Main Preview (Grid of 4)
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            Image(archive.muses[0].imageName).resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                            if archive.muses.count > 1 {
                                Image(archive.muses[1].imageName).resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                            }
                        }
                        HStack(spacing: 2) {
                            if archive.muses.count > 2 {
                                Image(archive.muses[2].imageName).resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                            }
                            if archive.muses.count > 3 {
                                Image(archive.muses[3].imageName).resizable().scaledToFill().frame(width: 60, height: 60).clipped()
                            }
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

@available(iOS 15.0, *)
struct ArchiveDetailView: View {
    let archive: MoodboardArchive
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(archive.muses[0].imageName).resizable().scaledToFill().frame(maxWidth: .infinity).frame(height: 200).clipped()
                            if archive.muses.count > 1 {
                                Image(archive.muses[1].imageName).resizable().scaledToFill().frame(maxWidth: .infinity).frame(height: 200).clipped()
                            }
                        }
                        HStack(spacing: 4) {
                            if archive.muses.count > 2 {
                                Image(archive.muses[2].imageName).resizable().scaledToFill().frame(maxWidth: .infinity).frame(height: 150).clipped()
                            }
                            if archive.muses.count > 3 {
                                Image(archive.muses[3].imageName).resizable().scaledToFill().frame(maxWidth: .infinity).frame(height: 150).clipped()
                            }
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
