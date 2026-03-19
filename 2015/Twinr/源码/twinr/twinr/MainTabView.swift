import SwiftUI

@available(iOS 14.0, *)
struct MainTabView: View {
    var body: some View {
        TabView {
            InspirationView()
                .tabItem {
                    Label("Inspiration", systemImage: "sparkles")
                }
            
            NailAcademyView()
                .tabItem {
                    Label("Academy", systemImage: "book.fill")
                }
            
            StyleMatcherView()
                .tabItem {
                    Label("Matcher", systemImage: "wand.and.stars")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.pink)
        .preferredColorScheme(.light)
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        MainTabView()
    } else {
        // Fallback on earlier versions
    }
}
