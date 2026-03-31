import SwiftUI

@available(iOS 15.0, *)
struct MainTabView: View {
    @StateObject private var dataStore = MuseDataStore()
    
    var body: some View {
        TabView {
            FeedView()
                .environmentObject(dataStore)
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
            
            StyleLabView()
                .environmentObject(dataStore)
                .tabItem {
                    Label("Style Lab", systemImage: "chart.bar.doc.horizontal")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .accentColor(.white) // Make the icons pop against dark background
        .onAppear {
            // Force TabBar appearance
            UITabBar.appearance().barTintColor = .black
            UITabBar.appearance().backgroundColor = .black
        }
    }
}
