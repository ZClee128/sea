import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeGalleryView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Explore")
                }
                .tag(0)
            
            VideoTutorialListView()
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("Techniques")
                }
                .tag(1)
            
            MakeupToolsView()
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver.fill")
                    Text("Pro Tools")
                }
                .tag(2)
            
            BeautyJournalView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(RevoDesign.primary)
        .forceLightMode()
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
