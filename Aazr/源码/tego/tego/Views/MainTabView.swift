//
//  MainTabView.swift
//  tego
//

import SwiftUI

@available(iOS 14.0, *)
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "magazine")
                    Text("Trends")
                }
            if #available(iOS 15, *) {
                MasterclassView()
                    .tabItem {
                        Image(systemName: "play.tv")
                        Text("Watch")
                    }
            }
            
            PoseStudioView()
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Studio")
                }
            
            if #available(iOS 15, *) {
                FavoritesView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Saved")
                    }
            } else {
                // Fallback on earlier versions
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(.primary)
    }
}
