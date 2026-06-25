//
//  MainContainerView.swift
//  monti
//
//  Created by zclee on 24/06/2026.
//

import SwiftUI
import Combine

struct MainContainerView: View {
    @ObservedObject var stageData = StageDataRepository()
    @State private var hasAgreed: Bool = UserDefaults.standard.bool(forKey: "PrivacyPolicyAgreed")
    
    // Track selected tab so we can pause/resume video on tab switch
    @State private var selectedTab: Int = 0
    // Keep track of previous tab to detect when leaving/returning to Reels
    @State private var previousTab: Int = 0

    // Reels tab index
    private let reelsTabIndex = 0

    // Custom binding that fires pause/resume logic on tab change (iOS 13 compatible)
    private var tabBinding: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { newTab in
                let old = selectedTab
                selectedTab = newTab
                if old == reelsTabIndex && newTab != reelsTabIndex {
                    // Leaving Reels → pause
                    BackgroundPlaybackManager.shared.pauseTop()
                } else if old != reelsTabIndex && newTab == reelsTabIndex {
                    // Returning to Reels → resume
                    BackgroundPlaybackManager.shared.resumeTop()
                }
            }
        )
    }

    var body: some View {
        Group {
            if hasAgreed {
                TabView(selection: tabBinding) {
                    VideoListView()
                        .tabItem {
                            Image(systemName: "play.circle.fill")
                            Text("Reels")
                        }
                        .tag(0)
                    
                    FeedListView()
                        .tabItem {
                            Image(systemName: "text.bubble.fill")
                            Text("Community")
                        }
                        .tag(1)
                    
                    ChatListView()
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Chats")
                        }
                        .tag(2)
                    
                    SettingsView(onLogoutState: {
                        self.hasAgreed = false
                    }, onDeleteAccountState: {
                        self.hasAgreed = false
                    })
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(3)
                }
                .accentColor(Color(red: 1.00, green: 0.00, blue: 0.50)) // Neon pink accents
            } else {
                PrivacyView(onAgree: {
                    // Agreeing to the policy automatically logs the user in silently
                    UserDefaults.standard.set(true, forKey: "PrivacyPolicyAgreed")
                    UserDefaults.standard.set(true, forKey: "UserIsLoggedIn")
                    self.hasAgreed = true
                })
            }
        }
        .environmentObject(stageData)
        .preferredColorScheme(.dark) // Global dark mode locking
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView()
    }
}
