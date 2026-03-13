import SwiftUI

struct MainTabView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        TabView {
            HomeView(appState: appState)
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Lookbook")
                }
            
            VideoFeedView(appState: appState)
                .tabItem {
                    Image(systemName: "play.tv")
                    Text("Tutorials")
                }
            
            StudioView(appState: appState)
                .tabItem {
                    Image(systemName: "wand.and.stars")
                    Text("Studio")
                }
            
            SettingsView(appState: appState)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}
