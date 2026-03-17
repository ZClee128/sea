import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            if #available(iOS 14.0, *) {
                EditorialFeedView()
                    .tabItem {
                        Label("Editorial", systemImage: "book.closed")
                    }
            } else {
                Text("Requires iOS 14+")
            }
            
            if #available(iOS 14.0, *) {
                TutorialsFeedView()
                    .tabItem {
                        Label("Tutorials", systemImage: "play.tv")
                    }
            } else {
                Text("Requires iOS 14+")
            }
            
            if #available(iOS 14.0, *) {
                MoodBoardView()
                    .tabItem {
                        if #available(iOS 14.0, *) {
                            Label("Mood Board", systemImage: "square.grid.2x2")
                        } else {
                            // Fallback on earlier versions
                        }
                    }
            } else {
                // Fallback on earlier versions
            }
            
            SettingsView()
                .tabItem {
                    if #available(iOS 14.0, *) {
                        Label("Settings", systemImage: "gearshape")
                    } else {
                        // Fallback on earlier versions
                    }
                }
        }
        .accentColor(.blue) // Ensure default tinting in Light mode
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
