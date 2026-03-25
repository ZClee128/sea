import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            VideoListView()
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("Video")
                }
                .tag(1)
            
            if #available(iOS 14.0, *) {
                ExploreView()
                    .tabItem {
                        Image(systemName: "sparkles")
                        Text("Explore")
                    }
                    .tag(2)
            } else {
                // Fallback on earlier versions
            }

            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(Color(red: 1.0, green: 0.6, blue: 0.2))  // 橙色主题
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
