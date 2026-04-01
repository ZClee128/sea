import SwiftUI

@available(iOS 15.0, *)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Image(systemName: "safari.fill")
                    Text("Insights")
                }
                .tag(0)
            
            FocusView()
                .tabItem {
                    Image(systemName: "sparkle")
                    Text("Focus")
                }
                .tag(1)
            
            ChatListView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Connect")
                }
                .tag(2)
            
            StudioTabView()
                .tabItem {
                    Image(systemName: "paintpalette.fill")
                    Text("Studio")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.black)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenStudioWithMuse"))) { _ in
            selectedTab = 3
        }
    }
}

@available(iOS 15.0, *)
struct StudioTabView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: WallPreviewView()) {
                    Label("Lock Screen Studio", systemImage: "iphone")
                }
                
                NavigationLink(destination: InspoCardView()) {
                    Label("Inspo Card Studio", systemImage: "quote.bubble.fill")
                }
            }
            .navigationTitle("Creative Studio")
        }
    }
}

@available(iOS 15.0, *)
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
