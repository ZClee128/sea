//
//  MainTabView.swift
//  vibble
//

import SwiftUI


@available(iOS 14.0, *)
struct MainTabView: View {
    @State private var selectedTab = 0
    
    init() {
        // 自定义 TabBar 外观以符合深色高级感
        UITabBar.appearance().backgroundColor = UIColor(Theme.background)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoveryView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Discover")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
                .tag(1)
            
            PostView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Post")
                }
                .tag(2)
            
            FriendsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(Theme.primary)
    }
}

