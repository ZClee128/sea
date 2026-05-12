//
//  MainTabView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case discovery
        case post
        case messages
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Feed
            HomeView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == .home ? "house.fill" : "house")
                }
                .tag(Tab.home)
            
            // Discovery
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: selectedTab == .discovery ? "safari.fill" : "safari")
                }
                .tag(Tab.discovery)
            
            // Post Creation
            PostCreationView()
                .tabItem {
                    Label("Post", systemImage: "plus.circle.fill")
                }
                .tag(Tab.post)
            
            // Messages
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: selectedTab == .messages ? "message.fill" : "message")
                }
                .tag(Tab.messages)
            
            // Profile
            ProfileView()
                .tabItem {
                    Label("Me", systemImage: selectedTab == .profile ? "person.fill" : "person")
                }
                .tag(Tab.profile)
        }
        .tint(Color(hex: "2ECC71"))
    }
}

@available(iOS 16.0, *)
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
