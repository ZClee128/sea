import SwiftUI

@available(iOS 15.0, *)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ArtGalleryView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Gallery")
                }
                .tag(0)
            
            AtmosphereView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Atmosphere")
                }
                .tag(1)

            StudioView()
                .tabItem {
                    Image(systemName: "wand.and.stars")
                    Text("Studio")
                }
                .tag(2)

            DiscoverView()
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Discover")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.pink)
    }
}
