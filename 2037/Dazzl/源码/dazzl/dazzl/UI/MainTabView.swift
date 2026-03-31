import SwiftUI

@available(iOS 15.0, *)
struct MainTabView: View {
    @StateObject private var dataStore = MuseDataStore()
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
            
            StyleLabView()
                .tabItem {
                    Label("Style Lab", systemImage: "chart.bar.doc.horizontal")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .environmentObject(dataStore)
        .accentColor(.white)
        .onAppear {
            // Force TabBar appearance
            UITabBar.appearance().barTintColor = .black
            UITabBar.appearance().backgroundColor = .black
        }
    }
}
