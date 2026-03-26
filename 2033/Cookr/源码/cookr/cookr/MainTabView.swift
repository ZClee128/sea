import SwiftUI

@available(iOS 15.0, *)
struct MainTabView: View {
    var body: some View {
        TabView {
            GalleryView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Discover")
                }

            TipsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Tips")
                }

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }

            MealPlanView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Meal Plan")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(.orange)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MainTabView()
        } else {
            // Fallback on earlier versions
        }
    }
}
