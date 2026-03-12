import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Portraits")
                }
            
            VideoFeedView()
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("Video")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(.black)
    }
}
