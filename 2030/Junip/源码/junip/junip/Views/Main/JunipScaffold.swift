import SwiftUI

@available(iOS 14.0, *)
struct JunipScaffold: View {
    @StateObject private var navState = JunipNavigationState()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        let activeIconColor = UIColor(hex: "1A1A1A")
        
        appearance.stackedLayoutAppearance.selected.iconColor = activeIconColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: activeIconColor, .font: UIFont.systemFont(ofSize: 10, weight: .bold)]
        
        let unselectedColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $navState.selectedTab) {
            StyleFeedExplorer()
                .tabItem {
                    Image(systemName: "magazine")
                    Text("Feed")
                }
                .tag(0)
            
            HairMasteryHub()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Mastery")
                }
                .tag(1)
            
            StyleLabExplorer()
                .tabItem {
                    Image(systemName: "sparkles.rectangle.stack")
                    Text("Lab")
                }
                .tag(2)
            
            JunipVault()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Vault")
                }
                .tag(3)
        }
        .accentColor(AppTheme.primary)
        .environmentObject(navState)
    }
}

struct JunipScaffold_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            JunipScaffold()
        } else {
            // Fallback on earlier versions
        }
    }
}
