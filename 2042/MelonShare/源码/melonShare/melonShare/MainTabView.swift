//
//  MainTabView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var auth = AuthManager.shared
    @State private var selectedTab = 0
    
    init() {
        // Customize the system UITabBar appearance for a premium, clean layout
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        
        // Highlight shadow line separation
        appearance.shadowColor = UIColor(red: 240/255, green: 241/255, blue: 244/255, alpha: 1.0)
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 160/255, green: 165/255, blue: 180/255, alpha: 1.0)
    }
    
    var body: some View {
        Group {
            if auth.isLoggedIn {
                TabView(selection: $selectedTab) {
                    
                    // Tab 1: Explore Recommendations
                    ExploreView()
                        .tabItem {
                            Image(systemName: "sparkles.tv.fill")
                            Text("Explore")
                        }
                        .tag(0)
                    
                    // Tab 2: Tracker Watchlist
                    TrackerView()
                        .tabItem {
                            Image(systemName: "checklist")
                            Text("Tracker")
                        }
                        .tag(1)
                    
                    // Tab 3: Video Trailers Player
                    TrailersView()
                        .tabItem {
                            Image(systemName: "play.rectangle.fill")
                            Text("Trailers")
                        }
                        .tag(2)
                    
                    // Tab 4: Card Generator poster exporter
                    CardGeneratorView()
                        .tabItem {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Amway Card")
                        }
                        .tag(3)
                    
                    // Tab 5: User Settings and Profile
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.crop.circle.fill")
                            Text("Profile")
                        }
                        .tag(4)
                }
                .accentColor(Theme.primaryPeach)
                .preferredColorScheme(.light)
            } else {
                AuthWelcomeView()
            }
        }
        .onReceive(auth.$isLoggedIn) { loggedIn in
            if !loggedIn {
                selectedTab = 0
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
