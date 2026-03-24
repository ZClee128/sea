import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    init() {
        // Customize appearance for iOS 13+
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().unselectedItemTintColor = .lightGray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                if #available(iOS 14.0, *) {
                    MainGalleryView()
                        .tabItem {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Gallery")
                        }
                        .tag(0)
                }
                
                if #available(iOS 14.0, *) {
                    CoutureClipsView()
                        .tabItem {
                            Image(systemName: "play.rectangle.fill")
                            Text("Catwalk")
                        }
                        .tag(1)
                } else {
                    // Fallback on earlier versions
                }
                
                if #available(iOS 14.0, *) {
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                        .tag(2)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        .accentColor(NeonCouture.primary)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
