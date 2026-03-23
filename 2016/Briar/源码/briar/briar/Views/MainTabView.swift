import SwiftUI

struct MainTabView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: "square.stack")
                    Text("Feed")
                }
                .tag(0)
            
            QuizView()
                .tabItem {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                    Text("Quiz")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Bookmarks")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.black)
    }
}
