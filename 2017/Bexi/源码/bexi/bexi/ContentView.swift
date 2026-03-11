//
//  ContentView.swift
//  bexi
//
//  Created by zclee on 2026/3/5.
//

import SwiftUI

import SwiftUI

@available(iOS 14.0, *)
struct ContentView: View {
    var body: some View {
        TabView {
            DailyView()
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("Daily")
                }
            
            DiscoverFeedView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Discover")
                }
                
            if #available(iOS 14.0, *) {
                StudioView()
                    .tabItem {
                        Image(systemName: "wand.and.stars")
                        Text("Studio")
                    }
            }
            
            if #available(iOS 14.0, *) {
                MyLibraryView()
                    .tabItem {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                        Text("My Library")
                    }
            } else {
                // Fallback on earlier versions logic 
                Text("Update iOS for Library")
                    .tabItem {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                        Text("My Library")
                    }
            }
            
            ProfileSettingsView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        ContentView()
    } else {
        // Fallback on earlier versions
    }
}
