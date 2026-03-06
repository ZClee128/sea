import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "rectangle.stack.fill" : "rectangle.stack")
                    Text("Discover")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    Text("Search")
                }
                .tag(1)
            
            AIGeneratorView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "wand.and.stars" : "wand.and.stars")
                    Text("AI Look")
                }
                .tag(2)
            
            WardrobeView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "archivebox.fill" : "archivebox")
                    Text("Wardrobe")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(4)
        }
        // Change accent color to fit modern minimal style
        .accentColor(.primary)
    }
}



struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppStateManager())
            .environmentObject(CacheManager())
    }
}
