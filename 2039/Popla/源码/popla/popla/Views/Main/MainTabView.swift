import SwiftUI

@available(iOS 15.0, *)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    // Set tabbar appearance for iOS 13+
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // Use this appearance for all states
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        UITabBar.appearance().unselectedItemTintColor = .gray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            ExploreGalleryView()
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Explore")
                }
                .tag(0)
            
            LifePlannerView()
                .tabItem {
                    Image(systemName: "calendar.badge.plus")
                    Text("Planner")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.black) // Fixed light mode accent color
        .onAppear {
            // Keep the status bar style or any global UI configurations here
        }
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
